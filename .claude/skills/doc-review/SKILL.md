---
name: doc-review
description: Review a design doc, spec, or other writing Josh is drafting (usually a Google Doc) and give feedback he works through over several rounds. Use when he asks to "read my doc and give feedback", "review this doc", "give me a full set of comments", "add comments on X", or hands over a doc link to critique. Keeps one running feedback file, re-reviews against the latest export, removes items as he resolves them, fixes trivial text issues directly, and records every correction in references/preferences.md.
---

# Doc review

**Read `references/preferences.md` before reviewing.** It is the accumulated
record of how Josh wants reviews done, and it overrides anything below.

## 1. Get the current text

- Google Doc: export it fresh every round; never review from an earlier read. Open
  `https://docs.google.com/document/d/<id>/export?format=txt` in a cmux browser
  split (`cmux browser open-split <url> --workspace "$CMUX_WORKSPACE_ID" --focus false`),
  move the newest `~/Downloads/<title>.txt` into the scratchpad, close the split.
- The export carries every document tab and all comments as lettered footnotes
  (`[a]`, `[b]`, …). Letters shift between exports, so quote a comment's text
  rather than citing its letter.
- Read the comment threads. A reply from whoever owns the decision is settled,
  not an open question.
- Links in the doc are not in the txt export. If you need them, export
  `?format=html` the same way and pull the `href`s.

## 2. Check before you write a comment

- Verify every claim against its source: the code, the spec, the linked docs.
  Cite where it comes from. If you can't verify it, drop it.
- Read the whole doc's structure first. A field that looks missing may be
  covered by a section that says "same as X."
- Check stated requirements before proposing an alternative. Never suggest an
  option the doc or the author has already ruled out.
- Match the doc's level. Details the implementer would handle anyway don't
  belong in the review.

## 3. Write the feedback

- One file per doc, e.g. `<project dir>/<doc>-feedback.md`. Open it once with
  `cmux markdown open` (it live-reloads); after that only edit it.
- Numbered items, most important first, grouped under short headings.
- Each item: what's wrong, the source that shows it, and the concrete fix. When
  the fix is a text change, give the exact current text and the replacement text.
- Mark items carried over from an earlier round *(earlier)*.
- Keep each list item to one idea, and each table row to one item.

## 4. Fix trivial things yourself

Spelling, punctuation, grammar, a stray colon: make the edit in the doc and tell
Josh what you changed. Don't hand these back as feedback. Anything that changes
meaning or needs content he has to write stays in the feedback.

Editing mechanics (Chrome MCP, table cells, autoformat traps, comments) are in
`references/google-docs-mechanics.md`.

## 5. Later rounds

- Re-export and re-read. An item he hasn't addressed means he hasn't gotten to it
  yet, not that he disagrees. Keep it.
- When he says an item is fixed, or the fresh export shows it is, delete it from
  the feedback file and renumber. Don't keep a "resolved" list.
- When he pushes back, update the item to his decision (or delete it) and record
  the correction in `references/preferences.md`.
- He often works top to bottom while you update; keep the file current as he
  reports each fix.

## 6. Doc comments

When asked to flag things in the doc itself (e.g. incomplete sentences), add a
Google Docs comment anchored on the exact text, phrased so it stands alone. The
mechanics are in `references/google-docs-mechanics.md`.

## 7. Record corrections

Every time Josh corrects how the review was done, append it to
`references/preferences.md` under "Learned in use" with the date and his words.
Keep it general: this skill lives in a public repo, so no project, customer, or
colleague names.
