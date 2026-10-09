// `date` format whose output `parse` reads: weekday|month|day|year|time|zone.
export const DATE_FORMAT = '+%a|%b|%-d|%Y|%-I:%M %p|%Z'

export type Clock = {
  weekday: string
  month: string
  day: string
  year: string
  time: string
  zone: string
}

export function parse(stdout: string): Clock | null {
  const parts = stdout.trim().split('|')
  if (parts.length !== 6 || parts.some(p => !p)) return null
  const [weekday, month, day, year, time, zone] = parts as [string, string, string, string, string, string]

  return { weekday, month, day, year, time, zone }
}

export function day(c: Clock): string {
  return `${c.weekday} ${c.month} ${c.day} ${c.year}`
}

// "Thu Oct 8 2026, 1:20 PM EDT"
export function stamp(c: Clock): string {
  return `${day(c)}, ${c.time} ${c.zone}`
}

// Changes once a day, so the system prompt (and the prompt cache behind it)
// stays stable between turns.
export function section(c: Clock): string {
  return [
    '# Local time',
    `The user's local date is ${day(c)}, timezone ${c.zone}.`,
    'Each user message carries the exact local time in a "Local time:" note.',
    'Use these instead of running `date`.',
    'Give times to the user in this local timezone, never UTC.',
  ].join('\n')
}

export function note(c: Clock): string {
  return `Local time: ${stamp(c)} (the user's local time; use it instead of running \`date\`).`
}

export function status(c: Clock): string {
  return `${c.time} ${c.zone}`
}
