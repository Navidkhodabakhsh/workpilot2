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

export type UserProductivityPoint = {
  user_id: string
  full_name: string
  hours: number
  task_count: number
  completion_percent: number
}

export function userProductivity(
  rows: WorkLogReportRow[],
  tasks: Task[],
  users: { id: string; full_name: string }[]
): UserProductivityPoint[] {
  const hoursByUser = new Map<string, number>()
  for (const row of rows) {
    if (row.status !== "approved") continue
    hoursByUser.set(row.user_id, (hoursByUser.get(row.user_id) ?? 0) + row.time_spent_minutes / 60)
  }

  const tasksByAssignee = new Map<string, Task[]>()
  for (const task of tasks) {
    if (!task.assignee_id) continue
    const list = tasksByAssignee.get(task.assignee_id) ?? []
    list.push(task)
    tasksByAssignee.set(task.assignee_id, list)
  }

  return users
    .map((u) => {
      const assigned = tasksByAssignee.get(u.id) ?? []
      const completed = assigned.filter((t) => t.status === "completed").length
      return {
        user_id: u.id,
        full_name: u.full_name,
        hours: Math.round((hoursByUser.get(u.id) ?? 0) * 100) / 100,
        task_count: assigned.length,
        completion_percent: assigned.length === 0 ? 0 : Math.round((completed / assigned.length) * 100),
      }
    })
    .filter((p) => p.hours > 0 || p.task_count > 0)
    .sort((a, b) => b.hours - a.hours)
}

export type WeeklyActivityPoint = { week_start: string; active_users: number }

function isoWeekStart(dateStr: string): string {
  const d = new Date(dateStr)
  const day = (d.getUTCDay() + 6) % 7
  d.setUTCDate(d.getUTCDate() - day)
  return d.toISOString().slice(0, 10)
}

export function weeklyActivity(rows: WorkLogReportRow[], weeks = 8): WeeklyActivityPoint[] {
  const usersByWeek = new Map<string, Set<string>>()
  for (const row of rows) {
    const week = isoWeekStart(row.log_date)
    const set = usersByWeek.get(week) ?? new Set<string>()
    set.add(row.user_id)
    usersByWeek.set(week, set)
  }
  return [...usersByWeek.entries()]
    .map(([week_start, users]) => ({ week_start, active_users: users.size }))
    .sort((a, b) => a.week_start.localeCompare(b.week_start))
    .slice(-weeks)
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
