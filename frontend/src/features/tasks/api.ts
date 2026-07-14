import { apiClient } from "@/lib/api-client"
import type { Task, TaskPriority, TaskStatus } from "@/lib/types"

export async function listTasks(projectId: string) {
  const { data } = await apiClient.get<Task[]>("/api/v1/tasks", { params: { project_id: projectId } })
  return data
}

export async function createTask(payload: {
  project_id: string
  title: string
  assignee_id?: string
  priority?: TaskPriority
  deadline?: string
}) {
  const { data } = await apiClient.post<Task>("/api/v1/tasks", payload)
  return data
}

export async function updateTaskStatus(taskId: string, status: TaskStatus) {
  const { data } = await apiClient.patch<Task>(`/api/v1/tasks/${taskId}`, { status })
  return data
}
