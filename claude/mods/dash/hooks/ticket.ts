import type { Ticket } from '../types'

// ABC-123 from `jq/abc-123-invoice-totals`; only at the start of a path segment,
// so `feat/los-reconcile-replace-2` is not read as REPLACE-2.
export function ticketFromBranch(branch: string): string | null {
  const m = branch.match(/(?:^|\/)([a-z]{2,6}-\d+)(?=$|[-_/])/i)
  return m ? m[1]!.toUpperCase() : null
}

// The issue JSON out of an MCP tool result, whichever wrapping it arrives in.
export function parseIssue(id: string, result: unknown): Ticket | null {
  const text = textOf(result)
  if (!text) return null
  try {
    const j = JSON.parse(text)
    if (!j?.title) return null
    return {
      id: j.id ?? id,
      title: j.title,
      status: j.status ?? '',
      statusType: j.statusType ?? '',
      url: j.url ?? '',
    }
  } catch {
    return null
  }
}

const ORDER = ['started', 'unstarted', 'backlog', 'triage']

// Open issues out of a list_issues result, in-progress first.
export function parseIssues(result: unknown): Ticket[] {
  const text = textOf(result)
  if (!text) return []
  try {
    const j = JSON.parse(text)
    const list: any[] = Array.isArray(j) ? j : j.issues ?? []
    return list
      .filter(i => i?.id && !['completed', 'canceled', 'duplicate'].includes(i.statusType) && i.status !== 'Duplicate')
      .map(i => ({ id: i.id, title: i.title ?? '', status: i.status ?? '', statusType: i.statusType ?? '', url: i.url ?? '' }))
      .sort((a, b) => rank(a.statusType) - rank(b.statusType))
  } catch {
    return []
  }
}

function rank(t: string): number {
  const i = ORDER.indexOf(t)
  return i < 0 ? ORDER.length : i
}

function textOf(r: any): string | null {
  if (typeof r === 'string') return r
  if (Array.isArray(r)) return r.map(textOf).filter(Boolean).join('')
  if (r && typeof r === 'object') {
    if (typeof r.text === 'string') return r.text
    if (r.content !== undefined) return textOf(r.content)
    if (r.title) return JSON.stringify(r)
  }
  return null
}

export function catchupPrompt(id: string, title: string, transcripts: string): string {
  return `Catch me up on ${id}${title ? ` (${title})` : ''}. I have several threads open and am switching back into this one. Don't change anything; just gather and report.

Gather:
- The Linear ticket ${id}: description, status, and recent comments.
- Commits on this branch that aren't on origin/main, plus any uncommitted changes.
- This branch's PR: CI, review state, and unresolved threads.
- The most recent Claude sessions in this worktree (${transcripts}): what I asked for and where each one ended.

Report in at most 10 bullets, grouped as Done, In flight, and Next or blocked. End with the single next action you'd take.`
}
