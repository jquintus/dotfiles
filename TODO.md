# Backlog

Config ideas collected on a road trip in August 2026 (videos, blogs, docs, no
computer), ordered by how cheap they are to evaluate against how much they would
touch a normal day.

**This is a research queue, not a commitment.** Nothing here is agreed to. The
work on most items is finding out whether the thing earns a place in the flow,
and "no" is a perfectly good outcome that should get written down so it does not
get re-researched next year.

## How an item leaves this list

Only two ways, and both are Josh's call, not an agent's:

- **in use** — actually being used, not just present and working.
- **dropped** — evaluated and declined, with the reason recorded.

Installed is not done. Configured is not done. Working is not done. A tool that
is installed and wired up but has not made it into the daily flow is still an
open question, and it stays on the list with its status noted.

Status tags used below:

| tag | means |
| --- | --- |
| *(none)* | unresearched, nothing done |
| **installed** | present on the machine, not necessarily used |
| **configured** | wired into this repo, adoption unconfirmed |
| **trialing** | being used right now, verdict pending |
| **in use** | adopted, confirmed by Josh |
| **dropped** | declined, reason recorded |

Implementation conventions still apply when something does get adopted: a new
config file is not done until it has a line in `scripts/links.manifest`, system
settings go in `scripts/macos-defaults.sh`, and nothing is committed until it is
confirmed working in a live shell. See `AGENTS.md`.

---

## Tier 1: cheap to try, touches every day

Mostly stock zsh features that need binding, plus tools that can be evaluated in
an afternoon and backed out in a minute.

### Zsh keys and options (all in `zsh/_zshrc`)

Low risk as a group, but each is a habit that has to actually form. Worth
revisiting a week after binding to see which ones got used.

- [ ] **Edit the command line in nvim.** `autoload -Uz edit-command-line; zle -N
      edit-command-line; bindkey '^X^E' edit-command-line`. Verified unbound.
      Probably the highest-value binding in this section for long commands.
- [ ] **Undo on `^_`.** Verified unbound in the live shell, despite being a
      stock emacs-keymap binding. Bind `undo` explicitly.
- [ ] **Make `^W` stop at path separators.** Already bound to
      `vi-backward-kill-word`, but `WORDCHARS` is still the default and contains
      `/`, so it eats a whole path instead of one segment. Shrink `WORDCHARS`
      rather than rebinding the key.
- [ ] **Magic space.** `bindkey ' ' magic-space` expands `!!` and `!$` as you
      type the space rather than at execution. Pairs with the existing
      `HIST_VERIFY`.
- [ ] **`setopt AUTO_CD`.** Bare directory name means cd. Open question: whether
      this survives adopting zoxide, or whether the two fight for the same
      muscle memory.
- [ ] **`setopt NUMERIC_GLOB_SORT`.** Sorts `file2` before `file10`.
- [ ] **Case-insensitive completion.** `zstyle ':completion:*' matcher-list
      'm:{a-zA-Z}={A-Za-z}'`.
- [ ] **`LS_COLORS` in completion menus.** `zstyle ':completion:*' list-colors
      ${(s.:.)LS_COLORS}`. Worth doing with the eza question so colors come from
      one source.
- [ ] **`compdef eza ls`.** Trivial, but only meaningful if eza is actually
      adopted (below).
- [ ] **Global and suffix aliases.** `alias -g` expands anywhere on the line
      (`alias -g G='| grep'`), `alias -s` binds a file extension to a program
      (`alias -s md=nvim`). Zero of either in `zsh/_zshrc-aliases` today. The
      research question is which handful would actually get used, since a large
      set of invisible expansions is its own problem.
- [ ] **Bind a key to `git commit -am`.** Needs a decision on whether it fires
      immediately or fills the buffer for editing. `_reload_shell` at
      `zsh/_zshrc:170` is the pattern to copy.

**"What are widgets?"**: a zle widget is a shell function registered with
`zle -N` so it can be bound to a key and manipulate the command line buffer
(`$BUFFER`, `$CURSOR`) rather than just run a command. There is already one in
the repo: `_reload_shell` at `zsh/_zshrc:170`, bound to `^X^R`. Most items above
are stock widgets that only need binding.

### Shell tooling

- [ ] **zsh-autosuggestions.** Not installed. Note the repo already carries the
      bracketed-paste workaround for it at `zsh/_zshrc:36` with no plugin
      present, which suggests it was used before and lost in a machine move.
      That is weak evidence it was liked.
