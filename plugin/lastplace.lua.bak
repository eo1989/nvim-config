if not eo then return end

local fn = vim.fn
local augroup = eo.augroup
-- adapted from akinsho & he adapted from gh repo ethanholz/nvim-lastplace ../blob/main/lua/nvim-lastplace/init.lua
local ignore_bftype = { 'quickfix', 'nofile', 'help', 'terminal' }
local ignore_fttype = { 'gitcommit', 'gitrebase', 'svn', 'hgcommit' }

augroup('LastPlace', {
  event = { 'BufWinEnter', 'FileType' },
  command = function()
    if vim.tbl_contains(ignore_bftype, vim.bo.buftype) then return end

    if vim.tbl_contains(ignore_fttype, vim.bo.filetype) then
      -- reset cursor to first line
      vim.cmd('Normal! gg')
      return
    end

    -- if a line has already been specified on the cmd line, we are done ex: nvim file +num
    if fn.line('.') > 1 then return end

    local last_line = fn.line([['"]])
    local buff_last_line = fn.line('$')
    -- if the last line is set and the less than the last line in the buffer
    if last_line > 0 and last_line <= buff_last_line then
      local win_last_line = fn.line('w$')
      local win_first_line = fn.line('w0')

      -- chk if the last line of the bufr is the same as the win
      if win_last_line == buff_last_line then
        vim.cmd('normal! g`"') -- set line to last line edited
      -- try to center
      elseif buff_last_line - last_line > ((win_last_line - win_first_line) / 2) - 1 then
        vim.cmd('normal! g`"zz')
      else
        vim.cmd([[normal! G'"<c-e>]])
      end
    end
  end,
})
