import { apiClient } from "@/lib/api-client"
import type { WorkLog, WorkLogStatus } from "@/lib/types"

export async function listWorklogs(projectId: string, status?: WorkLogStatus) {
  const { data } = await apiClient.get<WorkLog[]>("/api/v1/worklogs", {
    params: { project_id: projectId, status },
  })
  return data
}

export async function createWorklog(payload: {
  task_id: string
  activity_description: string
  time_spent_minutes: number
  progress_percent: number
  log_date: string
}) {
  const { data } = await apiClient.post<WorkLog>("/api/v1/worklogs", payload)
  return data
}

export async function approveWorklog(worklogId: string) {
  const { data } = await apiClient.post<WorkLog>(`/api/v1/worklogs/${worklogId}/approve`)
  return data
}

export async function rejectWorklog(worklogId: string, reviewComment: string) {
  const { data } = await apiClient.post<WorkLog>(`/api/v1/worklogs/${worklogId}/reject`, {
    review_comment: reviewComment,
  })
  return data
}
