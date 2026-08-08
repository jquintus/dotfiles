# Terminal cheat sheet

Things this machine is already configured to do and that are easy to forget.
Run `cheat` to page this file, or `cheat <section>` for one part (`cheat fzf`).

If something here is wrong, the config changed and this file did not. Fix both.

## fzf

- `Ctrl-T` insert a file path into the current command. Preview pane shows file
  contents via bat, and directories as a two-level tree via eza.
- `Ctrl-/` toggle that preview pane off when the list itself is what matters.
- `Ctrl-R` fuzzy search shell history.
- `Alt-C` cd into a subdirectory of the current one.
- `coi` pick a git branch from a list and check it out.
- `config` pick a shell config file and open it in the editor.

## Command line editing

- `Esc .` insert the last word of the previous command. Repeat to walk further
  back through history.
- `Ctrl-W` delete the word before the cursor.
- `Ctrl-U` clear the line, `Ctrl-A` jump to start, `Ctrl-E` jump to end.
- `Ctrl-X Ctrl-R` reload the shell (`exec zsh -l`). Same as `rl`.

## History

- Type a prefix, then `Up` / `Down` to cycle only commands that start with it.
- Start a command with a leading space to keep it out of history entirely.
- History is shared live between open shells, and records timestamps.
- `!!` is the previous command, `!$` its last argument. Expansions are shown for
  confirmation before they run rather than firing blind.

## Navigation

- `..` `...` `....` go up one, two, or three directories. `back` returns.
- `~` home, `dl` Downloads, `tst` ~/test.
- `f.` open the current directory in Finder, `f <dir>` opens a specific one.
- `clip` pipe into the macOS clipboard (`pbcopy` by another name).

## Git

- `s` status, `c` stage everything and commit, `co` checkout, `cob` new branch.
- `coi` fzf branch picker, `main` / `master` switch to the default branch.
- `branches` list branches, `pushup` push and set upstream, `pulls` open the PR
  in a browser.
- `prune-branches.sh` delete local branches whose remote branch is gone.

## Config

- `config` fzf picker over shell config files.
- `config zshrc | aliases | dirty | db` open one directly. `zshrc` and `aliases`
  are shortcuts for the first two.
- `bpr` re-source the alias file after editing it, without a full reload.
- `readme [file]` page a markdown file with glow. `cheat` is its sibling.

## macOS keys

- `Cmd-Tab` AltTab switcher across all windows.
- ``Cmd-` `` cycle windows of the active app (macOS native, not AltTab).
- Caps Lock held is Hyper (Cmd+Ctrl+Opt+Shift). Tapped alone it is Escape.
- `Hyper+<letter>` or `Hyper+<number>` jump straight to an app. Same key again
  hides it. `Hyper+0` shows the app launcher's own cheat sheet.

## Adding to this file

Anything that goes on trial in `TODO.md` should land here in the same commit,
otherwise it gets configured and then forgotten, which is the whole problem this
file exists to solve. Keep entries to one line and phrase them as what you would
be trying to do, not what the tool is called.

Work-specific commands do not belong in this file, since this repo is public.
Put those in `~/.cheat.work.md`, which is machine-local and untracked; `cheat`
appends it automatically when it exists.
