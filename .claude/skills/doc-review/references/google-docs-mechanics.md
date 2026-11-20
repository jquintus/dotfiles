# Editing Google Docs for a review

cmux cannot edit Google Docs (Trusted Types blocks its eval, and the body is
canvas-rendered). For sentence-level text edits use the google-workspace MCP's
`find_and_replace_doc`. Use Chrome MCP only for edits that must land at a caret
(tables, comments, styling), in a fresh tab of the MCP group, and close it when done.

## Positioning

- At most one positioned click per batch, then zoom to confirm the caret before
  typing. The window and layout shift without warning (a comment sidebar opening
  reflows the page), so coordinates from an earlier screenshot go stale.
- Insert after a line: click just right of the line's end, press `End`, zoom to
  confirm, then `Enter` and type. A new bullet inherits the list level.
- Select a word: double-click it, then zoom. Double-clicking can grab the adjacent
  space instead; if so, `Left` puts the caret at the start of the selection.
- Select a table cell's text: triple-click it.
- Don't use Cmd+F to position; the find box opens without focus and the search
  text goes into the document.

## Tables

- Click the first cell, type, `Tab` to the next cell. `Tab` in the last cell adds
  a row.

## Code font

- Type code inline wrapped in backticks (`` `name` ``); Docs converts it to code font as you
  type the closing backtick. Underscores inside the backticks are safe from the italics
  trap. This beats paint format for new text. Verified 2026-10-02.

## Autoformat traps

- A second `_` in one token italicizes the text between the underscores
  (`a_b_c` becomes `a`*b*`c`).
- The first word of a cell or line is capitalized when you type the following space,
  and a lowercase line (a filename, an identifier) is capitalized when you press `Enter`
  at its end.
- Heading styles: `cmd+alt+1`…`cmd+alt+6` apply Heading 1–6 to the current line.
- Fix both by pressing `cmd+z` immediately after the keystroke that triggered it
  (type `a_b_`, `cmd+z`, then `c`).

## Comments

- Select the anchor text, `cmd+alt+m`, type the comment, `cmd+Return` to post.
- Screenshot afterward to confirm the comment card appears.

## Concurrent editors

- Other people's cursors show as labeled flags. Typing directly is safe; avoid
  the clipboard when someone else is editing, since a paste can collide.
- Verify the result with a fresh `get_doc_as_markdown` read, not just screenshots.

## New tables and matching styles

- Insert a table with Insert > Table > hover the grid to the size you want, then click.
  Fill it with `Tab`; `Tab` in the last cell adds rows.
- A new table won't match existing ones. Copy the existing table's settings:
  - Column widths: click a cell in the existing table, open Table options > Column, and
    read each column's width in inches. Then set the same widths on the new table there.
    Don't drag column borders; a drag can resize the whole table.
  - Alignment: new tables default to centered. Set Table options > Table > Alignment to
    match (usually left).
  - Header shading: select the header cells (click, then shift-click), then use the
    toolbar's cell background (paint bucket) and pick the same gray.
- Paint format: select styled source text, click the paint-format icon, then double-click
  the target word. Double-clicking the icon makes it sticky, and Escape doesn't always
  turn it off. Click the icon again to deactivate, or the next click restyles whatever
  you touch.
- Clicking in blank space under a table can put the caret at the end of the next
  heading, not in an empty paragraph. Check the toolbar's style before pressing Delete.

## Find and replace

- Never use the Docs Find and replace dialog, by shortcut or by the Edit menu. Typed text
  has landed in the document body instead of the dialog and overwritten content.
- For sentence-level edits use the MCP's `find_and_replace_doc` with `tab_id`,
  `match_case: true`, and the exact text (curly apostrophes included) as
  `get_doc_as_markdown` returns it. A `\n` in the replacement starts a new paragraph that
  inherits the list or heading style.
