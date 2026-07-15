import { apiClient } from "@/lib/api-client"
import type { OrgUser, UserRole } from "@/lib/types"

export async function listOrgUsers() {
  const { data } = await apiClient.get<OrgUser[]>("/api/v1/users")
  return data
}

export async function createOrgUser(payload: {
  full_name: string
  email: string
  password: string
  role: UserRole
}) {
  const { data } = await apiClient.post<OrgUser>("/api/v1/users", payload)
  return data
}
