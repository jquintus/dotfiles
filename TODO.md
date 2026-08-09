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




- [ ] **atuin.** Deferred, not declined. Josh confirmed 2026-08-08 that he wants
      it, just not next. **Lead with this context when it comes up again:**

      The reason to adopt is *directory-scoped history*: "what did I run in this
      directory last time". He works across ten worktrees where the same command
      means different things depending on which one he is standing in, so that
      one feature fits the shape of his work. He confirmed this is a real want.

      atuin can answer it because it records what zsh never captured: the
      directory a command ran in, its exit status, duration, host, and session.
      `EXTENDED_HISTORY` stores a timestamp and duration only, so fzf's `^R` can
      only fuzzy-match flat text; filtering by directory or by "only the ones
      that worked" is impossible with the data zsh keeps. Also brings usage
      stats.

      **Correction to earlier notes in this file:** sync was twice cited as a
      blocker, on the grounds that it means shell history leaving a work laptop.
      That is wrong. Sync is entirely optional, atuin runs fully local with no
      account, and the docs say so plainly. Do not raise it as a cost again.

      The one real cost left: atuin wants the `^R` that fzf currently owns.

      What is NOT a reason to adopt it, since this was the original framing and
      it is now handled: `Up` returning another terminal's command. That was
      `SHARE_HISTORY`, fixed by swapping to `INC_APPEND_HISTORY`. Demonstrated
      with a two-shell test: SHARE gave `A_WEBSERVER, sleep 3, OTHER_TERMINAL`,
      INC_APPEND gave only the first two.

- [ ] **ripgrep** — **installed.** Unclear how much it is reached for versus
      grep out of habit. Cheap thing to notice over a week.


### Prompt (`starship.toml`)




---

## Tier 2: needs a decision or a real trial

- [ ] **Retire MacVim** — **in progress**, 2026-08-08. Reframed once the actual
      usage came out: MacVim is not a redundant editor, it is open all day as a
      scratchpad for jotting notes, and it "lives in a separate place in my mind
      than terminal nvim". So this is replacing a daily-use app, not deleting a
      duplicate.

      Done: the three `gvim` aliases (gprofile, galiases, gzshrc) are gone, dead
      for a while. The `.csv` Finder handler now points at VimR.

      **VimR over Neovide**, though both are installed and both are maintained
      (VimR pushed 2026-07-26, Neovide 2026-08-07). Neovide is structurally the
      terminal nvim floated into a window, one process per window; VimR is a
      native Mac app with windows, tabs and a file drawer, which is the same
      shape as MacVim and so more likely to keep occupying that separate mental
      slot rather than collapsing into "nvim again". Not a strong preference,
      easy to switch: it is one bundle id in `macos-defaults.sh`.

      `vim/` stays. Josh has Windows machines, and the gVim `guioptions` line in
      `vim/settings.vim` is for those. The win is not one config, it is one
      editor on the Mac, with `vim/` becoming Windows-only.

      Two things learned while wiring it: `duti -s <id> public.comma-separated-
      values-text all` reports success and changes nothing, so the script now
      also sets the `csv` extension, which is what LaunchServices honours.
      And nvim starts in 30ms, so a GUI wrapping it is not paying a startup tax.

      Confirmed working: the 22 associations, and opening a file from Finder
      when VimR has no window open, which was the one edge worth doubting.

      **Open question, to raise on or after 2026-08-15, at Josh's request:** has
      VimR actually taken over the all-day scratchpad job? Not "does it work",
      which is settled, but does it occupy the separate mental slot MacVim did.
      Ask directly rather than waiting for it to come up.

      Not yet, deliberately: `macvim` and `macvim-app` stay in the Brewfile
      until that question is answered yes. They may have to stay regardless,
      since MacVim declares the org.vim.* UTIs behind `.tsx`, `.toml`, `.ini`,
      `.conf` and `.sql`, and VimR exports none of them: uninstalling orphans
      those five whatever the script sets. README's app list goes at the same
      time, if it goes at all.

- [ ] **cmux feature sweep.** Mostly answered 2026-08-08. What the six notes
      turned out to be, and what is left:
  - **Port links: done.** Josh wired browser routing himself. It composes with
    the three tools he already had (site-hopper, the `url` command, the pairdev
    banner) rather than replacing them; cmux's contribution is landing those
    links in the embedded browser.
  - **Workspace grouping by cwd: done.** Also his, via `workspaceGroups.byCwd`,
    which takes globs matched longest-first and fits `~/code/backend.*` and
    `~/code/web.*` directly. Aimed at the too-many-workspaces problem.
  - **Vault** is agent session restore: `vault.agents` registers JSONL-backed
    coding agents that Vault can detect, list, and resume. Not a secrets store.
  - **claude-teams**: parked to 2026-08-15 at Josh's request, alongside the
    verdict pass. A CLI command, `cmux claude-teams [claude-args...]`, with
    `codex-teams`, `omo`, `omx`, `omc` alongside it. Multi-agent, not org teams.
    Relevant because his agent count is rising with the new job.
  - **cmux top: done.** Josh poked at it; it was a command he wanted to try and
    he has now tried it. Closed.
  - **Cmd+Shift+U**: does not appear in `cmux shortcuts` at all. Either an
    app-level chord or something that moved since the note was written.
    Unresolved.

      Only Cmd+Shift+U is left unresolved, and it is not blocking anything.

      **Caveat on the two that are done:** they went into the Settings UI, not
      `cmux.json`, so they are not file-managed and will not travel to a new
      machine. Pinning them is a five-minute job once Josh says what he set.

