vim.bo.tw = 85
vim.opt_local.formatoptions:append { 't' }

vim.api.nvim_create_user_command('NorgOtter', function()
  require('quarto').activate()
  local b = vim.api.nvim_get_current_buf()
  local function set(lhs, rhs) vim.api.nvim_buf_set_keymap(b, 'n', lhs, rhs, { silent = false, noremap = true }) end

  set('gd', ":lua require('otter').ask_definition()<CR>")
  set('gt', ":lua require('otter').ask_type_definition()<CR>")
  set('H', ":lua require('otter').ask_hover()<CR>")
  set('<leader>rn', ":lua require('otter').ask_rename()<CR>")
  set('gr', ":lua require('otter').ask_references()<CR>")
  set('gs', ":lua require('otter').ask_document_symbols()<CR>")
  set('<leader>rf', ":lua require('otter').ask_format()<CR>")
end, {})
