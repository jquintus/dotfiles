import { atom, read, update } from 'claude-code'
import type { EngineInterface, Register } from 'claude-code'

import type { PrItem, Question, Reply, SessionPr, Task, Ticket } from '../types'
import { describe, shortTitle, stackOrder } from './prs'
import { ago } from './tasks'
import { catchupPrompt, parseIssue, parseIssues, ticketFromBranch } from './ticket'

const PANE = 'dash'
const questions = atom({ plugin: 'dash', key: 'questions' } as const, [])
const reviews = atom({ plugin: 'dash', key: 'reviews' } as const, [])
const merges = atom({ plugin: 'dash', key: 'merges' } as const, [])
const applies = atom({ plugin: 'dash', key: 'applies' } as const, [])
const prs = atom({ plugin: 'dash', key: 'prs' } as const, [])
const tasks = atom({ plugin: 'dash', key: 'tasks' } as const, [])
const ticket = atom({ plugin: 'dash', key: 'ticket' } as const, null)
const expanded = atom({ plugin: 'dash', key: 'expanded' } as const, null)
const isLaterOpen = atom({ plugin: 'dash', key: 'isLaterOpen' } as const, false)
const myTickets = atom({ plugin: 'dash', key: 'myTickets' } as const, [])
const isTicketsOpen = atom({ plugin: 'dash', key: 'isTicketsOpen' } as const, true)
const allMine = atom({ plugin: 'dash', key: 'allMine' } as const, [])
const isOthersOpen = atom({ plugin: 'dash', key: 'isOthersOpen' } as const, false)
const tripped = atom({ plugin: 'dash', key: 'tripped' } as const, null)
const now = atom({ plugin: 'dash', key: 'now' } as const, 0)

const LOCAL_MS = 15_000
const GITHUB_MS = 90_000
const TICKET_MS = 5 * 60_000
const GET_ISSUE = 'mcp__claude_ai_Linear__get_issue'
const LIST_ISSUES = 'mcp__claude_ai_Linear__list_issues'
const qKey = (q: Question) => `${q.id}@${q.askedAt}`

let hasSessions = false
// qKey -> the model's verdict on whether that finished turn waits on Josh.
type Verdict = { isWaiting: boolean; summary: string; gist: string; replies: Reply[] }
const verdicts = new Map<string, Verdict>()

const TRIAGE = `You triage the last message a coding agent sent its user.
Decide whether it ends waiting on the user: a decision, an answer, an approval, or input it needs before it can continue. Numbered options with a recommendation or default still count as waiting.
A status report, a summary of finished work, or "I'll report when it's done" is not waiting.
When it is waiting, also offer the replies the user is most likely to send: the agent's recommendation, its default, and any options it named. With several numbered decisions, offer one reply that accepts every recommendation. At most 4 replies. Each reply is written as the user, in the first person, one line, specific enough to act on.
Reply with JSON only:
{"waiting": true or false,
 "summary": "what the user has to decide, at most 70 characters",
 "gist": "one or two plain sentences: the situation and the choice",
 "replies": [{"label": "at most 40 characters", "reply": "the message to send"}]}`

// Every model call and every send passes this shared breaker first
// (bin/gate.py: one locked state file for all sessions; a trip is sticky).
async function gate($: EngineInterface, kind: 'model' | 'send', key: string): Promise<boolean> {
  const res = await $.process.run(['python3', '-I', `${$.plugin.root}/bin/gate.py`, 'take', kind, key])
  if (res.exitCode === 0) return true
  if (res.exitCode === 2) await update($, tripped, () => res.stdout.trim())
  else $.ui.toast(res.stdout.trim())
  return false
}

async function cachePath($: EngineInterface): Promise<string> {
  return `${(await $.env.get('HOME')) ?? ''}/.claude/dash/verdicts.json`
}

// Verdicts are shared on disk, so sessions don't each pay for the same message.
async function loadVerdicts($: EngineInterface): Promise<Record<string, Verdict>> {
  try {
    return JSON.parse(await $.fs.read(await cachePath($)))
  } catch {
    return {}
  }
}

