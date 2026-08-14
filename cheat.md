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
- `dots` go to the dotfiles repo. `dotfiles` spelled out works too.
- `f.` open the current directory in Finder.
- `f <dir>` open a specific directory in Finder.
- `clip` pipe into the macOS clipboard.

## Finder

- `cmd-down` open the selected folder or file. `Enter` renames it instead, which is the thing that keeps catching you out.
- `cmd-O` the same open, when your hand is already off the arrow keys.

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

## SQL over a folder of CSVs

- `csvsql` open a SQL shell on the current directory: every CSV becomes a table named after the file, every subdirectory a schema. Also reads tsv, json, parquet, and xlsx.
- `.tables` list the tables and their columns once you are in there. `describe <table>` for the types it guessed.
- `csvsql . -c "select ..."` run one query and exit. Add `-csv` and redirect to write a new file.
- `csvsql --text .` reads every column as text, for a file too messy to type. Cast in the query yourself.
- `csvsql --show .` print the SQL it generated, to paste into a plain `duckdb` session and edit.
- `<leader>r` in the `sql` workspace still runs the open file, sending `.read` when the pane holds duckdb and `\i` when it holds psql.
- `.mode line` one field per line, for rows too wide to read. This is duckdb's `\x`; `.mode duckbox` goes back.
- `<leader>n` close the file browser to give duckdb the width back. It refuses to render a table under 80 columns, so a narrower pane wraps every row.

## Git

- `lazygit` use it.
- `c` stage everything and commit, including new files.
- `Ctrl-X Ctrl-G` write `git commit -am ''` on the line with the cursor between the quotes; type the message and press enter. Only stages files git already tracks.
- `n` / `N` jump to the next or previous file while paging a diff.

## cmux

- `cmd-opt-b` Open up the sidebar and checkout vault
- `cmux diff --last-turn` render what an agent changed since its turn started, in a split.

## macOS is stuck

- `opt-ctrl-shift-F5` cursor stuck holding a drag, clicks going nowhere, Finder window that won't close. Releases the drag macOS lost the mouse-up for.
- `hs -c 'require("unstick").release()'` same rescue from a terminal, for when the drag eats the hotkey.
