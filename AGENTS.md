# AGENTS.md

Context for AI agents working in this repo. Read this before changing anything here.

This is Josh's personal macOS dotfiles repo (`github.com/jquintus/dotfiles`). It is a
solo repo: no collaborators, no review, no CI.

## How the repo is wired

Config is **symlink-based**, not copied. `scripts/install-mac.sh` reads
`scripts/links.manifest` and creates one symlink per line into `$HOME`.

```
scripts/install-mac.sh    symlinks everything; the only install entry point
scripts/links.manifest    pipe-delimited: source | target | description
scripts/macos-defaults.sh every `defaults write` (plus a little nvram/duti)
Brewfile                  packages and casks
bin/                      scripts auto-linked to ~/bin by a glob, NOT in the manifest
TODO.md                   prioritized backlog of config ideas, one chunk per session
cheat.md                  terminal cheat sheet, paged by the `cheat` script in bin/
```

Because they are symlinks, editing a config through an app's own UI writes
**straight back into this repo**. Check `git status` here after changing VS Code
or Claude Code settings.

### Adding a new config file

1. Put the file in the appropriate directory in the repo.
2. Add a line to `scripts/links.manifest`. Easy to forget, and forgetting it
   means the file works on this machine but silently vanishes on a fresh one.
3. Anything dropped in `bin/` is picked up automatically. Do not add it to the
   manifest.

Files that become real dotfiles are named with a leading underscore in the repo
(`_zshrc`, `_gitconfig`, `_tmux.conf`) so they aren't hidden when browsing.

## Conventions that are easy to get wrong

- **Keep Homebrew out of `install-mac.sh`.** Brew is not a guaranteed
  prerequisite when that script runs. Anything depending on brew-installed
  tooling either lives elsewhere or degrades with a warning instead of failing
  (see the `duti` block in `macos-defaults.sh` for the pattern).
- **`claude/`, not `.claude/`, for Claude Code user settings.** A
  `.claude/settings.json` at the repo root would be read as *project* settings
  whenever Claude runs in this repo, double-registering hooks. The real user
  settings live in `claude/settings.json` and are symlinked to
  `~/.claude/settings.json`.
- **`~/.claude` is a real directory, not a symlink.** Tools write generated
  state there. Only authored config gets versioned, file by file.
- **This repo is public, and `claude/CLAUDE.md` is in it.** Work-specific
  content (DirtLabs internals, service topology, internal tool names) must not
  go in the tracked file. It belongs in `~/.claude/CLAUDE.work.md`, which is
  machine-local and pulled back in by an `@`-import at the bottom of
  `claude/CLAUDE.md`.
- **`macos-defaults.sh` is separate from `install-mac.sh` on purpose.** It
  mutates system state, so it is run explicitly. Every setting must be
  idempotent and annotated with where it lives in System Settings.
- **Hammerspoon is one module per feature.** Each module exposes `start()` or
  `bind()`, is required from `hammerspoon/init.lua`, and needs its own manifest
  line.
- **A new binding is not done until it is on the cheat sheet.** Anything that
  adds a keystroke, alias, or command belongs in `cheat.md` in the same commit.
  A binding Josh cannot recall is worth exactly as much as one that was never
  added, and that has already cost real config. `TODO.md` has the longer version
  of this rule. How to write entries there:
  - **One item per bullet.** Never two keystrokes on one line. Bulleted lists
    exist to be scanned, and packing three bindings into a sentence defeats the
    only thing the file is for.
  - **Phrase it as the thing he is trying to do**, not as what the tool is
    called.
  - **Nothing meta.** No preamble explaining what the file is, no maintenance
    instructions, no notes to agents. That content is a distraction to the
    person reading it under time pressure, and it belongs in this file instead.
  - **Only what is easy to forget.** Anything already in daily use is noise, and
    Josh will cut it.
  - **Nothing work-specific**, since this repo is public. Those go in
    `~/.cheat.work.md`, which is machine-local, untracked, and appended
    automatically by the `cheat` script when it exists.
- **Karabiner rewrites its own config and can eat the symlink.** It writes
  `karabiner.json` atomically on any UI change, which replaces the symlink with a
  regular file and silently decouples it from the repo. Prefer editing
  `karabiner/karabiner.json` here by hand. See `karabiner/README.md`.

## Committing

Commit **and** push in the same step (`git push origin main`). It is a solo
backup repo, so an unpushed commit has no upside.

**But do not commit until the change is confirmed to actually work.** For
anything that runs in the live environment (nvim, zsh, cmux, Hammerspoon), a
green headless test is necessary but not sufficient. Leave the edit uncommitted,
tell Josh exactly what to test, and wait for his confirmation. This rule exists
because premature commits previously left `main` full of unverified changes with
no clean revert point.

Commit identity: `Josh Quintus <josh@dirtlabs.ai>`.

## Things no script can do

Permissions and sign-ins are manual and documented in `README.md` under
"Fresh machine setup > step 7". Notably, Hammerspoon needs Accessibility
permission for global hotkeys, plus an Automation grant for Hammerspoon to
control Google Chrome.
