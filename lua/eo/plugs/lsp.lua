local lsp, fn, api, fmt = vim.lsp, vim.fn, vim.api, string.format
-- local highlight = eo.highlight

local map = vim.keymap.set

return {
  {
    'jmbuhr/otter.nvim',
    event = 'VeryLazy',
    ft = { 'markdown', 'quarto' },
    dependencies = { 'neovim/nvim-lspconfig', 'nvim-treesitter/nvim-treesitter' },
    opts = {},
  },
  {
    'b0o/schemastore.nvim',
    event = 'LspAttach',
    ft = { 'json', 'yaml' },
  },
  -- {
  --   'DNLHC/glance.nvim',
  --   event = 'LspAttach',
  --   opts = {
  --     preview_win_opts = { number = false },
  --     theme = { enable = true, mode = 'darken' },
  --   },
  -- },
  {
    {
      'williamboman/mason.nvim',
      cmd = 'Mason',
      build = ':MasonUpdate',
      opts = { ui = { border = 'rounded', height = 0.7 } },
    },
    {
      'williamboman/mason-lspconfig.nvim',
      event = { 'BufReadPre', 'BufNewFile' },
      dependencies = {
        'mason.nvim',
        {
          'neovim/nvim-lspconfig',
          dependencies = {
            {
              'folke/lazydev.nvim',
              dependencies = {
                { 'Bilal2453/luvit-meta', lazy = true },
              },
              ft = 'lua',
              opts = { library = { { path = 'luvit-meta/library', words = { 'vim%.uv' } } } },
            },
            {
              'j-hui/fidget.nvim',
              event = 'LspAttach',
              opts = {
                progress = {
                  display = {
                    overrides = {
                      lua_ls = { name = 'lua-ls' },
                    },
                  },
                },
                notification = {
                  override_vim_notify = true,
                  view = { stack_upwards = false },
                  window = {
                    y_padding = -1,
                    winblend = 10,
                    align = 'top',
                    max_height = 10,
                  },
                },
              },
            },
          },
          config = function()
            -- highlight.plugin('lspconfig', { { LspInfoBorder = { link = 'FloatBoarder' } } })
            require('lspconfig.ui.windows').default_options.border = 'rounded'
          end,
        },
      },
      opts = {
        automatic_installation = false,
        handlers = {
          function(name)
            local config = require('eo.servers')(name)
            if config then require('lspconfig')[name].setup(config) end
          end,
        },
      },
    },
    { 'Bilal2453/luvit-meta', lazy = true },
  },
  {
    'dgagn/diagflow.nvim',
    event = "DiagnosticChanged",
    opts = {
      scope = 'line', -- 'cursor' | 'line'
      show_sign = true,
      placement = 'top',
      update_event = {
        'DiagnosticChanged',
        'BufEnter',
        'TextChanged',
      },
      render_event = {
        'DiagnosticChanged',
        'TextChanged',
        'CursorMoved',
        'CursorHold',
        'BufEnter',
      },
    },
  },
  { 'mrjones2014/lua-gf.nvim', ft = 'lua' },
  { 'onsails/lspkind.nvim' },
  {
    'utilyre/barbecue.nvim',
    event = 'LspAttach',
    dependencies = {
      'neovim/nvim-lspconfig',
      {
        'SmiteshP/nvim-navic',
        opts = { highlight = true },
      },
      'nvim-tree/nvim-web-devicons',
    },
    opts = function(_, opts)
      local opts = {
        theme = 'auto',
        create_autocmd = false,
        attach_navic = true,
        show_dirname = false,
        show_basename = true,
      }
      vim.g.updatetime = 200
      vim.api.nvim_create_autocmd({
        'WinResized',
        'BufWinEnter',
        'CursorHold',
        'InsertLeave',
      }, {
        group = vim.api.nvim_create_augroup('Barbecue.updater', {}),
        callback = function() require('barbecue.ui').update() end,
      })
      require('barbecue').setup {}
    end,
  },
  {
    'Wansmer/symbol-usage.nvim',
    enabled = false,
    event = 'LspAttach',
    config = {
      text_format = function(symbol)
        local function h(name) return api.nvim_get_hl(0, { name = name }) end

        api.nvim_set_hl(0, 'SymbolUsageRounding', { fg = h('CursorLine').bg, italic = true })
        api.nvim_set_hl(0, 'SymbolUsageContent', { bg = h('CursorLine').bg, fg = h('Comment').fg, italic = true })
        api.nvim_set_hl(0, 'SymbolUsageRef', { fg = h('Function').fg, bg = h('CursorLine').bg, italic = true })
        api.nvim_set_hl(0, 'SymbolUsageDef', { fg = h('Type').fg, bg = h('CursorLine').bg, italic = true })
        api.nvim_set_hl(0, 'SymbolUsageImpl', { fg = h('@keyword').fg, bg = h('CursorLine').bg, italic = true })

        local stacked_funcs_content = symbol.stacked_count > 0 and ('+%S'):format(symbol.stacked_count) or ''

        local res = {}
        local ins = table.insert

        local round_start = { '', 'SymbolUsageRounding' }
        local round_end = { '', 'SymbolUsageRounding' }

        if symbol.references then
          local usage = symbol.references <= 1 and 'usage' or 'usages'
          local num = symbol.references == 0 and 'no' or symbol.references
          ins(res, round_start)
          ins(res, { '󰌹 ', 'SymbolUsageRef' })
          ins(res, { ('%s %s'):format(num, usage), 'SymbolUsageContent' })
          ins(res, round_end)
        end

        if symbol.definition then
          if #res > 0 then table.insert(res, { ' ', 'NonText' }) end
          ins(res, round_start)
          ins(res, { '󰳽 ', 'SymbolUsageDef' })
          ins(res, { symbol.definition .. ' defs', 'SymbolUsageContent' })
          ins(res, round_end)
        end

        if symbol.implementation then
          if #res > 0 then table.insert(res, { ' ', 'NonText' }) end
          ins(res, round_start)
          ins(res, { '󰡱 ', 'SymbolUsageImpl' })
          ins(res, { symbol.implementation .. ' impls', 'SymbolUsageContent' })
          ins(res, round_end)
        end

        if stacked_funcs_content ~= '' then
          if #res > 0 then ins(res, { ' ', 'NonText' }) end
          ins(res, round_start)
          ins(res, { ' ', 'SymbolUsageImpl' })
          ins(res, { stacked_funcs_content, 'SymbolUsageContent' })
          ins(res, round_end)
        end

        return res
      end,
      vt_position = 'textwidth', -- 'above' | 'textwidth' | 'signcolumn'
    },
  },
}
