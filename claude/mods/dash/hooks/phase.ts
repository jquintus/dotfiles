import type { SessionPr } from '../types'
import { describe } from './prs'

// Where a session is in Josh's usual flow: start-ticket, then
// /masterdevs:feature (refine, plan, unattended build), then pr-merge-ready,
// then a human approval, then merge. Sticky across turns.
export type Stage = 'ticket' | 'refine' | 'plan' | 'build' | 'pr' | 'approval' | 'merge'

export const STAGE_LABEL: Record<Stage, string> = {
  ticket: 'Starting ticket',
  refine: 'Refining the brief',
  plan: 'Planning',
  build: 'Building',
  pr: 'In PR loop',
  approval: 'Waiting for approval',
  merge: 'Merging',
}

// Skills arrive as a slash command in the prompt or a Skill tool call; match both.
const SKILLS: [RegExp, Stage][] = [
  [/\b(start-ticket|adopt-ticket)\b/, 'ticket'],
  [/\bmasterdevs:(feature|refine)\b/, 'refine'],
  [/\bmasterdevs:plan\b/, 'plan'],
  [/\b(pr-merge-ready|pr-push|copilot-respond|merge-origin)\b/, 'pr'],
  [/\bmerge-it\b/, 'merge'],
]

export function stageFromText(text: string): Stage | null {
  const head = text.slice(0, 400)
  for (const [re, stage] of SKILLS) if (re.test(head)) return stage
  return null
}

// What a tool call says about the stage (sticky) or the activity (this turn only).
export type Signal = { stage?: Stage | null; activity?: string }

export const TEST_CMD = /\b(pytest|vitest|jest|playwright|unittest|tox|go test|cargo test|make test|(npm|pnpm|yarn|bun)( run)? test|plugin test)\b/

// A subagent's test run or browser session is testing too (manual QA); the
// main loop's browser use without a loop is investigation (see signalOf).
export function isSubagentTest(tool: string, input: Record<string, any>): boolean {
  if (tool === 'Bash') return TEST_CMD.test(String(input.command ?? '')) || /\bcmux browser\b/.test(String(input.command ?? ''))
  return /^mcp__(claude-in-chrome|cmux-cua)__/.test(tool)
}

export function signalOf(tool: string, input: Record<string, any>, current: Stage | null): Signal {
  const cmd = String(input.command ?? '')
  const reason = String(input.reason ?? input.description ?? '')
  switch (tool) {
    case 'Skill': {
      const stage = stageFromText(String(input.skill ?? ''))
      return stage ? { stage } : {}
    }
    case 'Agent': {
      const type = String(input.subagent_type ?? '')
      if (/masterdevs:architect|^Plan$/.test(type)) return { stage: 'plan' }
      if (/masterdevs:(engineer|reviewer)/.test(type)) return { stage: 'build' }
      if (type === 'eng-skills:pr-reviewer') return { stage: 'pr' }
      return current ? {} : { activity: 'Researching' }
    }
    case 'Workflow':
      return { stage: 'build' }
    // The loops wait on timers between turns; the reason names what for.
    case 'ScheduleWakeup':
    case 'Monitor':
      if (/approval|gate check|merge-it/i.test(reason)) return { stage: 'approval' }
      if (/masterdevs|build/i.test(reason)) return { stage: 'build' }
      if (/\bPR\b|CI|copilot/i.test(reason)) return { stage: 'pr' }
      return {}
    case 'AskUserQuestion':
      return { activity: 'Waiting for your answer' }
    case 'Bash':
      if (/\bgh pr merge\b/.test(cmd)) return { stage: 'merge' }
      if (/\bgh pr (create|ready)\b/.test(cmd)) return { stage: 'pr' }
      if (/\b(wt switch|git worktree add)\b/.test(cmd)) return { stage: 'ticket' }
      // Lasts only while the command runs (register.tsx clears it after).
      if (TEST_CMD.test(cmd)) return { activity: 'Testing' }
      return {}
    case 'Edit':
    case 'Write':
    case 'NotebookEdit':
      // Inside a loop, edits are the loop's; on their own they are hand work.
      if (current === 'build' || current === 'pr') return {}
      return { stage: null, activity: 'Writing code' }
  }
  if (/^mcp__(datadog|sentry|claude-in-chrome)__/.test(tool) && !current) return { activity: 'Investigating' }
  return {}
}

// Between turns: what the session is waiting on.
export function idlePhase(o: {
  stage: Stage | null
  isAsking: boolean
  askSummary: string
  hasTimer: boolean
  wasAborted: boolean
  isTesting?: boolean
  prs: SessionPr[]
}): string {
  if (o.isAsking) {
    if ((o.stage === 'refine' || o.stage === 'plan') && /\bplan\b/i.test(o.askSummary)) return 'Waiting for plan approval'
    return 'Waiting for your answer'
  }
  // engineers test constantly inside a build, so their test runs never mask Building.
  if (o.isTesting && o.stage !== 'build') return 'Testing'
  if (o.hasTimer && o.stage) return STAGE_LABEL[o.stage]
  const open = o.prs.find(p => p.state === 'OPEN')
  if (open) {
    const status = describe(open).status
    if (status === 'Approved') return 'Ready to merge'
    if (status === 'Awaiting review') return 'PR loop done, waiting for approval'
    if (status === 'Your review') return 'Ready for your review'
    return `PR: ${status}`
  }
  if (o.prs.some(p => p.state === 'MERGED')) return 'Merged'
  if (o.wasAborted) return 'Stopped'
  return 'Idle'
}

// The pill: needs-you states stand out; the rest stay quiet.
export function pillOf(phase: string): { icon: string; color: string } {
  if (/^(Waiting for your|Waiting for plan|Ready for your|Ready to merge)/.test(phase)) return { icon: 'hand.raised.fill', color: '#FFC04D' }
  if (/^PR: (CI failed|Merge conflicts)/.test(phase)) return { icon: 'exclamationmark.triangle.fill', color: '#FF8A80' }
  if (/waiting for approval|^PR:/i.test(phase)) return { icon: 'clock', color: '#E5E5EA' }
  if (phase === 'Building' || phase === 'Writing code' || phase === 'Testing') return { icon: 'hammer.fill', color: '#A8D8FF' }
  if (phase === 'Idle' || phase === 'Merged' || phase === 'Stopped') return { icon: 'moon.fill', color: '#C7C7CC' }
  return { icon: 'sparkle', color: '#A8D8FF' }
}
