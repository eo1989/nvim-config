return {
  {
    'MeanderingProgrammer/markdown.nvim',
    enabled = true,
    ft = { 'markdown', 'rmd', 'vimwiki', 'norg', 'org', 'rst', 'quarto' },
    dependencies = {
      { 'headlines.nvim', enabled = false },
    },
    opts = {
      file_types = { 'markdown', 'rmd', 'vimwiki', 'norg', 'org', 'rst' },
    },
  },
  {
    'iamcco/markdown-preview.nvim',
    enabled = false,
    build = function() vim.fn['mkdp#util#install']() end,
    ft = { 'markdown' },
    config = function()
      vim.g.mkdp_auto_start = 0
      vim.g.mkdp_auto_close = 1
    end,
  },
  {
    'jbyuki/nabla.nvim',
    enabled = false,
    ft = { 'markdown', 'norg', 'org', 'rst', 'latex', 'quarto' },
  },
  -- { -- paste an image from the clipboard or drag-and-drop
  --   'HakonHarnes/img-clip.nvim',
  --   event = 'BufEnter',
  --   ft = { 'markdown', 'quarto' },
  --   opts = {
  --     default = {
  --       dir_path = 'img',
  --     },
  --     filetypes = {
  --       markdown = {
  --         url_encode_path = true,
  --         template = '![$CURSOR]($FILE_PATH)',
  --         drag_and_drop = {
  --           download_images = false,
  --         },
  --       },
  --       quarto = {
  --         url_encode_path = true,
  --         template = '![$CURSOR]($FILE_PATH)',
  --         drag_and_drop = {
  --           download_images = false,
  --         },
  --       },
  --     },
  --   },
  --   config = function(_, opts)
  --     require('img-clip').setup(opts)
  --     vim.keymap.set('n', '<localleader>ii', ':PasteImage<cr>', { desc = '[i]nsert [i]mage from clipboard' })
  --   end,
  -- },
  {
    'HakonHarnes/img-clip.nvim',
    event = 'VeryLazy',
    ft = { 'markdown', 'quarto' },
    opts = {
      default = {
        dir_path = function() return vim.fn.expand('%:t:r') end,
      },
      filetypes = {
        markdown = {
          url_encode_path = true,
          template = '![$CURSOR]($FILE_PATH)',
          drag_and_drop = {
            download_images = false,
          },
        },
        quarto = {
          url_encode_path = true,
          template = '![$CURSOR]($FILE_PATH)',
          drag_and_drop = {
            download_images = false,
          },
        },
      },
    },
    config = function(_, opts)
      require('img-clip').setup(opts)
      map('n', '<localleader>ii', ':PasteImage<CR>', { desc = '[i]nsert [i]mage from clipboard' })
    end,
  },
}
