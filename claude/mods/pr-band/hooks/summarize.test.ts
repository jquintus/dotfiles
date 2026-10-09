import { expect, test } from 'claude-code/testing'

import { parseRemote, summarize, transitions } from './summarize'

const response = (pr: object | null) => ({
  data: { repository: { pullRequests: { nodes: pr ? [pr] : [] } } },
})

const base = {
  number: 7,
  url: 'https://github.com/o/r/pull/7',
  isDraft: false,
  reviewDecision: null,
  commits: { nodes: [{ commit: {
    committedDate: '2026-10-08T10:00:00Z',
    statusCheckRollup: { contexts: { nodes: [
      { __typename: 'CheckRun', status: 'COMPLETED', conclusion: 'SUCCESS' },
      { __typename: 'CheckRun', status: 'IN_PROGRESS', conclusion: null },
    ] } },
  } }] },
  reviewRequests: { nodes: [{ requestedReviewer: { login: 'copilot-pull-request-reviewer' } }] },
  latestReviews: { nodes: [] },
  reviewThreads: { nodes: [{ isResolved: false }, { isResolved: true }] },
}

test('parses ssh and https remotes', () => {
  expect(parseRemote('git@github.com:acme/backend.git')).toEqual({ owner: 'acme', name: 'backend' })
  expect(parseRemote('https://github.com/jquintus/dotfiles\n')).toEqual({ owner: 'jquintus', name: 'dotfiles' })
  expect(parseRemote('https://gitlab.com/a/b')).toBe(null)
})

test('no open PR is null', () => {
  expect(summarize(response(null))).toBe(null)
})

test('pending CI and requested Copilot', () => {
  expect(summarize(response(base))).toEqual(expect.objectContaining({
    ci: 'pending', passed: 1, pending: 1, copilot: 'requested', openThreads: 1,
  }))
})

test('Copilot review older than the head commit is stale', () => {
  const pr = {
    ...base,
    reviewRequests: { nodes: [] },
    latestReviews: { nodes: [{ author: { login: 'copilot-pull-request-reviewer' }, submittedAt: '2026-10-08T09:00:00Z' }] },
  }
  expect(summarize(response(pr))?.copilot).toBe('stale')
})

test('toasts when CI finishes and Copilot lands', () => {
  const prev = summarize(response(base))!
  const next = { ...prev, ci: 'pass' as const, copilot: 'reviewed' as const }
  expect(transitions(prev, next)).toEqual([
    'PR #7: CI passed',
    'PR #7: Copilot reviewed, 1 open threads',
  ])
  expect(transitions(prev, { ...next, number: 8 })).toEqual([])
})
