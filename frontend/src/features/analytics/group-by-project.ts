import type { WorkLogReportRow } from "@/features/reports/api"

export type ProjectHours = { project_name: string; approved_hours: number }

export function groupApprovedHoursByProject(items: WorkLogReportRow[]): ProjectHours[] {
  const minutesByProject = new Map<string, number>()
  for (const item of items) {
    if (item.status !== "approved") continue
    minutesByProject.set(item.project_name, (minutesByProject.get(item.project_name) ?? 0) + item.time_spent_minutes)
  }
  return Array.from(minutesByProject.entries())
    .map(([project_name, minutes]) => ({ project_name, approved_hours: Math.round((minutes / 60) * 100) / 100 }))
    .sort((a, b) => b.approved_hours - a.approved_hours)
}
