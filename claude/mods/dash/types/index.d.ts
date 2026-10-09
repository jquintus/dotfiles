export type Reply = { label: string; reply: string }

export type Question = {
  id: string
  name: string
  kind: 'ask' | 'text'
  hasQuestionMark?: boolean
  summary: string
  gist?: string
  replies?: Reply[]
  text: string
  askedAt: string | null
  prompt: string | null
  cwd: string
  surface: string | null
  workspace: string | null
}

export type PrItem = {
  key: string
  repo: string
  number: number
  title: string
  url: string
  author?: string | null
  isDraft?: boolean
}

export type SessionPr = {
  key: string
  repo: string
  number: number
  title: string
  url: string
  state: string
  isDraft: boolean
  ci: 'pass' | 'fail' | 'pending' | 'none'
  failed: number
  pending: number
  copilot: 'none' | 'requested' | 'reviewed'
  threads: number
  humanThreads?: number
  approved: boolean
  action: 'apply' | 'conflicts' | 'mark ready' | 'merge' | null
  base?: string | null
  head?: string | null
}

export type Task = {
  id: string
  kind: 'agent' | 'shell' | 'monitor' | 'workflow' | 'wakeup'
  label: string
  startedAt: string | null
  delaySeconds?: number
}

export type Ticket = {
  id: string
  title: string
  status: string
  statusType: string
  url: string
}

declare module 'claude-code' {
  interface PluginState {
    dash: {
      questions: Question[]
      reviews: PrItem[]
      merges: PrItem[]
      applies: PrItem[]
      prs: SessionPr[]
      tasks: Task[]
      ticket: Ticket | null
      myTickets: Ticket[]
      allMine: SessionPr[]
      isOthersOpen: boolean
      isTicketsOpen: boolean
      expanded: string | null
      tripped: string | null
      isLaterOpen: boolean
      now: number
    }
  }
}