async function triage($: EngineInterface, q: Question): Promise<Verdict> {
  const fallback = { isWaiting: q.hasQuestionMark === true, summary: q.summary, gist: '', replies: [] }
  if (!(await gate($, 'model', qKey(q)))) return fallback
  const res = await $.model.complete({
    model: 'claude-haiku-5-5',
    system: TRIAGE,
    prompt: q.text.slice(-6000),
    maxTokens: 600,
    timeoutMs: 30_000,
  })
  if (!res.isAnswered) return fallback
  try {
    const j = JSON.parse(res.text.slice(res.text.indexOf('{'), res.text.lastIndexOf('}') + 1))
    const replies: Reply[] = Array.isArray(j.replies)
      ? j.replies
          .filter((r: any) => r?.label && r?.reply)
          .slice(0, 4)
          .map((r: any) => ({ label: String(r.label).slice(0, 40), reply: String(r.reply).replace(/\s+/g, ' ') }))
      : []
    return { isWaiting: j.waiting === true, summary: String(j.summary || q.summary), gist: String(j.gist || ''), replies }
  } catch {
    return fallback
  }
}

const MORE_CONTEXT =
  "Before I decide, give me more context on this: what led here, what each option changes, and what you'd worry about with each. Keep it short."

// Types `text` into the session's prompt and submits it, as if Josh typed it.
// Refuses when the prompt already holds a draft, so it never mixes with one.
const inFlight = new Set<string>()

async function send($: EngineInterface, q: Question, text: string) {
  // A second click while the first is in flight is dropped before any await.
  if (inFlight.has(q.id)) return
  inFlight.add(q.id)
  try {
    await sendOnce($, q, text)
  } finally {
    inFlight.delete(q.id)
  }
}

async function sendOnce($: EngineInterface, q: Question, text: string) {
  if (!q.surface) {
    $.ui.toast(`${q.name}: no cmux pane to send to`)
    return
  }
  const screen = await $.process.run(['cmux', 'read-screen', '--surface', q.surface, '--lines', '15'])
  const prompt = [...screen.stdout.matchAll(/^❯ ?(.*)$/gm)].pop()?.[1]?.trim()
  if (prompt === undefined) {
    $.ui.toast(`${q.name}: couldn't find its prompt; not sent`)
    return
  }
  if (prompt) {
    $.ui.toast(`${q.name} has a draft in its prompt; not sent`)
    return
  }
  if (!(await gate($, 'send', q.id))) return
  await $.process.run(['cmux', 'send', '--surface', q.surface, text])
  await $.process.run(['cmux', 'send-key', '--surface', q.surface, 'Enter'])
  $.ui.toast(`Sent to ${q.name}: ${text.slice(0, 60)}`)
  await update($, questions, list => list.filter(x => qKey(x) !== qKey(q)))
  await update($, expanded, () => null)
}

// AskUserQuestion always waits; a finished turn waits if the model says so.
// At most one uncached message is triaged per refresh, so a burst of new
// sessions is paced by the 15s timer, never by a loop.
async function waiting($: EngineInterface, candidates: Question[]): Promise<Question[]> {
  const disk = await loadVerdicts($)
  let hasSpent = false
  const out: Question[] = []
  for (const q of candidates) {
    if (q.kind === 'ask') {
      out.push(q)
      continue
    }
    let v = verdicts.get(qKey(q)) ?? disk[qKey(q)]
    if (!v && !hasSpent) {
      hasSpent = true
      v = await triage($, q)
      disk[qKey(q)] = v
      try {
        await $.fs.write(await cachePath($), JSON.stringify(disk))
      } catch (err) {
        fail($, 'verdict cache', err)
      }
    }
    if (!v) continue
    verdicts.set(qKey(q), v)
    if (v.isWaiting) out.push({ ...q, summary: v.summary, gist: v.gist, replies: v.replies })
  }
  return out
}
let hasGithub = false
let isTicketLoading = false

// Errors go to the debug log (`claude --debug`), never the transcript.
function fail($: EngineInterface, what: string, err: unknown) {
  $.ui.log(`dash: ${what}: ${String(err).slice(0, 300)}`, { to: 'debug' })
}

