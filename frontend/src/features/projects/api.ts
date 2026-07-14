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

export async function createProject(payload: { name: string; description?: string }) {
  const { data } = await apiClient.post<Project>("/api/v1/projects", payload)
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
