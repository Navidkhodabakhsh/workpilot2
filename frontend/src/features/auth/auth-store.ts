import { create } from "zustand"

export type CurrentUser = {
  id: string
  organization_id: string | null
  email: string
  full_name: string
  role: "platform_admin" | "org_admin" | "project_manager" | "employee"
  is_active: boolean
}

type AuthState = {
  accessToken: string | null
  user: CurrentUser | null
  setSession: (accessToken: string, user: CurrentUser) => void
  logout: () => void
}

// Access token is kept in memory only (not localStorage) to limit exposure to
// XSS-based token theft — see docs/ARCHITECTURE.md security section. This means
// a full page reload requires re-login until the Phase H refresh-token/cookie
// flow is implemented.
export const useAuthStore = create<AuthState>((set) => ({
  accessToken: null,
  user: null,
  setSession: (accessToken, user) => set({ accessToken, user }),
  logout: () => set({ accessToken: null, user: null }),
}))
