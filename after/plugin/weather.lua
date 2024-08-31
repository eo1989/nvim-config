local fmt = string.format
local win, buf
local M = {}

M.config = {
  city = '',
  win_height = math.ceil(vim.o.lines * 0.6 - 18),
  win_width = math.ceil(vim.o.columns * 0.3 - 20),
}

-- encode params
local function encode(param)
  local function char_to_hex(c) return fmt('%%%02X', string.byte(c)) end

  if param == nil then return end
  param = param:gsub('\n', '\r\n')
  param = param:gsub('([^%w ])', char_to_hex)
  param = param:gsub(' ', '+')
  return param
end

local function create_window()
  local win_height = M.config.win_height
  local win_width = M.config.win_width
  local xpos = 1
  local ypos = vim.o.columns - win_width

  local win_opts = {
    style = 'minimal',
    relative = 'editor',
    width = win_width,
    height = win_height,
    row = xpos,
    col = ypos,
    border = 'single',
  }

  -- create preview buffer and set local options
  buf = vim.api.nvim_create_buf(false, true)
  win = vim.api.nvim_open_win(buf, true, win_opts)

  -- creat mapping
  vim.keymap.set('n', 'q', M.close_window, { noremap = true, silent = true })

  -- kill buffer on close
  ---@diagnostic disable: deprecated --[[ TODO: atleast for now ]]
  vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
  vim.api.nvim_win_set_option(win, 'winblend', 80)
  -- vim.api.nvim_set_option_value({ 'winblend' }, { win }, { scope = 'local', win = win })
end

function M.show_weather(city_args)
  local city = city_args ~= '' and city_args or M.config.city
  city = encode(city)

  local cmd = fmt("curl https://wttr.in/%s'?'0", city)
  create_window()
  vim.fn.termopen(command)
end

-- closes floating window
function M.close_window() vim.api.nvim_win_close(win, true) end

function M.setup(config)
  if vim.version().minor < 7 then
    vim.api.nvim_err_writeln('weather.nvim: needs nvim 0.7 or higher')
    return
  end

  M.config = vim.tbl_extend('force', M.config, config or {})

  -- create :weather command
  vim.api.nvim_create_user_command('Weather', function(params) M.show_weather(params.args) end, { nargs = '*' })
end

return M
