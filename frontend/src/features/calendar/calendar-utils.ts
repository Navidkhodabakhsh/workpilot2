// The grid itself is computed on the Gregorian calendar (native Date math),
// but every label shown to the user goes through Intl with the Persian
// (Jalali) calendar -- see calendar-page.tsx -- so the UI reads as a
// familiar Iranian calendar without needing a Jalali date-math dependency.

export function toDateKey(date: Date): string {
  const y = date.getFullYear()
  const m = String(date.getMonth() + 1).padStart(2, "0")
  const d = String(date.getDate()).padStart(2, "0")
  return `${y}-${m}-${d}`
}

export function groupTasksByDate<T extends { deadline: string | null }>(tasks: T[]): Record<string, T[]> {
  const map: Record<string, T[]> = {}
  for (const task of tasks) {
    if (!task.deadline) continue
    ;(map[task.deadline] ??= []).push(task)
  }
  return map
}

/** 42-cell (6-week) grid covering the given Gregorian month, starting on
 * Saturday (the first day of the week in the Iranian calendar). */
export function getMonthGridDates(year: number, month: number): Date[] {
  const firstOfMonth = new Date(year, month, 1)
  const startOffset = (firstOfMonth.getDay() + 1) % 7
  const gridStart = new Date(year, month, 1 - startOffset)
  return Array.from({ length: 42 }, (_, i) => {
    const d = new Date(gridStart)
    d.setDate(gridStart.getDate() + i)
    return d
  })
}
