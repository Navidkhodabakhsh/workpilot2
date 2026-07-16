import { apiClient } from "@/lib/api-client"
import type { ApprovalStatus } from "@/lib/types"

export type LeaveRequest = {
  id: string
  organization_id: string
  user_id: string
  user_full_name: string | null
  start_date: string
  end_date: string
  reason: string | null
  status: ApprovalStatus
  reviewed_by_id: string | null
  review_comment: string | null
  created_at: string
}

export async function listLeaveRequests() {
  const { data } = await apiClient.get<LeaveRequest[]>("/api/v1/leave-requests")
  return data
}

export async function createLeaveRequest(payload: { start_date: string; end_date: string; reason?: string }) {
  const { data } = await apiClient.post<LeaveRequest>("/api/v1/leave-requests", payload)
  return data
}

export async function approveLeaveRequest(id: string) {
  const { data } = await apiClient.post<LeaveRequest>(`/api/v1/leave-requests/${id}/approve`)
  return data
}

export async function rejectLeaveRequest(id: string, reviewComment?: string) {
  const { data } = await apiClient.post<LeaveRequest>(`/api/v1/leave-requests/${id}/reject`, {
    review_comment: reviewComment,
  })
  return data
}
