import { apiClient } from "@/lib/api-client"
import type { Department } from "@/lib/types"

export async function listDepartments() {
  const { data } = await apiClient.get<Department[]>("/api/v1/departments")
  return data
}

export async function createDepartment(name: string) {
  const { data } = await apiClient.post<Department>("/api/v1/departments", { name })
  return data
}
