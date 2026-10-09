import { expect, test } from 'claude-code/testing'

import { ago } from './tasks'

test('ago reads in minutes then hours', () => {
  expect(ago(4 * 60_000)).toBe('4m')
  expect(ago(125 * 60_000)).toBe('2h05')
  expect(ago(-5)).toBe('0m')
  expect(ago((68 * 60 + 55) * 60_000)).toBe('2d20h')
})
