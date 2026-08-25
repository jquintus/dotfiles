# Global user preferences (all repos)

> Keep this file up to date as we work together. When I share a durable preference, workflow, or piece of tooling worth remembering across sessions, add or revise the relevant section here (and prune anything that becomes stale).

<!--
Lives in ~/dotfiles/claude/CLAUDE.md, symlinked to ~/.claude/CLAUDE.md.
Editing either path edits the repo. Commit and push after changing it.

This repo is PUBLIC, so work-specific content does not belong here. Anything
about DirtLabs internals goes in ~/.claude/CLAUDE.work.md, which is
machine-local and pulled in by the @-import at the bottom of this file.

Block-level HTML comments like this one are stripped before the file is
injected into Claude's context, so maintainer notes cost no tokens.
-->

## Most important

Be as brief as possible. 

No clickbait, ever — in chat as well as in documents. Do not tease a finding
before stating it, do not characterize it before delivering it, and do not tell
me a result is surprising, important, or favorable to some option. Say the thing.
"A number we've been quoting all session is wrong, and the correction favors
MicroVM" should have been "MicroVM's provision time is 1.64s, not 2.95s." I can
judge what it means; the framing just delays the content.

Write American English, always: `color`, `gray`, `initialize`, `behavior`, `canceled`. Never British spellings (`colour`, `grey`, `initialise`, `behaviour`). Applies to code, identifiers, comments, commit messages, docs, and chat.

## Dotfiles and machine setup
- My dotfiles live at `~/dotfiles` (`github.com/jquintus/dotfiles`). **Whenever I mention dotfiles, my shell/editor/terminal config, Hammerspoon, keybindings, macOS `defaults`, or customizing my machine in any way, read `~/dotfiles/AGENTS.md` first.** It has the repo layout, the symlink-manifest workflow, the conventions that are easy to get wrong, and the commit rules. Don't re-derive any of that by exploring.
- Short version so you know what you're looking for: config is symlink-based via `scripts/install-mac.sh` + `scripts/links.manifest`; system settings go in `scripts/macos-defaults.sh`; a new config file is not done until it has a manifest line.
- The repo is public. Keep work-specific detail out of it.

## Terminal: cmux
- I run [cmux](https://cmux.com) as my terminal. When `CMUX_SOCKET_PATH` is in your environment, you can drive the live UI from Bash with the `cmux` CLI: open browser splits, spawn panes, read screens, and post notifications/status/progress back to me.
- Two things I actively want you to do with it: **open a browser split and visually verify** anything web-facing you changed instead of telling me it should work, and **run long or watchable jobs in a visible pane** (including child `claude -p` agents) so I can follow along or take over.
- `cmux docs [browser|agents|settings|shortcuts]` prints curl commands for the current upstream docs. Short refs like `surface:3` are positional and renumber, so grab UUIDs (`--json --id-format uuids`) for anything you hold across commands.
- Clean up splits, panes, and statuses you created when you're done.

## Subagents (standing permission)

Use subagents (the Agent tool) freely — I do not need to ask for them, and any
default rule saying "don't spawn agents unless requested" is overridden here.
Default to delegating whenever it helps: broad codebase searches, reading across
many files, independent work that can run in parallel. Launch parallel agents in
a single message so they run concurrently.

Pick the model that fits the job rather than always inheriting mine:
- `sonnet` (or `haiku` for trivial lookups) for search, file discovery, and
  mechanical sweeps
- the default/inherited model for reasoning-heavy review, design, or debugging

Relay the conclusions — I never see the agent's report.

## Git branches
- Every branch you create for me MUST be prefixed with `jq/` (e.g. `jq/fix-flaky-tests`). This applies to all repositories, always.

## GitHub Actions
- When adding or editing any GitHub Action, use a current major that runs on **Node 24**, never Node 16/20 (they emit deprecation warnings the user actively dislikes). Before committing a new/changed `uses:`, verify the action.yml `runs.using` is `node24` (e.g. `gh api "repos/<owner>/<repo>/contents/action.yml?ref=<tag>"`). This includes helper actions like `actions/cache`, `actions/upload-artifact`, `actions/download-artifact`.
- **Resolve the major from the repo, don't recall it.** Check `releases/latest` — pinning the newest major you happen to remember can still leave you on node20. Known-good as of 2026-08: `actions/checkout@v7`, `actions/setup-python@v7`, `hashicorp/setup-terraform@v4`, `terraform-linters/setup-tflint@v6`, `aws-actions/configure-aws-credentials@v6`, `aws-actions/amazon-ecr-login@v2`, `docker/login-action@v4`. Docker-based actions (e.g. `bridgecrewio/checkov-action`) have no Node runtime and are exempt.
- **Don't match the file's existing version.** A workflow whose other jobs are on an old major is a reason to upgrade those jobs, not to join them — and expect a Copilot review comment claiming the new job is "inconsistent". That comment is wrong; reply citing this rule rather than downgrading.
- When a PR touches a workflow, confirm the fix landed rather than assuming: `gh run view <id> --log | grep -icE "deprecat|Node\.js 16|Node\.js 20"` should be 0. Actions in `workflow_dispatch`-only workflows are never exercised by PR checks — say so instead of implying they passed.

## Copilot PR review loop
- After addressing Copilot's review feedback on a PR: FIRST explicitly respond to the feedback (reply to each thread, or state the resolution), THEN re-request Copilot's review on that PR so the next round triggers automatically without me asking. Order matters: respond first, re-request second, never re-request before responding.
- Re-request via `gh` (e.g. `gh api --method POST repos/{owner}/{repo}/pulls/{n}/requested_reviewers -f "reviewers[]=copilot-pull-request-reviewer[bot]"`); if that call doesn't work for the Copilot bot, say so and tell me to click "Re-request review".

## Work-specific preferences

Machine-local, not in this repo:

@~/.claude/CLAUDE.work.md
