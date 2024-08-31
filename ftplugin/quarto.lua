local api, ts = vim.api, vim.treesitter
local b, wo = vim.b, vim.wo

b.slime_cell_delimiter = '```'

b['quarto_is_r_mode'] = nil
b['reticulate_running'] = false

wo.wrap = true
wo.linebreak = true
wo.breakindent = true
wo.showbreak = '|'

-- local config = require('quarto.config').config
-- local quarto = require('quarto')

-- local function set_keymap()
--   if not config.keymap then return end
--   local b = api.nvim_get_current_buf()
--   local function set(lhs, rhs)
--     if lhs then api.nvim_buf_set_keymap(b, 'n', lhs, rhs, { silent = true, noremap = true }) end
--   end
--
--   set(config.keymap.definition, ":lua require('otter').ask_definition()<CR>")
--   set(config.keymap.type_definition, ":lua require('otter').ask_type_definition()<CR>")
--   set(config.keymap.hover, ":lua require('otter').ask_hover()<CR>")
--   set(config.keymap.references, ":lua require('otter').ask_references()<CR>")
--   set(config.keymap.format, ":lua require('otter').ask_format()<CR>")
--   set(config.keymap.rename, ":lua require('otter').ask_rename()<CR>")
--   set(config.keymap.document_symbols, ":lua require('otter').ask_document_symbols()<CR>")
-- end

-- if config.lspFeatures.enabled then
--   quarto.activate()
--   set_keymap()
--   api.nvim.create_autocmd('LspAttach', {
--     buffer = api.nvim_get_current_buf(),
--     group = api.nvim_create_augroup('QuartoKeymapSetup', {}),
--     callback = set_keymap,
--   })
-- end

api.nvim_buf_set_var(0, 'did_ftplugin', true)

-- md vs qmd hacks
local ns = api.nvim_create_namespace('QuartoHighlight')
api.nvim_set_hl(ns, '@markup.strikethrough', { strikethrough = false })
api.nvim_set_hl(ns, '@markup.doublestrikethrough', { strikethrough = true })
api.nvim_win_set_hl_ns(0, ns)

-- ts based code chun highlighting uses a change
-- only available in nvim >= 0.10

if vim.fn.has('nvim-0.10.0') == 0 then return end

-- hl code cells similar to `lukas-reineke/headlines.nvim`
local buf = api.nvim_get_current_buf()
local parsername = 'markdown'
local parser = ts.get_parser(buf, parsername)
local tsquery = '(fenced_code_block)@codecell'

api.nvim_set_hl(0, '@markup.codecell', { link = 'CursorLine' })

local function clear_all()
  local all = api.nvim_buf_get_extmarks(buf, ns, 0, -1, {})
  for _, mark in ipairs(all) do
    api.nvim_buf_del_extmark(buf, ns, mark[1])
  end
end

local function highlight_range(from, to)
  for i = from, to do
    api.nvim_buf_add_extmark(buf, ns, i, 0, { hl_eol = true, line_hl_group = '@markup.codecell' })
  end
end

local function highlight_cells()
  clear_all()
  local query = ts.query.parse(parsername, tsquery)
  local tree = parser:parse()
  local root = tree[1]:root()
  for _, match, _ in query:iter_matches(root, buf, 0, -1, { all = true }) do
    for _, nodes in pairs(match) do
      for _, node in ipairs(nodes) do
        local start_line, _, end_line, _ = node:range()
        pcall(highlight_range, start_line, end_line - 1)
      end
    end
  end
end

-- higlight_cells()

api.nvim_create_autocmd({ 'ModeChanged', 'BufWrite' }, {
  group = api.nvim_create_augroup('QuartoCellHighlight', { clear = true }),
  buffer = buf,
  callback = highlight_cells,
})
