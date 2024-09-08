local api, fn = vim.api, vim.fn
-- local highlight = eo.highlight

local leap_keys = function()
  require('leap').leap {
    target_windows = vim.tbl_filter {
      function(win) return eo.empty(fn.win_gettype(win)) end,
      api.nvim_tabpage_list_wins(0),
    },
  }
end

return {
  {
    'ggandor/leap.nvim',
    lazy = true,
    keys = { { 's', leap_keys, mode = 'n' } },
    opts = { equivalence_classes = { ' \t\r\n', '([{', '}])', '`"\'' } },
    -- config = function(_, opts)
    --   highlight.plugin('leap', {
    --     theme = {
    --       ['*'] = { { LeapBackdrop = { fg = '#707070' } } },
    --     }
    --   })
    --   require('leap').setup(opts)
    -- end,
  },
  {
    'ggandor/flit.nvim',
    lazy = true,
    keys = { 'f', 'F' },
    dependencies = { 'ggandor/leap.nvim' },
    opts = { labeled_modes = 'nvo', multiline = false },
  },
}
