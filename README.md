# dotfiles

My personal macOS dotfiles. Originally based on
https://jooooel.com/sync-dotfiles-using-git/

All the dotfiles start with an underscore (`_zshrc`, `_gitconfig`, ...) so they
aren't hidden when browsing the repo. This makes `ls` behave nicely. The install
script maps each one to its real dotted location.

---

# Fresh machine setup

Do these in order. Steps 1-6 get a working machine; step 7 covers the things no
script can do (permissions, sign-ins) and must be done by hand.

## 1. Install the Xcode Command Line Tools

Gives you `git` so you can clone this repo. (Homebrew's installer in step 2 also
triggers this, so you can skip straight to step 2 if you prefer.)

```bash
xcode-select --install
```

## 2. Install Homebrew

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

The installer prints a "Next steps" note telling you to add Homebrew to your
`PATH`. On Apple Silicon that is:

```bash
eval "$(/opt/homebrew/bin/brew shellenv)"
```

Run that now so `brew` works in the current shell. (Once step 5 links `~/.zshrc`
and you open a new terminal, Homebrew is on `PATH` for good.)

## 3. Clone this repo

It must live at `~/dotfiles` (some configs reference that absolute path).

```bash
git clone https://github.com/jquintus/dotfiles ~/dotfiles
cd ~/dotfiles
```

## 4. Install packages and apps

Reads the `Brewfile` in the repo root: CLI tools, casks (GUI apps), and taps.

```bash
brew bundle install
```

Note: the Brewfile has no Mac App Store (`mas`) entries, so App-Store-only apps
are not installed here. Install those by hand from the App Store (see step 7).

## 5. Symlink the dotfiles

Links every config into place. No dependencies beyond bash, so it is safe to run
even before `brew bundle` if you like.

```bash
./scripts/install-mac.sh
```

The one-to-one links are declared in `scripts/links.manifest` (a
`source | target | description` table) that the script loops over. To add a
config later, add a line to the manifest rather than editing the script.
`bin/*` is linked by a glob, so new scripts there are picked up automatically.

Open a new terminal (or `source ~/.zshrc`) after this so the new shell config
takes effect.

## 6. Apply macOS system defaults

Sets system preferences via `defaults write` (key repeat, menu-bar clock
seconds, muted startup chime, disabled F11 Show Desktop, and more). Kept separate
from linking so symlinking never mutates OS state. Idempotent, safe to re-run.
Prompts for `sudo` once (to mute the startup chime, which lives in firmware).

```bash
./scripts/macos-defaults.sh
```

Some changes need a logout or restart to fully take effect.

## 7. Manual steps (no script can do these)

These require clicking through UI, signing in, or granting OS permissions.
There is no way to automate them, so run through the checklist by hand:

- **Sign into 1Password**, then enable any integrations you use (browser
  extension, SSH agent).
- **Authenticate the GitHub CLI:** `gh auth login`. The token lives in
  `gh/hosts.yml`, which is gitignored and machine-local by design, so it is
  never in this repo.
- **Grant Hammerspoon Accessibility permission:** System Settings > Privacy &
  Security > Accessibility > enable Hammerspoon. Required for the global hotkeys
  in `hammerspoon/`.
- **Approve Automation for Hammerspoon -> Google Chrome:** macOS prompts the
  first time a Google Meet hotkey runs. Needed by `hammerspoon/meet.lua`. (The
  matching Chrome-side setting, "Allow JavaScript from Apple Events," is set by
  `macos-defaults.sh` and takes effect on Chrome's next launch.)
- **Install App-Store-only apps** by signing into the App Store and downloading
  them (the Brewfile does not cover these).
- **Install editor plugins** (see "Vim & Neovim plugins" below).
- **Set up machine-local private files** that intentionally live outside this
  repo: `~/.pgpass` and any real DB connection details (see `zsh/_zshrc-aliases`).
- **Optional, per-host shell config:** this machine picks up
  `zsh/_zshrc-<LocalHostName>` if it exists. Find this machine's name with
  `scutil --get LocalHostName`, then create that file for host-specific tweaks.
- **Restart or log out** so firmware/hotkey changes from step 6 fully apply.

---

# Reference

## Homebrew package management

The `Brewfile` is a snapshot of installed Homebrew taps, formulae, and casks.

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

## macOS system defaults

`scripts/macos-defaults.sh` holds every `defaults write` (and a few related
`nvram` / `duti` calls). Each setting is annotated with where it lives in System
Settings. Run it with `./scripts/macos-defaults.sh`; it is idempotent.

## App user configs (VS Code, Claude Code)

Some apps keep their user config outside `$HOME` (e.g. under `Application
Support`). Those live in their own repo dirs and are symlinked into place by
`install-mac.sh`:

| Repo dir               | Symlinked to                                            |
| ---------------------- | ------------------------------------------------------- |
| `vscode/settings.json` | `~/Library/Application Support/Code/User/settings.json` |
| `claude/settings.json` | `~/.claude/settings.json`                               |

Because they're symlinks, editing the app's settings (via its UI or by hand)
writes **straight back to this repo**. So after changing a setting, remember to
`git commit && git push` here. The diff shows up under `vscode/` or `claude/`.

Note: the Claude source dir is `claude/`, **not** `.claude/`, on purpose. A
`.claude/settings.json` would be read as *project* settings whenever Claude runs
in this repo (double-registering hooks). Keep it as `claude/`.

## Vim & Neovim plugins

The install script symlinks both configs (`~/.vimrc` and
`~/.config/nvim/init.lua`), but plugins are managed separately. Each editor uses
a different plugin manager, and both auto-bootstrap the manager on first launch.

### Vim (vim-plug)

```bash
# Installs vim-plug automatically if missing, then installs all plugins
vim +PlugInstall +qall
```

Or open `vim` and run `:PlugInstall`.

### Neovim (Packer)

Packer auto-clones itself on the first launch, so this is a three-step dance:

```bash
nvim        # 1. prints "Installing packer.nvim..." and clones it, then quit
nvim        # 2. reopen so packer is on the runtime path
            # 3. run :PackerSync inside nvim to install/sync all plugins
```

> Note: `neo-vim/int.lua` hardcodes the repo path
> (`/Users/jq/dotfiles/neo-vim/lua`), so the Neovim config will break if the
> repo is moved. This is why step 3 clones to `~/dotfiles`.

## Links to consider

- [Tons of git aliases to add](https://kapeli.com/cheat_sheets/Oh-My-Zsh_Git.docset/Contents/Resources/Documents/index)
- [Yet another dotfiles manager](https://yadm.io/)

## Applications installed

A snapshot of `/Applications` (regenerate with `ls /Applications`):

- 1Password
- Alfred 5
- AltTab
- Amphetamine
- Bear
- ChatGPT
- Claude
- cmux
- ColorSlurp
- Commander One
- Cryptomator
- Cursor
- Docker
- Ghostty
- Granola
- Itsycal
- Karabiner-Elements
- Keynote
- logioptionsplus
- Maccy
- MacVim
- Magnet
- Monosnap
- Mouse Glide
- Obsidian
- OneDrive
- OrbStack
- Rectangle
- Shottr
- Slack
- Spotify
- Whatsapp
- Wispr Flow
