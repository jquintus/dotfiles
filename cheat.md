# Terminal cheat sheet

## fzf

- `Ctrl-T` insert a path from the current directory, previewed with bat for files and an eza tree for directories. Only one level deep, so `cd` first to reach anything else.
- `Ctrl-/` toggle that preview pane off when the list itself is what matters.
- `Ctrl-R` fuzzy search shell history.
- `Alt-C` cd into a subdirectory, previewed as a two-level tree.

## Command line editing

- `Esc .` insert the last word of the previous command. Repeat to walk further back through history.
- `Ctrl-X Ctrl-E` open the current command in nvim; save and quit to run it.
- `Ctrl-_` undo the last edit to the line.
- `Ctrl-W` delete the word before the cursor, stopping at each path segment.
- `Ctrl-U` clear the line.
- `Ctrl-A` jump to the start of the line.
- `Ctrl-E` jump to the end of the line.

## History

- Type a prefix, then `Up` / `Down` to cycle only commands that start with it.
- Start a command with a leading space to keep it out of history entirely.
- History is shared live between open shells.
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

## Claude sessions

- `search-sessions --deep <words>` find an old conversation by what was said in it, across every project directory. Without `--deep` it only searches session metadata and usually finds nothing.
- Each hit prints a `cd ... && claude -r <uuid>` line; run it to reopen that conversation.
- `--project <name>` narrow to one repo, `--since "3 days ago"` narrow by date.
- `--obsidian ~/notes` search the vault with the same command.

## Opening files by name

- Type a `.md` filename with no command in front of it to page it through glow.
- Type a `.json` filename to pretty-print it with jq.
- Type a `.png`, `.jpg`, or `.gif` filename to view the image in the terminal.

## Git

- `c` stage everything and commit, including new files.
- `Ctrl-X Ctrl-G` write `git commit -am ''` on the line with the cursor between the quotes; type the message and press enter. Only stages files git already tracks.
- `n` / `N` jump to the next or previous file while paging a diff.