- [ ] **zsh-syntax-highlighting.** Not installed. Must be sourced last, after
      all other zle setup, or it clobbers bindings.
- [ ] **atuin.** Searchable, synced shell history. Two questions to settle
      before installing: it wants the `^R` binding that fzf currently owns
      (`zsh/_zshrc:83`), and sync means shell history leaves the machine, which
      needs a deliberate yes on a work laptop. Self-hosting and sync-off are
      both options.
- [ ] **zoxide.** Frecency-based directory jumping. Would retire the `pushd`
      aliases at `zsh/_zshrc-aliases:47`. Question: `z` as a new verb, or shadow
      `cd` outright.
- [ ] **eza for `ll` and friends.** Partially answered: eza is now **trialing**
      inside the fzf picker (see below), but `ll` is still `ls -FGlAhp` at
      `zsh/_zshrc-aliases:32`. The open question is whether its output is wanted
      outside the picker too. `compdef eza ls` and the `LS_COLORS` item above
      both follow from a yes.
- [ ] **ripgrep** — **installed.** Unclear how much it is reached for versus
      grep out of habit. Cheap thing to notice over a week.
- [ ] **git-delta.** Not installed. Side-by-side syntax-highlighted diffs,
      configured in `git/` rather than the shell. Probably the most visible
      upgrade to everyday `git diff` and `git show` in this file.
- [ ] **lazygit.** Not installed (lazydocker is, which is a useful comparison
      point: is lazydocker actually used? If not, that predicts the answer
      here).

### Prompt (`starship.toml`)

- [ ] **Transient prompt.** Collapse previous prompts so scrollback is command
      plus output, not repeated prompt furniture. Needs starship's zsh
      transience integration, not just a config key.
- [ ] **Blank line between commands.** `add_newline = true` is already set, so
      clarify what is wanted beyond it. Likely a gap after output, which is the
      transient prompt work above.

---

## Tier 2: needs a decision or a real trial

- [ ] **Retire MacVim for a Neovim GUI.** Stated goal: one vim to support.
      `neovide-app` is already in the Brewfile alongside `macvim` and
      `macvim-app`, so a GUI is already available to trial without installing
      anything. Blocking question: `vim/` and `neo-vim/` both exist in this
      repo, so the config merge is the actual work. The `.csv` handler in
      `scripts/macos-defaults.sh` hardcodes MacVim and would need repointing.
- [ ] **cmux feature sweep.** One session to find out what is already there and
      what earns its keep, then capture the result in `cmux/cmux.json`:
  - Port links in the sidebar, opening a trunk's app in the embedded browser
    instead of typing the port. Given per-trunk ports, this is the one most
    likely to stick.
  - Vault.
  - cmux top.
  - Markdown viewer with Claude, and skills in general.
  - claude-teams.
  - What `Cmd+Shift+U` does.
- [ ] **A monitoring dock.** btop, vtop, or mactop, plus possibly lazygit and a
      log viewer, in a persistent cmux or tmux layout. Evaluate one system
      monitor rather than installing three. Prior question: is a monitor
      actually looked at, or is it decoration?
- [ ] **yazi.** Terminal file manager. Overlaps Commander One, which is already
      installed, so the question is whether either gets used.
- [ ] **jless.** Interactive JSON viewer. `jq`, `jd`, `yq`, and `xq` are already
      installed, so this is browsing rather than querying. Worth it only if
      there is real time spent squinting at `jq` output.
- [ ] **pspg as the psql pager.** Lands in `_psqlrc`, which already exists and
      is already linked. Small, self-contained, and easy to back out. Given how
      much psql work happens here this is probably the best value in Tier 2.
