import { apiClient } from "@/lib/api-client"
import type { ApprovalStatus, Task, TaskActivity, TaskPriority, TaskStatus } from "@/lib/types"

export async function listTasks(projectId: string) {
  const { data } = await apiClient.get<Task[]>("/api/v1/tasks", { params: { project_id: projectId } })
  return data
}

export type TaskFilters = {
  status?: TaskStatus
  approval_status?: ApprovalStatus
  assignee_id?: string
  overdue?: boolean
  personal_only?: boolean
}

export async function listAllTasks(filters?: TaskFilters) {
  const { data } = await apiClient.get<Task[]>("/api/v1/tasks", { params: filters })
  return data
}

export async function createTask(payload: {
  project_id?: string
  title: string
  assignee_id?: string
  priority?: TaskPriority
  deadline?: string
  estimated_hours?: number
  parent_task_id?: string
}) {
  const { data } = await apiClient.post<Task>("/api/v1/tasks", payload)
  return data
}

export async function updateTask(
  taskId: string,
  payload: Partial<{
    title: string
    description: string
    assignee_id: string
    priority: TaskPriority
    status: TaskStatus
    progress_percent: number
    estimated_hours: number
    deadline: string
  }>
) {
  const { data } = await apiClient.patch<Task>(`/api/v1/tasks/${taskId}`, payload)
  return data
}

export async function updateTaskStatus(taskId: string, status: TaskStatus) {
  const { data } = await apiClient.patch<Task>(`/api/v1/tasks/${taskId}`, { status })
  return data
}

export async function approveTask(taskId: string) {
  const { data } = await apiClient.post<Task>(`/api/v1/tasks/${taskId}/approve`)
  return data
}

export async function rejectTask(taskId: string, reviewComment: string) {
  const { data } = await apiClient.post<Task>(`/api/v1/tasks/${taskId}/reject`, { review_comment: reviewComment })
  return data
}

export async function getTaskActivity(taskId: string) {
  const { data } = await apiClient.get<TaskActivity[]>(`/api/v1/tasks/${taskId}/activity`)
  return data
}
