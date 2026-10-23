import { expect, test } from 'claude-code/testing'

import { lastReply, quote } from './quote'

const msg = (role: 'user' | 'assistant', text: string) => ({ role, text, toolUses: [] })

test('picks the last assistant message with text', () => {
  expect(lastReply([msg('assistant', 'first'), msg('user', 'hi'), msg('assistant', 'second'), msg('assistant', '')])).toBe('second')
  expect(lastReply([msg('user', 'hi')])).toBe(null)
})

test('quotes each line', () => {
  expect(quote('a\n\nb')).toBe('> a\n>\n> b\n')
})
