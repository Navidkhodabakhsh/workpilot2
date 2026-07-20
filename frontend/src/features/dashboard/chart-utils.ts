import type { WorkLogReportRow } from "@/features/reports/api"

export type HoursByProjectPoint = { project_id: string; project_name: string; hours: number }

export function hoursByProject(rows: WorkLogReportRow[], limit = 8): HoursByProjectPoint[] {
  const totals = new Map<string, HoursByProjectPoint>()
  for (const row of rows) {
    if (row.status !== "approved") continue
    const existing = totals.get(row.project_id)
    const hours = row.time_spent_minutes / 60
    if (existing) {
      existing.hours += hours
    } else {
      totals.set(row.project_id, { project_id: row.project_id, project_name: row.project_name, hours })
    }
  }
  return [...totals.values()]
    .map((p) => ({ ...p, hours: Math.round(p.hours * 100) / 100 }))
    .sort((a, b) => b.hours - a.hours)
    .slice(0, limit)
}
