local ui = eo.ui
local lsp = ui.lsp
local icons = ui.icons

return {
  {
    'nvim-neo-tree/neo-tree.nvim',
    -- version = '*',
    branch = 'v3.x',
    cmd = 'Neotree',
    keys = {
      { '<C-n>', '<Cmd>Neotree toggle reveal<CR>', desc = 'NeoTree' },
      -- {
      --   '<C-n>',
      --   -- function() require('neo-tree.command').execute { toggle = true, dir = vim.uv.cwd() } end,
      --   desc = 'NeoTree (cwd)',
      -- },
    },
    deactivate = function() vim.cmd([[Neotree close]]) end,
    init = function()
      if vim.fn.argc(-1) == 1 then
        local stat = vim.uv.fs_stat(vim.fn.argv(0))
        if stat and stat.type == 'Directory' then require('neo-tree') end
      end
    end,
    opts = {
      close_if_last_window = true,
      enable_diagnostics = false,
      auto_clean_after_session_restore = false,
      sources = { 'filesystem', 'document_symbols', 'git_status' },
      default_source = 'filesystem',
      enable_modified_markers = true,
      enable_opened_markers = true,
      enable_refresh_on_write = true,
      open_files_in_last_window = true,
      open_files_do_not_replace_types = {
        'terminal',
        'toggleterm',
        'trouble',
        'qf',
        'quickfix',
        'Outline',
        'edgy',
        'dap-ui',
        'overseer',
        'neotest-output',
        'FzfLua',
      },
      popup_border_style = 'NC',
      resize_timer_interval = 500, -- in ms, needed for containers to redraw right aligned and faded content
      source_selector = {
        winbar = true,
        -- separator = { left = '◖ ', right = ' ◗' },
        separator = { left = '◤ ', right = ' ◥' },
        separator_active = '',
        sources = {
          {
            source = 'filesystem',
            display_name = '  Files ',
          },
          {
            source = 'git_status',
            display_name = '  Git ',
          },
          {
            source = 'document_symbols',
            display_name = '  Symbols ',
          },
        },
      },
      -- enable_normal_mode_for_inputs = false,
      git_status_async = true,
      filesystem = {
        bind_to_cwd = false,
        -- hijack_netrw_behavior = 'open_current',
        use_libuv_file_watcher = true,
        group_empty_dirs = false,
        follow_current_file = {
          enabled = false,
          leave_dirs_open = true,
        },
        async_directory_scan = 'auto',
        filtered_items = {
          visible = true,
          show_hidden_count = true,
          hide_dotfiles = false,
          hide_gitignored = true,
          never_show = { '.DS_Store', 'thumbs.db', 'node_modules' },
        },
        window = {
          mappings = {
            -- ['<space>'] = 'none',
            ['/'] = 'none',
            ['g/'] = 'fuzzy_finder',
          },
        },
      },
      default_component_configs = {
        icon = { folder_empty = icons.documents.open_folder },
        name = { highlight_opened_files = true },
        indent = {
          with_expanders = true, -- if nil and file nesting is enabled, will enable expanders
          -- expander_collapsed = '',
          -- expander_expanded = '',
          expander_highlight = 'NeoTreeExpander',
        },
        document_symbols = {
          follow_cursor = true,
          kinds = vim.iter(lsp.highlights):fold({}, function(acc, k, v)
            acc[k] = { icon = v, hl = require('lspkind').symbol_map[k] }
            return acc
          end),
        },
        modified = { symbol = icons.misc.circle .. ' ' },
        git_status = {
          symbols = {
            added = icons.git.add,
            deleted = icons.git.remove,
            modified = icons.git.mod,
            renamed = icons.git.rename,
            untracked = icons.git.untracked,
            ignored = icons.git.ignored,
            unstaged = icons.git.unstaged,
            staged = icons.git.staged,
            conflict = icons.git.conflict,
          },
        },
        file_size = { require_width = 20 },
      },
      window = {
        position = 'left',
        width = 25,
        mappings = {
          ['<space>'] = 'none',
          ['<Tab>'] = 'toggle_node',
          ['<CR>'] = 'open',
          ['<c-s>'] = 'split_with_window_picker',
          ['<c-v>'] = 'vsplit_with_window_picker',
          ['<esc>'] = 'revert_preview',
          ['P'] = { 'toggle_preview', config = { use_float = false, use_image_nvim = true } },
          ['<C-d>'] = { 'scroll_preview', config = { direction = 10 } },
          ['<C-u'] = { 'scroll_preview', config = { direction = -10 } },
        },
      },
      buffers = {
        follow_current_file = {
          enabled = true,
        },
        group_empty_dirs = false,
      },
      event_handlers = {
        {
          event = 'neo_tree_popup_input_ready',
          ---@param args { bufnr: integer, winid: integer }
          handler = function(args)
            vim.cmd([[stopinsert]])
            map('i', '<ESC>', vim.cmd.stopinsert, { noremap = true, buffer = args.bufnr })
          end,
        },
      },
    },
    config = function(_, opts)
      opts.event_handlers = opts.event_handlers or {}
      -- vim.list_extend(opts.event_handlers, {
      --   { event = events.FILE_MOVED, handler = on_move }
      --   { event = events.FILE_RENAMED, handler = on_move }
      -- })
      require('neo-tree').setup(opts)
      vim.api.nvim_create_autocmd('TermClose', {
        -- [[* lua require('neo-tree.events').on_term_close()]],
        pattern = { '*lazy', 'terminal', 'toggleterm', '*lazygit' },
        callback = function()
          if package.loaded['neo-tree.sources.git_status'] then require('neo-tree.sources.git_status').refresh() end
        end,
      })
    end,
    dependencies = {
      'nvim-lua/plenary.nvim',
      'MunifTanjim/nui.nvim',
      'nvim-tree/nvim-web-devicons',
      '3rd/image.nvim',
      {
        's1n7ax/nvim-window-picker',
        version = '*',
        opts = {
          filter_rules = {
            include_current_win = false,
            autoselect_one = true,
            bo = {
              filetype = { 'neo-tree', 'neo-tree-popup', 'notify' },
              buftype = { 'terminal', 'quickfix' },
            },
          },
        },
      },
    },
  },
}
