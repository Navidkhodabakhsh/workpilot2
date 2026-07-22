import { useEffect, useState } from "react"
import { Loader2 } from "lucide-react"

import { refreshAccessToken } from "@/lib/api-client"
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
        // Uses the shared, deduped refresh helper (a bare client with no
        // response interceptor attached) instead of calling the
        // intercepted apiClient directly -- a 401 here must not itself
        // trigger the interceptor's own refresh-and-retry, which would
        // fire a second, redundant /auth/refresh call.
        const accessToken = await refreshAccessToken()
        if (!accessToken) throw new Error("No valid refresh cookie")
        useAuthStore.setState({ accessToken })
        const user = await fetchMe()
        if (!cancelled) setSession(accessToken, user)
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
      <div className="flex min-h-svh animate-in fade-in-0 items-center justify-center duration-300">
        <Loader2 className="size-6 animate-spin text-muted-foreground" aria-hidden="true" />
      </div>
    )
  }

  return <>{children}</>
}
