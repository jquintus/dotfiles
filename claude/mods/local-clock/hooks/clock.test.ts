import { expect, test } from 'claude-code/testing'

import { DATE_FORMAT, day, note, parse, section, stamp, status } from './clock'

const c = parse('Thu|Oct|8|2026|1:20 PM|EDT\n')

test('parses date output', () => {
  expect(c).toEqual({ weekday: 'Thu', month: 'Oct', day: '8', year: '2026', time: '1:20 PM', zone: 'EDT' })
  expect(DATE_FORMAT.split('|').length).toBe(6)
})

test('rejects malformed output', () => {
  expect(parse('')).toBe(null)
  expect(parse('Thu Oct 8 13:20:00 EDT 2026')).toBe(null)
  expect(parse('Thu|Oct||2026|1:20 PM|EDT')).toBe(null)
})

test('formats the stamp', () => {
  if (!c) throw new Error('unparsed')
  expect(stamp(c)).toBe('Thu Oct 8 2026, 1:20 PM EDT')
  expect(day(c)).toBe('Thu Oct 8 2026')
  expect(status(c)).toBe('1:20 PM EDT')
})

test('section holds the day, not the minute', () => {
  if (!c) throw new Error('unparsed')
  expect(section(c)).toContain('Thu Oct 8 2026, timezone EDT')
  expect(section(c)).not.toContain('1:20')
  expect(note(c)).toContain('Thu Oct 8 2026, 1:20 PM EDT')
})
