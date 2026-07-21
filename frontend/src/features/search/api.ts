import { apiClient } from "@/lib/api-client"

export type SearchResults = {
  projects: { id: string; name: string }[]
  tasks: { id: string; title: string; project_id: string }[]
  users: { id: string; full_name: string }[]
}

export async function globalSearch(q: string) {
  const { data } = await apiClient.get<SearchResults>("/api/v1/search", { params: { q } })
  return data
}
