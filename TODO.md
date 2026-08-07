# Backlog

Config ideas collected on a road trip in August 2026 (videos, blogs, docs, no
computer), consolidated and ordered by payoff per hour of work. Nothing here is
committed to; it is a queue to pull from, one chunk per session.

Each item says where it would land. The repo conventions still apply: a new
config file is not done until it has a line in `scripts/links.manifest`, system
settings go in `scripts/macos-defaults.sh`, and nothing gets committed until it
has been confirmed working in a live shell. See `AGENTS.md`.

Checked against the repo as of the last edit, so items already installed or
already configured have been moved to the bottom instead of left in the list.

---

## Tier 1: daily-driver ergonomics

Highest payoff, lowest risk, and all of it is reversible. The zsh block is one
sitting.

### Zsh keys and options (all in `zsh/_zshrc`)

- [ ] **Edit the command line in nvim.** `autoload -Uz edit-command-line; zle -N
      edit-command-line; bindkey '^X^E' edit-command-line`. Currently unbound.
      The single biggest win in this section for long commands.
- [ ] **Undo on `^_`.** Verified unbound in the live shell right now, despite
      being a stock emacs-keymap binding. Bind `undo` explicitly.
- [ ] **Make `^W` stop at path separators.** Already bound to
      `vi-backward-kill-word`, but `WORDCHARS` is still the default and contains
      `/`, so it eats a whole path instead of one segment. Shrink `WORDCHARS`
      rather than rebinding the key.
- [ ] **Magic space.** `bindkey ' ' magic-space` expands `!!` and `!$` inline as
      you type the space, instead of at execution. Pairs well with the existing
      `HIST_VERIFY`.
- [ ] **`setopt AUTO_CD`.** Bare directory name means cd. Partially retired by
      zoxide below, so decide whether both are wanted.
- [ ] **`setopt NUMERIC_GLOB_SORT`.** Sorts `file2` before `file10`.
- [ ] **Case-insensitive completion.** `zstyle ':completion:*' matcher-list
      'm:{a-zA-Z}={A-Za-z}'`.
- [ ] **`LS_COLORS` applied to completion menus.** `zstyle ':completion:*'
      list-colors ${(s.:.)LS_COLORS}`. Do this together with the eza item so the
      colors come from one source.
- [ ] **`compdef eza ls`** so eza gets ls's completions. Trivial, and only makes
      sense alongside actually adopting eza (below).
- [ ] **Global and suffix aliases.** `alias -g` expands anywhere on the line
      (`alias -g G='| grep'`), `alias -s` binds a file extension to a program
      (`alias -s md=nvim` so `./notes.md` just opens). Currently zero of either
      in `zsh/_zshrc-aliases`. Worth a small curated set, not a pile.
- [ ] **Bind a key to `git commit -am`.** Needs a decision on whether it runs
      immediately or just fills the buffer for editing. `_reload_shell` at
      `zsh/_zshrc:170` is the pattern to copy.

**"What are widgets?"**: a zle widget is a shell function registered with
`zle -N` so it can be bound to a key and manipulate the command line buffer
(`$BUFFER`, `$CURSOR`) rather than just run a command. There is already one in
the repo: `_reload_shell` at `zsh/_zshrc:170`, bound to `^X^R`. Most of the
items above are stock widgets that only need binding.

### Shell tooling

- [ ] **zsh-autosuggestions.** Brewfile plus a source line. Note the repo
      already carries the bracketed-paste workaround for it at `zsh/_zshrc:36`
      with no plugin installed, which suggests it was used before and lost in a
      machine move.
- [ ] **zsh-syntax-highlighting.** Must be sourced last, after all other zle
      setup, or bindings get clobbered.
- [ ] **atuin.** Searchable, synced shell history. Two things to settle first:
      it replaces the `^R` binding that fzf currently owns
      (`zsh/_zshrc:83`), and sync means shell history leaves the machine, which
      needs a deliberate yes/no on a work laptop. Self-hosting or sync-off are
      both options.
- [ ] **zoxide.** Frecency-based jumping. Retires the `pushd` aliases in
      `zsh/_zshrc-aliases:47`. Decide `z` vs shadowing `cd`.
- [ ] **Actually use eza.** Installed via Brewfile but nothing references it:
      `ll` is still `ls -FGlAhp` at `zsh/_zshrc-aliases:32`. Aliases, colors,
      icons (Meslo Nerd Font is already installed), plus the `compdef` above.
- [ ] **git-delta.** Side-by-side syntax-highlighted diffs, configured in
      `git/` rather than the shell. Biggest visible upgrade to everyday `git
      diff` and `git show`.
- [ ] **lazygit.** Not installed (lazydocker is). The note asks whether it
      belongs in a dock, which is really the Tier 2 cmux/dock question below.
- [ ] **bat preview for fzf `^T`.** fzf keybindings are already sourced, so this
      is one `FZF_CTRL_T_OPTS` export. bat is already installed.

### Prompt (`starship.toml`)

