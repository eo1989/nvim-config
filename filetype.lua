vim.filetype.add {
  extension = {
    -- lock = 'yaml',
    -- norg = 'norg',
    cconf = 'python',
    plist = 'xml.plist', -- macOS PropertyList files
    -- tex = 'latex',
    zsh = 'sh',
    sh = 'sh', -- force sh-files with zsh-shebang to still get sh as ft
  },
  filename = {
    ['NEOGIT_COMMIT_EDITMSG'] = 'NeogitCommitMessage',
    ['.psqlrc'] = 'conf',
    ['launch.json'] = 'jsonc',
    Podfile = 'ruby',
    Brewfile = 'ruby',
    ['.flake8'] = 'ini',
    ['MANIFEST.in'] = 'pymanifest',
    -- ['config.custom'] = 'sshconfig',
    ['fish_history'] = 'yaml',
    -- ['poetry.lock'] = 'toml',
    -- dsully/nvim/blob/main/filetype.lua ex:
    -- set specific ft to enable ruff_lsp & taplo to attach as lang servers
    ['pyproject.toml'] = 'toml.pyproject',
    ['ruff.toml'] = 'toml.ruff',
    ['.zshrc'] = 'sh',
    ['.zshenv'] = 'sh',
  },
  pattern = {
    ['*Caddyfile*'] = 'caddyfile',
    ['.*/.github/workflows/.*%yaml'] = 'yaml.ghaction',
    ['.*/.github/workflows/.*%yml'] = 'yaml.ghaction',
    ['.*requirements%.in'] = 'requirements',
    ['.*requirements%.txt'] = 'requirements',
    ['.*/%.vscode/.*%.json'] = 'json5', -- stevearc dotfiles -> these json files freq have comments
    ['.*%.conf'] = 'conf',
    ['.*%.theme'] = 'conf',
    ['.*%.gradle'] = 'groovy',
    ['^.env%..*'] = 'bash',
    ['.*aliases'] = 'bash',
    ['README.(a+)$'] = function(_, _, ext)
      if ext == 'md' then
        return 'markdown'
      elseif ext == 'rst' then
        return 'rst'
      end
    end,
  },
}