async function scan($: EngineInterface, ...args: string[]): Promise<any> {
  const res = await $.process.run(['python3', '-I', `${$.plugin.root}/bin/scan.py`, ...args], { timeoutMs: 45_000 })
  if (res.exitCode !== 0) throw new Error(`scan ${args[0]} exited ${res.exitCode}: ${res.stderr.slice(-300)}`)
  return JSON.parse(res.stdout)
}

// Toast each item that wasn't there last time (never on the first load).
function announce($: EngineInterface, before: string[], items: { key: string; text: string }[], isFirst: boolean) {
  if (isFirst) return
  for (const i of items) if (!before.includes(i.key)) $.ui.toast(i.text)
}

async function resetBreaker($: EngineInterface) {
  await $.process.run(['python3', '-I', `${$.plugin.root}/bin/gate.py`, 'reset'])
  await update($, tripped, () => null)
}

async function refreshLocal($: EngineInterface) {
  try {
    const st = await $.process.run(['python3', '-I', `${$.plugin.root}/bin/gate.py`, 'status'])
    const t = JSON.parse(st.stdout).tripped
    await update($, tripped, () => (t ? String(t.reason) : null))
  } catch (err) {
    fail($, 'gate status', err)
  }
  try {
    const data = await scan($, 'sessions')
    const before = (await read($, questions)).map(qKey)
    const next = await waiting($, data.questions as Question[])
    announce($, before, next.map(q => ({ key: qKey(q), text: `${q.name} is asking: ${q.summary.slice(0, 80)}` })), !hasSessions)
    hasSessions = true
    await update($, questions, () => next)
  } catch (err) {
    fail($, 'sessions', err)
  }
}

async function refreshGithub($: EngineInterface) {
  try {
    const data = await scan($, 'github')
    const toast = (label: string, before: PrItem[], next: PrItem[]) =>
      announce($, before.map(p => p.key), next.map(p => ({ key: p.key, text: `${label}: ${p.repo}#${p.number}` })), !hasGithub)
    toast('Ready to merge', await read($, merges), data.merges)
    toast('Ready to apply', await read($, applies), data.applies)
    await update($, reviews, () => data.reviews as PrItem[])
    await update($, merges, () => data.merges as PrItem[])
    await update($, applies, () => data.applies as PrItem[])
    await update($, allMine, () => data.mine as SessionPr[])
    hasGithub = true
  } catch (err) {
    fail($, 'github', err)
  }
  try {
    const data = await scan($, 'here', await $.session.id())
    if (data.ticketHint && !ticketHint) {
      ticketHint = data.ticketHint
      void refreshTicket($)
    }
    await update($, prs, () => data.prs as SessionPr[])
    await update($, tasks, () => data.tasks as Task[])
  } catch (err) {
    fail($, 'here', err)
  }
}

// Only the tasks change fast; refresh them with the local scan's cadence.
async function refreshTasks($: EngineInterface) {
  try {
    const data = await scan($, 'here', await $.session.id(), '--no-prs')
    await update($, tasks, () => data.tasks as Task[])
  } catch (err) {
    fail($, 'tasks', err)
  }
}

let ticketHint: string | null = null

// The branch names the ticket; mid-rebase (detached HEAD) the session name or
// a linked PR's title does.
async function currentTicketId($: EngineInterface): Promise<string | null> {
  const { stdout } = await $.process.run(['git', 'rev-parse', '--abbrev-ref', 'HEAD'])
  return ticketFromBranch(stdout.trim()) ?? ticketHint
}

// Linear connects after session start, so a miss retries in 20s, not 5 min.
async function refreshTicket($: EngineInterface, attempt = 0) {
  if (isTicketLoading) return
  isTicketLoading = true
  try {
    const id = await currentTicketId($)
    if (!id) return
    const ran = await $.tool.call({ tool: GET_ISSUE, id, fields: ['title', 'status', 'statusType', 'url'] })
    const next = ran.deny === undefined && !ran.isError ? parseIssue(id, ran.result) : null
    if (next) await update($, ticket, () => next)
    else if (attempt < 15) $.clock.after(20_000, () => void refreshTicket($, attempt + 1))
  } catch (err) {
    fail($, 'ticket', err)
    if (attempt < 15) $.clock.after(20_000, () => void refreshTicket($, attempt + 1))
  } finally {
    isTicketLoading = false
  }
}

