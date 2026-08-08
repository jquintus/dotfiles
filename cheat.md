# Terminal cheat sheet

## fzf

- `Ctrl-T` insert a path from the current directory. `Ctrl-Shift-T` for a recursive list
- `Ctrl-/` toggle that preview pane off when the list itself is what matters.
- `Ctrl-R` fuzzy search shell history.
- `Alt-C` cd into a subdirectory, previewed as a two-level tree.

## Command line editing

- `Esc .` insert the last word of the previous command. Repeat to walk further back through history.
- `Ctrl-X Ctrl-E` open the current command in nvim; save and quit to run it.
- `Right arrow` accept the greyed-out suggestion from history. `Ctrl-E` does the same at the end of a line.
- `Alt-F` accept just the next word of that suggestion.
- `Ctrl-_` undo the last edit to the line.
- `Ctrl-W` delete the word before the cursor, stopping at each path segment.
- `Ctrl-U` clear the line.
- `Ctrl-A` jump to the start of the line.
- `Ctrl-E` jump to the end of the line.

## History

- Type a prefix, then `Up` / `Down` to cycle only commands that start with it.
- Start a command with a leading space to keep it out of history entirely.
- `!!` the previous command.
- `!$` the last argument of the previous command.
- Press space after `!!` or `!$` to expand it in place, so it can be edited before it runs.

## Navigation

- Type a directory name on its own, with no `cd`, to change into it.
- `...` go up two directories.
- `....` go up three directories.
- `back` return to the directory you came from.
- `dl` go to Downloads.
- `f.` open the current directory in Finder.
- `f <dir>` open a specific directory in Finder.
- `clip` pipe into the macOS clipboard.

## Opening files by name

- Type a `.md` filename with no command in front of it to page it through glow.
- Type a `.json` filename to pretty-print it with jq.
- Type a `.png`, `.jpg`, or `.gif` filename to view the image in the terminal.

## jless

- `jless <file>` browse a JSON or YAML document. Reads stdin too, so anything can be piped in.
- `Space` fold or unfold the node under the cursor.
- `c` collapse everything at this level, `e` expand it again.
- `/` search forward, `n` for the next hit.
- `yy` copy the focused value, `yp` copy the path to it.
- `m` switch between data mode and raw line mode.
- `q` quit.

## Git

- `c` stage everything and commit, including new files.
- `Ctrl-X Ctrl-G` write `git commit -am ''` on the line with the cursor between the quotes; type the message and press enter. Only stages files git already tracks.
- `n` / `N` jump to the next or previous file while paging a diff.

