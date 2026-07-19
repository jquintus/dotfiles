# dotfiles

Syncing my dotfiles. I'm primarily using https://jooooel.com/sync-dotfiles-using-git/ as my guide

All the dotfiles start with an underscore so that they aren't hidden when I'm in the repo. This makes `ls` work a lot nicer.

To install the dotfiles, simply link them. The easiest way is to use the install script.

```bash
./scripts/install-mac.sh
```

The one-to-one symlinks are declared in `scripts/links.manifest` (a
`source | target | description` table), which the install script loops over.
To add a config, add a line to the manifest instead of editing the script.
`bin/*` is linked by a glob so new scripts there are picked up automatically.

# macOS system defaults

`install-mac.sh` only symlinks dotfiles. System preferences (`defaults write`)
live in a separate script so linking never mutates OS state. Run it explicitly
on a new machine (safe to re-run; each setting is idempotent):

```bash
./scripts/macos-defaults.sh
```

Some changes require a logout/restart to take effect.

# App user configs (VS Code, Claude Code)

Some apps keep their user config outside `$HOME` (e.g. under `Application
Support`). Those live in their own repo dirs and are symlinked into place by
`install-mac.sh`:

| Repo dir              | Symlinked to                                                  |
| --------------------- | ------------------------------------------------------------- |
| `vscode/settings.json` | `~/Library/Application Support/Code/User/settings.json`      |
| `claude/settings.json` | `~/.claude/settings.json`                                     |

Because they're symlinks, editing the app's settings (via its UI or by hand)
writes **straight back to this repo**. So after changing a setting, remember to
`git commit && git push` here — the diff shows up under `vscode/` or `claude/`.

Note: the Claude source dir is `claude/`, **not** `.claude/`, on purpose — a
`.claude/settings.json` would be read as *project* settings whenever Claude runs
in this repo (double-registering hooks). Keep it as `claude/`.

# Vim & Neovim plugins

The install script symlinks both configs (`~/.vimrc` and `~/.config/nvim/init.lua`),
but plugins are managed separately. Each editor uses a different plugin manager, and
both auto-bootstrap the manager on first launch.

## Vim (vim-plug)

```bash
# Installs vim-plug automatically if missing, then installs all plugins
vim +PlugInstall +qall
```

Or open `vim` and run `:PlugInstall`.

## Neovim (Packer)

Packer auto-clones itself on the first launch, so this is a three-step dance:

```bash
nvim        # 1. prints "Installing packer.nvim..." and clones it, then quit
nvim        # 2. reopen so packer is on the runtime path
            # 3. run :PackerSync inside nvim to install/sync all plugins
```

> Note: `neo-vim/int.lua` hardcodes the repo path (`/Users/jq/dotfiles/neo-vim/lua`),
> so the Neovim config will break if the repo is moved.

# Homebrew packages

The `Brewfile` is a snapshot of all installed Homebrew taps, formulae, casks, and Mac App Store apps.

```bash
# Install everything from the Brewfile (e.g. on a new machine)
brew bundle install

# Re-snapshot after installing/removing packages
brew bundle dump --force

# Check whether all Brewfile entries are installed
brew bundle check

# Show installed packages NOT in the Brewfile (add --force to uninstall them)
brew bundle cleanup
```

# Links to consider

- [Tons of git aliases to add](https://kapeli.com/cheat_sheets/Oh-My-Zsh_Git.docset/Contents/Resources/Documents/index)
- [Yet another dotfiles manager](https://yadm.io/)

# Applications installed 

```bash
ls /Applications /Applications/Utilities 2>/dev/null >> README.md
```
* /Applications
  * 1Password
  * Alfred 5
  * AltTab
  * Amphetamine
  * Bear
  * ChatGPT
  * Claude
  * cmux
  * ColorSlurp
  * Commander One
  * Cryptomator
  * Cursor
  * Docker
  * Ghostty
  * Granola
  * Itsycal
  * Karabiner-Elements
  * Keynote
  * logioptionsplus
  * Maccy
  * MacVim
  * Magnet
  * Monosnap
  * Mouse Glide
  * Obsidian
  * OneDrive
  * OrbStack
  * Rectangle
  * Shottr
  * Slack
  * Spotify
  * Utilities
  * Whatsapp
  * Wispr Flow
* /Applications/Utilities:
  * Logi Options+ Driver Installer.bundle
  * LogiPluginService
  * MB-EngineHostApp-NCEP
