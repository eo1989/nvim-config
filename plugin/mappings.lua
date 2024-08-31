---@diagnostic disable: deprecated
if not eo then return end

local api, map = vim.api, vim.keymap.set
local M = vim.lsp.protocol.Methods
local wk = require('which-key')

vim.g['quarto_is_r_mode'] = nil
vim.g['reticulate_running'] = false

-- local opts = { noremap = true, silent = false }
local nmap = function(key, effect) map('n', key, effect, { noremap = true, silent = false }) end
local vmap = function(key, effect) map('v', key, effect, { noremap = true, silent = false }) end
local imap = function(key, effect) map('i', key, effect, { noremap = true, silent = false }) end

-- send code to terminal with vim-slime
-- TODO incoporate this into the quarto-nvim plugin s.t. QuartoRun functions get the same
-- capabilities
local function send_cell()
  if vim.b['quarto_is_r_mode'] == nil then
    vim.fn['slime#send']()
    return
  end
  if vim.b['quarto_is_r_mode'] == true then
    vim.g.slime_python_ipython = 0
    local is_python = require('otter.tools.functions').is_otter_language_context('python')
    if is_python and not vim.b['reticulate_running'] then
      vim.fn['slime#send']('reticulate::repl_python()' .. '\r')
      vim.b['reticulate_running'] = true
    end
    if not is_python and vim.b['reticulate_running'] then
      vim.fn['slime#send']('exit' .. '\r')
      vim.b['reticulate_running'] = false
    end
    vim.fn['slime#send_cell']()
  end
end

local slime_send_region_cmd = ':<C-u>call slime#send_op(visualmode(), 1)<CR>'
slime_send_region_cmd = vim.api.nvim_replace_termcodes(slime_send_region_cmd, true, false, true)
local function send_region()
  -- if ft is not quarto just send_region
  if vim.bo.filetype ~= 'quarto' or vim.b['quarto_is_r_mode'] == nil then
    vim.cmd('normal' .. slime_send_region_cmd)
    return
  end
  if vim.b['quarto_is_r_mode'] == true then
    vim.g.slime_python_ipython = 0
    local is_python = require('otter.tools.functions').is_otter_language_context('python')
    if is_python and not vim.b['reticulate_running'] then
      vim.fn['slime#send']('reticulate::repl_python()' .. '\r')
      vim.b['reticulate_running'] = true
    end
    if not is_python and vim.b['reticulate_running'] then
      vim.fn['slime#send']('exit' .. '\r')
      vim.b['reticulate_running'] = false
    end
    vim.cmd('normal' .. slime_send_region_cmd)
  end
end

