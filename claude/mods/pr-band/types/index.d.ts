export type Ci = 'pass' | 'fail' | 'pending' | 'none'
export type Copilot = 'none' | 'requested' | 'reviewed' | 'stale'

export type Pr = {
  number: number
  url: string
  isDraft: boolean
  ci: Ci
  passed: number
  failed: number
  pending: number
  copilot: Copilot
  openThreads: number
  approved: boolean
}

declare module 'claude-code' {
  interface PluginState {
    'pr-band': { pr: Pr | null }
  }
}
