local api, cmd, fn, fmt = vim.api, vim.cmd, vim.fn, string.format
-- local border, highlight, icons = eo.ui.current.border, eo.highlight, eo.ui.icons

return {
  -- {
  --   '~/.config/nvim/lua/eo/plugs/weather',
  --   dependencies = { 'nvim-lua/plenary.nvim' },
  --   opts = {
  --     weather_icons = require('weather.other_icons').nerd_font,
  --   },
  -- },
  -- {
  --   'mikesmithgh/kitty-scrollback.nvim',
  --   enabled = false,
  --   lazy = true,
  --   cmd = { 'KittyScrollbackGenerateKittens', 'KittyScrollbackCheckHealth' },
  --   event = { 'User KittyScrollbackLaunch' },
  --   opts = {},
  -- },
  {
    'nvim-lua/plenary.nvim',
    version = '*',
    lazy = false,
  },
  { 'MunifTanjim/nui.nvim' },
  { 'grapp-dev/nui-components.nvim' },
  { 'kkharji/sqlite.lua' },
  { 'nvim-tree/nvim-web-devicons', lazy = false, opts = {} },
  { 'psliwka/vim-smoothie', lazy = false },
  {
    -- TODO: check Oliver-Leete for his julia autopairs configurations
    'windwp/nvim-autopairs',
    event = { 'InsertEnter', 'BufReadPre' },
    dependencies = { 'hrsh7th/nvim-cmp' },
    config = function()
      local cmp = require('cmp')
      local autopairs = require('nvim-autopairs')
      local cmp_autopairs = require('nvim-autopairs.completion.cmp')
      -- local handlers = require('nvim-autopairs.completion.handlers')
      cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done { map_char = { tex = '' } })
      autopairs.setup {
        close_triple_quotes = true,
        disable_filetype = { 'neo-tree-popup' },
        check_ts = true,
        map_cr = true,
        map_c_w = true,
        fast_wrap = { map = '<M-e>' },
      }
    end,
  },
  {
    'famiu/bufdelete.nvim',
    keys = { { '<leader>qq', '<Cmd>Bdelete<CR>', desc = 'buffer delete' } },
  },
  {
    'willothy/flatten.nvim',
    priority = 1005,
    config = {
      window = { open = 'alternate' },
      callbacks = {
        block_end = function() require('toggleterm').toggle() end,
        post_open = function(_, winnr, _, is_blocking)
          if is_blocking then
            require('toggleterm').toggle()
          else
            vim.api.nvim_set_current_win(winnr)
          end
        end,
      },
    },
  },
  { 'fladson/vim-kitty', lazy = false },
  { 'neoclide/jsonc.vim', ft = { 'jsonc', 'json5', 'json' }, lazy = false },
  { 'mtdl9/vim-log-highlighting', ft = 'log', lazy = false },
  {
    'mrjones2014/smart-splits.nvim',
    event = { 'BufReadPost', 'BufNewFile' },
    opts = {},
    build = './kitty/install-kittens.bash',
    keys = {
      -- TODO: Change these as <A-h/l> are already mapped to resize left/right
      { '<A-h>', function() require('smart-splits').resize_left() end },
      { '<A-l>', function() require('smart-splits').resize_right() end },
      { '<C-A-j>', function() require('smart-splits').resize_down() end },
      { '<C-A-k>', function() require('smart-splits').resize_up() end },
      { '<C-h>', function() require('smart-splits').move_cursor_left() end },
      { '<C-j>', function() require('smart-splits').move_cursor_down() end },
      { '<C-k>', function() require('smart-splits').move_cursor_up() end },
      { '<C-l>', function() require('smart-splits').move_cursor_right() end },
    },
  },
  { 'tpope/vim-repeat', event = 'VeryLazy' },
  { 'tpope/vim-scriptease', event = 'VeryLazy' },
  { 'milisims/nvim-luaref', lazy = true },
  {
    url = 'https://gitlab.com/yorickpeterse/nvim-pqf',
    -- enabled = true,
    event = 'VeryLazy',
    opts = {},
  },
  {
    'kevinhwang91/nvim-bqf',
    -- enabled = true,
    ft = 'qf',
    opts = {
      auto_enable = true,
      preview = {
        win_height = 12,
        win_vheight = 16,
        delay_syntax = 20,
        border_chars = { '┃', '┃', '━', '━', '┏', '┓', '┗', '┛', '█' },
      },
      func_map = {
        vsplit = '',
        ptogglemode = 'z,',
        stoggleup = '',
      },
      filter = {
        fzf = {
          action_for = { ['ctrl-s'] = 'split' },
          extra_opts = { '--bind', 'ctrl-o:toggle-all', '--prompt', ' ' }, -- 󰄾 >
        },
      },
    },
  },
  {
    'mbbill/undotree',
    enabled = true,
    cmd = 'UndotreeToggle',
    keys = { { '<localleader>u', '<Cmd>UndotreeToggle<CR>', desc = 'undotree: toggle' } },
    config = function()
      vim.g.undotree_TreeNodeShape = '◦' -- Alternative: '◉'
      vim.g.undotree_SetFocusWhenToggle = 1
    end,
  },
  {
    'rafcamlet/nvim-luapad',
    enabled = true,
    cmd = 'Luapad',
  },
  {
    'norcalli/nvim-colorizer.lua',
    cmd = 'ColorizerToggle',
    config = function()
      require('colorizer').setup({ '*' }, {
        RGB = true,
        mode = 'foreground',
      })
    end,
  },
  {
    'pteroctopus/faster.nvim',
    lazy = false,
    opts = {},
  },
  {
    'danymat/neogen',
    cmd = { 'Neogen' },
    dependencies = 'nvim-treesitter/nvim-treesitter',
    opts = {},
  },
  {
    'chrishrb/gx.nvim',
    enabled = true,
    keys = { { 'gx', '<cmd>Browse<cr>', mode = { 'n', 'x' } } },
    cmd = { 'Browse' },
    init = function()
      vim.g.netrw_nogx = 1
    end,
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = {
      handler_options = {
        -- you can select between google, bing, duckduckgo, and ecosia
        search_engine = 'google',
      },
    },
  },
}
