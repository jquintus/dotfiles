import { expect, test } from 'claude-code/testing'

import { parseIssue, parseIssues, ticketFromBranch } from './ticket'

const issue = { id: 'ABC-123', title: 'Invoice totals', status: 'In Progress', statusType: 'started', url: 'https://linear.app/x' }

test('reads the ticket from the branch name', () => {
  expect(ticketFromBranch('jq/abc-123-invoice-totals')).toBe('ABC-123')
  expect(ticketFromBranch('xyz-503')).toBe('XYZ-503')
  expect(ticketFromBranch('feat/los-reconcile-replace-2')).toBe(null)
  expect(ticketFromBranch('main')).toBe(null)
})

test('parses the issue from any MCP result wrapping', () => {
  const json = JSON.stringify(issue)
  expect(parseIssue('ABC-123', json)?.status).toBe('In Progress')
  expect(parseIssue('ABC-123', [{ type: 'text', text: json }])?.title).toBe('Invoice totals')
  expect(parseIssue('ABC-123', { content: [{ type: 'text', text: json }] })?.url).toBe('https://linear.app/x')
  expect(parseIssue('ABC-123', issue)?.statusType).toBe('started')
  expect(parseIssue('ABC-123', 'not found')).toBe(null)
})

test('lists open assigned issues, in progress first', () => {
  const json = JSON.stringify({ issues: [
    { id: 'ABC-200', title: 'b', status: 'Backlog', statusType: 'backlog', url: 'u' },
    { id: 'ABC-100', title: 'd', status: 'Done', statusType: 'completed', url: 'u' },
    { id: 'ABC-123', title: 'a', status: 'In Progress', statusType: 'started', url: 'u' },
  ] })
  expect(parseIssues(json).map(t => t.id)).toEqual(['ABC-123', 'ABC-200'])
  expect(parseIssues('nope')).toEqual([])
})
