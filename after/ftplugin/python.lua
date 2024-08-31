local api, bo, cmd, optl = vim.api, vim.bo, vim.cmd, vim.opt_local
local map = map or vim.keymap.set

-- cmd([[call matchadd('TabLineSel', '\%80v', 79)]])
-- local options = {
-- stylua: ignore start
bo.tabstop = 4                    -- ts
bo.textwidth = 79                 -- tw
bo.shiftwidth = 4                 -- sw
bo.softtabstop = 4                -- sts
bo.expandtab = true               -- et
bo.autoindent = true              -- ai
optl.smarttab = true                --
-- optl.conceallevel = 2             -- cole
optl.colorcolumn = '+1'           -- cc
-- optl.foldmethod = 'syntax'        -- fdm  -- syntax?
-- stylua: ignore end

-- https://github.com/echasnovski/nvim/blob/master/after/ftplugin/python.lua
-- g['pyindent_open_paren'] = 'shiftwidth()'
-- g['pyindent_continue'] = 'shiftwidth()'
-- g['pyindent_nested_paren'] = 'shiftwidth()'

-- api.nvim_buf_set_keymap(0, 'i', '<M-i>', ' = ', { noremap = true })
-----------------------------------------------------------------------------
-- https://github.com/chrisgrieser/.config/blob/main/nvim/lua/config/utils.lua
-- local ft_abbr = function(lhs, rhs)
--   -- cmd('iabbrev <buffer> ' .. lhs .. ' ' .. rhs)
--   vim.keymap.set("!ia", lhs, rhs, { buffer = true})
-- end

cmd.inoreabbrev('<buffer> true True')
cmd.inoreabbrev('<buffer> false False')

cmd.inoreabbrev('<buffer> // #')
cmd.inoreabbrev('<buffer> null None')
cmd.inoreabbrev('<buffer> none None')
cmd.inoreabbrev('<buffer> nil None')

-- from dhruvmanila/dotfiles/blob/master/config/nvim/after/ftplugin/python.lua
-- bo.makeprg = 'python %'

-- PyDoc attempt
---@param node_text string
---@return string
local function construct_pydoc_query(node_text)
  return ([[
  [
  ;; import <dotted_name>
  ;; import <dotted_name> as <alias>
  ((import_statement
    name: [
      (dotted_name) @import
      (aliased_import
        name: (_) @alias
        alias: (_) @import)
    ]
    (#eq? @import "%s")))

  ;; from <module_name> import <dotted_name>
  ;; from <module_name> import <dotted_name> as <alias>
  ((import_from_statement
    module_name: (_) @module
    name: [
      (dotted_name) @import
      (aliased_import
        name: (_) @alias
        alias: (_) @import)
    ]
    (#eq? @import "%s")))
  ]
  ]]):format(node_text, node_text)
end

-- Return the fully qualified name of the given import name. The returned value
-- will be a table of strings where each string is a part of the import which
-- can be concatenated with a dot ('.').
---@param import_name string
---@return string[]
local function fully_qualified_name(import_name)
  local parser = vim.treesitter.get_parser(0)
  local tree = parser:parse()[1]
  if not tree then
    vim.notify('PyDoc', 'Failed to parse the tree', vim.log.levels.ERROR)
    return {}
  end

  local ok, pydoc_query = pcall(vim.treesitter.parse_query, 'python', construct_pydoc_query(import_name))
  if not ok then
    vim.notify('PyDoc', 'Failed to parse the PyDoc query', vim.log.levels.ERROR)
    return {}
  end

  local root = tree:root()
  local start_row, _, end_row, _ = root:range()
  local qualname = {}
  for id, node in pydoc_query:iter_captures(root, 0, start_row, end_row) do
    local name = pydoc_query.captures[id]
    if name == 'module' then
      table.insert(qualname, vim.treesitter.get_node_text(node, 0))
    elseif name == 'alias' then
      table.insert(qualname, vim.treesitter.get_node_text(node, 0))
    end
  end

  return qualname
end

vim.api.nvim_buf_create_user_command(0, 'PyDoc', function(opts)
  local word = opts.args

  -- Extract the 'word' at the cursor {{{
  --
  -- By expanding leftwards across identifiers and the '.' operator, and
  -- rightwards across the identifier only.
  --
  -- For example:
  --   `import xml.dom.minidom`
  --            ^   !
  --
  -- With the cursor at ^ this returns 'xml'; at ! it returns 'xml.dom'.
  -- }}}
  if word == '' then
    local _, col = unpack(vim.api.nvim_win_get_cursor(0))
    local line = vim.api.nvim_get_current_line()
    local names = vim.split(
      line:sub(0, col):match('[%w_.]*$') .. line:match('^[%w_]*', col + 1),
      '.',
      { plain = true, trimempty = true }
    )
    local import_name = table.remove(names, 1)
    local qualname = fully_qualified_name(import_name)
    if vim.tbl_isempty(qualname) then table.insert(qualname, import_name) end
    vim.list_extend(qualname, names)
    word = table.concat(qualname, '.')
  end

  local lines = {}
  local fd = io.popen('python -m pydoc ' .. word)
  for line in fd:lines() do
    lines[#lines + 1] = line
  end
  fd:close()

  -- In case `pydoc` cannot find the documentation for `word` {{{
  --
  -- The output is:
  --
  --     > No Python documentation found for '<word>'.
  --     > Use help() to get the interactive help utility.
  --     > Use help(str) for help on the str class.
  --
  -- We are only interested in the first line.
  -- }}}
  if #lines < 5 then
    vim.notify('PyDoc', lines[1])
    return
  end

  cmd(opts.mods .. ' split __doc__')
  api.nvim_buf_set_lines(0, 0, -1, false, lines)
  bo.readonly = true
  bo.modifiable = false
  bo.buftype = 'nofile'
  bo.filetype = 'man'
  bo.bufhidden = 'wipe'
end, {
  nargs = '?',
})

-- }}}

-- Similar to how `gf` works with a different keymap of `gK` for vertical split.
map('n', 'gk', '<Cmd>PyDoc<CR>', { buffer = 0 })
map('n', 'gK', '<Cmd>vertical PyDoc<CR>', { buffer = 0 })
map('n', '<C-w>gk', '<Cmd>tab PyDoc<CR>', { buffer = 0 })

local function replaceNodeText(node, text)
  local start_row, start_col, end_row, end_col = node:range()
  local lines = vim.split(text, '\n')
  cmd.undojoin() -- make undos ignore the next change, see issue #8
  api.nvim_buf_set_text(0, start_row, start_col, end_row, end_col, lines)
end

api.nvim_create_autocmd({ 'InsertLeave', 'TextChanged' }, {
  pattern = { '*.py' },
  callback = function()
    local node = vim.treesitter.get_node()
    if not node then return end

    local str_node
    if node:type() == 'string' then
      str_node = node
    elseif node:type():find('^string_') then
      str_node = node:parent()
    elseif node:type() == 'escape_sequence' then
      str_node = node:parent():parent()
    else
      return
    end

    local text = vim.treesitter.get_node_text(str_node, 0)
    if text == '' then return end
    local isFString = text:find('^f')
    local hasBraces = text:find('{.-}')

    if not isFString and hasBraces then
      replaceNodeText(str_node, 'f' .. text)
    elseif isFString and not hasBraces then
      text = text:sub(2)
      replaceNodeText(str_node, text)
    end
  end,
})
