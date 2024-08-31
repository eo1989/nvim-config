local optl = vim.opt_local

vim.cmd([[autocmd! BufEnter <buffer> if winnr('$') < 2 | q | endif]])

optl.scrolloff = 0
optl.wrap = false
optl.number = false
-- optl.relativenumber = false
-- optl.linebreak = true
-- optl.list = true
optl.cursorline = true
optl.spell = false
optl.buflisted = false
optl.signcolumn = 'yes'

map('n', 'dd', eo.list.qf.delete, { desc = 'delete current qf entry', buffer = 0 })
map('v', 'd', eo.list.qf.delete, { desc = 'delete current qf entry', buffer = 0 })
map('n', 'H', ':colder<CR>', { buffer = 0 })
map('n', 'L', ':cnewer<CR>', { buffer = 0 })

-- force qf to open beneath all other splits
vim.cmd.wincmd('J')
eo.adjust_split_height(3, 10)
