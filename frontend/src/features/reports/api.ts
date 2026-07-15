import { apiClient } from "@/lib/api-client"
import type { WorkLogStatus } from "@/lib/types"

export type WorkLogReportRow = {
  worklog_id: string
  task_id: string
  task_title: string
  project_id: string
  project_name: string
  user_id: string
  user_full_name: string
  activity_description: string
  time_spent_minutes: number
  progress_percent: number
  log_date: string
  status: WorkLogStatus
  created_at: string
}

export type WorkLogReport = {
  items: WorkLogReportRow[]
  total_minutes: number
  total_hours: number
}

export type WorkLogReportFilters = {
  project_id?: string
  user_id?: string
  status?: WorkLogStatus
  date_from?: string
  date_to?: string
}

export async function getWorklogReport(filters: WorkLogReportFilters) {
  const { data } = await apiClient.get<WorkLogReport>("/api/v1/reports/worklogs", { params: filters })
  return data
}