-- needs kitty config:
-- map shift-enter send_text all \x1b[13;2u
-- map ctrl-enter send_text all \x1b[13;5u
nmap('<C-CR>', send_cell)
nmap('<S-CR>', send_cell)
imap('<C-CR>', send_cell)
imap('<S-CR>', send_cell)

local is_code_chunk = function()
  local current, _ = require('otter.keeper').get_current_language_context()
  if current then
    return true
  else
    return false
  end
end

--- insert code chunk of given language
--- splits current chunk if already within a chunk
---@param lang string
local function insert_code_chunk(lang)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<esc>', true, false, true), 'n', true)
  local keys
  if is_code_chunk() then
    keys = [[o```<cr><cr>```{]] .. lang .. [[}<esc>o]]
  else
    keys = [[o```{]] .. lang .. [[}<cr>```<esc>o]]
  end
  keys = vim.api.nvim_replace_termcodes(keys, true, false, true)
  vim.api.nvim_feedkeys(keys, 'n', false)
end

local function insert_py_chunk() insert_code_chunk('python') end
local function insert_jl_chunk() insert_code_chunk('julia') end
local function insert_sh_chunk() insert_code_chunk('zsh') end

-- ['<Esc>'] = { '<Cmd>noh<cr>', 'remove search highlight' },
-- ['n'] = { 'nzzzv', 'center search' },
wk.register({
  ['<C-LeftMouse>'] = { '<Cmd>lua vim.lsp.buf.definition()<CR>', 'Goto Definition' },
  ['<C-q>'] = { '<Cmd>q<cr>', 'close buffer' },
  ['<M-i>'] = { insert_code_chunk, 'code chunk' },
  ['<M-I>'] = { insert_py_chunk, 'py chunk' },
  ['[q'] = { ':silent cprev<cr>', '[q]uickfix prev' },
  [']q'] = { ':silent cnext<cr>', '[q]uickfix next' },
  ['z?'] = { ':setlocal spell!<cr>', 'toggle [z]pellchck' },
}, { mode = 'n' })

-- visual
wk.add({
  ['<CR>'] = { send_region, 'run code region' },
  -- ['<M-j>'] = { ":m'>+<CR>`<my`>mzgv`yo`z", 'move line down' },
  -- ['<M-k>'] = { ":m'<-2<CR>`>my`<mzgv`yo`z", 'move line up' },
  -- ['.'] = { ':norm .<CR>', 'repeat last norm mode cmd' },
  -- ['q'] = { ':norm @q<CR>', 'repeat q macro' },
}, { mode = 'v' })

-- insert
wk.add({
  -- ['<M-->'] = { ' <- ', 'assign' },
  -- ['<M-m>'] = { ' |>', 'pipe' },
  --[[ NOTE: Testing to see which function is working ]]
  ['<M-i>'] = { insert_code_chunk, 'code chunk' },
  ['<M-I>'] = { insert_py_chunk, 'py chunk' },
  -- ['<C-x><C-x>'] = { '<c-x><c-o>', 'omnifunc completion' },
}, { mode = 'i' })

local function new_term(lang) vim.cmd('vsplit term://' .. lang) end

local function new_term_py() new_term('python') end

local function new_term_ipy() new_term('ipython --no-confirm-exit') end

local function new_term_jl() new_term('julia') end

local function new_term_shell() new_term('$SHELL') end

local function get_otter_symbols_lang()
  local otterkeeper = require('otter.keeper')
  local main_nr = vim.api.nvim_get_current_buf()
  local langs = {}
  for i, l in ipairs(otterkeeper.rafts[main_nr].languages) do
    langs[i] = i .. ': ' .. l
  end
  -- prompt to choose one of the langs
  local i = vim.fn.inputlist(langs)
  local lang = otterkeeper.rafts[main_nr].languages[i]
  local params = {
    textDocument = vim.lsp.util.make_text_document_params(),
    otter = { lang = lang },
  }
  -- dont pass a handler, as we want otter to use its own handlers
  vim.lsp.buf_request(main_nr, M.textDocument_documentSymbol, params, nil)
end
map('n', '<localleader>os', get_otter_symbols_lang, { desc = 'otter [s]ymbols' })

--- Show R dataframe in the browser
-- might not use what you think should be your default web browser
-- because it is a plain html file, not a link
-- see https://askubuntu.com/a/864698 for places to look for
local function show_r_table()
  local node = vim.treesitter.get_node { ignore_injections = false }
  assert(node, 'no symbol found under cursor')
  local text = vim.treesitter.get_node_text(node, 0)
  local cmd = [[call slime#send("DT::datatable(]] .. text .. [[)" . "\r")]]
  vim.cmd(cmd)
end

-- normal mode w/ leader
wk.add({
  ['<CR>'] = { send_cell, 'run code cell' },
  c = {
    name = '[c]ode/[c]ell/[c]unk',
    n = { new_term_shell, '[n]ew term w/ shell' },
    -- r = {
    --   function()
    --     vim.b['quarto_is_r_mode'] = true
    --     new_term('R --no-save')
    --   end,
    --   'new [R] term',
    -- },
    p = { new_term_py, 'new [py] term' },
    i = { new_term_ipy, 'new [i]py term' },
    j = { new_term_jl, 'new [j]l term' },
  },
  -- e = { name = '[e]dit' },
  -- d = {
  --   name = '[d]ebug',
  --   t = {
  --     name = '[t]est',
  --   },
  -- },
  i = { name = '[i]mage' },
  o = {
    name = '[o]tter & c[o]de',
    a = { function() return require('otter').activate() end, 'otter [a]ctivate' },
    d = { function() return require('otter').deactivate() end, 'otter [d]eactivate' },
    c = { 'O# %%<CR>', 'magic [c]omment code chunk # %%' },
    p = { insert_py_chunk, '[p]y chunk' },
    j = { insert_jl_chunk, '[j]l chunk' },
    z = { insert_sh_chunk, '[z]sh chunk' },
  },
  q = {
    name = '[q]uarto',
    a = { ':QuartoActivate<CR>', '[a]ctivate' },
    p = { ':lua require("quarto").quartoPreview()<CR>', '[p]review' },
    q = { ':lua require("quarto").quartoClosePreview()<CR>', '[q]uit preview' },
    h = { ':QuartoHelp<CR>', '[h]elp' },
    r = {
      name = '[r]un',
      -- r = { ':QuartoSend<CR>', 'to cu[r]sor' },
      r = {  ':lua require("quarto.runner").run_cell()<CR>', 'to cu[r]sor' },
      R = { ':lua require("quarto.runner").run_range()<CR>', 'to cu[r]sor' },
      A = { ':QuartoSendAll<CR>', 'run [a]ll' },
      b = { ':QuartoSendBelow<CR>', 'run [b]elow' },
    },
    e = { require('otter').export, '[e]xport' },
    E = {
      function() require('otter').export(true) end,
      '[E]xport w/ overwrite',
    },
  },
  -- r = {
  --   name = '[r]R specific tools',
  --   t = { show_r_table, 'show [t]able' },
  -- },
  v = {
    name = '[v]im',
    m = { ':Mason<CR>', '[m]ason installer' },
    i = { require('lazy').show, 'Plugin info' },
    p = { require('lazy').profile, 'Profile plugins' },
    s = { require('lazy').sync, 'Sync plugins' },
    e = { ':e $MYVIMRC | :cd %:p:h | vsplit . | wincmd j<CR>', '[e]dit vimrc' },
  },
}, { mode = 'n', prefix = '<localleader>' })

for _, mode in ipairs { 'n', 'v' } do
  map(mode, 'H', '^', { noremap = true })
  map(mode, 'L', 'g_', { noremap = true })
end

-- Remap for dealing with word wrap
-- map('n', 'k', [[v:count == 0 ? 'gk' : 'k']], { expr = true })
map('n', 'k', [[(v:count > 1 ? 'm`' . v:count : '') . 'gk']], { expr = true, silent = true })
-- map('n', 'j', [[v:count == 0 ? 'gj' : 'j']], { expr = true })
map('n', 'j', [[(v:count > 1 ? 'm`' . v:count : '') . 'gj']], { expr = true, silent = true })

-- Better viewing
map('n', 'g,', 'g,zvzz')
map('n', 'g;', 'g;zvzz')

map('n', 'n', 'nzzzv')
map('n', 'N', 'Nzzzv')

-- Scrolling
map('n', '<C-d>', '<C-d>zz')
map('n', '<C-u>', '<C-u>zz')

-- Zero should go to the first non-blank character not to the first column (which could be blank)
-- but if already at the first character then jump to the beginning
--@see: https://github.com/yuki-yano/zero.nvim/blob/main/lua/zero.lua
map('n', '0', "getline('.')[0 : col('.') - 2] =~# '^\\s\\+$' ? '0' : '^'", { expr = true, noremap = true })

-- when going to the end of the line in visual mode ignore whitespace characters
map('v', '$', 'g_', { noremap = true })

-- stylua: ignore start
-- map('n', [[<leader>"]], [[ciw"<c-r>""<esc>]], { desc = 'surround with double quotes', noremap = true })
-- map('n', '<leader>`',   [[ciw`<c-r>"`<esc>]], { desc = 'surround with backticks',     noremap = true })
-- map('n', "<leader>'",   [[ciw'<c-r>"'<esc>]], { desc = 'surround with single quotes', noremap = true })
-- map('n', '<leader>)',   [[ciw(<c-r>")<esc>]], { desc = 'surround with parens',        noremap = true })
-- map('n', '<leader>}',   [[ciw{<c-r>"}<esc>]], { desc = 'surround with curly braces',  noremap = true })
-- stylua: ignore end

-- Better escape using jk in insert and terminal mode
map('i', 'kj', [[col('.') == 1 ? '<esc>' : '<esc>l']], { expr = true, nowait = true })

map('t', 'kj', '<C-\\><C-n>', { nowait = true })
map('t', '<C-h>', '<C-\\><C-n><C-w>h')
map('t', '<C-j>', '<C-\\><C-n><C-w>j')
map('t', '<C-k>', '<C-\\><C-n><C-w>k')
map('t', '<C-l>', '<C-\\><C-n><C-w>l')

-- Add undo break-points
map('i', ',', ',<c-g>u')
map('i', '.', '.<c-g>u')
map('i', ';', ';<c-g>u')

-- Better indent
-- map('v', '<', '<gv')
-- map('v', '>', '>gv')

-- even better indent (wont kick you out of visual mode this time) ty famiu/dot-nvim/blob/master/lua/keybinds.lua
map('v', '<', '<gv^')
map('v', '>', '>gv^')
-- apply the . cmd to all selected lines in visual mode; again, ty famiu
map('v', '.', ':normal .<CR>', { silent = true })

-- in case bufferline isnt setup or for whatever 4932849023840x10^3982498 reasons my config decides to fubar my day...
map('n', '<leader><Tab>', ':bn<CR>', { silent = true })
map('n', '<leader><S-Tab>', ':bp<CR>', { silent = true })

-- Paste over currently selected text without yanking it
map('v', 'p', '"_dp')

-- Insert blank line
map('n', ']<Space>', [[<cmd>put =repeat(nr2char(10), v:count1)<cr>]], { desc = 'add space below' })
map('n', '[<Space>', [[<cmd>put! =repeat(nr2char(10), v:count1)<cr>'[]], { desc = 'add space below' })

-- Auto indent
map('n', 'i', function()
  if #vim.fn.getline('.') == 0 then
    return [["_cc]]
  else
    return 'i'
  end
end, { expr = true })

map('n', 'g>', [[<cmd>set nomore<bar>40messages<bar>set more<CR>]], { desc = 'show message history', noremap = true })

map('n', 'zO', [[zCzO]], { noremap = true })

-- TLDR: Conditionally modify character at end of line
-- Description:
-- This function takes a delimiter character and:
--   * removes that character from the end of the line if the character at the end
--     of the line is that character
--   * removes the character at the end of the line if that character is a
--     delimiter that is not the input character and appends that character to
--     the end of the line
--   * adds that character to the end of the line if the line does not end with
--     a delimiter
-- Delimiters:
-- - ","
-- - ";"
---@param chars string
---@return function
local function modify_line_end_delimiter(chars)
  local delims = { ',', ';' }
  return function()
    local line = api.nvim_get_current_line()
    local last_char = line:sub(-1)
    if last_char == chars then
      api.nvim_set_current_line(line:sub(1, #line - 1))
    elseif vim.tbl_contains(delims, last_char) then
      api.nvim_set_current_line(line:sub(1, #line - 1) .. chars)
    else
      api.nvim_set_current_line(line .. chars)
    end
  end
end

map('n', '<localleader>,', modify_line_end_delimiter(','), { desc = "add ',' to the end of line", noremap = true })

map('n', '<localleader>;', modify_line_end_delimiter(';'), { desc = "add ';' to the end of line", noremap = true })

map('n', '<leader>E', '<Cmd>Inspect<CR>', { desc = 'Inspect the cursor position', noremap = true })

map('n', '<M-k>', '<Cmd>move-2<CR>==', { noremap = true, silent = true })
map('n', '<M-j>', '<Cmd>move+<CR>==', { noremap = true, silent = true })
map('x', '<M-k>', ":move-2<CR>='[gv", { noremap = true, silent = true })
map('x', '<M-j>', ":move'>+<CR>='[gv", { noremap = true, silent = true })

map('v', 'J', [[:move '>+1<CR>gv=gv]], { silent = true })
map('v', 'K', [[:move '<-2<CR>gv=gv]], { silent = true })

-- windows
map(
  'n',
  '<localleader>wh',
  '<C-W>t <C-W>K',
  { desc = 'change two horizontally split windows to vertical splits', noremap = true }
)

map(
  'n',
  '<localleader>wv',
  '<C-W>t <C-W>H',
  { desc = 'change two vertically split windows to horizontal splits', noremap = true }
)

map('n', '<leader>[', [[:%s/\<<C-r>=expand("<cword>")<CR>\>/]], { silent = false, desc = 'file replace word' })

map('n', '<leader>]', [[:s/\<<C-r>=expand("<cword>")<CR>\>/]], { silent = false, desc = 'line replace word' })

map('v', '<leader>[', [["zy:%s/<C-r><C-o>"/]], { silent = false, desc = 'visual replace word' })

if vim.fn.bufwinnr(1) then
  map('n', '<A-h>', '<C-W>>')
  map('n', '<A-l>', '<C-W><')
end

-- map('i', '<Tab>', [[pumvisible() ? "\<C-n>" : "\<Tab>"]], { expr = true })
-- map('i', '<S-Tab>', [[pumvisible() ? "\<C-p>" : "\<S-Tab>"]], { expr = true })
