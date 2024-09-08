-- local components = require('eo.plugs.components')
return {
  {
    'nvim-lualine/lualine.nvim',
    version = '*',
    lazy = false,
    dependencies = {
      'nvim-tree/nvim-web-devicons',
      'meuter/lualine-so-fancy.nvim',
    },
    opts = {
      options = {
        icons_enabled = true,
        theme = 'auto', -- auto, tokyonight
        -- component_separators = { left = '', right = '' },
        component_separators = { left = '', right = '' },
        section_separators = { left = '', right = '' },
        -- statusline = { 'alpha' },
        -- refresh = { statusline = 5000, winbar = 5000 },
        refresh = { statusline = 5000 },
        winbar = {
          'help',
          'alpha',
          'fzflua',
        },
        always_divide_middle = true,
        globalstatus = true,
      },
      sections = {
        lualine_a = {
          { 'fancy_mode', separator = { left = '' }, right_padding = 2 },
        },
        lualine_b = {
          { 'fancy_filename' },
          { 'fancy_cwd', substitute_home = true },
          { 'fancy_branch' },
          { 'fancy_diff' },
        },
        lualine_c = {
          { 'fancy_lsp_servers' },
        },
        lualine_x = {
          { 'fancy_diagnostics' },
          { 'fancy_filetype', ts_icon = ' ' },
        },
        lualine_y = {
          -- { 'progress', padding = { left = 1, right = 1 } },
          { 'progress' },
          { 'fancy_location' },
          { 'fancy_searchcount' },
        },
        lualine_z = {
          -- { "require('weather.lualine').custom(default_f_formatter, require('weather.other_icons').nerd_font)"},
          -- { function() return ' ' .. os.date('%R') end },
          { function() return ' ' .. os.date('%R') end, separator = { right = '' }, left_padding = 2 },
        },
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {},
        lualine_x = {},
        lualine_y = { 'fancy_location', 'fancy_searchcount' },
        lualine_z = {},
      },
      extensions = {
        'toggleterm',
        'quickfix',
        'overseer',
        'neo-tree',
        'fzf',
        'lazy',
        'man',
        'fugitive',
        'trouble',
        'mason',
        'symbols-outline',
        'nvim-dap-ui',
      },
    },
  },
}
