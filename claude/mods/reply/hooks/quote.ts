import type { SessionMessage } from 'claude-code'

// The last assistant message that has text, i.e. what Claude last said to you.
export function lastReply(messages: readonly SessionMessage[]): string | null {
  for (let i = messages.length - 1; i >= 0; i--) {
    const m = messages[i]!
    if (m.role === 'assistant' && m.text.trim()) return m.text.trim()
  }
  return null
}

// Quote every line so your inline answers stand apart from Claude's text.
export function quote(text: string): string {
  return text.split('\n').map(line => (line ? `> ${line}` : '>')).join('\n') + '\n'
}
