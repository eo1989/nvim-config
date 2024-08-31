-- local cmd = vim.api.nvim_buf_create_user_command

-- vim.opt_local.conceallevel = 0
vim.wo.conceallevel = 0

-- local ok, quarto = pcall(require, 'quarto')
-- if ok then quarto.activate() end

-- vim.keymap.set({ 'o', 'x' }, 'il', "<cmd>lua require('various-textobjs').mdlink('inner')<CR>", { buffer = true })
-- vim.keymap.set({ 'o', 'x' }, 'al', "<cmd>lua require('various-textobjs').mdlink('outer')<CR>", { buffer = true })

vim.api.nvim_buf_create_user_command(0, 'MDRun', function()
  local current_file = vim.fn.expand('%:p')
  if vim.fn.expand('%:e') == 'md' then
    vim.fn.system('inlyne ' .. current_file)
  else
    vim.notify("This isn't a markdown file", vim.log.levels.WARN, {})
  end
end, {})
