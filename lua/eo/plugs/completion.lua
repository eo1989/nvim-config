---@diagnostic disable: missing-fields

local api, ui = vim.api, eo.ui

return {
  {
    'kawre/neotab.nvim',
    event = 'InsertEnter',
    opts = {},
  },
  {
    'hrsh7th/nvim-cmp',
    version = false,
    branch = 'main',
    event = 'InsertEnter',
    dependencies = {
      { 'hrsh7th/cmp-nvim-lsp' },
      { 'hrsh7th/cmp-path' },
      { 'onsails/lspkind.nvim' },
      -- { 'hrsh7th/cmp-nvim-lua' },
      { 'folke/lazydev.nvim' },
      { 'rcarriga/cmp-dap' },
      { 'theHamsta/nvim-dap-virtual-text' },
      { 'L3MON4D3/LuaSnip' },
      { 'saadparwaiz1/cmp_luasnip' },
      { 'hrsh7th/cmp-buffer' },
      { 'hrsh7th/cmp-nvim-lsp-document-symbol' },
      { 'hrsh7th/cmp-cmdline' },
      { 'petertriho/cmp-git' },
      { 'amarakon/nvim-cmp-lua-latex-symbols' },
      { 'jmbuhr/otter.nvim' },
    },
    config = function()
      local cmp = require('cmp')
      local cmp_types = require('cmp.types')
      local lspkind = require('lspkind')
      local luasnip = require('luasnip')
      local neotab = require('neotab')

      local function has_words_before()
        unpack = unpack or table.unpack
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match('%s') == nil
      end

      cmp.setup {
        experimental = { ghost_text = false, native_menu = false },
        performance = {
          debounce = 18,
          throttle = 24,
          fetching_timeout = 80,
          async_budget = 18,
          confirm_resolve_timeout = 80,
          max_view_entries = 32,
        },
        completion = {
          keyword_length = 1,
          completeopt = 'menu,menuone,noselect',
          autocomplete = {
            'TextChanged',
            'TextChangedI',
            'TextChangedT',
          },
        },
        snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
        view = {
          entries = {
            name = 'custom',
            selection_order = 'near_cursor',
          },
          docs = { auto_open = true },
        },
        matching = {
          disallow_fuzzy_matching = true,
          disallow_fullfuzzy_matching = true,
          disallow_partial_fuzzy_matching = true,
          disallow_partial_matching = true,
          disallow_prefix_unmatching = false,
        },
        preselect = cmp.PreselectMode.Item, -- Item | None
        sources = {
          { name = 'path', option = { trailing_slash = true } },
          { name = 'lazydev', group_index = 0 },
          { name = 'luasnip', priority = 9, max_item_count = 3 },
          { name = 'nvim_lsp', priority = 10 },
          { { name = 'buffer', keyword_length = 3, max_item_count = 3 } },
        },
        window = {
          documentation = {
            winblend = 10,
            border = 'rounded',
            zindex = 52,
          },
          completion = cmp.config.window.bordered {
            col_offset = -3,
            side_padding = 0,
            zindex = 52,
          },
        },
        mapping = {
          ['<Down>'] = cmp.mapping(cmp.mapping.select_next_item { behavior = cmp.SelectBehavior.Insert }, { 'i' }),
          ['<Up>'] = cmp.mapping(cmp.mapping.select_prev_item { behavior = cmp.SelectBehavior.Insert }, { 'i' }),
          ['<C-n>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item { behavior = cmp_types.cmp.SelectBehavior.Insert }
            elseif has_words_before then
              cmp.complete()
            else
              fallback()
            end
          end, { 'i', 'c' }),
          -- ['<C-p>'] = cmp.mapping(cmp.mapping.select_prev_item({ behavior = cmp_types.SelectBehavior.Insert })),
          ['<C-p>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.mapping.select_prev_item { behavior = cmp_types.cmp.SelectBehavior.Insert }
            else
              fallback()
            end
          end, { 'i', 'c' }),

          -- ['<C-Space>'] = cmp.mapping(cmp.mapping.complete({reason = 'auto'})),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
          -- ['<C-g>'] = function(fallback)
          --   if cmp.core.view:visible() then
          --     if cmp.visible_docs() then
          --       cmp.close_docs()
          --     else
          --       cmp.open_docs()
          --     end
          --   else
          --     fallback()
          --   end
          -- end,

          ['<CR>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              if cmp.get_selected_entry() then
                cmp.confirm { select = false, cmp_types.cmp.ConfirmBehavior.Insert }
              else
                cmp.close()
              end
            else
              fallback()
            end
          end),

          ['<C-u>'] = cmp.mapping(cmp.mapping.scroll_docs(-4)),
          ['<C-d>'] = cmp.mapping(cmp.mapping.scroll_docs(4)),

          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.locally_jumpable(1) then
              luasnip.jump(1)
            else
              -- neotab.tabout()
              fallback()
            end
          end, { 'i', 's' }),

          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { 'i', 's' }),
        },
        formatting = {
          deprecated = false,
          expandable_indicator = true,
          fields = { 'kind', 'abbr', 'menu' },
          format = function(entry, vim_item)
            local kind = require('lspkind').cmp_format {
              mode = 'symbol_text',
              maxwidth = 50,
              ellipsis_char = '…',
              menu = {
                nvim_lsp = '[LSP]',
                jupyter = '[Jupy]',
                copilot = '[Pilot]',
                nvim_lua = '[Lua]',
                lazydev = '[Lua]',
                luasnip = '[Snip]',
                buffer = '[Buf]',
                async_path = '[aPath]',
                path = '[Path]',
                ['lua-latex-symbols'] = '[Tex]',
                latex_symbols = '[Tex]',
                neorg = '[Norg]',
                git = '[Git]',
                norg = '[Norg]',
                env = '[Env]',
                cmp_zsh = '[Zsh]',
                dictionary = '[Dict]',
                spell = '[Spell]',
                snippets = '[Snip]',
                emoji = '[Emoji]',
                dap = '[Dap]',
                otter = '[Otter]',
                pandoc_references = '[ref]',
              },
              symbol_map = {
                otter = '🦦',
                jupyter = '🪐',
                copilot = ' ',
                nvim_lsp = ' ',
                nvim_lua = ' ',
                lazydev = ' ',
                luasnip = ' ',
                buffer = '﬘ ',
                latex_symbols = ' ',
                ['lua-latex-symbols'] = ' ',
                dictionary = ' ',
                spell = '暈 ',
                snippets = ' ',
                emoji = '󰞅 ',
                dap = '暈 ',
                path = ' ',
                pandoc_references = ' ',
                git = ' ',
                norg = ' ',
                cmp_zsh = ' ',
                env = ' ',
                async_path = ' ',
                neorg = ' ',
                cmdline = ' ',
              },
            }(entry, vim_item)
            local strings = vim.split(kind.kind, '%s', { trimempty = true })
            kind.kind = ' ' .. (strings[1] or '') .. ' '
            kind.menu = '    (' .. (strings[2] or entry.source.name) .. ')'
            return kind
          end,
        },
      }

      cmp.setup.filetype({ 'markdown', 'quarto' }, {
        sources = cmp.config.sources {
          { name = 'lua-latex-symbols', priority = 5 },
          { name = 'otter', priority = 10 },
        },
      })

      cmp.setup.filetype({ 'dap-repl', 'dapui_watches', 'dapui_hover' }, {
        sources = cmp.config.sources {
          { name = 'dap' },
        },
      })

      cmp.setup.cmdline({ '/', '?' }, {
        sources = cmp.config.sources {
          { name = 'nvim_lsp_document_symbol' },
          { name = 'buffer' },
        },
      })

      cmp.setup.cmdline(':', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources {
          { name = 'path' },
          {
            name = 'cmdline',
            keyword_pattern = [=[[^[:blank:]\!]*]=],
            option = { ignore_cmds = {} },
          },
        },
        matching = { disallow_symbol_nonprefix_matching = false },
      })
    end,
  },
  {
    'zbirenbaum/copilot-cmp',
    -- version = '*',
    enabled = true,
    event = 'InsertEnter',
    opts = {},
    init = function() vim.api.nvim_set_hl(0, 'CmpItemKindCopilot', { fg = '#6CC644' }) end,
    dependencies = {
      {
        'zbirenbaum/copilot.lua',
        version = '*',
        build = ':Copilot auth',
        opts = {
          panel = { enabled = false },
          suggestion = {
            enabled = true,
            auto_trigger = true,
            debounce = 250,
            keymap = {
              accept = false,
              accept_word = '<M-w>',
              accept_line = '<M-l>',
              next = '<M-]>',
              prev = '<M-[>',
            },
          },
          filetypes = {
            norg = false,
            ['*'] = true,
            quarto = false,
            gitcommit = false,
            ['dap-repl'] = false,
            ['FzfLua'] = false,
            DressingInput = false,
            TelescopePrompt = false,
            ['neo-tree-popup'] = false,
            NeogitCommitMessage = false,
          },
        },
      },
    },
  },
}

-- local function has_words_before()
--   local line, col = unpack(api.nvim_win_get_cursor(0))
--   if col == 0 then return false end
--   local str = api.nvim_buf_get_lines(0, line - 1, line, true)[1]
--   local curr_char = str:sub(col, col)
--   local next_char = str:sub(col + 0, col + 1)
--   return col ~= -1
--     and curr_char:match('%s') == nil
--     and next_char ~= '"'
--     and next_char ~= "'"
--     and next_char ~= '}'
--     and next_char ~= ']'
--     and next_char ~= ')'
-- end
