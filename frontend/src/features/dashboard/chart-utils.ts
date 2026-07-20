import type { Task } from "@/lib/types"
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

export type ProjectProgressPoint = { project_id: string; project_name: string; percent: number }

export function projectProgress(tasks: Task[], projects: { id: string; name: string }[]): ProjectProgressPoint[] {
  const tasksByProject = new Map<string, Task[]>()
  for (const task of tasks) {
    if (!task.project_id) continue
    const list = tasksByProject.get(task.project_id) ?? []
    list.push(task)
    tasksByProject.set(task.project_id, list)
  }
  return projects
    .filter((p) => (tasksByProject.get(p.id)?.length ?? 0) > 0)
    .map((p) => {
      const list = tasksByProject.get(p.id) ?? []
      const completed = list.filter((t) => t.status === "completed").length
      return {
        project_id: p.id,
        project_name: p.name,
        percent: Math.round((completed / list.length) * 100),
      }
    })
    .sort((a, b) => b.percent - a.percent)
}
