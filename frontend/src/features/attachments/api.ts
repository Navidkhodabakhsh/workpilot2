import { apiClient } from "@/lib/api-client"

export type Attachment = {
  id: string
  task_id: string
  uploaded_by_id: string
  uploaded_by_full_name: string
  original_filename: string
  content_type: string
  size_bytes: number
  created_at: string
  task_title: string | null
  project_id: string | null
}

export async function listTaskAttachments(taskId: string) {
  const { data } = await apiClient.get<Attachment[]>(`/api/v1/tasks/${taskId}/attachments`)
  return data
}

export async function listOrgAttachments() {
  const { data } = await apiClient.get<Attachment[]>("/api/v1/attachments")
  return data
}

export async function uploadAttachment(taskId: string, file: File) {
  const formData = new FormData()
  formData.append("file", file)
  const { data } = await apiClient.post<Attachment>(`/api/v1/tasks/${taskId}/attachments`, formData, {
    headers: { "Content-Type": "multipart/form-data" },
  })
  return data
}

export async function deleteAttachment(attachmentId: string) {
  await apiClient.delete(`/api/v1/attachments/${attachmentId}`)
}

// The download endpoint requires the Bearer token, so a plain <a href> link
// won't carry auth -- fetch as a blob (same pattern as export downloads)
// and trigger the save via a temporary object URL.
export async function downloadAttachment(attachmentId: string, filename: string) {
  const response = await apiClient.get(`/api/v1/attachments/${attachmentId}/download`, { responseType: "blob" })
  const blob = new Blob([response.data])
  const url = window.URL.createObjectURL(blob)
  const link = document.createElement("a")
  link.href = url
  link.download = filename
  link.click()
  window.URL.revokeObjectURL(url)
}
