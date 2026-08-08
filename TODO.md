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

## When something goes on trial

Anything that reaches **trialing** gets proposed entries for `cheat.md` as part
of wiring it up, in the same commit, not as a follow-up.

This is not bookkeeping. The failure mode being guarded against is real and has
already happened: a binding that cannot be recalled is indistinguishable from
one that was never configured, so a trial with nothing on the cheat sheet is not
a trial at all, it just quietly expires. Suggesting the entry is part of the
work; whether it earns a line is Josh's call like everything else here.

Keep entries to one line, and phrase them as what you would be trying to do
rather than what the tool is called.

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

Most of this batch is now **trialing**, wired 2026-08-07: `^X^E`
(edit-command-line), `^_` (undo), the `WORDCHARS` shrink so `^W` stops at path
segments, `magic-space`, `AUTO_CD`, `NUMERIC_GLOB_SORT`, case-insensitive
completion, and colored completion matches. Verdict question for all of them:
which ones actually got used a week later, and which were just interesting.

Two notes from wiring it up worth keeping:

- `LS_COLORS` is empty on macOS because BSD `ls` reads `LSCOLORS`, so the usual
  `list-colors ${(s.:.)LS_COLORS}` one-liner is a silent no-op. It needs
  `gdircolors` (GNU coreutils) to generate a real value first. eza reads the
  same variable, so both got colors from one source after all.
- `AUTO_CD` turned out to fully replace `alias ..='pushd ..'`, but only with
  `AUTO_PUSHD` alongside it, since `cd` and `pushd` are not interchangeable and
  `back` depends on the stack. Both are set; `..`, `home`, `tst`, and `bpr` are
  deleted. `...` and `....` stay, since they are not real directories and
  `AUTO_CD` cannot help.

Still open in this section:




- [ ] **atuin.** Searchable, synced shell history. Two questions to settle
      before installing: it wants the `^R` binding that fzf currently owns
      (`zsh/_zshrc:83`), and sync means shell history leaves the machine, which
      needs a deliberate yes on a work laptop. Self-hosting and sync-off are
      both options.

- [ ] **ripgrep** — **installed.** Unclear how much it is reached for versus
      grep out of habit. Cheap thing to notice over a week.
- [ ] **lazygit.** Not installed (lazydocker is, which is a useful comparison
      point: is lazydocker actually used? If not, that predicts the answer
      here).

### Prompt (`starship.toml`)




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
- [ ] **zoxide.** Bottom of the list on purpose, moved here 2026-08-07: Josh
      does not have the problem it solves. Frecency-based jumping is only worth
      something if you regularly need to reach a directory far from where you
      are, and that is not how he moves around. Not dropped, since the shallow
      fzf pickers could change that, but do not resurface it without a reason.

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
- [ ] **git-delta** — **trialing**, installed 2026-08-07 (v0.19.2). Configured
      in `git/_gitconfig`: `core.pager`, `interactive.diffFilter` so `git add -p`
      matches, `navigate` for n/N between files, and line numbers. Replaces
      `pager = less -R`. `side-by-side` is present but commented out, since it
      wants a wide window. Verdict question: does it stay on, or does it start
      feeling like decoration on a `git diff` you were already reading fine?
- [ ] **search-sessions, for finding old Claude sessions** — **trialing**,
      installed 2026-08-08 (v0.3.1, `sinzin91/tap`). Josh found it; it is the
      right category where ccmanager was not, a search tool rather than a
      session manager. Prints project path, date, snippet, and a
      `cd ... && claude -r <uuid>` line per hit, across every project at once.
      Being a plain CLI it also sidesteps the ncurses-in-nvim problem that
      killed pspg. Also searches the Obsidian vault via `--obsidian ~/notes`.
      Gotcha worth remembering: the default search reads session metadata only
      and returns nothing useful; `--deep` searches content and is the real
      mode. Verdict question: does searching past sessions actually become a
      habit, or is it a thing wanted once and then forgotten?
- [ ] **Suffix aliases and a commit binding** — **trialing**, wired 2026-08-08.
      `alias -s md='glow -p'`, `json='jq .'`, `{png,jpg,gif}='viu'` in
      `zsh/_zshrc-aliases`, so typing a filename opens it in the right reader.
      This replaced the `readme()` function, which only ever handled README.md.
      `^X^G` writes `git commit -am ''` and parks the cursor inside the quotes
      without running, which is the thing `c` cannot do since `c` always opens
      an editor. Verdict question: does typing a bare filename become reflex,
      and does the commit chord beat just typing `c`?
- [ ] **eza as `ls`, `ll`, and `lr`** — **trialing**, wired 2026-08-08.
      `ls` is now `eza --icons --group-directories-first`, `ll` adds `-lah
      --git`, and `lr` is `eza --tree --level=2`, which replaced a
      `ls -R | grep | sed x4 | less` pipeline that faked a tree.

      Aliasing `ls` itself was held back at first on the theory that something
      might parse its output; Josh asked for it anyway and it is fine, since
      aliases are interactive-only and scripts calling `ls` never see them.
      `-t` and `-F` do break, because eza reads them as `--time FIELD` and
      `--classify WHEN` and they swallow the path argument. Confirmed unused.

      `compdef eza ls` is closed rather than done: eza ships its own `_eza`
      completion into Homebrew's site-functions.

      Verdict question: is the git column and icon noise worth it on every
      listing, or does the denser plain `ls` output get missed?

