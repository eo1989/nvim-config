local fn = vim.fn
local function sync(path) return string.format('%s/notes/%s', vim.fn.expand('$SYNC_DIR'), path) end

return {
  {
    'nvim-neorg/neorg',
    enabled = false,
    -- lazy = false,
    -- event = 'VeryLazy',
    ft = 'norg',
    -- build = ':Neorg sync-parsers',
    dependencies = {
      { 'nvim-lua/plenary.nvim' },
      { 'tamton-aquib/neorg-jupyter' },
      -- { 'laher/neorg-exec' },
      { '3rd/image.nvim' },
    },
    opts = {
      -- local sync = function(path) return string.format('%s/notes/%s', vim.fn.expand('$SYNC_DIR'), path) end
      configure_parsers = true,
      load = {
        ['core.defaults'] = {},
        -- ['core.upgrade'] = {},
        ['core.export'] = {},
        ['core.looking-glass'] = {}, -- enables the looking_glass module
        ['core.esupports.metagen'] = { config = { type = 'auto' } },
        ['external.exec'] = {},
        ['external.jupyter'] = {},
        --[[ add keybindings for
      :Neorg jupyter init
      :Neorg jupyter generate filename.ipynb (gens a neorg file from the provided nb)
      :Neorg jupyter run
      ]]
        -- ['core.integrations.telescope'] = {},
        ['core.integrations.nvim-cmp'] = {},
        ['core.integrations.otter'] = {
          config = {
            auto_start = false,
            languages = { 'python', 'lua', 'julia' },
            keys = {
              hover = 'H',
              definition = 'gd',
              type_definition = 'gt',
              references = 'gr',
              rename = '<leader>rn',
              document_symbols = 'gs',
              format = '<leader>gf',
            },
          },
        },
        ['core.integrations.treesitter'] = { config = { configure_parsers = true } },
        ['core.keybinds'] = {
          config = {
            default_keybinds = true,
            neorg_leader = '<localleader>',
            hook = function(keybinds)
              -- keybinds.unmap('norg', 'n', '<C-s>')
              -- keybinds.map_event('norg', 'n', '<C-b>', 'core.integrations.telescope.find_linkable')
              keybinds.map_event('norg', 'n', '<A-x>', 'magnify-code-block', { buffer = true })
            end,
          },
        },
        ['core.completion'] = { config = { engine = 'nvim-cmp' } },
        ['core.concealer'] = {
          config = {
            icon_preset = 'diamond',
            markup_preset = 'varied',
          },
        },
        ['core.dirman'] = {
          config = {
            workspaces = {
              -- notes = '~/Notes/neorg/notes/',
              notes = fn.expand('$SYNC_DIR/Notes/neorg/notes/'),
              -- tasks = sync('neorg/tasks/'),
              -- work = sync('neorg/work/'),
              dotfiles = fn.expand('$DOTFILES/neorg/'),
            },
            index = 'index.norg',
          },
        },
        ['core.qol.toc'] = {
          config = {
            close_split_on_jump = false,
            toc_split_placement = 'left',
          },
        },
        ['core.journal'] = {
          config = {
            workspace = 'notes',
            journal_folder = 'journal',
            use_folders = true,
          },
        },
      },
    },
  },
}
