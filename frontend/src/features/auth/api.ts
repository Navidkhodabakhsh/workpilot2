import { apiClient } from "@/lib/api-client"
import type { CurrentUser } from "@/features/auth/auth-store"

export type LoginPayload = { email: string; password: string }
export type SignupPayload = {
  organization_name: string
  full_name: string
  email: string
  password: string
}

export async function login(payload: LoginPayload) {
  const { data } = await apiClient.post<{ access_token: string; token_type: string }>(
    "/api/v1/auth/login",
    payload
  )
  return data
}

export async function signup(payload: SignupPayload) {
  const { data } = await apiClient.post<CurrentUser>("/api/v1/auth/signup", payload)
  return data
}

export async function fetchMe() {
  const { data } = await apiClient.get<CurrentUser>("/api/v1/auth/me")
  return data
}