- [ ] **Log viewers.** logdy (streams logs to a browser UI) and nless
      (<https://github.com/mpryor/nothing-less>). Evaluate against the current
      workflow before adding either, and probably pick one.
- [ ] **Taproom.** A GUI over Homebrew. Weigh against the fact that the Brewfile
      here is the source of truth: anything installed by clicking still has to
      be written back by hand.
- [ ] **Context compression for CLAUDE.md.** repomix or similar, if any
      `CLAUDE.md` grows big enough to eat context budget. Not a problem yet.
      Revisit when one stops fitting comfortably.
- [ ] **cmux `set-status` / `set-progress` from hooks.** Cheap given the hooks
      already in place. Payoff is at-a-glance triage across many panes.
- [ ] **uBlock to block cookie banners.** A browser extension, so nothing to
      script here, but still a real workflow change to evaluate. If adopted it
      belongs in the manual steps in `README.md` under "Fresh machine setup".

---

## Tier 3: big swings, evaluate in isolation first

These replace working parts of the setup rather than adding to them. Worth
trying standalone before any config lands in this repo.

- [ ] **AeroSpace.** Tiling window manager. Supersedes Rectangle (installed) and
      overlaps `hammerspoon/layout.lua`. The largest behavior change in this
      file and the one most likely to be abandoned after a week, which is
      exactly why it should be trialed before anything is written down.
  - [ ] **JankyBorders** for an active-window border, which only matters once
        tiling is in place.
- [ ] **SketchyBar.** Custom menu bar. Overlaps itsycal and the Hammerspoon
      menu-bar modules (`mutebar.lua`, `controls.lua`), which would need porting
      or retiring. Most of the appeal is a workspace indicator, so it depends on
      AeroSpace landing first.
- [ ] **skhd.** Hotkey daemon. Karabiner already provides the hyper key and
      Hammerspoon already owns global hotkeys, so this is likely redundant
      unless AeroSpace lands and its bindings want to live outside Hammerspoon.
- [ ] **Bartender 6.** Paid menu-bar manager. `hiddenbar` is **installed** and
      free, so the first question is what hiddenbar cannot do. Note that
      "hiddenbar is installed" says nothing about whether the menu bar is
      actually under control today.
- [ ] **hyperkey.app.** Finding, not a verdict: Caps Lock is already remapped to
      Hyper by Karabiner ("Caps Lock -> Hyper (cmd+ctrl+opt+shift); Escape when
      tapped alone") and `hammerspoon/launcher.lua` already consumes it for app
      launching. So adopting it means replacing two working pieces with one app.
      That could still be worth it if the current setup is fiddly to maintain;
      that is the question to answer.

---

## Configured, adoption unconfirmed

Wired up and working, but that is not the same as being used. These stay here
until confirmed either way.

- [ ] **bat as the fzf `^T` previewer** — **trialing**, wired 2026-08-07.
      `FZF_CTRL_T_OPTS` in `zsh/_zshrc`, right after the fzf source lines.
      Confirmed working and liked on sight; the open question is whether it
      still earns the pane after a few weeks, or becomes noise that gets toggled
      off with Ctrl-/. Separate from bat as a `cat` replacement, which is
      dropped.
- [ ] **eza in the fzf `^T` preview** — **trialing**, wired 2026-08-07.
      Directories in the picker render as a two-level eza tree with icons. This
      is deliberately the smallest possible trial of eza: it costs nothing to
      revert (an `ls` fallback is already in the same block for machines without
      eza) and it says nothing yet about whether `ll` should change. Verdict
      question: does eza's output get missed outside the picker?
- [ ] **direnv** — **configured.** Hooked at `zsh/_zshrc-dirty:13`, so
      per-project venvs auto-activate on this host. Two open questions: is it
      actually relied on, and should it be promoted out of the per-host file so
      a fresh machine on a different hostname gets it.
- [ ] **fzf** — **configured.** Key bindings and completion sourced at
      `zsh/_zshrc:83`. `^R`, `^T`, and `Alt-C` are all live. Which of the three
      are reflexes and which are forgotten is worth noticing, since the answer
      decides the atuin question above.
- [ ] **history-substring-search** — **configured** at `zsh/_zshrc:90` with
      up/down arrow bindings. Same question, and it also overlaps atuin.
- [ ] **starship** — **configured.** In daily use by definition since it draws
      the prompt, but the open items are in Tier 1.

---

## In use

- [x] **AltTab on Cmd+Tab.** Confirmed working and in use, 2026-08-07, commit
      `e727aee`. Scripted in `scripts/macos-defaults.sh` along with opting out
      of the AltTab Pro prompts and dropping to one shortcut slot. Residual open
      question: the second shortcut slot (Option+backtick, windows of the active
      app) is gone unless Pro is bought, and native Cmd+backtick is standing in
      for it. Worth revisiting whether that substitute is good enough.

---

## Dropped

When something is declined, move it here with the reason, so it does not come
back around as a fresh idea later.

- [x] **bat as a `cat` replacement.** Tried and disliked, 2026-08-07. The alias
      stays commented out at `zsh/_zshrc-aliases:64`; leave it that way rather
      than deleting it, since the comment is the record of the decision. bat
      stays installed and is still wanted as the fzf `^T` previewer (Tier 1),
      which is a different job: highlighting inside a picker, not replacing a
      tool that already does its job fine.
