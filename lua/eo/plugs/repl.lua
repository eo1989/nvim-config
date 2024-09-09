local map = map or vim.keymap.set

-- ~~lhkphuc/dotfiles/blob/master/nvim/lua/plugins/repl.lua~~ not using cell_marker anymore.
--[[
-- In a native script, we mimick a notebook cell by defining a marker
-- Its commonly defined in many editors and programed to use a space and two percent (%) signs after the comment symbol.
-- for python, julia, etc, that would be a line starting with `# %%`
--]]
-- local code_cell = [[# %%]]

return {
  {
    'klafyvel/nvim-smuggler',
    ft = 'julia',
    dependencies = { 'nvim-neotest/nvim-nio' },
    opts = {},
  },
  {
    'GCBallesteros/jupytext.nvim',
    -- event = 'VeryLazy',
    lazy = false,
    version = '*',
    opts = {
      custom_language_formatting = {
        -- python = {
        --   extension = 'md',
        --   style = 'markdown',
        --   force_ft = 'markdown', -- you can set whatever ft you want here
        -- },
        python = {
          extension = 'qmd',
          style = 'quarto',
          force_ft = 'quarto', -- you can set whatever ft you want here
        },
      },
    },
  },
  {
    'jpalardy/vim-slime',
    enabled = true,
    -- event = 'VeryLazy',
    -- lazy = false,
    version = '*',
    init = function()
      vim.b['quarto_is_python_chunk'] = false
      Quarto_is_in_python_chunk = function() require('otter.tools.functions').is_otter_language_context('python') end

      vim.cmd([[
      let g:slime_dispatch_ipython_pause = 100
      function! SlimeOverride_EscapeText_quarto(text)
        call v:lua.Quarto_is_in_python_chunk()
        if exists('g:slime_python_ipython') && len(split(a:text, "\n")) > 1 && b:quarto_is_python_chunk && !(exists('b:quarto_is_r_mode') && b:quarto_is_r_mode)
          return ["%cpaste -q\n", g:slime_dispatch_ipython_pause, a:text, "--", "\n"]
        else
          if exists('b:quarto_is_r_mode') && b:quarto_is_r_mode && b:quarto_is_python_chunk
            return [a:text, "\n"]
          else
            return [a:text]
          end
        end
      endfunction
      ]])

      vim.g.slime_target = 'kitty'
      vim.g.slime_no_mappings = false
      vim.g.slime_python_ipython = 1
      vim.g.slime_cell_delimiter = '# %%'
      vim.g.slime_bracketed_paste = 1
    end,
    config = function()
      vim.g.slime_input_pid = false
      vim.g.slime_suggest_default = true
      vim.g.slime_menu_config = false
      vim.g.slime_neovim_ignore_unlisted = true

      local function mark_terminal()
        -- vim.g.slime_last_channel = vim.b.terminal_job_id
        local job_id = vim.b.terminal_job_id
        vim.print('job_id: ' .. job_id)
      end

      local function set_terminal()
        -- vim.b.slime_config = { jobid = vim.g.slime_last_channel }
        vim.fn.call('slime#config', {})
      end

      map('n', '<localleader>cm', mark_terminal, { desc = 'mark terminal' })
      map('n', '<localleader>cs', set_terminal, { desc = 'set terminal' })
    end,
  },
  --[[ lkhphuc/dotfiles/blob/master/nvim/lua/plugins/repl.lua ]]
  {
    'benlubas/molten-nvim',
    enabled = true,
    version = '*',
    build = ':UpdateRemotePlugins',
    lazy = false,
    -- init = function()
    --   vim.g.molten_image_provider = 'image.nvim'
    --   vim.g.molten_output_win_height = 20
    --   vim.g.molten_auto_open_output = false
    --   vim.g.molten_virt_text_output = true
    --   vim.g.molten_virt_lines_off_by_1 = false
    --   vim.g.molten_wrap_output = true
    --   vim.api.nvim_create_autocmd('User', {
    --     -- buffer = 0,
    --
    --     pattern = 'MoltenInitPost',
    --     callback = function()
    --       -- map('n', '<leader>mx', '<cmd>MoltenDeinit<CR>', { buffer = 0, desc = 'Molten Stop' })
    --       map('n', '<S-CR>', '<cmd>MoltenEvaluateOperator<CR>', { buffer = 0, desc = 'Run' })
    --       map('x', '<S-CR>', '<cmd>MoltenEvaluateVisual<CR>', { buffer = 0, desc = 'Run xSelection' })
    --       map('v', '<S-CR>', '<cmd><C-u>MoltenEvaluateVisual<CR>', { buffer = 0, desc = 'Run vSelection' })
    --       map('n', '<S-CR><S-CR>', 'vib<S-CR>]bj', { buffer = 0, remap = true, desc = 'Run cell and move' })
    --       map('n', '<leader>rn', '<cmd>MoltenHideOutput<CR>', { buffer = 0, desc = 'Hide Output' })
    --       map('n', '<leader>ro', '<cmd>noautocmd MoltenEnterOutput<CR>', { buffer = 0, desc = 'Show/Enter Output' })
    --       map('n', '<leader>ri', '<cmd>MoltenImportOutput<CR>', { buffer = 0, desc = 'Import Notebook Output' })
    --       map(
    --         { 'v', 'x' },
    --         '<leader>mv',
    --         '<cmd><C-u>MoltenEvaluateVisual<CR>',
    --         { buffer = true, desc = 'molten eval visual' }
    --       )
    --     end,
    --   })
    --   vim.api.nvim_create_autocmd('BufWritePost', {
    --     pattern = { '*.ipynb' },
    --     callback = function()
    --       if require('molten.status').initialized() == 'Molten' then vim.cmd('MoltenExportOutput') end
    --     end,
    --   })
    -- end,
  },
}
