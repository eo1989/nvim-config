local api = vim.api
local map = map or vim.keymap.set

--[[ Requirements for linux
https://github.com/3rd/image.nvim?tab=readme-ov-file#requirements
check for dependencies with `:checkhealth kickstart`
needs:
sudo apt install imagemagick
sudo apt install libmagickwand-dev
sudo apt install liblua5.1-0-dev
sudo apt installl luajit
]]

return {
  {
    'https://github.com/leafo/magick',
    build = 'rockspec',
  },
  {
    '3rd/image.nvim',
    ft = { 'markdown', 'quarto' },
    -- dependencies = {
    --   {
    --     'vhyrro/luarocks.nvim',
    --     -- priority = 1001,
    --     opts = { rocks = { 'magick' } },
    --   },
    -- },
    config = function()
      local image = require('image')
      image.setup {
        backend = 'kitty',
        integrations = {
          markdown = {
            enabled = true,
            download_remote_images = false,
            only_render_image_at_cursor = false,
            filetypes = { 'markdown', 'quarto' },
          },
          neorg = {
            enabled = false,
            clear_in_insert_mode = false,
            download_remote_images = false,
            only_render_image_at_cursor = false,
            filetypes = { 'norg' },
          },
        },
        max_width = nil,
        max_height = nil,
        -- max_height_window_percentage = math.huge,
        max_height_window_percentage = nil,
        max_width_window_percentage = 30,
        window_overlap_clear_enabled = true, -- toggles images when windows are overlapped
        window_overlap_clear_ft_ignore = { 'cmp_menu', 'cmp_docs', '' },
        editor_only_render_when_focused = false,
        tmux_show_only_in_active_window = true,
        kitty_method = 'normal',
      }

      local function clear_all_images()
        local bufnr = api.nvim_get_current_buf()
        local images = image.get_images { buffer = bufnr }
        for _, img in ipairs(images) do
          img:clear()
        end
      end

      local function get_image_at_cursor(buf)
        local images = image.get_images { buffer = buf }
        local row = api.nvim_win_get_cursor(0)[1] - 1
        for _, img in ipairs(images) do
          if img.geometry ~= nil and img.geometry.y == row then
            local og_max_height = img.global_state.options.max_height_window_percentage
            img.global_state.options.max_height_window_percentage = nil
            return img, og_max_height
          end
        end
        return nil
      end

      local create_preview_window = function(img, og_max_height)
        local buf = api.nvim_create_buf(false, true)
        local win_width = api.nvim_get_option_value('columns', {})
        local win_height = api.nvim_get_option_value('lines', {})
        local win = api.nvim_open_win(buf, true, {
          relative = 'editor',
          style = 'minimal',
          width = win_width,
          height = win_height,
          row = 0,
          col = 0,
          zindex = 1000,
        })

        map('n', '<ESC>', function()
          api.nvim_win_close(win, true)
          img.global_state.options.max_height_window_percentage = og_max_height
        end, { buffer = buf })
        return { buf = buf, win = win }
      end

      local function handle_zoom(bufnr)
        local img, og_max_height = get_image_at_cursor(bufnr)
        if img == nil then return end

        local preview = create_preview_window(img, og_max_height)
        image.hijack_buffer(img.path, preview.win, preview.buf)
      end

      map('n', '<localleader>io', function()
        local bufnr = api.nvim_get_current_buf()
        handle_zoom(bufnr)
      end, { buffer = true, desc = 'image [o]pen' })

      map('n', '<leader>ic', clear_all_images, { desc = 'image [c]lear' })
    end,
  },
  {
    'HakonHarnes/img-clip.nvim',
    -- event = 'VeryLazy',
    ft = { 'markdown', 'latex', 'quarto' },
    opts = {
      default = {
        dir_path = function() return vim.fn.expand('%:t:r') end,
      },
      filetypes = {
        markdown = {
          url_encode_path = true,
          template = '![$CURSOR]($FILE_PATH)',
          drag_and_drop = {
            download_images = false,
          },
        },
        quarto = {
          url_encode_path = true,
          template = '![$CURSOR]($FILE_PATH)',
          drag_and_drop = {
            download_images = false,
          },
        },
      },
    },
    config = function(opts, _)
      require('img-clip').setup(opts)
      map('n', '<localleader>ii', ':PasteImage<CR>', { desc = 'insert [i]mage from clipboard' })
    end,
  },
}
