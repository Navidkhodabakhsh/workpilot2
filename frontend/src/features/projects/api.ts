import { apiClient } from "@/lib/api-client"
import type { Project, ProjectMember } from "@/lib/types"

export async function listProjects() {
  const { data } = await apiClient.get<Project[]>("/api/v1/projects")
  return data
}

export async function getProject(projectId: string) {
  const { data } = await apiClient.get<Project>(`/api/v1/projects/${projectId}`)
  return data
}

export async function createProject(payload: {
  name: string
  description?: string
  start_date?: string
  end_date?: string
  manager_id?: string
  department_id?: string
  member_ids?: string[]
}) {
  const { data } = await apiClient.post<Project>("/api/v1/projects", payload)
  return data
}

export async function updateProject(
  projectId: string,
  payload: Partial<{
    name: string
    description: string
    start_date: string
    end_date: string
    status: string
    manager_id: string
    department_id: string
  }>
) {
  const { data } = await apiClient.patch<Project>(`/api/v1/projects/${projectId}`, payload)
  return data
}

export async function listProjectMembers(projectId: string) {
  const { data } = await apiClient.get<ProjectMember[]>(`/api/v1/projects/${projectId}/members`)
  return data
}

export async function addProjectMember(projectId: string, userId: string) {
  const { data } = await apiClient.post<ProjectMember>(`/api/v1/projects/${projectId}/members`, {
    user_id: userId,
  })
  return data
}

export async function removeProjectMember(projectId: string, userId: string) {
  await apiClient.delete(`/api/v1/projects/${projectId}/members/${userId}`)
}
