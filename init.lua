local cmd, env, fn, g, opt, uv = vim.cmd, vim.env, vim.fn, vim.g, vim.opt, vim.uv

function _G.dump(...)
  local objects = vim.tbl_map(vim.inspect, { ... })
  print(unpack(objects))
end

g.python3_host_prog = os.getenv('HOME') .. '/.pyenv/versions/gen/bin/python'

-- solves the issue of missing luarocks when running neovim
env.DYLD_LIBRARY_PATH = '$BREW_PREFIX/lib'

-- add luarocks to rtp
-- TODO: Add before or after sourcing all config files? before lsp? before lazy?
local home = vim.uv.os_homedir()
package.path = package.path .. ';' .. home .. '/.luarocks.share/lua/5.1/?/init.lua;'
package.path = package.path .. ';' .. home .. '/.luarocks.share/lua/5.1/?.lua;'

vim.loader.enable()

g.os = vim.uv.os_uname().sysname
g.open_cmd = g.os == 'Darwin' and 'open' or 'xdg-open'
g.nvim_dir = fn.expand('~/.config/nvim')
env.NVIM_CONFIG = g.nvim_dir
-- g.nvim_dir = fn.expand('~/.config/nvim/')
-- g.vim_dir = g.dotfiles or fn.expand('~/.dotfiles')

g.mapleader = ' '
g.maplocalleader = ','

local namespace = {
  ui = {
    winbar = { enable = false },
    statuscolumn = { enable = true },
    statusline = { enable = true },
  },
  -- apparently some mappings require a mix of cmd line & function calls
  -- this table is a place to store lua functions to be called in those mappings
  mappings = { enable = true },
}
--- NOTE: this table is a globally accessible store to facilitate accessing
--- helper functions and variables throughout the configuration.
_G.eo = eo or namespace
_G.map = vim.keymap.set
_G.P = vim.print

require('eo.globals')
require('eo.highlights')
require('eo.ui')
require('eo.options')

-- g.defaults = {
--   lazyfile = { { 'BufReadPost', 'BufNewFile', 'BufWritePre' } },
-- }

g.large_file = false
g.large_file_size = 1024 * 512

local data = fn.stdpath('data')
local lazypath = data .. '/lazy/lazy.nvim'

if not vim.uv.fs_stat(lazypath) then
  -- bootstrap lazy.nvim
  -- stylua: ignore
  fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
  vim.notify('Installed Lazy.vim')
end

opt.runtimepath:prepend(lazypath)

if env.NVIM then return require('lazy').setup { { 'willothy/flatten.nvim', config = true } } end

require('lazy').setup {
  spec = {
    { import = 'eo.plugs' },
  },
  defaults = { lazy = true, version = '*' },
  install = {
    colorscheme = { 'tokyonight-storm', 'catppuccin-mocha' },
    missing = true,
  },
  change_detection = {
    enabled = false,
    notify = false,
  },
  checker = {
    enabled = true,
    concurrency = 4,
    frequency = 24 * 60 * 60, -- 24h
    notify = true,
  },
  diff = { cmd = 'terminal_git' },
  git = {
    log = { '--since=3 days ago' },
  },
  rocks = { hererocks = true },
  performance = {
    cache = { enabled = true },
    rtp = {
      paths = { data .. '/site' },
      disabled_plugins = {
        '2html_plugin',
        'getscript',
        'getscriptPlugin',
        'gzip',
        -- 'health',
        -- 'man',
        'spellfile',
        'spellfilePlugin',
        'logipat',
        -- 'rplugin',
        -- 'rrhelper',
        -- 'matchit',
        -- 'matchparen',
        'netrw',
        'netrwFileHandlers',
        'netrwSettings',
        'netrwPlugin',
        'tohtml',
        'tutor',
        'vimball',
        'vimballPlugin',
        'zip',
        'zipPlugin',
      },
    },
  },
}

-- stylua: ignore start
-- vim.keymap.set('n', '<leader>vi', require('lazy').show,    { desc = 'Plugin Info'     })
-- vim.keymap.set('n', '<leader>vp', require('lazy').profile, { desc = 'Profile Plugins' })
-- vim.keymap.set('n', '<leader>vs', require('lazy').sync,    { desc = 'Sync Plugins'    })
-- stylua: ignore end

vim.notify = require('notify')
cmd.packadd('cfilter')
-- cmd.colorscheme('tokyonight-storm')
cmd.colorscheme('catppuccin-macchiato')
-- eo.command('TSR', function() vim.cmd([[ write edit TSBufEnable highlight ]]) end, {})

vim.api.nvim_create_user_command(
  'TSR',
  function()
    vim.cmd([[
    write
    edit
    TSBufEnable highlight
    ]])
  end,
  {}
)
