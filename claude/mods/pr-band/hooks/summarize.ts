import type { Ci, Copilot, Pr } from '../types'

export const QUERY = `query($owner: String!, $name: String!, $branch: String!) {
  repository(owner: $owner, name: $name) {
    pullRequests(headRefName: $branch, states: OPEN, first: 1) {
      nodes {
        number url isDraft reviewDecision
        commits(last: 1) { nodes { commit {
          committedDate
          statusCheckRollup { contexts(first: 100) { nodes {
            __typename
            ... on CheckRun { status conclusion }
            ... on StatusContext { state }
          } } }
        } } }
        reviewRequests(first: 20) { nodes { requestedReviewer {
          ... on Bot { login } ... on User { login }
        } } }
        latestReviews(first: 20) { nodes { author { login } submittedAt } }
        reviewThreads(first: 100) { nodes { isResolved } }
      }
    }
  }
}`

const IS_COPILOT = /copilot/i
const PASSING = new Set(['SUCCESS', 'NEUTRAL', 'SKIPPED'])

// owner/name from an ssh or https GitHub remote, null for anything else.
export function parseRemote(url: string): { owner: string; name: string } | null {
  const m = url.trim().match(/github\.com[:/]([^/]+)\/([^/]+?)(\.git)?$/)
  return m ? { owner: m[1]!, name: m[2]! } : null
}

export function summarize(json: any): Pr | null {
  const pr = json?.data?.repository?.pullRequests?.nodes?.[0]
  if (!pr) return null

  const commit = pr.commits?.nodes?.[0]?.commit
  let passed = 0
  let failed = 0
  let pending = 0
  for (const c of commit?.statusCheckRollup?.contexts?.nodes ?? []) {
    if (c.__typename === 'CheckRun') {
      if (c.status !== 'COMPLETED') pending++
      else if (PASSING.has(c.conclusion)) passed++
      else failed++
    } else {
      if (c.state === 'SUCCESS') passed++
      else if (c.state === 'PENDING' || c.state === 'EXPECTED') pending++
      else failed++
    }
  }
  const ci: Ci = failed ? 'fail' : pending ? 'pending' : passed ? 'pass' : 'none'

  const requested = (pr.reviewRequests?.nodes ?? []).some((r: any) =>
    IS_COPILOT.test(r.requestedReviewer?.login ?? ''),
  )
  const review = (pr.latestReviews?.nodes ?? []).find((r: any) =>
    IS_COPILOT.test(r.author?.login ?? ''),
  )
  const copilot: Copilot = requested
    ? 'requested'
    : !review
      ? 'none'
      : commit && review.submittedAt < commit.committedDate
        ? 'stale'
        : 'reviewed'

  return {
    number: pr.number,
    url: pr.url,
    isDraft: pr.isDraft,
    ci,
    passed,
    failed,
    pending,
    copilot,
    openThreads: (pr.reviewThreads?.nodes ?? []).filter((t: any) => !t.isResolved).length,
    approved: pr.reviewDecision === 'APPROVED',
  }
}

// Toasts worth raising when the same PR moves from `prev` to `next`.
export function transitions(prev: Pr | null, next: Pr | null): string[] {
  if (!prev || !next || prev.number !== next.number) return []
  const out: string[] = []
  if (prev.ci === 'pending' && next.ci === 'pass') out.push(`PR #${next.number}: CI passed`)
  if (prev.ci !== 'fail' && next.ci === 'fail') out.push(`PR #${next.number}: CI failed (${next.failed})`)
  if (prev.copilot === 'requested' && next.copilot === 'reviewed') {
    out.push(`PR #${next.number}: Copilot reviewed, ${next.openThreads} open threads`)
  }
  return out
}
