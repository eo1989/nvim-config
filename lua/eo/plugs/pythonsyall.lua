return {
  {
    'lkhphuc/jupyter-kernel.nvim',
    enabled = false,
    opts = { timeout = 0.5 },
    build = ':UpdateRemotePlugins',
    cmd = 'JupyterAttach',
    dependencies = { 'nvim-cmp' },
    config = function()
      require('jupyter_kernel').setup {}
      map('n', '<localleader>k', '<cmd>JupyterInspect<CR>', { buffer = 0, desc = 'Inspect obj in krnl' })
    end,
    -- keys = {
    --   { '<localleader>k', '<cmd>JupyterInspect<CR>', desc = 'Inspect object in kernel' },
    -- },
  },
  { 'vimjas/vim-python-pep8-indent', ft = 'python' },
  { 'microsoft/python-type-stubs', ft = 'python' },
  {
    'linux-cultist/venv-selector.nvim',
    branch = 'regexp',
    -- event = 'VeryLazy',
    -- lazy = false,
    ft = 'python',
    cmd = 'VenvSelect',
    -- priority = 1001,
    dependencies = {
      'neovim/nvim-lspconfig',
      'nvim-telescope/telescope.nvim',
      'mfussenegger/nvim-dap',
      'mfussenegger/nvim-dap-python',
    },
    opts = { auto_refresh = false },
    config = function(_, opts)
      -- this function gets called by the plugin when a new result from fd is received
      -- change the filename displayed here to what you need, example: remove the /bin/python part.

      -- map('n', '<localleader>vs', '<cmd>VenvSelect<cr>', { buffer = 0, desc = 'Select Virtualenv' })

      require('venv-selector').setup(opts)
    end,
    keys = { { '<localleader>v', '<cmd>VenvSelect<cr>', desc = 'Select Virtualenv', ft = 'python' } },
  },
}
