import { expect, test } from 'claude-code/testing'

import type { SessionPr } from '../types'
import { describe, shortTitle, stackOrder } from './prs'

const pr = (over: Partial<SessionPr>): SessionPr => ({
  key: 'k', repo: 'backend', number: 1, title: 't', url: 'u', state: 'OPEN', isDraft: true,
  ci: 'pass', failed: 0, pending: 0, copilot: 'reviewed', threads: 0, approved: false, action: null, ...over,
})

test('one status and one next step per PR', () => {
  // Approved and green: merge.
  expect(describe(pr({ isDraft: false, approved: true, action: 'merge' }))).toEqual({ status: 'Approved', isBad: false, next: 'Merge', tone: 'good' })
  // Out of draft with only Copilot threads open: waiting on a human.
  expect(describe(pr({ isDraft: false, threads: 8, humanThreads: 0 }))).toEqual({ status: 'Awaiting review', isBad: false, next: '', tone: 'wait' })
  expect(describe(pr({ isDraft: false, threads: 3, humanThreads: 2 })).status).toBe('2 reviewer comments')
  // Draft past the Copilot loop: Josh reviews and promotes it.
  expect(describe(pr({ action: 'mark ready', threads: 3, humanThreads: 0 }))).toEqual({ status: 'Your review', isBad: false, next: 'Ready for review', tone: 'you' })
  // Draft still in the loop: wait.
  expect(describe(pr({ ci: 'pending', pending: 4 }))).toEqual({ status: 'CI running', isBad: false, next: '', tone: 'wait' })
  expect(describe(pr({ copilot: 'requested' })).status).toBe('Copilot reviewing')
  // Out of draft, Copilot is the agent's loop: still waiting on a human.
  expect(describe(pr({ isDraft: false, copilot: 'requested', threads: 1, humanThreads: 0 })).status).toBe('Awaiting review')
  expect(describe(pr({ ci: 'fail', failed: 2 }))).toEqual({ status: 'CI failed (2)', isBad: true, next: '', tone: 'bad' })
  expect(describe(pr({ action: 'conflicts' })).next).toBe('')
  expect(describe(pr({ state: 'MERGED' })).status).toBe('Merged')
})

test('titles drop the ticket and commit-type prefixes', () => {
  expect(shortTitle('ABC-123 feat(billing): store invoice totals')).toBe('store invoice totals')
  expect(shortTitle('chore: bump')).toBe('bump')
  expect(shortTitle('New VDR nav')).toBe('New VDR nav')
})

test('stacked PRs come bottom-up with their position', () => {
  const prs = [
    pr({ key: 'c', number: 1409, base: 'b2', head: 'b3' }),
    pr({ key: 'w', repo: 'web', number: 551, base: 'main', head: 'w1' }),
    pr({ key: 'a', number: 1407, base: 'main', head: 'b1' }),
    pr({ key: 'b', number: 1408, base: 'b1', head: 'b2' }),
  ]
  expect(stackOrder(prs).map(s => `${s.pr.number} ${s.position}`)).toEqual([
    '551 ', '1407 1/3', '1408 2/3', '1409 3/3',
  ])
})