// Links in a pane aren't clickable in every terminal; a Button always is.
async function openUrl($: EngineInterface, url: string) {
  await $.process.run(['open', url])
}

async function refreshMyTickets($: EngineInterface, attempt = 0) {
  try {
    const ran = await $.tool.call({
      tool: LIST_ISSUES,
      assignee: 'me',
      fields: ['title', 'status', 'statusType', 'url'],
      limit: 100,
    })
    const list = ran.deny === undefined && !ran.isError ? parseIssues(ran.result) : []
    if (list.length) {
      await update($, myTickets, () => list)
      // The browser dash can't reach Linear; it reads this copy.
      await $.fs.write(`${(await $.env.get('HOME')) ?? ''}/.claude/dash/tickets.json`, JSON.stringify(list))
    }
    else if (attempt < 15) $.clock.after(20_000, () => void refreshMyTickets($, attempt + 1))
  } catch (err) {
    fail($, 'my tickets', err)
    if (attempt < 15) $.clock.after(20_000, () => void refreshMyTickets($, attempt + 1))
  }
}

async function toggle($: EngineInterface): Promise<string> {
  const pane = (await $.ui.panes()).find(p => p.id === PANE)
  if (pane?.isShown) {
    await $.ui.close({ id: PANE })
    return 'Dash closed.'
  }
  await $.ui.open({ id: PANE, title: 'Dash' })
  void refreshLocal($)
  void refreshGithub($)
  return 'Dash opened.'
}

// Ready for review (out of draft + request the team) is reversible, so one
// click does it, through the shared actions.py and its breaker. Merge and
// apply aren't, so those open the PR to finish there.
async function act($: EngineInterface, next: string, url: string) {
  if (next !== 'Ready for review') {
    await openUrl($, url)
    return
  }
  const res = await $.process.run(['python3', '-I', `${$.plugin.root}/bin/actions.py`, 'ready', url], { timeoutMs: 90_000 })
  $.ui.toast(`${url.split('/').slice(-3).join('/')}: ${res.stdout.trim() || res.stderr.trim().slice(0, 120)}`)
  void refreshGithub($)
}

async function goTo($: EngineInterface, q: Question) {
  if (!q.workspace || !q.surface) return
  await $.process.run(['cmux', 'select-workspace', '--workspace', q.workspace])
  await $.process.run(['cmux', 'focus-panel', '--panel', q.surface, '--workspace', q.workspace])
}

