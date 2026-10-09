import { atom, read, update } from 'claude-code'
import type { EngineInterface, Register } from 'claude-code'

import type { Pr } from '../types'
import { parseRemote, QUERY, summarize, transitions } from './summarize'

const pr = atom({ plugin: 'pr-band', key: 'pr' } as const, null)

const POLL_MS = 60_000
// Bash commands after which the PR state has likely changed.
const TRIGGERS = /\b(git (push|checkout|switch)|gh (pr|api))\b/

let isRefreshing = false

async function refresh($: EngineInterface) {
  if (isRefreshing) return
  isRefreshing = true
  try {
    const branch = (await $.process.run(['git', 'rev-parse', '--abbrev-ref', 'HEAD'])).stdout.trim()
    const remote = parseRemote((await $.process.run(['git', 'remote', 'get-url', 'origin'])).stdout)
    let next: Pr | null = null
    if (branch && branch !== 'HEAD' && remote) {
      const res = await $.process.run([
        'gh', 'api', 'graphql',
        '-f', `query=${QUERY}`,
        '-F', `owner=${remote.owner}`,
        '-F', `name=${remote.name}`,
        '-F', `branch=${branch}`,
      ])
      if (res.exitCode !== 0) return
      next = summarize(JSON.parse(res.stdout))
    }
    const prev = await read($, pr)
    for (const msg of transitions(prev, next)) $.ui.toast(msg)
    await update($, pr, () => next)
  } catch {
    // Not a repo, gh missing or offline: leave the band as it was.
  } finally {
    isRefreshing = false
  }
}

export const register: Register = on => {
  on('session.start', async ($, e, next) => {
    void refresh($)
    $.clock.every(POLL_MS, () => void refresh($))

    return next(e)
  })

  on('tool.call', { tool: 'Bash' }, async ($, e, next) => {
    const ran = await next(e)
    if (TRIGGERS.test(e.command)) void refresh($)

    return ran
  }).catch(($, e, next) => next(e))

  on('ui.render', { component: 'AbovePrompt' }, async ($, e, next) => {
    const p = await read($, pr)
    if (e.props.hasSurvey || !p) return next(e)

    const { Box, Link, Text } = $.ui.resolve(e)
    const ci =
      p.ci === 'pass' ? <Text color="success">CI ✓ {p.passed}</Text>
      : p.ci === 'fail' ? <Text color="error">CI ✗ {p.failed} failed</Text>
      : p.ci === 'pending' ? <Text color="warning">CI … {p.pending} running</Text>
      : <Text dimColor>CI none</Text>
    const copilot =
      p.copilot === 'requested' ? <Text color="warning">Copilot requested</Text>
      : p.copilot === 'reviewed' ? <Text color="success">Copilot reviewed</Text>
      : p.copilot === 'stale' ? <Text color="warning">Copilot review stale</Text>
      : <Text dimColor>no Copilot review</Text>
    const sep = <Text dimColor> · </Text>

    const below = await next(e)

    return (
      <Box flexDirection="column">
        <Box>
          <Link href={p.url} label={`PR #${p.number}`} />
          {p.isDraft && <Text dimColor> (draft)</Text>}
          {sep}{ci}{sep}{copilot}{sep}
          <Text color={p.openThreads ? 'warning' : 'success'}>
            {p.openThreads} open thread{p.openThreads === 1 ? '' : 's'}
          </Text>
          {p.approved && <>{sep}<Text color="success">approved</Text></>}
        </Box>
        {below}
      </Box>
    )
  })
}
