# Terminal cheat sheet

## fzf

- `Ctrl-T` insert a file path into the current command. Preview pane shows file contents via bat, and directories as a two-level tree via eza.
- `Ctrl-/` toggle that preview pane off when the list itself is what matters.
- `Ctrl-R` fuzzy search shell history.
- `Alt-C` cd into a subdirectory of the current one.

## Command line editing

- `Esc .` insert the last word of the previous command. Repeat to walk further back through history.
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

- `...` go up two directories.
- `....` go up three directories.
- `back` return to the directory you came from.
- `dl` go to Downloads.
- `f.` open the current directory in Finder.
- `f <dir>` open a specific directory in Finder.
- `clip` pipe into the macOS clipboard.

## Git

- `c` stage everything and commit.
