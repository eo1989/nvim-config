-- local border = eo.ui.current.border
-- local map = map or vim.keymap.set

--@param env: string
--@return string[]
-- local function py_env()
--   local ok, venv = pcall(require, 'venv-selector')
--   if ok then
--     -- return require('venv-selector.venv').current_venv()
--     -- return require("venv-selector.system").getenv
--     return require('venv-selector.venv').activate_venv()
--   else
--     return os.getenv('VIRTUAL_ENV')
--   end
-- end

return {
  {
    'michaelb/sniprun',
    enabled = false,
    build = 'sh ./install.sh 1',
    -- branch = 'dev',
    -- cmd = { 'SnipRun', 'SnipInfo', 'SnipReset', 'SnipClose' },
    -- keys = {
    --   {
    --     '<localleader>rs',
    --     -- function() require('sniprun').run('v') end,
    --     [[<cmd>lua require('sniprun').run('v')<CR>]],
    --     expr = true,
    --     mode = { 'v', 'x', 'o' },
    --     {
    --       desc = 'Run Selection',
    --     },
    --   },
    --   {
    --     mode = 'n',
    --     '<F2>',
    --     [[<cmd>b:caret=winsaveview()<CR>|:%SnipRun<CR>|call winrestview(b:caret)<CR>]],
    --     { silent = true, expr = true },
    --   },
    --   { mode = 'n', '<F3>', [[<cmd>SnipClose<CR>]], { desc = 'close sniprun' } },
    --   { mode = 'n', '<F4>', [[<cmd>SnipReset<CR>]], { desc = 'reset sniprun' } },
    --   { mode = 'n', '<F10>', [[<cmd>SnipInfo<CR>]], { desc = 'sniprun info' } },
    -- },
    opts = {
      selected_interpreters = {
        'lua_nvim',
        'Python3_fifo',
        'GFM_original',
      },
      repl_enable = {
        'Python3_jupyter',
        'Julia_original',
      },
      -- repl_disable = { 'lua_nvim' },
      interpreter_options = {
        Python3_fifo = {
          interpreter = vim.fn.expand('~') .. '/.pyenv/versions/gen/bin/python',
          -- venv = vim.fn.expand('~/.local/pipx/venvs/jupyterlab'),
          venv = vim.fn.expand('~') .. '/.pyenv/versions',
          error_truncate = 'auto',
        },
        Python3_jupyter = {
          interpreter = vim.fn.expand('~') .. '/.local/pipx/venvs/jupyterlab/bin/python',
          venv = vim.fn.expand('~') .. '/.local/pipx/venvs/jupyterlab',
          error_truncate = 'auto',
        },
        -- TODO: make this from a function
        -- Julia_jupyter = {
        --   from the docs:
        --   jupyter-kernel --kernel=julia-1.8 --KernelManager.connection_file=$HOME/.cache/sniprun/julia_jupyter/kernel_sniprun.json
        --   interpreter = os.getenv('HOME') .. '/home/eo/.local/this'
        -- },
        julia_original = {
          interpreter = 'julia',
          project = '.',
        },
        GFM_original = {
          default_filetype = 'python',
        },
      },
      -- borders = border,
      display = {
        'VirtualTextError',
        'LongTempFloatingWindow',
        'TerminalWithCodeErr',
        -- 'VirtualTextOk',
        -- 'NvimNotify',
        -- 'TerminalWithCode',
      },
      display_options = {
        terminal_widths = 20,
        notification_timeout = 10,
      },
    },
    config = function(_, opts)
      require('sniprun').setup(opts)
      -- vim.api.nvim_set_keymap(
      --   'v',
      --   '<localleader>rs',
      --   [[<cmd>lua require("sniprun").run()<CR>]],
      --   { expr = true, noremap = true, silent = true }
      -- )
      vim.keymap.set(
        { 'v' },
        '<localleader>rs',
        [[<cmd>lua require("sniprun").run("v")<cr>]],
        { expr = true, noremap = true, buffer = vim.api.nvim_get_current_buf() }
      )
      vim.keymap.set(
        'n',
        '<F8>',
        ":let b:caret=winsaveview()<CR>| :%SnipRun<CR>| :call winrestview(b:caret)<CR>",
        {  buffer = 0, expr = true }
      )
      vim.keymap.set(
        'n',
        '<F9>',
        [[<cmd>SnipClose<CR>]],
        { silent = true }
      )
      vim.keymap.set(
        'n',
        '<F10>',
        [[<cmd>SnipReset<CR>]],
        { noremap = true, silent = true, buffer = vim.api.nvim_get_current_buf() }
      )

      -- local wk = require('which-key')
      -- wk.register {
      --   ['<localleader>r'] = {
      --     name = '+SnipRun',
      --     s = { { { function() require('sniprun').run('v') end, 'SnipRun' }, mode = { 'v' } } },
      --     v = { { { "<cmd>'<'><Plug>(SnipRun)<CR>", 'SnipRun' }, mode = { 'v' } } },
      --   },
      --   -- ['<F2>'] = {
      --   --   vim.cmd([[:b:caret=winsaveview()<CR>|<cmd>%SnipRun<CR>|call winrestview(b:caret)<CR>]]),
      --   --   'Run buffer',
      --   --   -- silent = true,
      --   --   expr = true,
      --   -- },
      --   ['<F3>'] = { [[<cmd>SnipClose<CR>]], 'SnipClose', noremap = true, silent = true },
      --   ['<F4>'] = { [[<cmd>SnipReset<CR>]], 'SnipReset', noremap = true, silent = true },
      -- }
    end,
  },
}
