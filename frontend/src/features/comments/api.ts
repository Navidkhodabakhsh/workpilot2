import { apiClient } from "@/lib/api-client"

export type Comment = {
  id: string
  task_id: string
  author_id: string
  author_full_name: string
  body: string
  created_at: string
}

export async function listComments(taskId: string) {
  const { data } = await apiClient.get<Comment[]>(`/api/v1/tasks/${taskId}/comments`)
  return data
}

export async function createComment(taskId: string, body: string) {
  const { data } = await apiClient.post<Comment>(`/api/v1/tasks/${taskId}/comments`, { body })
  return data
}
