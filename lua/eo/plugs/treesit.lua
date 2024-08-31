--[[
  The should_disable logic and subsequent settings are applied after reviewing stevearc/dotfiles
  specifically: github.com/stevearc/dotfiles/blob/master/nvim/lua/plugins/treesitter.lua
]]

return {
  {
    'nvim-treesitter/nvim-treesitter',
    version = '*',
    build = ':TSUpdate',
    opts = {
      sync_install = true,
      auto_install = false,
      ensure_installed = {
        'julia',
        'python',
        'pymanifest',
        'lua',
        'luap',
        'luadoc',
        'bash',
        'mermaid',
        'html',
        'json',
        'jsonc',
        'markdown',
        'markdown_inline',
        'requirements',
        'diff',
        'query',
        'regex',
        'latex', -- requires Mason install tree-sitter-cli??
        'yaml',
        'toml',
        'sql',
        'ini',
        'todotxt',
        'gitcommit',
        'git_rebase',
        'gitignore',
        'git_config',
        'gitattributes',
      },
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
        disable = function(_long, buf)
          local max_size = 10000 * 1024 -- 10mb
          local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
          if ok and stats and stats.size > max_size then
            vim.notify('Treesitter highlight disabled')
            return true
          end
        end,
      },
      indent = {
        enable = true,
        disable = { 'yaml', 'python', 'markdown' },
      },
      incremental_selection = {
        enable = true,
        disable = { 'help', 'txt' },
        keymaps = {
          init_selection = '<C-Space>',
          node_incremental = '<CR>',
          node_decremental = '<C-CR>',
        },
      },
      textobjects = {
        select = {
          enable = true,
          -- lookahead = true,
          keymaps = {
            ['af'] = { query = '@function.outer', desc = 'ts: all function' },
            ['if'] = { query = '@function.inner', desc = 'ts: inner function' },
            -- ['ac'] = { query = '@class.outer', desc = 'ts: all class' },
            -- ['ic'] = { query = '@class.inner', desc = 'ts: inner class' },
            -- ['aC'] = { query = '@conditional.outer', desc = 'ts: all conditional' },
            -- ['iC'] = { query = '@conditional.inner', desc = 'ts: inner conditional' },
            ['ib'] = { query = '@block.inner', desc = 'ts: inner block' },
            ['ab'] = { query = '@block.outer', desc = 'ts: outer block' },
          },
        },
        move = {
          enable = true,
          set_jumps = false, -- whether to set jumps in the jumplist
          lookahead = true, -- automatically jump forward to textobj, similar to targets.vim
          goto_next_start = {
            [']m'] = { query = '@function.outer', desc = 'next function' },
            -- [']M'] = { query = '@class.outer', desc = 'next class' },
            [']b'] = { query = '@block.inner', desc = 'next code block' },
          },
          goto_previous_start = {
            ['[m'] = { query = '@function.outer', desc = 'previous function' },
            -- ['[M'] = { query = '@class.outer', desc = 'previous class' },
            ['[b'] = { query = '@block.inner', desc = 'previous code block' },
          },
        },
      },
      query_linter = {
        enable = true,
        use_virtual_text = true,
        lint_events = { 'BufWrite', 'CursorHold' },
      },
      matchup = {
        enable = true,
        enable_quotes = true,
        -- disable = { 'latex', 'markdown', 'norg', 'quarto', 'julia', 'txt', 'help' },
        disable = { 'txt', 'help' },
        include_match_words = true,
        disable_virtual_text = false,
      },
      endwise = { enable = true },
      playground = { persist_queries = true },
      autopairs = { enable = true },
      rainbow = {
        enable = true,
        -- disable = { 'markdown', 'norg', 'quarto', 'julia', 'txt', 'help' },
        disable = { 'txt', 'help' },
      },
    },
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
      'JoosepAlviste/nvim-ts-context-commentstring',
      {
        'andymass/vim-matchup',
        -- event = { 'CursorHold' },
        -- cmd = { 'MatchupWhereAmI' },
        init = function()
          vim.o.matchpairs = '(:),{:},[:]'
          vim.g['matchup_surround_enabled'] = 1
          -- vim.g['matchup_matchparen_deferred'] = 1
          vim.g['matchup_matchparen_hi_surround_always'] = 1
          vim.g['matchup_matchparen_deferred'] = 50
          vim.g['matchup_matchparen_deferred_show_delay'] = 250
          vim.g['matchup_matchparen_deferred_hide_delay'] = 1000
          vim.g['matchup_matchparen_stopline'] = 200

          local matchup_hl = vim.api.nvim_create_augroup('MatchupHighlight', {})
          vim.api.nvim_clear_autocmds { group = matchup_hl }
          vim.api.nvim_create_autocmd('BufEnter', {
            group = matchup_hl,
            desc = 'redefinition of treesitter highlight group',
            callback = function()
              vim.api.nvim_set_hl(0, 'MatchWord', { bold = true, reverse = false })
              vim.api.nvim_set_hl(0, 'MatchParen', { bold = true, reverse = false })
              vim.api.nvim_set_hl(0, 'MatchupVirtualText', { bold = true, reverse = false })
            end,
          })
        end,
        config = function(_, opts)
          local ok, cmp = eo.pcall(require, 'cmp')
          if ok then
            cmp.event:on('menu_opened', function() vim.b.matchup_matchparen_enabled = false end)
            cmp.event:on('menu_closed', function() vim.b.matchup_matchparen_enabled = true end)
          end
          -----------------------------------------------------------------------
          local fsize = vim.fn.getfsize(vim.fn.expand('%:p:f'))
          if fsize == nil or fsize < 0 then fsize = 1 end
          local enabled = 1
          if fsize > 500000 then enabled = 0 end
          if vim.tbl_contains({ 'markdown', 'txt', 'help' }, vim.bo.filetype) then enabled = 0 end
          vim.g['matchup_enabled'] = enabled
          vim.g['matchup_surround_enabled'] = enabled
          vim.g['matchup_transmute_enabled'] = 0
          vim.g['matchup_matchparen_deferred'] = enabled
          vim.g['matchup_matchparen_hi_surround_always'] = enabled
          vim.g['matchup_matchparen_offscreen'] = { method = 'popup', scrolloff = 1 }
          vim.g['matchup_matchparen_nomode'] = 'i'
          vim.g['matchup_matchparen_pumvisible'] = 0
          -- dont recognize anything in comments
          vim.g['matchup_delim_noskips'] = 2
          vim.g['matchup_motion_cursor_end'] = 1
          vim.g['matchup_matchpref'] = { html = { nolists = 1 } }
          -- vim.keymap.set('n', '<c-s-k>', ':<c-u>MatchupWhereAmI<cr>', { noremap = true })
          -----------------------------------------------------------------------
          require('match-up').setup(opts)
        end,
      },
      {
        'RRethy/nvim-treesitter-endwise',
        event = 'InsertEnter',
      },
    },
  },
  {
    'm-demare/hlargs.nvim',
    lazy = false,
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    opts = { hlpriority = 1000 },
  },
  {
    'HiPhish/rainbow-delimiters.nvim',
    event =  'BufRead',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    config = function()
      local rb = require('rainbow-delimiters')
      vim.g.rainbow_delimiters = {
        strategy = {
          [''] = rb.strategy['global'],
        },
        query = {
          [''] = rb.strategy['local'],
        },
        blacklist = { 'help', 'txt' },
      }
    end,
  },
  {
    'CKolkey/ts-node-action',
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'tpope/vim-repeat' },
    event = { 'CursorHold', 'FuncUndefined' },
    version = '*',
    opts = {},
    keys = {
      {
        'gA',
        -- function() require('ts-node-action').node_action() end,
        [[<cmd>lua require('ts-node-action').node_action()<cr>]],
        desc = 'Node Action',
      },
    },
  },
  {
    'Wansmer/treesj', --[[ why not just use ts-node-action for all of it?! ]]
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    cmd = { 'TSJSplit', 'TSJJoin' },
    opts = {
      use_default_keymaps = false,
      cursor_behavior = 'start',
      max_join_length = 160,
    },
    keys = {
      {
        'gS',
        '<cmd>TSJSplit<cr>',
        desc = 'Toggle Split to multiple lines',
      },
      {
        'gJ',
        '<cmd>TSJJoin<cr>',
        desc = 'Toggle Join to single line',
      },
    },
  },
  {
    'Wansmer/sibling-swap.nvim',
    version = '*',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    keys = {
      {
        '[w',
        -- function() require('sibling-swap').swap_with_left() end,
        [[:lua require('sibling-swap').swap_with_left()<CR>]],
        { desc = 'Swap with Left', silent = true },
      },
      {
        ']w',
        [[:lua require('sibling-swap').swap_with_right()<CR>]],
        -- [[<cmd>lua require('sibling-swap').swap_with_right()<CR>]],
        { desc = 'Swap with Right', silent = true },
      },
    },
    opts = {
      max_join_length = 120,
      check_syntax_error = true,
      cursor_behavior = 'hold',
      dot_repeat = true,
      highlight_node_at_cursor = true,
      use_default_keymaps = false,
    },
  },
  {
    'numToStr/Comment.nvim',
    version = '*',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    keys = { 'gcc', { 'gc', mode = { 'x', 'n', 'o' } } },
    opts = function(_, opts)
      local ok, integration = pcall(require, 'ts_context_commentstring.integrations.comment_nvim')
      if ok then opts.pre_hook = integration.create_pre_hook() end
    end,
  },
}
