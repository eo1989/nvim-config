local api, fn, map = vim.api, vim.fn, map or vim.keymap.set
local hl, ui, falsy, augroup = eo.highlight, eo.ui, eo.falsy, eo.augroup
-- local icons, border, rect = ui.icons.lsp, ui.current.border, ui.border.rectangle
-- local lspkind = require('lspkind')

return {
  {
    'lukas-reineke/virt-column.nvim',
    version = '*',
    -- event = { 'BufNewFile', 'BufReadPost' },
    event = 'UIEnter',
    opts = { char = '▕' },
    -- init = function()
    --   augroup('VirtCol', {
    --     event = { 'VimEnter', 'BufEnter', 'WinEnter', 'UIEnter' },
    --     command = function(args)
    --       ui.decorations.set_colorcolumn(
    --         args.buf,
    --         function(virtcolumn) require('virt-column').setup_buffer { virtcolumn = virtcolumn } end
    --       )
    --     end,
    --   })
    -- end,
  },
  {
    'lukas-reineke/indent-blankline.nvim',
    enabled = true,
    version = '*',
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'HiPhish/rainbow-delimiters.nvim' },
    -- event = { 'BufNewFile', 'BufReadPost' },
    event = 'UIEnter',
    main = 'ibl',
    opts = {
      exclude = {
        -- stylua: ignore start
        filetypes = {
          'dbout', 'neo-tree', 'neo-tree-popup', 'log', 'gitcommit',
          'txt', 'help', 'NvimTree', 'git', 'undotree', 'checkhealth',
          'quarto', 'markdown', 'norg', 'org', 'orgagenda','lspinfo',
        },
        buftypes = {
          'terminal', 'nofile', 'quickfix', 'prompt', 'Lazy',
          'Mason', 'fzf', 'FzfLua', 'overseer', 'fzf-lua',
        },
        -- stylua: ignore end
      },
      debounce = 500,
      indent = {
        smart_indent_cap = true,
        char = '│', -- ▏┆ ┊ 
      },
      scope = {
        enabled = true,
        show_start = true,
        show_exact_scope = true, -- default 'false'
        show_end = false,
        char = '▎', -- 🮇
        include = {
          node_type = {
            lua = { 'return_statement', 'table_constructor' },
          },
        },
        -- highlight = {
        --   'RainbowDelimiterRed',
        --   'RainbowDelimiterYellow',
        --   'RainbowDelimiterBlue',
        --   'RainbowDelimiterOrange',
        --   'RainbowDelimiterGreen',
        --   'RainbowDelimiterViolet',
        --   'RainbowDelimiterCyan',
        -- },
      },
    },
    config = function(_, opts)
      require('ibl').setup(opts)
      local hooks = require('ibl.hooks')
      -- hooks.register(hooks.type.SCOPE_HIGHLIGHT, hooks.builtin.scope_highlight_from_extmark)
      hooks.register(hooks.type.WHITESPACE, hooks.builtin.hide_first_tab_indent_level)
      hooks.register(hooks.type.WHITESPACE, hooks.builtin.hide_first_space_indent_level)
    end,
  },
  {
    'rcarriga/nvim-notify',
    lazy = false,
    version = '*',
    opts = {
      -- background_colour = '#000000',
      stages = 'fade_in_slide_out',
      top_down = false,
      timeout = 1200,
      -- max_height = function() return math.floor(vim.o.lines * 0.8) end,
      -- max_width = function() return math.floor(vim.o.columns * 0.6) end,
      -- on_open = function(win)
      --   if not api.nvim_win_is_valid(win) then return end
      --   api.nvim_win_set_config(win, { border = 'rounded' })
      -- end,
      -- render = function(...)
      --   local notification = select(2, ...)
      --   local style = falsy(notification.title[1]) and 'minimal' or 'default'
      --   require('notify.render')[style](...)
      -- end,
      render = 'wrapped-compact',
    },
  },
}
