return {
  -- {
  --   'lifepillar/pgsql.vim',
  --   lazy = false,
  --   enabled = false,
  -- },
  -- {
  --   'tpope/vim-dadbod',
  --   enabled = false,
  --   dependencies = {
  --     'hrsh7th/nvim-cmp',
  --     -- 'kristijanhusak/vim-dadbod-ui',
  --     'kristijanhusak/vim-dadbod-completion',
  --     {
  --       'kristijanhusak/vim-dadbod-ui',
  --       -- dependencies = 'tpope/vim-dadbod',
  --       cmd = { 'DBUI', 'DBUIToggle', 'DBUIAddConnection' },
  --       init = function()
  --         vim.g.db_ui_use_nerd_fonts = 1
  --         vim.g.db_ui_show_database_icon = 1
  --       end,
  --     },
  --   },
  --   opts = {
  --     db_completion = function() require('cmp').setup.buffer { sources = { { name = 'vim-dadbod-completion' } } } end,
  --     -- db_completion = function() require('cmp').setup.filetype { sources = { { name = 'vim-dadbod-completion' } } } end,
  --   },
  --   config = function(_, opts)
  --     -- is this required?
  --     vim.g.db_ui_save_location = vim.fn.stdpath('config') .. require('plenary.path').path.sep .. 'db_ui'
  --
  --     vim.api.nvim_create_autocmd('FileType', {
  --       pattern = {
  --         'sql',
  --         'mysql',
  --         'plsql',
  --       },
  --       command = [[setlocal omnifunc=vim_dadbod_completion#omni]],
  --       callback = function() vim.schedule(opts.db_completion) end,
  --     })
  --
  --     vim.api.nvim_create_autocmd('FileType', {
  --       pattern = {
  --         'sql',
  --         'mysql',
  --         'plsql',
  --       },
  --       callback = function() vim.schedule(opts.db_completion) end,
  --     })
  --     map('n', '<localleader>Dt', '<cmd>DBUIToggle<CR>', { desc = 'dadbod: Toggle UI' })
  --     map('n', '<localleader>Df', '<cmd>DBUIFindBuffer<CR>', { desc = 'dadbod: Find Buffer' })
  --     map('n', '<localleader>Dr', '<cmd>DBUIRenameBuffer<CR>', { desc = 'dadbod: Rename Buffer' })
  --     map('n', '<localleader>Dq', '<cmd>DBUILastQueryInfo<CR>', { desc = 'dadbod: Last Query Info' })
  --   end,
  --   -- keys = {
  --   --   stylua: ignore start
  --   --   { '<localleader>Dt', '<cmd>DBUIToggle<CR>',        desc = 'dadbod: Toggle UI'       },
  --   --   { '<localleader>Df', '<cmd>DBUIFindBuffer<CR>',    desc = 'dadbod: Find Buffer'     },
  --   --   { '<localleader>Dr', '<cmd>DBUIRenameBuffer<CR>',  desc = 'dadbod: Rename Buffer'   },
  --   --   { '<localleader>Dq', '<cmd>DBUILastQueryInfo<CR>', desc = 'dadbod: Last Query Info' },
  --   --   map('n', '<localleader>Db', '<cmd>DBUIToggle<CR>',        { desc = 'dadbod: Toggle UI' })
  --   --   map('n', '<localleader>Dr', '<cmd>DBUIRenameBuffer<CR>',  { desc = 'dadbod: Rename Buffer' })
  --   --   map('n', '<localleader>Df', '<cmd>DBUIFindBuffer<CR>',    { desc = 'dadbod: Find Buffer' })
  --   --   map('n', '<localleader>Dq', '<cmd>DBUILastQueryInfo<CR>', { desc = 'dadbod: Last Query Info' })
  --   --   stylua: ignore end
  --   -- },
  -- },
}
