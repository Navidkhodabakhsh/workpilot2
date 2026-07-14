import axios from "axios"

import { useAuthStore } from "@/features/auth/auth-store"

const baseURL = import.meta.env.VITE_API_BASE_URL ?? "http://localhost:8000"

export const apiClient = axios.create({ baseURL, withCredentials: true })

// Bare client for the refresh call itself, so a 401 there can't recurse back
// into the response interceptor below.
const refreshClient = axios.create({ baseURL, withCredentials: true })

apiClient.interceptors.request.use((config) => {
  const token = useAuthStore.getState().accessToken
  if (token) {
    config.headers.Authorization = `Bearer ${token}`
  }
  return config
})

let refreshPromise: Promise<string | null> | null = null

async function refreshAccessToken(): Promise<string | null> {
  if (!refreshPromise) {
    refreshPromise = refreshClient
      .post<{ access_token: string }>("/api/v1/auth/refresh")
      .then((res) => res.data.access_token)
      .catch(() => null)
      .finally(() => {
        refreshPromise = null
      })
  }
  return refreshPromise
}

apiClient.interceptors.response.use(
  (response) => response,
  async (error) => {
    const originalRequest = error.config
    if (error.response?.status === 401 && !originalRequest._retried) {
      originalRequest._retried = true
      const newToken = await refreshAccessToken()
      if (newToken) {
        useAuthStore.setState({ accessToken: newToken })
        originalRequest.headers.Authorization = `Bearer ${newToken}`
        return apiClient(originalRequest)
      }
      useAuthStore.getState().logout()
    }
    return Promise.reject(error)
  }
)
