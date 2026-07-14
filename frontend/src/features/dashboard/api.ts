import { apiClient } from "@/lib/api-client"

export type StatusCount = { status: string; count: number }
export type TeamMemberHours = { user_id: string; full_name: string; approved_hours: number }
export type RecentActivityItem = {
  worklog_id: string
  task_id: string
  task_title: string
  user_id: string
  user_full_name: string
  status: string
  created_at: string
}

export type DashboardSummary = {
  project_count: number
  projects_by_status: StatusCount[]
  task_count: number
  tasks_by_status: StatusCount[]
  total_approved_hours: number
  team_hours: TeamMemberHours[]
  recent_activity: RecentActivityItem[]
}

export async function getDashboardSummary() {
  const { data } = await apiClient.get<DashboardSummary>("/api/v1/dashboard/summary")
  return data
}
