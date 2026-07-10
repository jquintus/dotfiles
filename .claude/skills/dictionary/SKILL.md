---
name: dictionary
description: Post-process the glossary master page into one atomic note per term. Use when the user says "process the dictionary", "/dictionary", or has pasted new definitions into reference/Dictionary.md and wants them filed into individual glossary notes, deduped/merged, and linked across the vault.
user_invocable: true
---

# dictionary

Turn freeform definitions pasted into the vault's master page into one atomic note
per term, merge duplicates, keep a Dataview view fresh, and (with approval) link
mentions across the vault.

**Vault:** `~/notes` (`/Users/jq/notes`), plain Markdown on disk. Read/write directly.

- Master page: `~/notes/reference/Dictionary.md`
- Glossary notes: `~/notes/reference/glossary/<term>.md` (one per term)

## Step 1 — Parse the entry area

Read `reference/Dictionary.md`. Everything under the `## ➕ Add here` heading (down to
the next `##` heading) is the unprocessed entry area. The user pastes in **any reasonable
format** — do not assume one shape. Recognize entries such as:

- Bullets: `- Term. Definition.` / `- Term — definition` / `- Term: definition`
- Markdown table rows: `| term | definition | context |`
- Plain lines: `Term - definition`

For each entry extract **term**, **definition**, and optional **context**. The term is the
leading label before the first sentence-ending `.`, `—`, `-`, or `:`. Be liberal. If an
entry is genuinely ambiguous (can't tell where the term ends), ask the user rather than guess.

If the entry area is empty, tell the user there's nothing to process and stop.

## Step 2 — File each term into a glossary note

For each parsed term, target `reference/glossary/<term>.md` where `<term>` is the term
**verbatim** (preserve case and spaces): `LOS.md`, `A&D.md`, `mineral owner.md`,
`operator.md`, `effective date.md`. This makes `[[term]]` resolve directly. (This
intentionally bends the vault's kebab-case filename convention — for glossary notes the
filename IS the linkable term.)

Note format — use **inline Dataview fields** so the note is one source of truth that is
both human-readable and queryable:

```markdown
---
aliases: [<expansions / plural / alternate spellings>]
tags: [glossary]
---
# <Term>

**definition**:: <definition — a clean sentence or two>

**context**:: <context, if any>
```

- `aliases` should include natural variants so links/search resolve: the expansion for an
  acronym (`LOS` → `Lease operating statement`), common plurals, alternate spellings. Omit
  the key if there are none.
- Keep `definition` concise (the Dataview table shows it). Extra nuance can go in prose
  below the fields.

## Step 3 — Merge duplicates, flag conflicts

If `reference/glossary/<term>.md` already exists:

- **Merge** — take the union of facts. Enrich the existing definition/context with new
  detail; don't drop what's there.
- **Conflict** — if the new definition materially *contradicts* the existing one (not just
  adds detail), DO NOT overwrite. Surface both versions to the user and ask which is correct,
  or whether they're two distinct senses worth noting together. Wait for their answer before
  writing.

Also dedupe *within* a single run (the same term may appear in both an old table and a fresh
paste).

## Step 4 — Rebuild the master page

Rewrite `reference/Dictionary.md` to this canonical shape, **clearing** the processed entries
from the add area (so re-runs are idempotent):

```markdown
# Dictionary

Paste new terms below in any format (bullets, `Term — definition`, or a table).
Then run `/dictionary` to file them into individual notes and refresh the glossary.

## ➕ Add here


## Glossary

​```dataview
TABLE definition, context
FROM "reference/glossary"
SORT file.name ASC
​```
```

(The `dataview` block requires the Dataview community plugin, which is installed.)

## Step 5 — Auto-link mentions across the vault (show edits first)

After notes are filed, offer to link mentions so `[[term]]` jumps work everywhere:

1. Scan all notes under `~/notes` (excluding `reference/glossary/` itself, `Dictionary.md`,
   and `attachments/`) for occurrences of each term and its aliases.
2. Link only the **first occurrence per note** (avoid a sea of links). Use
   `[[term|matched text]]` when the surface form differs (plurals/case).
3. Separate **safe** terms (unambiguous jargon: `VDR`, `LOS`, `Aries`, `tie-out`) from
   **risky common words** (ordinary English that happens to be a term: `operator`,
   `diligence`, `qualifier`). Propose safe ones for linking; list risky ones separately for
   explicit opt-in.
4. **Present the proposed edits to the user (file + line + before→after) and apply only what
   they approve.** Never bulk-edit other notes without confirmation.

## Committing

The vault is git-tracked but **only commit when the user asks**. If they do, use:

```bash
git -c user.name="jq" -c user.email="josh@dirtlabs.ai" -C ~/notes commit ...
```
