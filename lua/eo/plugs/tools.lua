local api, fs, fmt, uv = vim.api, vim.fs, string.format, vim.uv
local config = vim.env.HOME .. '/.config'
return {
  {
    'stevearc/conform.nvim',
    cmd = { 'ConformInfo', 'LspAttach' },
    -- from stevearc/dotfiles/blob/master/.config/nvim/lua/plugins/format.lua
    -- && LazyVim/LazyVim/blob/main/lua/lazyvim/plugins/formatting.lua
    init = function() vim.o.formatexpr = "v:lua.require'conform'.formatexpr()" end,
    keys = {
      {
        '=',
        function()
          require('conform').format({ async = true, lsp_fallback = 'fallback' }, function(err)
            if not err then
              if vim.startswith(api.nvim_get_mode().mode:lower(), 'v') then
                api.nvim_feedkeys(api.nvim_replace_termcodes('<Esc>', true, false, true), 'n', true)
              end
            end
          end)
        end,
        mode = '',
        desc = 'Format Buffer',
      },
      { '<leader>rf', '<cmd>lua require("conform").format()<CR>', desc = '[rf]ormat' },
    },
    opts = {
      format = {
        timeout_ms = 500,
        async = true,
        quiet = false,
      },
      notify_on_error = true,
      notify_no_formatters = true,
      log_level = vim.log.levels.ERROR,
      -- format_after_save = { lsp_format = 'fallback' },
      default_format_opts = {
        lsp_format = 'fallback',
      },
      format_on_save = { lsp_format = 'fallback', timeout_ms = 500 },
      formatters_by_ft = {
        lua = { 'stylua' },
        -- ['python'] = function(bufnr)
        --   if require('conform').get_formatter_info('ruff_format', bufnr).available then
        --     return { 'ruff_format' }
        --   else
        --     return { 'black' }
        --   end
        -- end,
        python = { { 'ruff_fix', 'ruff_format' }, 'black' },
        ['yaml'] = { 'yamlfmt', 'prettier', 'yq' },
        ['json'] = { 'jq', 'dprint', 'prettier' },
        markdown = { { 'injected' }, 'markdownlint-cli2' },
        quarto = { 'injected' },
        -- ['norg'] = { { 'injected' }, 'dprint' },
        ['sh'] = { 'shfmt' },
        ['zsh'] = { 'shfmt' },
        -- pgsql = { { 'pg_format', 'sqlfluff' } },
        ['sql'] = { 'sql_formatter', 'sqlfmt', 'sqlfluff' },
        ['toml'] = { 'taplo' },
        ['_'] = { 'trim_whitespace', 'trim_newlines', 'squeeze_blanks' },
        -- ['*'] = { 'trim_whitespace' },
      },
      formatters = {
        injected = {
          options = {
            ignore_errors = false,
            -- map of ts lang to file extension
            -- temp file name with this extension will be generated during formatting
            -- because some formatters care about the filename
            lang_to_ext = {
              bash = 'sh',
              c_sharp = 'cs',
              julia = 'jl',
              latex = 'tex',
              markdown = 'md',
              -- quarto = 'py',
              python = 'py',
              ruby = 'rb',
              rust = 'rs',
              teal = 'tl',
              r = 'r',
            },
            -- map of ts lang to formatters to use
            -- (defaults to the value from formatters_by_ft)
            lang_to_formatters = {},
          },
        },
        stylua = {
          args = { '--config-path', config .. '/nvim/stylua.toml', '-' },
        },
        dprint = {
          condition = function(ctx)
            return fs.find({ 'dprint.json', 'dprint.toml' }, {
              upward = true,
              path = ctx.filename,
              stop = uv.os_homedir(),
            })[1]
          end,
        },
        shfmt = {
          args = { '-i', '4', '-ci' },
        },
      },
    },
  },
  {
    'mfussenegger/nvim-lint',
    -- event = { 'BufReadPost', 'BufNewFile', 'BufWritePre' },
    init = function()
      api.nvim_create_autocmd({ 'BufReadPost', 'BufWritePost' }, {
        callback = function(args)
          if args.file:match('/(node_modules|__pypackages__|site_packages)/') then return end
          if not vim.g.large_file then require('lint').try_lint() end
        end,
        group = api.nvim_create_augroup('nvim-lint', { clear = true }),
      })
    end,
    config = function()
      local lint = require('lint')
      lint.linters_by_ft = {
        python = { 'ruff' },
        markdown = { 'markdownlint_cli2' },
        sql = { 'sqlfluff' },
        yaml = { 'yamllint' },
      }
      lint.linters = {
        zsh = {
          -- cmd = 'zsh',
          args = { '-n' },
        },
        ruff = {
          -- cmd = 'ruff',
          -- args = { 'lint' },
          args = function() return fmt('--config=%s/ruff/ruff.toml', config) end,
        },
        -- flake8 = {
        --   cmd = 'flake8',
        --   args = function() return fmt('--config=%s/flake8'), config end,
        -- },
        sqlfluff = {
          cmd = 'sqlfluff',
          pre_args = { '--dialect', 'ansi' },
          args = { 'lint' },
        },
        markdownlint = {
          cmd = 'markdownlint',
          args = function() return fmt('--config=%s/nvim/markdownlint.yaml', config) end,
        },
        markdownlint_cli2 = {
          cmd = 'markdownlint-cli2',
          args = function() return fmt('--config=%s/markdownlint-cli2/.markdownlint-cli2.jsonc', config) end,
        },
        yamllint = {
          env = { 'YAMLLINT_CONFIG_FILE' },
          args = function() return fmt('-c=%s/yamllint/config', config) end,
        },
        -- ruff = {
        --   cmd = 'ruff check',
        --   args = {
        --     function(ctx) return fs.find({ 'ruff.toml', 'pyproject.toml' }, { path = ctx.filename, upward = true })[1] end,
        --   },
        -- },
        -- pflake8 = {
        --   -- name = 'pflake8',
        --   cmd = 'pflake8',
        --   args = {
        --     function()
        --       return fmt('--config=%s/flake8', config)
        --       -- return vim.fs.find({ 'flake8', '.flake8' }, { path = ctx.filename, upward = true })[1]
        --     end,
        --   },
        -- },
      }
    end,
  },
}
