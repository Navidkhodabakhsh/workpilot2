import { useEffect, useState } from "react"

import { apiClient } from "@/lib/api-client"
import { fetchMe } from "@/features/auth/api"
import { useAuthStore } from "@/features/auth/auth-store"

/**
 * On first load the access token is empty (kept in memory only -- see
 * docs/ARCHITECTURE.md). Before rendering the app, try the httpOnly refresh
 * cookie once to silently restore the session instead of forcing a fresh
 * login after every page reload.
 */
export function AuthBootstrap({ children }: { children: React.ReactNode }) {
  const [ready, setReady] = useState(false)
  const setSession = useAuthStore((s) => s.setSession)

  useEffect(() => {
    let cancelled = false

    async function restore() {
      try {
        const { data } = await apiClient.post<{ access_token: string }>("/api/v1/auth/refresh")
        useAuthStore.setState({ accessToken: data.access_token })
        const user = await fetchMe()
        if (!cancelled) setSession(data.access_token, user)
      } catch {
        // No valid refresh cookie -- that's fine, the user just isn't logged in.
      } finally {
        if (!cancelled) setReady(true)
      }
    }

    restore()
    return () => {
      cancelled = true
    }
  }, [setSession])

  if (!ready) {
    return (
      <div className="flex min-h-svh items-center justify-center">
        <p className="text-muted-foreground">در حال بارگذاری...</p>
      </div>
    )
  }

  return <>{children}</>
}
