--@diagnostic disable: unused-function, undefined-doc-name, undefined-field, param-type-mismatch
if not eo then return end

local augroup = eo.augroup
local lsp, fn, api, fmt = vim.lsp, vim.fn, vim.api, string.format
local diagnostic = vim.diagnostic
local L, S = vim.lsp.log_levels, vim.diagnostic.severity
local M = vim.lsp.protocol.Methods

table.unpack = table.unpack or unpack

----------------------------------------------------------------------------------------------------
--  Related Locations
----------------------------------------------------------------------------------------------------
-- This relates to:
-- 1. https://github.com/neovim/neovim/issues/19649#issuecomment-1327287313
-- 2. https://github.com/neovim/neovim/issues/22744#issuecomment-1479366923
-- neovim does not currently correctly report the related locations for diagnostics.
-- TODO: once a PR for this is merged delete this workaround

local function show_related_locations(diag)
  local related_info = diag.relatedInformation
  if not related_info or #related_info == 0 then return diag end
  for _, info in ipairs(related_info) do
    diag.message = ('%s\n%s(%d:%d)%s'):format(
      diag.message,
      fn.fnamemodify(vim.uri_to_fname(info.location.uri), ':p:.'),
      info.location.range.start.line + 1,
      info.location.range.start.character + 1,
      not eo.falsy(info.message) and (': %s'):format(info.message) or ''
    )
  end
  return diag
end

local handler = lsp.handlers[M.textDocument_publishDiagnostics]

---@diagnostic disable-next-line: duplicate-set-field
lsp.handlers[M.textDocument_publishDiagnostics] = function(err, result, ctx, config)
  result.diagnostics = vim.tbl_map(show_related_locations, result.diagnostics)
  handler(err, result, ctx, config)
end

lsp.handlers['textDocument/hover'] = lsp.with(lsp.handlers.hover, { border = 'rounded' })
lsp.handlers['textDocument/signatureHelp'] = lsp.with(lsp.handlers.signature_help, { border = 'rounded' })

lsp.handlers['window/logMessage'] = function(_, result)
  local msg = result.message
  if type(msg) == 'table' then msg = vim.inspect(msg) end
  if type(msg) == 'string' then vim.notify(msg, 'info', { title = 'LSP' }) end
end

lsp.handlers['window/logMessage'] = function(_, content, _)
  if content.type == 3 then
    if content.message:find('pythonPath') then vim.notify(content.message) end
  end
end

--[[ from stevearc/dotfiles/blob/master/config/nvim/lua/plugins/lsp.lua ]]
lsp.handlers["window/showMessage"] = function(_err, result, context, _config)
  local client_id = context.client_id
  local msg_type = result.type
  local msg = result.message
  local client = lsp.get_client_by_id(client_id)
  local client_name = client and client.name or fmt("id=%d", client_id)
  if not client then
    vim.notify("LSP[" .. client_name .. "]: client has shut down after sending the message", vim.log.levels.ERROR)
  end
  if msg_type == lsp.protocol.MessageType.Error then
    vim.notify("LSP[" .. client_name .. "]: " .. msg, vim.log.levels.ERROR)
  else
    local msg_type_name = lsp.protocol.MessageType[msg_type]
    local map = {
      Error = vim.log.levels.ERROR,
      Warning = vim.log.levels.WARN,
      Info = vim.log.levels.INFO,
      Log = vim.log.levels.DEBUG,
    }
    -- the entire point to override this handler is so that this uses vim.notify instead of api.nvim_out_write
    vim.notify(fmt("LSP[%s] %s\n", client_name, msg), map[msg_type_name])
  end
  return result
end

