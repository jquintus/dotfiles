import { expect, test } from 'claude-code/testing'

import type { SessionPr } from '../types'
import { idlePhase, isSubagentTest, signalOf, stageFromText } from './phase'

const pr = (over: Partial<SessionPr>): SessionPr => ({
  key: 'k', repo: 'backend', number: 1, title: 't', url: 'u', state: 'OPEN', isDraft: false,
  ci: 'pass', failed: 0, pending: 0, copilot: 'reviewed', threads: 0, approved: false, action: null, ...over,
})
const idle = { stage: null, isAsking: false, askSummary: '', hasTimer: false, wasAborted: false, prs: [] }

test('skills place the session in the flow', () => {
  expect(stageFromText('/eng-skills:start-ticket https://linear.app/x/issue/ABC-1')).toBe('ticket')
  expect(stageFromText('/masterdevs:feature add a widget')).toBe('refine')
  expect(stageFromText('/eng-skills:pr-merge-ready')).toBe('pr')
  expect(stageFromText('why is this test failing?')).toBe(null)
  expect(signalOf('Skill', { skill: 'eng-skills:copilot-respond' }, null)).toEqual({ stage: 'pr' })
})

test('loops and their timers', () => {
  expect(signalOf('Workflow', { scriptPath: 'feature-loop.js' }, 'plan')).toEqual({ stage: 'build' })
  expect(signalOf('ScheduleWakeup', { reason: 'masterdevs 5-min status update for ABC-123 build' }, 'build')).toEqual({ stage: 'build' })
  expect(signalOf('Monitor', { description: 'PR #12 waiting on a human approval' }, 'pr')).toEqual({ stage: 'approval' })
  expect(signalOf('Bash', { command: 'gh pr merge 12 --squash' }, 'approval')).toEqual({ stage: 'merge' })
})

test('tests run in or out of a loop', () => {
  expect(signalOf('Bash', { command: 'uv run pytest tests/' }, 'build')).toEqual({ activity: 'Testing' })
  expect(signalOf('Bash', { command: 'pnpm test' }, null)).toEqual({ activity: 'Testing' })
  expect(signalOf('Bash', { command: 'git status' }, null)).toEqual({})
  expect(isSubagentTest('mcp__claude-in-chrome__navigate', {})).toBe(true)
  expect(isSubagentTest('Bash', { command: 'cmux browser open-split http://localhost:3000' })).toBe(true)
  expect(isSubagentTest('Read', {})).toBe(false)
  // A subagent testing while the main turn waits shows as testing, unless it asks.
  expect(idlePhase({ ...idle, isTesting: true, stage: 'build' })).toBe('Testing')
  expect(idlePhase({ ...idle, isTesting: true, isAsking: true })).toBe('Waiting for your answer')
})

test('edits are hand work only outside a loop', () => {
  expect(signalOf('Edit', {}, 'build')).toEqual({})
  expect(signalOf('Edit', {}, null)).toEqual({ stage: null, activity: 'Writing code' })
})

test('between turns', () => {
  expect(idlePhase({ ...idle, isAsking: true, stage: 'refine', askSummary: 'Approve the plan?' })).toBe('Waiting for plan approval')
  expect(idlePhase({ ...idle, isAsking: true })).toBe('Waiting for your answer')
  expect(idlePhase({ ...idle, hasTimer: true, stage: 'build' })).toBe('Building')
  expect(idlePhase({ ...idle, prs: [pr({})] })).toBe('PR loop done, waiting for approval')
  expect(idlePhase({ ...idle, prs: [pr({ approved: true, action: 'merge' })] })).toBe('Ready to merge')
  expect(idlePhase({ ...idle, prs: [pr({ ci: 'fail', failed: 2 })] })).toBe('PR: CI failed (2)')
  expect(idlePhase({ ...idle, prs: [pr({ state: 'MERGED' })] })).toBe('Merged')
  expect(idlePhase(idle)).toBe('Idle')
})