- [ ] **A monitoring dock.** btop, vtop, or mactop, plus possibly lazygit and a
      log viewer, in a persistent cmux or tmux layout. Evaluate one system
      monitor rather than installing three. Prior question: is a monitor
      actually looked at, or is it decoration?
- [ ] **yazi.** Deferred 2026-08-08, "ignore for now". Note the entry's premise
      was wrong: it weighed yazi against Commander One, which turns out not to
      be installed at all. `README.md:228` lists it, so that app inventory is
      stale. Re-evaluate on its own merits if it comes back.

- [ ] **logdy** — **trialing**, rebuilt 2026-08-08 as ONE shared viewer.
      Stable port 8099 (`PAIRDEV_LOGDY_PORT`), every workspace in one view, so a
      bookmark keeps working and there is one place to look.

      Design forced by a constraint: `logdy follow` takes its file list at
      startup, so a shared instance would never see pairs started later. Hence
      one combined file, `~/.pairdev-logs/all.log`, that everything appends to.
      Streams are told apart by a `<workspace> <service> ` prefix written only to
      the file; the terminal still gets raw lines. Services are named
      `django-admin`, `temporal-worker`, `web`.

      The viewer is detached and deliberately outlives any single pairdev: it is
      not in `pids` and its port is not freed on Ctrl-C, since other pairs are
      using it. Log trimmed at 50MB, but only when nothing is listening, since
      truncating mid-stream would throw away another pair's history.

      **Facets are a UI job, and persist themselves.** `handleClientSettingsSave`
      writes `logdy.config.json` into logdy's working directory, and startup
      auto-loads that filename from cwd. The viewer runs with cwd
      `~/.pairdev-logs`, so saving layout in the UI lands exactly where the next
      start reads it. Verified: the saved file comes back as `configStr` from
      `/api/status`. No `--config` flag needed, so that plumbing was removed.

      Two dead ends recorded so they are not retried: socket mode labels streams
      by origin PORT (unreadable) and under-delivered for reasons never
      diagnosed, and absolute paths under `$TMPDIR` made origins read
      `/var/folders/f6/r3jh...`, which the sidebar truncates to nothing.

      Lives in eng-tools. Verdict question unchanged: does the browser UI get
      opened during a real debugging session?


- [ ] **Context compression for CLAUDE.md.** repomix or similar, if any
      `CLAUDE.md` grows big enough to eat context budget. Not a problem yet.
      Revisit when one stops fitting comfortably.

- [ ] **cmux `set-status` / `set-progress` from hooks.** Cheap given the hooks
      already in place. Payoff is at-a-glance triage across many panes.
- [ ] **uBlock for cookie banners.** Not done, but the how-to is settled so it
      does not need re-deriving:

      On Chrome you can only have uBlock Origin **Lite**. Full uBO is Manifest
      V2, which Chrome disabled in v138 (July 2025). Then: extension icon >
      Dashboard/Settings > **Filter lists > Annoyances > EasyList Cookie**.

      The step that makes or breaks it: uBOL has **no generic cosmetic filtering
      by default**, and its FAQ says you must raise the blocking mode to
      **Complete** to get it. Enabling the cookie list alone hides nothing, which
      is exactly how this ends up filed as "tried it, did not work".

      Worth knowing it *hides* banners rather than answering them, so a site that
      blocks scrolling until you consent will still block scrolling. If that
      turns up, Consent-O-Matic actually clicks reject, and is the better tool
      for that case.


---

## Tier 3: big swings, evaluate in isolation first

These replace working parts of the setup rather than adding to them. Worth
trying standalone before any config lands in this repo.

- [ ] **AeroSpace** — **trialing, paused** 2026-08-08. Josh installed it
      (v0.21.3-Beta, `~/.aerospace.toml`) and stopped for now: "done with my
      aerospace fiddling". Still installed, still not in the Brewfile, which is
      the right state for something undecided.

      What the fiddling turned up: the three-finger swipe stops changing
      workspaces, because AeroSpace's workspaces are not macOS Spaces, and the
      tool tried for that (SwipeAeroSpace) did not work well. Worth knowing that
      Rectangle and `hammerspoon/layout.lua` are both still active and overlap
      it, so any future trial should quiet those first rather than judging
      AeroSpace through their interference.

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


