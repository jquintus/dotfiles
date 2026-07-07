# dotfiles

Syncing my dotfiles. I'm primarily using https://jooooel.com/sync-dotfiles-using-git/ as my guide

All the dotfiles start with an underscore so that they aren't hidden when I'm in the repo. This makes `ls` work a lot nicer.

To install the dotfiles, simply link them. The easiest way is to use the install script.

```bash
./scripts/install-mac.sh
```

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
