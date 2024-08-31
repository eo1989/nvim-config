return {
  'folke/which-key.nvim',
  version = '*',
  -- dependencies = { 'mrjones2014/legendary.nvim' },
  event = { 'VeryLazy' },
  opts = {
    setup = {
      show_help = true,
      plugins = {
        marks = false,
        registers = false,
        spelling = { enabled = false },
      },
      -- key_labels = { ['<leader>'] = 'SPC' },
      triggers = 'auto',
      window = {
        border = 'single', -- none, single, double, shadow
        position = 'bottom', -- bottom, top
        margin = { 1, 0, 1, 0 }, -- extra window margin [top, right, bottom, left]
        padding = { 1, 2, 1, 2 }, -- extra window padding [top, right, bottom, left]
        wo = { winblend = 40 },
      },
      layout = {
        height = { min = 4, max = 24 }, -- min and max height of the columns
        width = { min = 20, max = 50 }, -- min and max width of the columns
        spacing = 3, -- spacing between columns
        align = 'center', -- align columns left, center or right
      },
    },
    -- defaults = {
    --   prefix = '<leader>',
    --   mode = { 'n', 'v' },
    --   q = {
    --     name = 'Quit',
    --     q = { function() require('bufdelete').bufdelete(0, true) end, 'delete buf' },
    --     t = { '<cmd>tabclose<cr>', 'Close Tab' },
    --   },
    -- },
  },
  config = function(_, opts)
    local wk = require('which-key')
    wk.setup(opts)
    -- wk.register(opts.defaults)
  end,
}