---Setup mapping when an lsp attaches to a buffer
---@param client vim.lsp.Client
---@param bufnr integer
local function setup_mappings(client, bufnr)
  local mappings = {
    { 'n', ']d', function() diagnostic.jump { count = -1, float = true } end, desc = 'go to prev diagnostic' },
    { 'n', '[d', function() diagnostic.jump { count = 1, float = true } end, desc = 'go to next diagnostic' },
    -- { { 'n', 'x' }, '<leader>ca', lsp.buf.code_action, desc = 'code action', capability = M.textDocument_codeAction },
    { 'n', '<leader>ca', lsp.buf.code_action, desc = 'code action', capability = M.textDocument_codeAction },
    {
      'v',
      '<leader>ca',
      "<cmd>'<,'>lua vim.lsp.buf.code_action()<CR>",
      desc = 'code action',
      capability = M.textDocument_codeAction,
    },
    { 'n', 'gd', lsp.buf.definition, desc = 'def', capability = M.textDocument_definition },
    -- { 'n', 'gD', lsp.buf.type_definition, desc = 'type def', capability = M.textDocument_typeDefinition },
    { 'n', 'gr', lsp.buf.references, desc = 'ref', capability = M.textDocument_references },
    { 'n', 'gI', lsp.buf.incoming_calls, desc = 'incoming calls', capability = M.textDocument_prepareCallHierarchy },
    { 'n', 'gi', lsp.buf.implementation, desc = 'implementation', capability = M.textDocument_implementation },
    -- stylua: ignore start
    -- { 'n', '<leader>gd', lsp.buf.type_definition, desc = 'go to type definition', capability = M.textDocument_definition },
    -- stylua: ignore end
    { 'n', '<leader>cl', lsp.codelens.run, desc = 'run code lens', capability = M.textDocument_codeLens },
    {
      'n',
      '<leader>ci',
      function()
        -- local enabled = lsp.inlay_hint.is_enabled(0)
        -- lsp.inlay_hint.enable(0, not enabled)
        lsp.inlay_hint.enable(not lsp.inlay_hint.is_enabled { nil })
      end,
      desc = 'inlay hints toggle',
      M.textDocument_inlayHint,
    },
    { 'n', '<leader>ri', lsp.buf.rename, desc = 'rename', capability = M.textDocument_rename },
    --[[ unsure if this will work, but worth a shot. May conflict with conform...]]
    {
      'v',
      '=',
      function()
        local start_row, _ = table.unpack(api.nvim_buf_get_mark(0, '<'))
        local end_row, _ = table.unpack(api.nvim_buf_get_mark(0, '>'))
        vim.lsp.buf.format {
          range = {
            ['start'] = { start_row, 0 },
            ['end'] = { end_row, 0 },
          },
          async = true,
        }
      end,
      desc = 'visual format',
      silent = true,
      capability = M.textDocument_rangeFormatting,
    },
  }

  vim.iter(mappings):each(function(m)
    if
      (not m.exclude or not vim.tbl_contains(m.exclude, vim.bo[bufnr].ft))
      and (not m.capability or client.supports_method(m.capability))
    then
      map(m[1], m[2], m[3], { buffer = bufnr, desc = fmt('lsp: %s', m.desc) })
    end
  end)
end

---@alias ClientOverrides {on_attach: fun(client: vim.lsp.Client, bufnr: number), semantic_tokens: fun(bufnr: number, client: vim.lsp.Client, token: table)}

--- A set of custom overrides for specific lsp clients
--- This is a way of adding functionality for specific lsps
--- without putting all this logic inthe general on_attach function
---@type {[string]: ClientOverrides}
local client_overrides = {
  tsserver = {
    semantic_tokens = function(bufnr, client, token)
      if token.type == 'variable' and token.modifiers['local'] and not token.modifiers.readonly then
        lsp.semantic_tokens.highlight_token(token, bufnr, client.id, '@danger')
      end
    end,
  },
}

-----------------------------------------------------------------------------//
-- Autocommands
-----------------------------------------------------------------------------//

---@param client lsp.Client
---@param buf integer
local function setup_autocommands(client, buf)
  if client.supports_method(M.textDocument_codeLens) then
    augroup(('LspCodeLens%d'):format(buf), {
      event = { 'BufEnter', 'InsertLeave', 'BufWritePost' },
      desc = 'LSP: Code Lens',
      buffer = buf,
      -- call via vimscript so that errors are silenced
      command = 'silent! lua vim.lsp.codelens.refresh()',
    })
  end

  if client.supports_method(M.textDocument_inlayHint, { bufnr = buf }) then
    vim.lsp.inlay_hint.enable(true, { bufnr = buf })
  end

  if client.supports_method(M.textDocument_documentHighlight) then
    augroup(('LspReferences%d'):format(buf), {
      event = { 'CursorHold', 'CursorHoldI' },
      buffer = buf,
      desc = 'LSP: References',
      command = function() lsp.buf.document_highlight() end,
    }, {
      event = 'CursorMoved',
      desc = 'LSP: References Clear',
      buffer = buf,
      command = function() lsp.buf.clear_references() end,
    })
  end
