local fn, optl = vim.fn, vim.opt_local

-- enable ts highlight on vim help [vimdoc]
-- if fn.has('nvim-0.9.0') > 0 then vim.treesitter.start() end
if vim.version().minor >= 9 then vim.treesitter.start() end

-- buffer local options (even if not opened via :help)
optl.colorcolumn = '79'
-- helptags can include chars like '-', '.', '(', ')'
optl.iskeyword:append { '-', '.', '(', ')' }
vim.wo.conceallevel = 0

--- [[ Keymap ]]
-- make navigation and jump within helpdoc easier
local nbufmap = function(lhs, rhs) vim.keymap.set('n', lhs, rhs, { buffer = true, nowait = true }) end
nbufmap('gd', '<C-]>')
nbufmap('<CR>', '<C-]>')
nbufmap('<C-[>', '<C-o>')

---[[ helpful.vim ]]
--- automatically show :HelpfulVersion information as the cursor is moved
--- and as soon as we enter the buffer for the first time
--- (Note: dont use b:helpful = 1 because we want to control autocmd on our own)
-- vim.cmd([[
--   augroup helpful_auto
--     autocmd! * <buffer>
--     autocmd CursorMoved <buffer> call helpful#cursor_word()
--   augroup END
-- ]])
