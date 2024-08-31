return {
  {
    'folke/tokyonight.nvim',
    lazy = false,
    priority = 1003,
    opts = {
      style = 'storm',
      transparent = false,
      terminal_colors = true,
      styles = {
        comments = { italic = true },
        keywords = { italic = true },
        functions = { italic = true, bold = true },
        variables = { italic = true },
        sidebars = 'transparent', -- dark, transparent, normal
        floats = 'transparent',
      },
      sidebars = { 'qf', 'help', 'fzf_lua', 'overseer', 'terminal' },
      lualine_bold = true, -- when true, section headers in lualine will be bold
    },
    config = function(_, opts)
      local tokyonight = require('tokyonight')
      tokyonight.setup(opts)
      tokyonight.load()
    end,
  },
  {
    'catppuccin/nvim',
    priority = 1003,
    lazy = false,
    name = 'catppuccin',
    opts = {
      flavor = 'mocchiato',
      transparent_background = false,
      term_colors = true,
      compile = { enabled = true, path = vim.fn.stdpath('cache') .. '/catppuccin', suffix = '_compiled' },
      styles = {
        comments = { 'italic' },
        conditionals = { 'italic' },
        loops = { 'italic' },
        functions = { 'italic', 'bold' },
        keywords = { 'italic' },
        variables = { 'italic' },
        strings = {},
        numbers = {},
        booleans = {},
        properties = {},
        types = {},
        operators = {},
      },
      default_integrations = true,
      integrations = {
        native_lsp = {
          enabled = true,
          virtual_text = {
            errors = { 'italic' },
            hints = { 'italic' },
            warnings = { 'italic' },
            information = { 'italic' },
            ok = { 'italic' },
          },
          underlines = {
            errors = { 'undercurl' },
            hints = { 'underline' },
            warnings = { 'undercurl' },
            information = { 'underline' },
            ok = { 'underline' },
          },
          inlay_hints = { background = false },
        },
        alpha = true,
        cmp = true,
        dap = true,
        dap_ui = true,
        barbecue = {
          dim_dirname = true,
          bold_basename = true,
          dim_context = false,
          alt_background = false,
        },
        -- colorful_winsep = {
        --   enabled = true,
        --   -- color = 'red',
        -- },
        -- diffview = true,
        gitsigns = true,
        fidget = true,
        illuminate = true,
        headlines = true,
        indent_blankline = {
          enabled = true,
          -- scope_color = "",
          colored_indent_levels = true,
        },
        leap = true,
        lsp_trouble = true,
        mason = false,
        mini = true,
        navic = {
          enabled = false,
          custom_bg = 'NONE',
        },
        neogit = true,
        neotest = true,
        noice = false,
        notify = true,
        neotree = true,
        semantic_tokens = true,
        telescope = false,
        ts_rainbow = true,
        ts_rainbow2 = true,
        markdown = false,
        octo = false,
        overseer = true,
        rainbow_delimiters = true,
        window_picker = true,
        treesitter = true,
        which_key = true,
      },
    },
  },
  -- { 'rebelot/kanagawa.nvim', lazy = false, name = 'kanagawa' },
  -- {
  --   'ellisonleao/gruvbox.nvim',
  --   name = 'gruvbox',
  --   lazy = false,
  --   config = function() require('gruvbox').setup() end,
  -- },
}
