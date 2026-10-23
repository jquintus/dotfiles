import type { Register } from 'claude-code'

import { lastReply, quote } from './quote'

export const register: Register = on => {
  on('session.start', async ($, e, next) => {
    await $.command.register({ name: 'reply', description: "Quote Claude's last message in the prompt box (then ctrl+g)" })
    return next(e)
  })

  on('command.run', { command: 'reply' }, async $ => {
    const text = lastReply(await $.session.messages())
    if (!text) return { text: 'No message to reply to.' }
    // The box is cleared after the command submits; fill it once that's done.
    void $.clock.sleep(50).then(() => $.prompt.fill({ text: quote(text) }))
    return { text: 'Quoted. Press ctrl+g to edit.' }
  })
}