- [ ] **Transient prompt.** Collapse previous prompts to something minimal so
      scrollback is command plus output, not repeated prompt furniture. Needs
      starship's zsh transience integration, not just a config key.
- [ ] **Blank line between commands.** `add_newline = true` is already set, so
      confirm what is actually wanted here beyond it: probably a gap after
      output, which is the transient prompt work above.

---

## Tier 2: worth doing, each needs a decision

- [ ] **Retire MacVim for a Neovim GUI.** Stated goal: one vim to support.
      `neovide-app` is already in the Brewfile alongside `macvim` and
      `macvim-app`, so this is mostly removal plus repointing: the `.csv`
      handler in `scripts/macos-defaults.sh` hardcodes MacVim, and `vim/` and
      `neo-vim/` both exist in this repo. Do the config merge before dropping
      the casks.
- [ ] **cmux feature sweep.** One session to work through what is already
      available and turn on what earns its keep, then capture the result in
      `cmux/cmux.json`:
  - Port links in the sidebar, opening a trunk's app in the embedded browser
    instead of typing the port. Real time-saver given per-trunk ports.
  - Vault.
  - cmux top.
  - Markdown viewer with Claude, and skills in general.
  - claude-teams.
  - What `Cmd+Shift+U` does.
- [ ] **A monitoring dock.** btop, vtop, or mactop, plus possibly lazygit and a
      log viewer, in a persistent cmux or tmux layout. Pick one system monitor
      rather than installing three.
- [ ] **yazi.** Terminal file manager. Would overlap with Commander One, which
      is already installed.
- [ ] **jless.** Interactive JSON viewer. `jq`, `jd`, `yq`, and `xq` are already
      installed, so this is for browsing rather than querying.
- [ ] **pspg as the psql pager.** Lands in `_psqlrc`, which already exists and
      is already linked. Small, self-contained, and immediately useful given how
      much psql work happens here.
- [ ] **Log viewers.** logdy (streams logs to a browser UI) and nless
      (<https://github.com/mpryor/nothing-less>). Evaluate against just using
      the existing setup before adding both.
- [ ] **Taproom.** A GUI over Homebrew. Judge it against the fact that the
      Brewfile in this repo is the source of truth: anything installed by
      clicking still has to be written back here by hand.
- [ ] **Context compression for CLAUDE.md.** repomix or similar, if any
      `CLAUDE.md` grows big enough to eat context budget. Not a problem yet;
      revisit when one of them stops fitting comfortably.
- [ ] **cmux `set-status` / `set-progress` from hooks.** Cheap given the hooks
      already in place, and the payoff is at-a-glance triage across many panes.

---

## Tier 3: big swings, do last

These replace working parts of the setup rather than adding to it, so they are
worth trying in isolation before committing anything to the repo.

- [ ] **AeroSpace.** Tiling window manager. This supersedes Rectangle (already
      installed) and overlaps `hammerspoon/layout.lua`. The largest behavior
      change in this file, and the one most likely to be abandoned after a week,
      so try it before writing any config here.
  - [ ] **JankyBorders** for an active-window border, which only matters once
        tiling is in place.
- [ ] **SketchyBar.** Custom menu bar. Overlaps itsycal and the Hammerspoon
      menu-bar modules (`mutebar.lua`, `controls.lua`), which would need to be
      ported or retired. Only sensible after AeroSpace, since most of the appeal
      is a workspace indicator.
- [ ] **skhd.** Hotkey daemon. Mostly redundant: Karabiner already provides the
      hyper key and Hammerspoon already owns global hotkeys. Only worth it if
      AeroSpace lands and its bindings want to live outside Hammerspoon.
- [ ] **Bartender 6.** Paid menu-bar manager. `hiddenbar` is already installed
      and free, so the honest first step is figuring out what hiddenbar cannot
      do before paying.

---

## Already covered, or decided against

- **Map AltTab to Cmd+Tab.** Done, commit `e727aee`. Scripted in
  `scripts/macos-defaults.sh`, along with opting out of the AltTab Pro prompts
  and dropping to one shortcut slot.
- **hyperkey.app.** Redundant. Caps Lock is already remapped to Hyper by
  Karabiner ("Caps Lock -> Hyper (cmd+ctrl+opt+shift); Escape when tapped
  alone"), and `hammerspoon/launcher.lua` already consumes it for app launching.
  Adopting it would mean replacing two working pieces with one app.
- **direnv.** Already hooked at `zsh/_zshrc-dirty:13`, so per-project venvs
  already auto-activate. Open question worth revisiting: it lives in a per-host
  file, so a fresh machine on a different hostname would not get it. Consider
  promoting to `zsh/_zshrc`.
- **ripgrep, bat, fzf, eza, direnv, starship, neovim.** All already in the
  Brewfile. The work left is configuration, captured in Tier 1.
- **uBlock for cookie banners.** A browser extension, not a dotfile. Nothing to
  script; if it is worth remembering, it belongs in the manual steps in
  `README.md` under "Fresh machine setup" alongside the other sign-ins.
