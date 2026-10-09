import type { EngineInterface, Register } from 'claude-code'

import { type Clock, DATE_FORMAT, note, parse, section, status } from './clock'

const TTL_MS = 30_000
const SECTION_ID = 'local-clock:time'

let cached: { at: number; clock: Clock } | null = null

async function now($: EngineInterface): Promise<Clock | null> {
  const at = Date.now()
  if (cached && at - cached.at < TTL_MS) return cached.clock
  try {
    const res = await $.process.run(['date', DATE_FORMAT])
    const clock = res.exitCode === 0 ? parse(res.stdout) : null
    if (clock) cached = { at, clock }

    return clock ?? cached?.clock ?? null
  } catch {
    return cached?.clock ?? null
  }
}

async function tick($: EngineInterface) {
  const clock = await now($)
  if (clock) $.ui.status(status(clock))
}

export const register: Register = on => {
  on('session.start', async ($, e, next) => {
    void tick($)
    $.clock.every(TTL_MS, () => void tick($))

    return next(e)
  })

  // Day-level only: a per-minute system prompt would spend the prompt cache.
  on('prompt.compose', async ($, e, next) => {
    const out = await next(e)
    const clock = await now($)
    if (!clock) return out

    return { sections: [...out.sections, { id: SECTION_ID, text: section(clock), scope: 'session' as const }] }
  })

  // The exact time rides each user message, where it stays in the transcript.
  on('prompt.submit', async ($, e, next) => {
    const clock = await now($)
    if (!clock) return next(e)

    return next({ ...e, context: [...(e.context ?? []), note(clock)] })
  }).catch(($, e, next) => next(e))
}
