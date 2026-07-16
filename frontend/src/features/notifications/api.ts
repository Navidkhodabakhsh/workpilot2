import { apiClient } from "@/lib/api-client"

export type NotificationType =
  | "task_created"
  | "deadline_approaching"
  | "report_submitted"
  | "report_reviewed"
  | "comment_added"
  | "event_reminder"
  | "leave_reviewed"

export type Notification = {
  id: string
  type: NotificationType
  payload: Record<string, string>
  is_read: boolean
  created_at: string
}

export async function listNotifications() {
  const { data } = await apiClient.get<Notification[]>("/api/v1/notifications")
  return data
}

export async function getUnreadCount() {
  const { data } = await apiClient.get<{ unread_count: number }>("/api/v1/notifications/unread-count")
  return data.unread_count
}

export async function markRead(id: string) {
  const { data } = await apiClient.post<Notification>(`/api/v1/notifications/${id}/read`)
  return data
}

export async function markAllRead() {
  const { data } = await apiClient.post<{ updated: number }>("/api/v1/notifications/read-all")
  return data
}
