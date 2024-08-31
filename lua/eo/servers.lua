---@diagnostic disable: missing-fields
if not eo then return end
-- local border = eo.ui.current.border
-----------------------------------------------------------------------------//
-- Language servers
-----------------------------------------------------------------------------//
-- local function strsplit(s, delim)
--   local result = {}
--   for match in (s .. delim):gmatch('(.-)' .. delim) do
--     table.insert(result, match)
--   end
--   return result
-- end
-- local function get_qmd_resource()
--   local f = assert(io.popen('quarto --paths', 'r'))
--   local s = assert(f:read('*a'))
--   f:close()
--   return strsplit(s, '\n')[2]
-- end

-- local resources = get_qmd_resource()
-- local lua_libs = vim.api.nvim_get_runtime_file('', true) -- and vim.env.VIMRUNTIME .. '/lua' or vim.env.VIMRUNTIME

-- table.insert(lua_libs, resources .. '/lua-types')
-- table.insert(lua_libs, vim.fn.expand('$VIMRUNTIME/lua'))

-- local runtime_path = vim.split(package.path, ';')
-- table.insert(runtime_path, 'lua/?.lua')
-- table.insert(runtime_path, 'lua/?/init.lua')
-- table.insert(runtime_path, '?.lua')
-- table.insert(runtime_path, '?/init.lua')

-- local lua_plugs = {}

-- if resources == nil then
--   vim.notify_once('quarto not found, lua libs not loaded')
-- else
--   table.insert(runtime_path, resources .. '?/init.lua')
--   table.insert(runtime_path, resources .. 'lua-plugin/plugin.lua')
-- end

local md_root_files = { '.marksman.toml', '_quarto.yml', '.git' }
local util = require('lspconfig.util')

