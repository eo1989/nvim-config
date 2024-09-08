return {
  {
    'monaqa/dial.nvim',
    keys = {
      { '<C-a>', '<Plug>(dial-increment)', mode = 'n' },
      { '<C-x>', '<Plug>(dial-decrement)', mode = 'n' },
      { '<C-a>', '<Plug>(dial-increment)', mode = 'v' },
      { '<C-x>', '<Plug>(dial-decrement)', mode = 'v' },
      { 'g<C-a>', 'g<Plug>(dial-increment)', mode = 'v' },
      { 'g<C-x>', 'g<Plug>(dial-decrement)', mode = 'v' },
    },
    config = function()
      local augend = require('dial.augend')
      local config = require('dial.config')

      local casing = augend.case.new {
        types = { 'camelCase', 'snake_case', 'PascalCase', 'SCREAMING_SNAKE_CASE' },
        cyclic = true,
      }

      config.augends:register_group {
        default = {
          augend.integer.alias.decimal,
          augend.integer.alias.hex,
          augend.integer.alias.binary,
          augend.date.alias['%m/%d/%Y'],
          augend.date.new(
            {
              pattern = '%m/%d',
              default_kind ="day",
              only_valid = true,
              word = true,
              clamp = true,
              end_sensitive = true,
            }
          ),
          -- augend.constant.alias.bool,
          augend.constant.new({
            elements = { 'and', 'or' },
            word = true, -- if false, 'sand' is incremented into 'sor', 'doctor' into 'doctand', etc
            cyclic = true, -- 'or' increments into 'and'
          }),
          augend.constant.new { elements = { 'True', 'False' }, word = false, preserve_case = true, cyclic = true },
          augend.constant.new { elements = { 'true', 'false' }, word = false, cyclic = true },
        },
      }

      -- config.augends:register_group {
      --   python = {
      --     augend.integer.alias.decimal,
      --     augend.constant.new { elements = { 'True', 'False' }, word = false, cyclic = true },
      --     augend.constant.new { elements = { 'and', 'or' }, word = false, cyclic = true },
      --     augend.constant.new { elements = { '&', '|' }, word = false, cyclic = true },
      --     augend.constant.new { elements = { 'is', 'is not' }, word = false, cyclic = true },
      --   },
      -- }

    end,
  },
  {
    'jghauser/fold-cycle.nvim',
    opts = {},
    keys = {
      { '<BS>', function() require('fold-cycle').open() end, desc = 'fold-cycle: toggle' },
    },
  },
  {
    'kylechui/nvim-surround',
    lazy = false,
    version = '*',
    keys = { { 's', mode = 'v' }, '<C-g>s', '<C-g>S', 'ys', 'yss', 'yS', 'cs', 'ds' },
    opts = { move_cursor = true, keymaps = { visual = 's' } },
  },
  {
    'glts/vim-textobj-comment',
    dependencies = { { 'kana/vim-textobj-user', dependencies = { 'kana/vim-operator-user' } } },
    init = function() vim.g.textobj_comment_no_default_key_mappings = 1 end,
    keys = {
      { 'ax', '<Plug>(textobj-comment-a)', mode = { 'x', 'o' } },
      { 'ix', '<Plug>(textobj-comment-i)', mode = { 'x', 'o' } },
    },
  },
  -- {
  --   'chrisgrieser/nvim-various-textobjs',
  --   enabled = false,
  --   -- ft = { 'markdown', 'quarto' },
  --   config = function()
  --     require('various_textobjs').setup {
  --       lookForwardLines = 8, -- default 5
  --     }
  --     map(
  --       { 'o', 'x' },
  --       'is',
  --       ":lua require('various-textobjs').sub_word(true)<CR>",
  --       { silent = true, desc = 'inner subword' }
  --     )
  --     map(
  --       { 'o', 'x' },
  --       'as',
  --       ":lua require('various-textobjs').sub_word(false)<CR>",
  --       { silent = true, desc = 'around subword' }
  --     )
  --   end,
  -- },
  {
    'tpope/vim-abolish',
    event = 'CmdlineEnter',
    keys = {
      {
        '<localleader>[',
        ':S/<C-R><C-W>//<LEFT>',
        mode = 'n',
        silent = false,
        desc = 'abolish: replace word under the cursor (line)',
      },
      {
        '<localleader>]',
        ':%S/<C-r><C-w>//c<left><left>',
        mode = 'n',
        silent = false,
        desc = 'abolish: replace word under the cursor (file)',
      },
      {
        '<localleader>[',
        [["zy:'<'>S/<C-r><C-o>"//c<left><left>]],
        mode = 'x',
        silent = false,
        desc = 'abolish: replace word under the cursor (visual)',
      },
    },
  },
}
