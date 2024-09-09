local cwd = vim.fn.getcwd
local highlight = eo.highlight
-- local border = eo.ui.current.border
-- local icons = eo.ui.icons.separators

local neogit = eo.reqidx('neogit')
-- local gitlinker = eo.reqidx('gitlinker')
-- local function browser_open() return { action_callback = require('gitlinker.actions').open_in_browser } end

return {
  {
    'akinsho/git-conflict.nvim',
    enabled = true,
    event = 'VeryLazy',
    opts = { disable_diagnostics = true },
  },
  {
    'NeogitOrg/neogit',
    enabled = true,
    cmd = 'Neogit',
    dependencies = { 'nvim-lua/plenary.nvim' },
    keys = {
      { '<localleader>gs', function() neogit.open() end, desc = 'open status buffer' },
      { '<localleader>gc', function() neogit.open { 'commit' } end, desc = 'open commit buffer' },
      { '<localleader>gl', function() neogit.popups.pull.create() end, desc = 'open pull popup' },
      { '<localleader>gp', function() neogit.popups.push.create() end, desc = 'open push popup' },
    },
    opts = {
      disable_signs = false,
      disable_hint = true,
      disable_commit_confirmation = true,
      disable_builtin_notifications = true,
      disable_insert_on_commit = false,
      signs = {
        section = { ' ', '󰘕 ' }, -- "󰁙 ", "󰁊 "
        item = { '▸', '▾' },
        hunk = { '󰐕', '󰍴' },
      },
      integrations = {
        diffview = true,
      },
    },
  },
  {
    'sindrets/diffview.nvim',
    enabled = true,
    cmd = { 'DiffviewOpen', 'DiffviewFileHistory' },
    -- keys = {
    --   { '<localleader>gd', '<Cmd>DiffviewOpen<CR>', desc = 'diffview: open', mode = 'n' },
    --   { '<localleader>gh', [[:'<'>DiffviewFileHistory<CR>]], desc = 'diffview: file history', mode = 'v' },
    --   {
    --     '<localleader>gh',
    --     '<Cmd>DiffviewFileHistory<CR>',
    --     desc = 'diffview: file history',
    --     mode = 'n',
    --   },
    -- },
    opts = {
      default_args = { DiffviewFileHistory = { '%' } },
      enhanced_diff_hl = true,
      hooks = {
        diff_buf_read = function()
          local opt = vim.opt_local
          opt.wrap, opt.list, opt.relativenumber = false, false, false
          opt.colorcolumn = ''
        end,
      },
      keymaps = {
        view = { q = '<Cmd>DiffviewClose<CR>' },
        file_panel = { q = '<Cmd>DiffviewClose<CR>' },
        file_history_panel = { q = '<Cmd>DiffviewClose<CR>' },
      },
    },
    config = function(_, opts)
      highlight.plugin('diffview', {
        { DiffAddedChar = { bg = 'NONE', fg = { from = 'diffAdded', attr = 'bg', alter = 0.3 } } },
        { DiffChangedChar = { bg = 'NONE', fg = { from = 'diffChanged', attr = 'bg', alter = 0.3 } } },
        { DiffviewStatusAdded = { link = 'DiffAddedChar' } },
        { DiffviewStatusModified = { link = 'DiffChangedChar' } },
        { DiffviewStatusRenamed = { link = 'DiffChangedChar' } },
        { DiffviewStatusUnmerged = { link = 'DiffChangedChar' } },
        { DiffviewStatusUntracked = { link = 'DiffAddedChar' } },
      })
      require('diffview').setup(opts)
    end,
  },
  -- {
  --   'ruifm/gitlinker.nvim',
  --   enabled = false,
  --   dependencies = { 'nvim-lua/plenary.nvim' },
  --   keys = {
  --     {
  --       '<localleader>gu',
  --       function() gitlinker.get_buf_range_url('n') end,
  --       desc = 'gitlinker: copy line to clipboard',
  --       mode = 'n',
  --     },
  --     {
  --       '<localleader>gu',
  --       function() gitlinker.get_buf_range_url('v') end,
  --       desc = 'gitlinker: copy range to clipboard',
  --       mode = 'v',
  --     },
  --     {
  --       '<localleader>go',
  --       function() gitlinker.get_repo_url(browser_open()) end,
  --       desc = 'gitlinker: open in browser',
  --     },
  --     {
  --       '<localleader>go',
  --       function() gitlinker.get_buf_range_url('n', browser_open()) end,
  --       desc = 'gitlinker: open current line in browser',
  --     },
  --     {
  --       '<localleader>go',
  --       function() gitlinker.get_buf_range_url('v', browser_open()) end,
  --       desc = 'gitlinker: open current selection in browser',
  --       mode = 'v',
  --     },
  --   },
  --   opts = {
  --     mappings = nil,
  --     callbacks = {
  --       ['github-work'] = function(url_data) -- Resolve the host for work repositories
  --         url_data.host = 'github.com'
  --         return require('gitlinker.hosts').get_github_type_url(url_data)
  --       end,
  --     },
  --   },
  -- },
  {
    'lewis6991/gitsigns.nvim',
    event = { 'BufReadPost', 'BufNewFile' },
    config = function()
      local gitsigns = require('gitsigns')
      gitsigns.setup {
        signs = {
          add = { text = '🮉' },
          change = { text = '🮉' },
          delete = { text = '🮉' },
          topdelete = { text = '🮉' },
          changedelete = { text = '🮉' },
          untracked = { text = '░' },
        },
        -- current_line_blame = not cwd():match('dotfiles'),
        current_line_blame_formatter = ' <author>, <author_time> · <summary>',
        preview_config = { border = 'rounded' },
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns
          -- local gs = require('gitsigns')

          local function bmap(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
          end

          -- stylua: ignore start
          bmap('n', '<localleader>hu',         gs.undo_stage_hunk,                           { desc = 'undo stage'                          })
          bmap('n', '<localleader>hi',         gs.preview_hunk_inline,                       { desc = 'preview current hunk'                })
          bmap('n', '<localleader>hb',         gs.toggle_current_line_blame,                 { desc = 'toggle current line blame'           })
          bmap('n', '<localleader>hd',         gs.diffthis,                                  { desc = 'diff this'                           })
          bmap('n', '<localleader>hD',         '<cmd>Gitsigns diffthis ~',                   { desc = 'diff this ~'                         })
          bmap('n', '<localleader>hw',         gs.toggle_word_diff,                          { desc = 'toggle word diff'                    })
          bmap('n', '<localleader>gw',         gs.stage_buffer,                              { desc = 'stage entire buffer'                 })
          bmap('n', '<localleader>gre',        gs.reset_buffer,                              { desc = 'reset entire buffer'                 })
          bmap('n', '<localleader>td',         gs.toggle_deleted,                            { desc = 'show deleted lines'                  })
          bmap('n', '<localleader>gbl',        function() gs.blame_line({full = true}) end,  { desc = 'blame current line'                  })
          bmap('n', '<localleader>hQ',         function() gs.setqflist('all') end,           { desc = 'list modified in quickfix'           })
          bmap('n', '<localleader>hq',         gs.setqflist,                                 { desc = 'quickfix'                            })
          bmap('v' , '<localleader>hs',        function() gs.stage_hunk({vim.fn.line('.'), vim.fn.line('v')}) end, { desc = 'stage git hunk'})
          bmap('v' , '<localleader>hr',        function() gs.reset_hunk({vim.fn.line('.'), vim.fn.line('v')}) end, { desc = 'reset hunk'    })
          bmap({ 'o', 'x' }, 'ih',             ':<C-U>Gitsigns select_hunk<CR>',             { desc = 'select hunk'                         })
          -- stylua: ignore stop


          bmap('n', ']c', function()
            -- if vim.wo.diff then
            --   vim.cmd.normal { ']h', bang = true }
            -- else
            --   gs.nav_hunk('next')
            -- end
            if vim.wo.diff then
              return "]c"
            end
            vim.schedule(function() gs.nav_hunk { 'next', preview = false, count = 1 }  end)
            return "<ignore>"
          end, { expr = true })
          bmap('n', '[c', function()
            -- if vim.wo.diff then
            --   vim.cmd.normal { '[h', bang = true }
            -- else
            --   gs.nav_hunk('prev')
            -- end
            if vim.wo.diff then
              return "[c"
            end
            vim.schedule(function() gs.nav_hunk { 'prev', preview = false, count = 1 } end)
            return "<ignore>"
          end, { expr = true })
        end,
      }
    end,
  },
}
