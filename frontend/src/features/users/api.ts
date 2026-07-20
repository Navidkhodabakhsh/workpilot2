import { apiClient } from "@/lib/api-client"
import type { OrgUser, UserRole } from "@/lib/types"

export type DepartmentMembershipInput = { department_id: string; role: "project_manager" | "employee" }

export async function listOrgUsers() {
  const { data } = await apiClient.get<OrgUser[]>("/api/v1/users")
  return data
}

export async function createOrgUser(payload: {
  full_name: string
  email: string
  phone_number: string
  password?: string
  role: UserRole
  department_id?: string
}) {
  const { data } = await apiClient.post<OrgUser>("/api/v1/users", payload)
  return data
}

export async function updateOrgUser(
  userId: string,
  payload: { role?: UserRole; is_active?: boolean; phone_number?: string; department_id?: string }
) {
  const { data } = await apiClient.patch<OrgUser>(`/api/v1/users/${userId}`, payload)
  return data
}

export async function setUserDepartments(userId: string, memberships: DepartmentMembershipInput[]) {
  const { data } = await apiClient.put<OrgUser>(`/api/v1/users/${userId}/departments`, memberships)
  return data
}
