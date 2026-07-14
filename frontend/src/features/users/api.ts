import { apiClient } from "@/lib/api-client"
import type { OrgUser } from "@/lib/types"

export async function listOrgUsers() {
  const { data } = await apiClient.get<OrgUser[]>("/api/v1/users")
  return data
}
