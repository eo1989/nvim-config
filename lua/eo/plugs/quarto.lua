return {
  {
    'quarto-dev/quarto-nvim',
    enabled = true,
    version = '*',
    ft = { 'quarto' },
    dependencies = {
      'jmbuhr/otter.nvim'
      -- 'hrsh7th/nvim-cmp',
      -- 'neovim/nvim-lspconfig',
      -- 'nvim-treesitter/nvim-treesitter',
    },
    opts = {},
  },
}
