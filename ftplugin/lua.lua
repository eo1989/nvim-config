local options = {
  tabstop = 8,
  textwidth = 100,
  shiftwidth = 2,
  softtabstop = 2,
  autoindent = true,
  expandtab = true,
  -- conceallevel = 2,
  -- foldmethod = "expr", -- indent? syntax?
}
local window_local_only = {
  colorcolumn = '+1',
}
-- smarttab = true,

for k, v in pairs(options) do
  vim.bo[k] = v
end

for k, v in pairs(window_local_only) do
  vim.wo[k] = v
end
-- local ok, mini = pcall(require, "mini.surround")

-- local ts_input = require("mini.surround").gen_spec.input.treesitter
-- vim.b.minisurround_config = {
--   custom_surroundings = {
--     a = {
--       input = { "function%(.-%).-end", "^function%(%)%s?().-()%s?end$" },
--       output = { left = "function() ", right = " end" },
--     },
--   },
-- }
