import { apiClient } from "@/lib/api-client"

export type Payment = {
  id: string
  project_id: string
  recorded_by_id: string
  payment_date: string
  description: string
  amount: string
  created_at: string
}

export async function listPayments(projectId: string) {
  const { data } = await apiClient.get<Payment[]>(`/api/v1/projects/${projectId}/payments`)
  return data
}

export async function createPayment(
  projectId: string,
  payload: { payment_date: string; description: string; amount: string }
) {
  const { data } = await apiClient.post<Payment>(`/api/v1/projects/${projectId}/payments`, payload)
  return data
}

export async function deletePayment(projectId: string, paymentId: string) {
  await apiClient.delete(`/api/v1/projects/${projectId}/payments/${paymentId}`)
}
