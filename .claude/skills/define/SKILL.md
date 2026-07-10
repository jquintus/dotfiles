---
name: define
description: Quickly add a single term to the glossary from an inline definition. Use when the user runs "/define <definition sentence>" — infer the term being defined and file it as one glossary note. The fast, one-off sibling of the dictionary skill (which batch-processes the Dictionary.md entry area).
user_invocable: true
---

# define

Add **one** term to the vault glossary directly from a definition the user types inline,
without going through the `Dictionary.md` entry area.

**Vault:** `~/notes` (`/Users/jq/notes`), plain Markdown on disk. Write directly.
Glossary notes: `~/notes/reference/glossary/<term>.md` (one per term).

## Usage

```
/define <a sentence or two defining a term>
```

Example: `/define An MMBtu stands for one million British thermal units. It is the standard
unit used in the energy industry to quantify heat content and pricing of fuels like natural
gas, propane, and LNG.` → files `reference/glossary/MMBtu.md`.

## Steps

1. **Infer the term.** The argument is a definition sentence; identify the term it defines —
   usually the salient acronym, noun, or phrase the sentence is *about* (e.g. "An **MMBtu**
   stands for…" → `MMBtu`). If the term is genuinely ambiguous, ask the user which term this
   defines rather than guess. If no argument text was given, ask for the definition.

2. **File the note** at `reference/glossary/<term>.md`, where `<term>` is the term **verbatim**
   (preserve case and spaces): `MMBtu.md`, `LOS.md`, `mineral owner.md`. This makes `[[term]]`
   resolve directly. Use inline Dataview fields so the note is both readable and queryable:

   ```markdown
   ---
   aliases: [<expansions / plural / alternate spellings / casing variants>]
   tags: [glossary]
   ---
   # <Term>

   **definition**:: <a clean sentence or two>

   **context**:: <usage/context, if the sentence carries any — otherwise omit>
   ```

   - Rewrite the user's sentence into a tidy `definition` (don't paste it raw if it starts
     with "An X stands for…" — lead with the meaning). Split genuine usage/context into
     `context`.
   - `aliases`: include the expansion (acronym → full form) and obvious casing variants.

3. **Merge, don't clobber.** If `reference/glossary/<term>.md` already exists, enrich it
   (union of facts). If the new definition *contradicts* the existing one, surface both and
   ask before overwriting.

4. **Report** the term filed and its definition. It appears automatically in the Dataview
   view on `reference/Dictionary.md` (no rebuild needed).

## Linking

This skill does **not** scan/link mentions across the vault — that's the `dictionary` skill's
Step 5. If the user wants the new term linked elsewhere, offer to run `/dictionary`'s linking
pass (or link on request).

## Committing

The vault is git-tracked but **only commit when the user asks**. If they do:

```bash
git -c user.name="jq" -c user.email="josh@dirtlabs.ai" -C ~/notes commit ...
```
