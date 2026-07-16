import type { WorkLogReportRow } from "@/features/reports/api"
import type { Project } from "@/lib/types"

export type StatusSlice = { name: string; value: number }

const WORKLOG_STATUS_ORDER = ["draft", "submitted", "approved", "rejected"] as const
const WORKLOG_STATUS_LABEL: Record<string, string> = {
  draft: "پیش‌نویس",
  submitted: "در انتظار تأیید",
  approved: "تأییدشده",
  rejected: "ردشده",
}

export function worklogStatusBreakdown(rows: WorkLogReportRow[]): StatusSlice[] {
  const counts = new Map<string, number>()
  for (const row of rows) {
    counts.set(row.status, (counts.get(row.status) ?? 0) + 1)
  }
  return WORKLOG_STATUS_ORDER.filter((status) => (counts.get(status) ?? 0) > 0).map((status) => ({
    name: WORKLOG_STATUS_LABEL[status],
    value: counts.get(status) ?? 0,
  }))
}

const PROJECT_STATUS_ORDER = ["active", "completed", "archived"] as const
const PROJECT_STATUS_LABEL: Record<string, string> = {
  active: "فعال",
  completed: "تکمیل‌شده",
  archived: "بایگانی‌شده",
}

export function projectStatusBreakdown(projects: Pick<Project, "status">[]): StatusSlice[] {
  const counts = new Map<string, number>()
  for (const project of projects) {
    counts.set(project.status, (counts.get(project.status) ?? 0) + 1)
  }
  return PROJECT_STATUS_ORDER.filter((status) => (counts.get(status) ?? 0) > 0).map((status) => ({
    name: PROJECT_STATUS_LABEL[status],
    value: counts.get(status) ?? 0,
  }))
}