export const register: Register = on => {
  on('session.start', async ($, e, next) => {
    await $.command.register({ name: 'dash', description: 'Toggle the pane of what needs you and what you are waiting on', immediate: true })
    await $.command.register({ name: 'catchup', description: "Summarize what's been done on this branch's ticket so far" })
    void refreshLocal($)
    void refreshGithub($)
    void refreshTicket($)
    void refreshMyTickets($)
    $.clock.every(LOCAL_MS, () => {
      void refreshLocal($)
      void refreshTasks($)
    })
    $.clock.every(GITHUB_MS, () => void refreshGithub($))
    $.clock.every(TICKET_MS, () => {
      void refreshTicket($)
      void refreshMyTickets($)
    })
    $.clock.every(30_000, async () => update($, now, () => Date.now()))

    return next(e)
  })

  on('command.run', { command: 'dash' }, async $ => ({ text: await toggle($) }))

  on('command.run', { command: 'catchup' }, async ($, e) => {
    const t = await read($, ticket)
    const id = e.args.trim().toUpperCase() || t?.id || (await currentTicketId($))
    if (!id) return { text: 'No ticket on this branch. Try /catchup ABC-123.' }
    const cwd = await $.session.cwd()
    const transcripts = `~/.claude/projects/${cwd.replace(/[^A-Za-z0-9]/g, '-')}/*.jsonl`
    void $.prompt.submit({ text: catchupPrompt(id, t?.id === id ? t.title : '', transcripts) })

    return { text: `Catching up on ${id}…` }
  })

  // A Linear write likely moved the ticket; a git/gh command likely moved a PR.
  on('tool.call', async ($, e, next) => {
    const ran = await next(e)
    if (e.tool.startsWith('mcp__claude_ai_Linear__save')) {
      void refreshTicket($)
      void refreshMyTickets($)
    }
    if (e.tool === 'Bash' && /\b(git push|gh (pr|api))\b/.test((e as { command?: string }).command ?? '')) {
      void refreshGithub($)
    }

    return ran
  }).catch(($, e, next) => next(e))

  // One clickable line above the prompt: what needs you, and the pane toggle.
  on('ui.render', { component: 'AbovePrompt' }, async ($, e, next) => {
    if (e.props.hasSurvey) return next(e)
    const counts = [
      [(await read($, questions)).length, 'question'],
      [(await read($, merges)).length, 'to merge'],
      [(await read($, applies)).length, 'to apply'],
    ] as const
    const todo = counts.filter(([n]) => n > 0).map(([n, w]) => (w === 'question' && n > 1 ? `${n} questions` : `${n} ${w}`))
    const trip = await read($, tripped)
    const { Box, Button } = $.ui.resolve(e)
    const below = await next(e)

    return (
      <Box flexDirection="column">
        <Button key="dash-toggle" label={['Dash', ...(trip ? ['⚠ breaker tripped'] : []), ...todo].join(' · ')} onPress={() => toggle($)} />
        {below}
      </Box>
    )
  })

  on('ui.render', { component: 'Pane', requestId: PANE }, async ($, e) => {
    const { Box, Button, Text } = $.ui.resolve(e)
    const t = (await read($, now)) || (await $.clock.now())
    const since = (iso: string | null) => (iso ? ago(t - Date.parse(iso)) : '')
    const tk: Ticket | null = await read($, ticket)
    const trip = await read($, tripped)
    const mine = await read($, prs)
    const running = await read($, tasks)
    const qs = await read($, questions)
    const open = await read($, expanded)
    // Your own PRs are priorities; other people's review requests can wait.
    // PRs already listed in This session (with their action) aren't repeated.
    const todo = [
      ['Merge', await read($, merges)],
      ['Apply (Atlantis)', await read($, applies)],
    ] as const
    const later = await read($, reviews)
    const assigned = await read($, myTickets)
    // A PR belongs to this session when the session linked it, or when its
    // title carries this session's ticket (ABC-123 …).
    const everyMine = await read($, allMine)
    const linkedKeys = mine.map(p => p.key)
    const byTicket = tk ? everyMine.filter(p => !linkedKeys.includes(p.key) && p.title.includes(tk.id)) : []
    const sessionPrs = [...mine, ...byTicket]
    const sessionKeys = sessionPrs.map(p => p.key)
    const others = everyMine.filter(p => !sessionKeys.includes(p.key))
    const todoHere = todo.map(([verb, list]) => [verb, list.filter(p => !sessionKeys.includes(p.key))] as const)
    const total = qs.length + todoHere.reduce((n, [, l]) => n + l.length, 0)
    const othersOpen = await read($, isOthersOpen)
    const ticketsOpen = await read($, isTicketsOpen)
    const laterOpen = await read($, isLaterOpen)


    // Fixed column widths keep every row aligned.
    const W = { link: 25, status: 19, next: 22 }
    const head = (cols: string[]) => (
      <Box>
        <Box width={2} flexShrink={0} />
        <Box width={W.link} flexShrink={0}><Text dimColor>{cols[0]}</Text></Box>
        <Box width={W.status} flexShrink={0}><Text dimColor>{cols[1]}</Text></Box>
        <Box width={W.next} flexShrink={0}><Text dimColor>{cols[2]}</Text></Box>
        <Text dimColor>{cols[3]}</Text>
      </Box>
    )
    const TONE = { good: 'success', you: 'suggestion', wait: 'warning', bad: 'error', done: 'inactive' } as const
    const row = (key: string, label: string, url: string, status: string, tone: keyof typeof TONE | null, next: string, title: string, position = '') => (
      <Box key={key}>
        <Box width={2} flexShrink={0} />
        <Box width={W.link} flexShrink={0}>
          <Button key={`open-${key}`} label={label} onPress={() => openUrl($, url)} />
          {position ? <Text dimColor> {position}</Text> : null}
        </Box>
        <Box width={W.status} flexShrink={0}><Text color={tone ? TONE[tone] : undefined} wrap="truncate-end">{status}</Text></Box>
        <Box width={W.next} flexShrink={0}>
          {next ? <Button key={`act-${key}`} label={next} onPress={() => act($, next, url)} /> : <Text> </Text>}
        </Box>
        <Box flexShrink={1}><Text dimColor wrap="truncate-end">{title}</Text></Box>
      </Box>
    )

    return (
      <Box flexDirection="column">
        {trip && (
          <Box flexDirection="column" marginBottom={1}>
            <Text color="error" bold>Breaker tripped: {trip}</Text>
            <Text dimColor>Model calls and sends are off in every session until you reset.</Text>
            <Button key="reset-breaker" label="Reset breaker" onPress={() => resetBreaker($)} />
          </Box>
        )}
        <Text bold>This session</Text>
        {tk ? (
          <Box>
            <Box width={2} flexShrink={0} />
            <Box width={W.link} flexShrink={0}><Button key="ticket" label={tk.id} onPress={() => openUrl($, tk.url)} /></Box>
            <Box width={W.status} flexShrink={0}><Text>{tk.status}</Text></Box>
            <Box flexShrink={1}><Text dimColor wrap="truncate-end">{tk.title}</Text></Box>
          </Box>
        ) : (
          <Text dimColor>  No ticket on this branch.</Text>
        )}
        <Text> </Text>
        {sessionPrs.length === 0 ? (
          <Text dimColor>  No PRs linked yet.</Text>
        ) : (
          head(['PR', 'Status', 'Next for you', 'Title'])
        )}
        {stackOrder(sessionPrs).map(({ pr: p, position }) => {
          const d = describe(p)
          return row(p.key, `${p.repo}#${p.number}`, p.url, d.status, d.tone, d.next, shortTitle(p.title), position)
        })}
        {running.length > 0 && <Text> </Text>}
        {running.length > 0 && head(['Running', 'For', '', ''])}
        {running.map(task => (
          <Box key={task.id}>
            <Box width={2} flexShrink={0} />
            <Box width={W.link} flexShrink={0}><Text>{task.kind}</Text></Box>
            <Box width={W.status} flexShrink={0}>
              <Text>
                {task.delaySeconds !== undefined && task.startedAt
                  ? `due in ${ago(Date.parse(task.startedAt) + task.delaySeconds * 1000 - t)}`
                  : since(task.startedAt)}
              </Text>
            </Box>
            <Box flexShrink={1}><Text dimColor wrap="truncate-end">{task.label}</Text></Box>
          </Box>
        ))}

        <Text> </Text>
        <Text bold>You need to ({total})</Text>
        {total === 0 && <Text dimColor>  Nothing.</Text>}
        {total > 0 && head(['Where', 'Waiting', 'Do', 'What'])}
        {qs.map(q => (
          <Box flexDirection="column" key={qKey(q)}>
            <Box>
              <Box width={2} flexShrink={0} />
              <Box width={W.link} flexShrink={0}>
                <Button
                  key={`q-${qKey(q)}`}
                  label={`${open === qKey(q) ? '▾' : '▸'} ${q.name}`.slice(0, W.link - 6)}
                  onPress={() => update($, expanded, cur => (cur === qKey(q) ? null : qKey(q)))}
                />
              </Box>
              <Box width={W.status} flexShrink={0}><Text>{since(q.askedAt)}</Text></Box>
              <Box width={W.next} flexShrink={0}>
                <Button
                  key={`ans-${qKey(q)}`}
                  label="Answer"
                  onPress={() => update($, expanded, cur => (cur === qKey(q) ? null : qKey(q)))}
                />
              </Box>
              <Box flexShrink={1}><Text dimColor wrap="truncate-end">{q.summary}</Text></Box>
            </Box>
            {open === qKey(q) && (
              <Box flexDirection="column" marginLeft={4} marginY={1}>
                {q.gist && <Text bold>{q.gist}</Text>}
                {q.kind === 'ask' && <Text dimColor>Answer this one in the session.</Text>}
                {(q.replies ?? []).length > 0 && (
                  <Box flexDirection="column" marginTop={1}>
                    {(q.replies ?? []).map((r, i) => (
                      <Box key={`r-${i}`}>
                        <Box width={44} flexShrink={0}>
                          <Button key={`reply-${qKey(q)}-${i}`} label={r.label} onPress={() => send($, q, r.reply)} />
                        </Box>
                        <Box flexShrink={1}><Text dimColor wrap="truncate-end">{r.reply}</Text></Box>
                      </Box>
                    ))}
                  </Box>
                )}
                <Box marginTop={1}>
                  {q.kind === 'text' && q.surface && (
                    <Button key={`more-${qKey(q)}`} label="More context" onPress={() => send($, q, MORE_CONTEXT)} />
                  )}
                  <Text> </Text>
                  {q.surface && <Button key={`go-${qKey(q)}`} label="Go to session" onPress={() => goTo($, q)} />}
                </Box>
                <Box marginTop={1} flexDirection="column">
                  {q.prompt && <Text dimColor wrap="truncate-end">You asked: {q.prompt.split('\n')[0]}</Text>}
                  <Text>{q.text.split('\n').slice(-30).join('\n')}</Text>
                </Box>
              </Box>
            )}
          </Box>
        ))}
        {todoHere.flatMap(([verb, list]) =>
          list.map(p =>
            row(`${verb}-${p.key}`, `${p.repo.split('/').pop()}#${p.number}`, p.url, '', null,
              verb === 'Apply (Atlantis)' ? 'Apply' : verb, shortTitle(p.title)),
          ),
        )}

        {others.length > 0 && (
          <Box flexDirection="column" marginTop={1}>
            <Button
              key="others"
              label={`${othersOpen ? '▾' : '▸'} My other PRs (${others.length})`}
              onPress={() => update($, isOthersOpen, v => !v)}
            />
            {othersOpen && head(['PR', 'Status', 'Next for you', 'Title'])}
            {othersOpen &&
              stackOrder(others).map(({ pr: p, position }) => {
                const d = describe(p)
                return row(`other-${p.key}`, `${p.repo}#${p.number}`, p.url, d.status, d.tone, d.next, shortTitle(p.title), position)
              })}
          </Box>
        )}

        {assigned.length > 0 && (
          <Box flexDirection="column" marginTop={1}>
            <Button
              key="tickets"
              label={`${ticketsOpen ? '▾' : '▸'} My tickets (${assigned.length})`}
              onPress={() => update($, isTicketsOpen, v => !v)}
            />
            {ticketsOpen &&
              assigned.map(a => (
                <Box key={`tk-${a.id}`}>
                  <Box width={2} flexShrink={0} />
                  <Box width={W.link} flexShrink={0}>
                    <Button key={`open-tk-${a.id}`} label={a.id} onPress={() => openUrl($, a.url)} />
                  </Box>
                  <Box width={W.status} flexShrink={0}>
                    <Text bold={a.id === tk?.id}>{a.status}</Text>
                  </Box>
                  <Box flexShrink={1}>
                    <Text dimColor wrap="truncate-end">{a.title}</Text>
                  </Box>
                </Box>
              ))}
          </Box>
        )}

        {later.length > 0 && (
          <Box flexDirection="column" marginTop={1}>
            <Button
              key="later"
              label={`${laterOpen ? '▾' : '▸'} Later (${later.length})`}
              onPress={() => update($, isLaterOpen, v => !v)}
            />
            {laterOpen && head(['PR', 'Author', 'Do', 'Title'])}
            {laterOpen &&
              later.map(p =>
                row(`later-${p.key}`, `${p.repo.split('/').pop()}#${p.number}`, p.url, p.author ?? '', null, 'Review', shortTitle(p.title)),
              )}
          </Box>
        )}
      </Box>
    )
  })
}
