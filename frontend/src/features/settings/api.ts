import { apiClient } from "@/lib/api-client"
import type { CurrentUser } from "@/features/auth/auth-store"

export async function updateProfile(fullName: string) {
  const { data } = await apiClient.patch<CurrentUser>("/api/v1/auth/me", { full_name: fullName })
  return data
}

export async function changePassword(currentPassword: string, newPassword: string) {
  const { data } = await apiClient.post<{ detail: string }>("/api/v1/auth/me/change-password", {
    current_password: currentPassword,
    new_password: newPassword,
  })
  return data
}

export type Organization = { id: string; name: string }

export async function getMyOrganization() {
  const { data } = await apiClient.get<Organization>("/api/v1/organizations/me")
  return data
}

export async function updateMyOrganization(name: string) {
  const { data } = await apiClient.patch<Organization>("/api/v1/organizations/me", { name })
  return data
}
