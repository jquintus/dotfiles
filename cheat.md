# Terminal cheat sheet

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
- `Ctrl-U` clear the line.
- `Ctrl-A` jump to the start of the line.
- `Ctrl-E` jump to the end of the line.

## History

- Type a prefix, then `Up` / `Down` to cycle only commands that start with it.
- Start a command with a leading space to keep it out of history entirely.
- History is shared live between open shells.
- `!!` the previous command.
- `!$` the last argument of the previous command.

## Navigation

- `..` go up one directory.
- `...` go up two directories.
- `....` go up three directories.
- `back` return to the directory you came from.
- `~` go home.
- `dl` go to Downloads.
- `tst` go to ~/test.
- `f.` open the current directory in Finder.
- `f <dir>` open a specific directory in Finder.
- `clip` pipe into the macOS clipboard.

## Git

- `s` status.
- `c` stage everything and commit.
- `co` checkout.
- `cob` create and switch to a new branch.
- `coi` fzf branch picker.
- `main` switch to the default branch.
- `branches` list branches.
- `pushup` push and set upstream.
- `pulls` open the PR in a browser.
- `prune-branches.sh` delete local branches whose remote branch is gone.