local servers = {
  taplo = {
    init_options = {
      configurationSection = 'evenBetterToml',
      cachePath = vim.NIL,
    },
    root_dir = util.root_pattern('.git', 'Cargo.toml', '~/.config/*'),
  },
  jsonls = {
    on_new_config = function(new_conf)
      -- if require('eo.has')('schemastore.nvim') then
      if vim.has('schemastore.nvim') then
        new_conf.settings.json.schemas = new_conf.settings.json.schemas or {}
        vim.list_extend(new_conf.settings.json.schemas, require('schemastore').json.schemas {})
      end
    end,
    settings = {
      json = {
        -- schemas = function() require('schemastore').json.schemas() end,
        -- schemas = require('schemastore').json.schemas {},
        filetypes = { 'json', 'jsonc', 'json5' },
        validate = { enable = true },
        format = { enable = false },
      },
    },
  },
  marksman = {
    filetypes = { 'markdown', 'quarto' },
    root_dir = vim.fs.dirname(vim.fs.find(md_root_files, { upward = true })[1]),
    -- root_dir = util.root_pattern(unpack(md_root_files)),
  },
  bashls = {
    filetypes = {
      'sh',
      'bash',
      'zsh',
      'env',
    },
    root_dir = util.root_pattern('.git', '.zshrc'),
  },
  julials = {
    single_file_support = true,
    settings = {
      julia = {
        symbolCacheDownload = true,
        enableTelemetry = false,
      },
    },
    on_new_config = function(new_conf, _)
      local julz = fn.expand('~/.julia/environments/nvim-lspconfig/bin/julia')
      local REVISE_LANGSERVER = false
      if REVISE_LANGSERVER then
        new_conf.cmd[5] = (new_conf.cmd[5]):gsub(
          'using LanguageServer',
          'using Revise; using LanguageServer; LanguageServer.USE_REVISE[] = true'
        )
      elseif util.path.is_file(julia) then
        new_conf.cmd[1] = julia
      end
    end,
    root_dir = function(fname)
      -- local util = require('lspconfig.util')
      return util.root_pattern('Project.toml')(fname) or util.find_git_ancestor(fname) or util.path.dirname(fname)
    end,
    on_attach = function(client, bufnr)
      on_attach(client, bufnr)
      -- disable automatic formatexpr since the LS.jl formatter isn't great
      vim.bo[bufnr].formatexpr = ''
    end,
  },
  basedpyright = {
    on_attach = function(client, bufnr)
      client.server_capabilities.hoverProvider = false
      client.server_capabilities.documentFormattingProvider = false
      client.server_capabilities.documentRangeFormattingProvider = false
    end,
    basedpyright = {
      settings = {
        disableLanguageServices = false,
        disableOrganizeImports = true,
        -- completeFunctionParens = true,
        -- autoImportCompletions = false,
        basedpyright = {
          analysis = {
            useLibraryCodeForTypes = true,
            autoSearchPaths = true,
            typeCheckingMode = 'off', -- 'off' | 'basic' | 'standard' | 'strict' | 'all'
            diagnosticMode = 'off',
            diagnosticSeverityOverrides = {
              reportUnusedVariable = 'none',
              reportUnusedCallResult = 'none',
              reportUnusedExpression = 'none',
              reportUnknownMemberType = 'none',
              reportUnknownLambdaType = 'none',
              reportUnknownParameterType = 'none',
              reportMissingParameterType = 'none',
              reportUnknownVariableType = 'none',
              reportUnknownArgumentType = 'none',
              reportImplicitOverride = 'none',
              reportAny = 'none',
            },
          },
        },
      },
    },
  },
  ruff = {
    on_attach = function(client, bufnr)
      client.server_capabilities.hoverProvider = false
      client.server_capabilities.signatureHelpProvider = false
      client.server_capabilities.documentFormattingProvider = true
      client.server_capabilities.documentRangeFormattingProvider = true
    end,
    -- handers = {
    --   -- ['textDocument/hover'] = function(...) end,
    --   ['textDocument/publishDiagnostics'] = function(...) end,
    -- },
    init_options = {
      settings = {
        -- configuration
        loglevel = 'debug',
        logFile = vim.fn.expand('~') .. '/.local/state/nvim/ruff.log',
        organizeImports = true,
        fixAll = true,
        codeAction = { fixViolation = { enable = true } },
        -- args = {
        --   '--extend-select',
        --   'W,C90,UP,ASYNC,S,B,A,COM,C4,DTZ,T10,EXE,ISC,ICN,G,INP,PIE,PYI,PT,RET,SIM,TID,TCH,PL,TRY,PD,NPY,PERF',
        --   '--ignore',
        --   'E40,E50,W29,PLR0913,S101,RET504,RET505,C901,TRY003,F401,F501,PLR0915,COM812,PLR2004,S301,S311,PIE808,B007s,UP039,SIM300,PLR5501,I',
        -- },
      },
    },
  },
  -- jedi_language_server = {
  --   on_attach = function(client, bufnr)
  --     client.server_capabilities.hoverProvider = true
  --     client.server_capabilities.documentFormattingProvider = false
  --     client.server_capabilities.documentRangeFormattingProvider = false
  --   end,
  --   handlers = {
  --     ['textDocument/publishDiagnostics'] = function() end,
  --   },
  --   initializationOptions = {
  --     diagnostics = {
  --       enable = false,
  --       didOpen = false,
  --       didChange = false,
  --       didSave = false,
  --     },
  --     completion = {
  --       disableSnippets = false,
  --       resolveEagerly = true,
  --     },
  --   },
  -- },
  yamlls = {
    settings = {
      yaml = {
        format = { enable = false },
        schemaStore = {
          enable = false,
          url = '',
        },
        schemas = require('schemastore').yaml.schemas {},
      },
    },
  },
  lua_ls = {
    settings = {
      Lua = {
        runtime = {
          version = 'LuaJIT',
          -- plugin = lua_plugin_paths,
        },
        codeLens = { enable = true },
        misc = {},
        hover = { expandAlias = false },
        type = { castNumberToInteger = false },
        hint = {
          enable = true,
          await = true,
          setType = false,
          -- paramType = true,
          paramName = 'Disable', -- 'Disable' | 'Literal'
          -- semicolon = 'Disable',
          arrayIndex = 'Disable', -- show hints ('auto') only when table is >3 items, or tbl is mixed; 'Disable'
        },
        format = { enable = false },
        diagnostics = {
          disable = { 'unused-local', 'trailing-space' },
          globals = {
            'quarto',
            'pandoc',
            'io',
            'string',
            'print',
            'bit',
            'require',
            'table',
            'eo',
            'hs',
            'map',
            'vim',
            'P',
            'describe',
            'it',
            'before_each',
            'after_each',
            'pending',
          },
        },
        completion = {
          autoRequire = false,
          keywordSnippet = 'Disable',
          workspaceWord = false, -- folke -> true
          callSnippet = 'Replace',
          showWord = 'Disable',
        },
        workspace = {
          maxPreload = 100000,
          preloadFileSize = 50000,
          checkThirdParty = false,
          -- library = { lua_libs },
        },
        telemetry = { enable = false },
      },
    },
  },
}

-- overrides for lang server capabilities. these apply to all servers.
local workspace_overrides = {
  workspace = {
    -- PERF: didChangeWatchedFiles is too slow
    -- TODO: remove this when github.com/neovim/neovim/issues/23291#issuecomment-1686709265 is fixed
    didChangeWatchedFiles = { dynamicRegistration = false },
  },
}

-- return function(name)
--@eo razak17/nvim

---Get the configuration for a specific language server
---@param name string?
---@return table<string, any>?
return function(name)
  local config = servers[name] or {}
  if not config then return end
  -- if not config then
  --   vim.notify_once('No LSP config found for ' .. name, vim.log.levels.WARN)
  --   return
  -- end
  if type(config) == 'function' then config = config() end
  local ok, cmp_nvim_lsp = pcall(require, 'cmp_nvim_lsp')
  if ok then config.capabilities = cmp_nvim_lsp.default_capabilities() end
  config.capabilities = vim.tbl_deep_extend('force', config.capabilities, workspace_overrides, {
    textDocument = {
      completion = { completionItem = { snippetSupport = true } },
      foldingRange = { dynamicRegistration = false, lineFoldingOnly = true },
    },
  })
  return config
end
