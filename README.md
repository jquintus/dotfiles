# dotfiles

Syncing my dotfiles. I'm primarily using https://jooooel.com/sync-dotfiles-using-git/ as my guide

All the dotfiles start with an underscore so that they aren't hidden when I'm in the repo. This makes `ls` work a lot nicer.

To install the dotfiles, simply link them. The easiest way is to use the install script.

```bash
./scripts/install-mac.sh
```

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
