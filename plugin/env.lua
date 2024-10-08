if not eo then return end
local api, fn, fs = vim.api, vim.fn, vim.fs
local fmt = string.format

local function read_file(file, line_handler)
  for line in io.lines(file) do
    line_handler(line)
  end
end

api.nvim_create_user_command('DotEnv', function()
  local files = fs.find({ '.env', '.envrc' }, {
    upward = true,
    stop = fn.fnamemodify(fn.getcwd(), ':p:h:h'),
    path = fn.expand('%:p:h'),
  })
  if vim.tbl_isempty(files) then return end
  local filename = files[1]
  local lines = {}
  read_file(filename, function(line)
    if #line > 0 then table.insert(lines, line) end
    if not vim.startswith(line, '#') then
      local name, value = unpack(vim.split(line, '='))
      fn.setenv(name, value)
    end
  end)
  local markdown = table.concat(vim.iter({ '', '```sh', lines, '```', '' }):flatten(math.huge):totable(), '\n')
  vim.notify(fmt('Read **%s**\n', filename) .. markdown, 'info', {
    title = 'Nvim Env',
    on_open = function(win)
      local buf = api.nvim_win_get_buf(win)
      if not api.nvim_buf_is_valid(buf) then return end
      api.nvim_set_option_value(buf, 'filetype', 'markdown')
    end,
  })
end, {})
