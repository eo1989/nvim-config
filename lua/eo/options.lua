-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
local fn, g, go, o, opt, uv, v = vim.fn, vim.g, vim.go, vim.o, vim.opt, vim.uv, vim.v
-- local icons = eo.ui.icons
-- local misc = icons.misc

-- vim.g.mapleader = ' '
-- vim.g.maplocalleader = ','

-- cmd([[ set path=.,,,$PWD/**]])
-- cmd([[ set path=.,,**,$PWD/**,~/.config/nvim/**]])

-- HOW DID I NOT KNOW ABOUT THIS OPTION BEFORE?!
vim.env.SHELL = '/usr/local/bin/zsh'
o.shell = '/usr/local/bin/zsh'
-- opt.selection = 'inclusive' -- default => 'inclusive', 'exclusive' 'old' also a possible value.
opt.wrap = false
o.wrapscan = true
o.wrapmargin = 2
-- o.textwidth = 80
o.colorcolumn = '+1'

-- o.wrapscan = true
-- opt.matchpairs:append('<:>')
opt.syntax = 'enable'
opt.incsearch = true
opt.smarttab = true
g.vimsyn_embed = 'alpPrj'
opt.path:append { '**' } --'**'
o.synmaxcol = 300
o.whichwrap = 'h,l'
opt.clipboard = { 'unnamedplus' }
o.showmatch = true
o.ignorecase = true
o.smartcase = true
o.infercase = true
o.expandtab = true -- convert all tabs that are typed into spaces
o.shiftwidth = 2
-- o.smartindent = true -- add <tab> depending on syntax (C/C++)
o.autoindent = true
o.shiftround = true
o.swapfile = false
o.undofile = true
o.backup = false
o.writebackup = false
o.splitkeep = 'screen'
o.splitbelow = true
o.splitright = true
o.eadirection = 'hor'
opt.termguicolors = true
o.emoji = false
opt.guifont = {
  'FiraCodeNF-Ret',
  'Symbols Nerd Font',
  'VictorMonoNFP-MediumOblique:h10',
}
-- 'Symbols Nerd Font',
-- 'Delugia Italic:h12',
-- vim.opt.guicursor = 'n-v-c:block-Cursor/lCursor,i-ci-ve:ver25-Cursor/lCursor,r-cr:hor20,o:hor50'
opt.guicursor = {
  'n-v-c-sm:block-Cursor',
  'i-ci-ve:ver25-iCursor',
  'r-cr-o:hor20-Cursor',
  'a:blinkon0',
}
-- function eo.modified_icon() return vim.bo.modified and icons.ui.Circle or '' end
-- function eo.modified_icon() return vim.bo.modified and misc.circle or '' end
-- o.titlestring = '%{fnamemodify(getcwd(), ":t")}%( %{v:lua.eo.modified_icon()}%)'
---@diagnostic disable-next-line: missing-parameter
o.titleold = fn.fnamemodify(uv.os_getenv('SHELL'), ':t') or ''
o.title = true
o.titlelen = 70
opt.cursorlineopt = { 'both' }
o.updatetime = 300
o.timeout = true
o.timeoutlen = 300
o.ttimeoutlen = 50
o.switchbuf = 'useopen,uselast'

o.showmode = false
-- dont remember:
-- * help files since that will error if theyre from a lazy loaded plugin
-- * folds since they are created dynamically and might be missing on startup
opt.sessionoptions = {
  'globals',
  'buffers',
  'curdir',
  'winpos',
  'winsize',
  'help',
  'tabpages',
  'terminal',
  'localoptions',
  'blank',
}

opt.viewoptions = { 'cursor', 'folds' }
o.virtualedit = 'block,onemore' -- allow cursor to move where there is no text in visual block mode
opt.jumpoptions = { 'stack' } -- make jumplist behave like a browser stack
opt.list = true -- invisible chars
opt.listchars = {
  eol = nil,
  tab = '  ', -- Alternatives: '▷ ▷',
  extends = '…', -- Alternatives: … » ›
  precedes = '░', -- Alternatives: … « ‹
  trail = '•', -- BULLET (U+2022, UTF-8: E2 80 A2)
}

-- Use in vertical diff mode, blank lines to keep sides aligned, Ignore whitespace changes
opt.diffopt = vim.opt.diffopt
  + {
    'vertical',
    'iwhite',
    'hiddenoff',
    'foldcolumn:0',
    'context:4',
    'algorithm:histogram',
    'indent-heuristic',
    'linematch:60',
  }
-----------------------------------------------------------------------------//
-- Format Options {{{1
-----------------------------------------------------------------------------//
opt.formatoptions = {
  ['1'] = true,
  ['2'] = true, -- Use indent from 2nd line of a paragraph
  q = true, -- continue comments with gq"
  c = true, -- Auto-wrap comments using textwidth
  r = true, -- Continue comments when pressing Enter
  n = true, -- Recognize numbered lists
  t = false, -- autowrap lines using text width value
  j = true, -- remove a comment leader when joining lines.
  -- Only break if the line was not longer than 'textwidth' when the insert
  -- started and only at a white character that has been entered during the
  -- current insert command.
  l = true,
  v = true,
}

-- NOTE: from akinsho dotfiles ... date: 10-14-2023
-- unfortunately folding in (n)vim is a mess, if you set the fold level to start
-- at X then it will auto fold anything at that level, all good so far. If you then
-- try to edit the content of your fold and the foldmethod=manual then it will
-- recompute the fold which when using nvim-ufo means it will be closed again...
o.foldlevelstart = 3
opt.foldmethod = 'expr'
opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()'

-- function eo.ui.foldtext()
--   local fold = vim.treesitter.foldtext() --[=[@as string[][]]=]
--   local c = v.foldend - v.foldstart + 1
--   fold[#fold + 1] = { (' ⋯ [%d Lines]'):format(c), 'Oprerator' }
--   return fold
-- end

-- opt.foldtext = 'v:lua.eo.ui.foldtext()'
opt.foldtext = ''

-- NOTE: from tbung/dotfiles/blob/main/config/nvim/lua/tillb/options.lua after seeing it akinsho's dotfile commit history &&
-- the corresponding reddit post @https://www.reddit.com/r/neovim/comments/16sqyjz/finally_we_can_have_highlighted_folds/
opt.fillchars = {
  eob = ' ', -- suppress '~' at EndOfBuffer
  diff = '╱', -- alternatives = ⣿ ░ ─
  msgsep = '─', -- alternatives: ‾ ─ ' '
  fold = ' ',
  foldopen = '▽', -- '▼' ''
  foldclose = '▷', -- '▶' ''
  foldsep = ' ',
}

opt.mouse = 'a'
o.mousefocus = false
o.mousemoveevent = true
opt.mousescroll = { 'ver:1', 'hor:6' }
opt.autowrite = false

o.conceallevel = 2
o.concealcursor = 'niv'
o.breakindentopt = 'sbr'
o.linebreak = true -- lines wrap at words rather than random chars
o.signcolumn = 'yes:2'
o.ruler = false
-- o.cmdheight = 2
-- oncomouse/dotfiles/blob/master/conf/vim/init.lua
o.cmdheight = 1
if fn.has('nvim-0.9') == 1 and opt.cmdheight == 0 then opt.showcmdloc = 'statusline' end
-- showcmdloc default: 'lawt', statusline, tabline (requires 'showtabline' enabled)
o.showbreak = [[↪ ]] -- Options include -> '…', '↳ ', '→','↪ '
o.confirm = false
o.laststatus = 3
o.showtabline = 1
opt.rnu = true
opt.nu = true
o.pumblend = 20 -- make popup window translucent
o.pumheight = 20
o.previewheight = 20
o.hlsearch = true
o.autowriteall = true -- automatically :write before running commands and changing files
opt.shortmess = {
  t = true, -- truncate file messages at start
  A = true, -- ignore annoying swap file messages
  o = true, -- file-read message overwrites previous
  O = true, -- file-read message overwrites previous
  T = true, -- truncate non-file messages in middle
  F = true, -- don't give file info when editing a file, NOTE: this breaks autocommand messages
  W = true, -- don't give "written" or "[w]" when writing
  s = true, -- don't give "[silent]" or "silent" when executing
  c = true, -- don't give |ins-completion-menu| messages
  -- q = true, -- always use internal messages for quickfix
  I = true, -- don't give intro message when starting vim
  a = true, -- use abbreviations in messages eg. `[RO]` instead of `[readonly]`
}
o.wildcharm = ('\t'):byte()
-- o.wildmode = 'longest:full,full:full'
o.wildmode = 'longest,full:full'
-- o.wildmode = 'longest:list,full'
-- vim.o.wildmode = 'longest,list,full' -- stevearc dotfiles
-- o.wildmode = 'longest,full'
o.wildignorecase = true -- Ignore case when completing file names and directories
-- Binary
opt.wildignore = {
  '*.git/**',
  '**/.git/**',
  '*DS_Store*',
  '**/node_modules/**',
  'log/**',
  '*.aux',
  '*.out',
  '*.toc',
  '*.o',
  '*.obj',
  '*.dll',
  '*.jar',
  '*.pyc',
  '*.rbc',
  '*.class',
  '*.gif',
  '*.ico',
  '*.jpg',
  '*.jpeg',
  '*.png',
  '*.avi',
  '*.wav',
  -- Temp/System
  '*.*~',
  '*~ ',
  '*.swp',
  '*.lock',
  '.DS_Store',
  'tags.lock',
}
-- opt.wildoptions = { 'pum', 'fuzzy' }
opt.wildoptions = { 'pum' }
o.scrolloff = 3
o.sidescrolloff = 6
o.sidescroll = 1

if eo and not eo.falsy(fn.executable('rg')) then
  vim.o.grepprg = [[rg --glob "!{.git,.venv,node_modules}" --no-heading --vimgrep --smart-case --follow $*]]
  opt.grepformat = opt.grepformat ^ { '%f:%l:%c:%m' }
elseif eo and not eo.falsy(fn.executable('ag')) then
  vim.o.grepprg = [[ag --nogroup --nocolor --vimgrep]]
  opt.grepformat = opt.grepformat ^ { '%f:%l:%c:%m' }
end

g['markdown_fenced_languages'] = {
  'go',
  'zsh=sh',
  'bash=sh',
  'lua',
  'python',
  'julia',
  'sql',
  'yaml',
  'json',
}