- [ ] **zsh-autosuggestions and zsh-syntax-highlighting** — **trialing**,
      installed 2026-08-08. Sourced at the very bottom of `zsh/_zshrc`;
      syntax-highlighting must be last because it wraps every zle widget that
      exists when it loads, and anything defined afterwards stops being
      highlighted. Verified `^X^E`, `^X^G`, `^_` and `magic-space` all survived
      the wrap. The bracketed-paste workaround near the top of the file turned
      out to be for autosuggestions, left behind when the plugin went missing in
      a machine move; it has something to do again.
      Suggestion colour is the default `fg=8`, which is dim on this background;
      bump `ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE` if it is hard to read.
      Verdict question: does the suggestion get accepted often enough to be
      worth the noise, or does it just sit there being ignored?
- [ ] **Ctrl-Shift-T, the recursive file picker** — **trialing**, wired
      2026-08-08. Ctrl-T stays one level deep; this searches the whole tree via
      ripgrep, so `.gitignore` still applies. Ctrl-Shift-T works because Ghostty
      emits it as the CSI-u sequence `ESC [ 116 ; 6 u`, having no legacy
      encoding to fall back on; classic Ctrl+letter collapses to one control
      byte with Shift discarded, which is why the chord is usually impossible.
      `^X^T` is bound to the same widget as a portable fallback, since the CSI-u
      binding is silent in terminals that do not emit it, ssh included.
      Verdict question: two keys for one idea, or does the shallow default just
      want to be recursive after all?
- [ ] **Transient prompt** — **trialing**, wired 2026-08-08. Finished commands
      keep a bare `❯` instead of the full powerline, so scrollback is commands
      and output rather than furniture. `setopt TRANSIENT_RPROMPT` does the same
      for the command duration on the right.

      The backlog entry was wrong about the method: starship has no zsh
      transience at all (fish, PowerShell, cmd, and bash-with-ble.sh only), so
      there is no `enable_transience` to call. This is a hand-rolled
      `accept-line` widget that swaps PROMPT before redrawing, which works only
      because starship rebuilds PROMPT on every precmd. Defined before
      zsh-syntax-highlighting, which wraps whatever exists when it loads.

      Absorbs the old "blank line between commands" item, which was the same
      want stated twice; `add_newline` already handles the gap on the live
      prompt.

      Known limit: the retired `❯` is always green, where the live one turns red
      on failure. Re-deriving exit status here would duplicate starship's logic
      for a glyph already seen. Verdict question: is the denser scrollback worth
      losing the directory context of past commands?
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

- [x] **Global aliases (`alias -g`).** Declined 2026-08-08, without trying
      them. The downsides landed harder than the upside: single capitals collide
      with real arguments, the expansion is invisible to anyone reading the
      command later, and anything using one breaks the moment it is pasted into
      a script. Suffix aliases from the same item were taken and are trialing.
      Not a permanent no; worth raising again if a repeated pipeline shows up.
- [x] **pspg.** Installed and removed 2026-08-07. Unreadable inside nvim's
      `:terminal`, which is where psql actually runs, and three rounds of theme
      work did not fix it. `_psqlrc` is back to `\pset pager off`.

      Why it failed: pspg is an ncurses program, and given a hex colour it tries
      to *redefine a terminal palette entry*. nvim's `:terminal` does not honour
      that, so colours land on whatever occupied the slot, producing green
      backgrounds and grey-on-grey text. `termguicolors` is irrelevant; it
      governs how nvim draws its own buffers, not what an ncurses child can do
      to the palette. Named colours plus `Default` got the table body readable,
      but the bottom menu bar draws from `template_menu` rather than any theme
      field and could not be fixed at all, only hidden.

      **Scope: this is a psql constraint, not a general one.** psql runs inside
      an nvim `:terminal` because `neo-vim/lua/sql.lua` deliberately builds that
      layout, editor beside a terminal buffer marked `b:sql`. So any future
      *psql* pager or viewer has to look right in there untouched. TUIs launched
      from a normal shell (yazi, jless, btop) are unaffected and should be
      judged on their own.
- [x] **ccmanager.** Installed and uninstalled the same night, 2026-08-07.
      Wrong category: it manages sessions (creating, switching, worktree
      juggling), and the actual want is finding old ones. That distinction now
      drives the sharpened Tier 2 entry, and it disqualifies most of the tools
      in this space, which are all launchers wearing different hats.
- [x] **bat as a `cat` replacement.** Tried and disliked, 2026-08-07. The alias
      stays commented out at `zsh/_zshrc-aliases:64`; leave it that way rather
      than deleting it, since the comment is the record of the decision. bat
      stays installed and is still wanted as the fzf `^T` previewer (Tier 1),
      which is a different job: highlighting inside a picker, not replacing a
      tool that already does its job fine.