---

## Configured, adoption unconfirmed

**Verdict pass deferred to on or after 2026-08-15.** Josh: "It's too soon for A.
Ask again after a week." Everything below has a verdict question already
written; the point of waiting is that a week of ordinary use answers them and an
afternoon of enthusiasm does not.

**Ask about VimR in the same pass** (see the MacVim entry in Tier 2). The
question is not whether it works, which it does, but whether it took over the
all-day scratchpad job MacVim held. Josh asked to be asked again, so raise it
rather than waiting for him to bring it up.


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
- [ ] **`cmux diff --last-turn` on a Stop hook** — **trialing**, wired
      2026-08-08. Added alongside peon-ping in `claude/settings.json`, so the
      diff pane refreshes itself every time an agent finishes a turn. The point
      is ambient review: glance at a pane instead of scrolling back through tool
      output. It reuses the same pane rather than stacking splits, and
      `--no-focus` keeps it from stealing focus.

      Uses `$CMUX_CLAUDE_HOOK_CMUX_BIN`, which cmux sets for exactly this, with
      a `cmux` fallback and `|| true` so sessions outside cmux fail silently
      instead of erroring on every turn. Both paths verified to exit 0.

      Verified behaviour worth knowing: `--last-turn` works even with a clean
      tree, so the baseline is a snapshot from turn start rather than the
      working tree, and committing mid-turn does not hide the diff. It needs a
      cmux surface (dead over plain ssh) and git sources need a repo, though a
      piped patch works anywhere.

      **Silent no-op when the agent's cwd is not a git repo.** Confirmed
      2026-08-08: a session running from `~/code` (a directory of repos, not a
      repo) gets `Error: cmux diff git sources require a git repository`, which
      `|| true` swallows, so the pane stays empty and nothing indicates why.
      Normal work runs inside `backend.jq-*` and `web.*` worktrees, where it
      fires correctly, so this is an artifact of dotfiles sessions rather than a
      bug to fix. Worth knowing before concluding the hook is broken.

      Verdict question: does the pane actually get looked at, or does it become
      furniture? And does firing on conversational turns with no file changes
      become annoying?


- [ ] **Taproom** — **trialing**, installed by Josh 2026-08-08 (v0.6.2), now in
      the Brewfile. Correction to this file's earlier description: it is a TUI,
      not "a GUI over Homebrew", and it is a brew formula rather than a cask.
      The original caveat still holds though: the Brewfile here is the source of
      truth, so anything installed through Taproom still has to be written back.
      Verdict question: does it beat `brew search` / `brew info`, or is it a nicer
      way to do something that was never hard?
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

- [x] **lazygit** — **in use.** Installed by Josh 2026-08-08, with the Brewfile
      and cheat sheet updated by him in the same pass. Notable because the
      backlog predicted the opposite: lazydocker was already installed and the
      entry argued that not reaching for it predicted the same here. Wrong.
- [x] **jless** — **in use.** Installed by Josh himself 2026-08-08, tried, and
      kept: "I like it. Make it permanent." Added to the Brewfile so it survives
      a fresh machine. Sits alongside jq rather than replacing it: jq queries a
      document you already understand, jless browses one you do not.

- [x] **AltTab on Cmd+Tab.** Confirmed working and in use, 2026-08-07, commit
      `e727aee`. Scripted in `scripts/macos-defaults.sh` along with opting out
      of the AltTab Pro prompts and dropping to one shortcut slot. Residual open
      question: the second shortcut slot (Option+backtick, windows of the active
      app) is gone unless Pro is bought, and native Cmd+backtick is standing in
      for it. Worth revisiting whether that substitute is good enough.

---

## Dropped

When something is declined, move it here with the reason, so it does not come
back around as a *fresh* idea later.

Dropped is not permanent. Raising one again is fine, and sometimes right:
circumstances change and so do preferences. What the recorded reason buys is
that the conversation restarts from what was already learned rather than from
zero. Bring it back with the history attached, instead of either pretending it
never came up or treating it as settled forever.

- [x] **hyperkey.app.** Declined 2026-08-08: "karabiner does it." Karabiner
      already maps Caps Lock to Hyper (with Escape on tap) and
      `hammerspoon/launcher.lua` consumes it, so this would have replaced two
      working pieces with one app.
- [x] **SwipeAeroSpace.** Installed and removed the same evening, 2026-08-08:
      "It didn't work well." Was meant to put the three-finger swipe back for
      AeroSpace workspaces, which the native gesture cannot do since those are
      not macOS Spaces. Untapped too. If the gesture comes up again, the other
      candidate was [aerospace-swipe](https://github.com/acsandmann/aerospace-swipe)
      (C, more stars, but `curl | bash` into a launchd service), and Hammerspoon
      can read raw multitouch via `hs.eventtap` + `event:getTouches()` with no
      new dependency at all.
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
