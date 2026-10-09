export function ago(ms: number): string {
  const m = Math.max(0, Math.round(ms / 60_000))
  if (m < 60) return `${m}m`
  if (m < 24 * 60) return `${Math.floor(m / 60)}h${String(m % 60).padStart(2, '0')}`
  return `${Math.floor(m / 1440)}d${Math.floor((m % 1440) / 60)}h`
}
