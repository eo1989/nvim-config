return {
  {
    'L3MON4D3/LuaSnip',
    enabled = true,
    version = 'v2.*',
    event = 'InsertEnter',
    build = 'make install_jsregexp',
    dependencies = { 'rafamadriz/friendly-snippets' },
    config = function()
      local ls = require('luasnip')
      local types = require('luasnip.util.types')
      local extras = require('luasnip.extras')
      local fmt = require('luasnip.extras.fmt').fmt
      ls.setup {
        loaders_store_source = true,
        keep_roots = true,
        link_roots = false,
        link_children = false,
        enable_autosnippets = true,
        store_selection_keys = '<Tab>',
        update_events = 'InsertLeave',
        -- region_check_events = 'CursorMoved', -- prevent <tab> from jumping back to a snippet after its left
        region_check_events = { 'CursorMoved', 'CursorHold', 'InsertEnter' },
        -- delete_check_events = { 'TextChanged', 'InsertEnter' },
        delete_check_events = 'InsertEnter',
        -- ft_func = require('extras').filetype_functions.from_pos_or_filetype,
        -- ft_func = require('luasnip.extras.filetype_functions').from_cursor_pos,
        -- specifically from akinsho.
        ext_opts = {
          [types.choiceNode] = {
            active = {
              hl_mode = 'combine',
              virt_text = { { '●', 'Operator' } },
            },
          },
          [types.insertNode] = {
            active = {
              hl_mode = 'combine',
              virt_text = { { 'λ', 'Type' } },
            },
          },
        },
        snip_env = {
          fmt = fmt,
          m = extras.match,
          t = ls.text_node,
          f = ls.function_node,
          c = ls.choice_node,
          d = ls.dynamic_node,
          i = ls.insert_node,
          l = extras.lambda,
          snippet = ls.snippet,
        },
      }

      require('luasnip.loaders.from_vscode').lazy_load()
      require('luasnip.loaders.from_lua').lazy_load()
      require('luasnip.loaders.from_lua').lazy_load { paths = vim.fn.stdpath('config') .. '/luasnippets' }
      ls.filetype_extend('quarto', { 'markdown' })

      vim.api.nvim_create_user_command(
        'LuaSnipEdit',
        function() require('luasnip.loaders.from_lua').edit_snippet_files() end,
        {}
      )

      -- map({ 's', 'i' }, '<C-l>', function()
      --   if ls.choice_active() then
      --     ls.change_choice(1) -- else
      --     --   require('tab').tab()
      --   end
      -- end)

      map({ 's', 'i' }, '<C-j>', function()
        if not require('luasnip').expand_or_jumpable() then
          return '<Tab>'
          -- else
          --   require('tab').tab()
        end
        require('luasnip').expand_or_jump()
      end, { expr = true })

      map({ 's', 'i' }, '<C-h>', function()
        if not require('luasnip').jumpable(-1) then
          return '<S-Tab>'
          -- else
          --   require('tab').tab()
        end
        require('luasnip').jump(-1)
      end, { expr = true })
    end,
  },
}
