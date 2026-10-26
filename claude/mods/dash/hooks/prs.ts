import type { SessionPr } from '../types'

// good: ready to go. you: your move. wait: someone else's. bad: broken. done: closed.
export type Tone = 'good' | 'you' | 'wait' | 'bad' | 'done'
export type Row = { status: string; isBad: boolean; next: string; tone: Tone }

const NEXT: Record<string, string> = { apply: 'Apply', 'mark ready': 'Ready for review', merge: 'Merge' }

// One plain-language status per PR, and what Josh has to do next (or '').
export function describe(p: SessionPr): Row {
  const next = (p.action && NEXT[p.action]) || ''
  const row = (status: string, tone: Tone, n = next): Row => ({ status, isBad: tone === 'bad', next: n, tone })
  if (p.state !== 'OPEN') return row(p.state === 'MERGED' ? 'Merged' : 'Closed', 'done', '')
  if (p.action === 'conflicts') return row('Merge conflicts', 'bad', '')
  if (p.ci === 'fail') return row(`CI failed (${p.failed})`, 'bad')
  if (p.action === 'apply') return row('Plan ready', 'good')
  if (p.ci === 'pending') return row('CI running', 'wait')
  if (p.isDraft) {
    if (p.copilot === 'requested') return row('Copilot reviewing', 'wait')
    return p.action === 'mark ready' ? row('Your review', 'you') : row('In PR loop', 'wait')
  }
  if (p.action === 'merge') return row('Approved', 'good')
  // Out of draft: Copilot's comments are the agent's; only reviewers' count.
  const human = p.humanThreads ?? p.threads
  if (human) return row(`${human} reviewer comment${human > 1 ? 's' : ''}`, 'wait')
  return row('Awaiting review', 'wait')
}

// "ABC-123 feat(billing): store invoice totals" -> "store invoice totals"
export function shortTitle(title: string): string {
  return title
    .replace(/^[A-Z]{2,6}-\d+\s+/, '')
    .replace(/^\w+(\([^)]*\))?!?:\s*/, '')
}

// A PR belongs to this session when the session linked it, when its title
// carries this session's ticket (ABC-123 …), or when it sits in the same
// stack as one of those: a stack built with `gh stack` links only the top PR.
export function sessionPrsOf(linked: SessionPr[], everyMine: SessionPr[], ticketId: string | null): SessionPr[] {
  const keys = new Set(linked.map(p => p.key))
  const out = [...linked, ...everyMine.filter(p => !keys.has(p.key) && !!ticketId && p.title.includes(ticketId))]
  out.forEach(p => keys.add(p.key))
  const branch = (repo: string, b?: string | null) => (b ? `${repo}:${b}` : '')
  const isNeighbor = (a: SessionPr, b: SessionPr) =>
    a.repo === b.repo && (branch(a.repo, a.base) === branch(b.repo, b.head) || branch(a.repo, a.head) === branch(b.repo, b.base))
  for (let i = 0; i < out.length; i++) {
    for (const p of everyMine) {
      if (!keys.has(p.key) && isNeighbor(p, out[i]!)) {
        keys.add(p.key)
        out.push(p)
      }
    }
  }
  return out
}

export type Stacked = { pr: SessionPr; position: string }

// Orders PRs bottom-up within each stack (a PR whose base is another's head
// sits on it) and labels each "2/4". A PR on its own gets no label.
export function stackOrder(prs: SessionPr[]): Stacked[] {
  const key = (repo: string, branch?: string | null) => `${repo}:${branch ?? ''}`
  const byHead = new Map(prs.map(p => [key(p.repo, p.head), p]))
  const parent = (p: SessionPr) => byHead.get(key(p.repo, p.base))
  const children = (p: SessionPr) => prs.filter(c => c !== p && parent(c) === p)
  const out: Stacked[] = []
  for (const root of prs.filter(p => !parent(p))) {
    const chain: SessionPr[] = []
    const walk = (p: SessionPr) => {
      if (chain.includes(p)) return
      chain.push(p)
      children(p).forEach(walk)
    }
    walk(root)
    chain.forEach((p, i) => out.push({ pr: p, position: chain.length > 1 ? `${i + 1}/${chain.length}` : '' }))
  }
  // A cycle has no root; keep its PRs rather than drop them.
  for (const p of prs) if (!out.some(o => o.pr === p)) out.push({ pr: p, position: '' })
  return out
}