end

-- Add buffer local mappings, autocommands etc for attaching servers
-- this runs for each client because they have different capabilities so each time one
-- attaches it might enable autocommands or mappings that the previous client did not support
---@param client lsp.Client the lsp client
---@param bufnr number
local function on_attach(client, bufnr)
  setup_autocommands(client, bufnr)
  setup_mappings(client, bufnr)
  -- setup_semantic_tokens(client, bufnr)
end

augroup('LspSetupCommands', {
  event = 'LspAttach',
  desc = 'setup the lsp autocommands',
  command = function(args)
    local client = lsp.get_client_by_id(args.data.client_id)
    if not client then return end
    on_attach(client, args.buf)
    local overrides = client_overrides[client.name]
    if not overrides or not overrides.on_attach then return end
    overrides.on_attach(client, args.buf)
  end,
}, {
  event = 'DiagnosticChanged',
  desc = 'Update the diagnostic locations',
  command = function(args)
    diagnostic.setloclist { open = false }
    if #args.data.diagnostics == 0 then vim.cmd('silent! lclose') end
  end,
})

-----------------------------------------------------------------------------//
-- Handler Overrides
-----------------------------------------------------------------------------//
-- This section overrides the default diagnostic handlers for signs and virtual text so that only
-- the most severe diagnostic is shown per line

--- The custom namespace is so that ALL diagnostics across all namespaces can be aggregated
--- including diagnostics from plugins
local ns = api.nvim_create_namespace('severe-diagnostics')

--- Restricts nvim's diagnostic signs to only the single most severe one per line
--- see `:help vim.diagnostic`
---@param callback fun(namespace: integer, bufnr: integer, diagnostics: table, opts: table)
---@return fun(namespace: integer, bufnr: integer, diagnostics: table, opts: table)
local function max_diagnostic(callback)
  return function(_, bufnr, diagnostics, opts)
    local max_severity_per_line = vim.iter(diagnostics):fold({}, function(diag_map, d)
      local m = diag_map[d.lnum]
      if not m or d.severity < m.severity then diag_map[d.lnum] = d end
      return diag_map
    end)
    callback(ns, bufnr, vim.tbl_values(max_severity_per_line), opts)
  end
end

local signs_handler = diagnostic.handlers.signs
diagnostic.handlers.signs = vim.tbl_extend('force', signs_handler, {
  show = max_diagnostic(signs_handler.show),
  hide = function(_, bufnr) signs_handler.hide(ns, bufnr) end,
})

-----------------------------------------------------------------------------//
-- Diagnostic Configuration
-----------------------------------------------------------------------------//

local max_width = math.min(math.floor(vim.o.columns * 0.7), 100)
local max_height = math.min(math.floor(vim.o.lines * 0.3), 30)

-----------------------------------------------------------------------------//
-- Signs
-----------------------------------------------------------------------------//
diagnostic.config {
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  jump = { float = true },
  signs = {
    severity = { min = S.WARN },
    text = {
      [S.WARN] = ' ',
      [S.INFO] = ' ',
      [S.HINT] = '󰌶',
      [S.ERROR] = '✗',
    },
    linehl = {
      [S.WARN] = 'DiagnosticSignWarnLine',
      [S.INFO] = 'DiagnosticSignInfoLine',
      [S.HINT] = 'DiagnosticSignHintLine',
      [S.ERROR] = 'DiagnosticSignErrorLine',
    },
  },
  virtual_text = true and {
    severity = { min = S.WARN },
    spacing = 4,
    prefix = function(d) local level = diagnostic.severity[d.severity] end,
  },
  float = {
    max_width = max_width,
    max_height = max_height,
    border = 'rounded',
    title = { { '  ', 'DiagnosticFloatTitleIcon' }, { 'Problems  ', 'DiagnosticFloatTitle' } },
    focusable = false,
    -- header = '',
    -- scope = 'cursor',
    -- source = 'if_many',
    source = true,
    -- from willothy/nvim-config/blob/main/lua/configs/lsp/lspconfig.lua
    header = setmetatable({}, {
      __index = function(_, k)
        local arr = {
          fmt(
            'Diagnostics: %s %s',
            require('nvim-web-devicons').get_icon_by_filetype(vim.bo.filetype),
            vim.bo.filetype
          ),
          'Title',
        }
        return arr[k]
      end,
    }),
  },
}
