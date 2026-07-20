import { create } from "zustand"

import type { DepartmentMembership } from "@/lib/types"

export type CurrentUser = {
  id: string
  organization_id: string | null
  email: string
  full_name: string
  role: "platform_admin" | "org_admin" | "project_manager" | "employee"
  is_active: boolean
  department_id: string | null
  department_memberships: DepartmentMembership[]
}

type AuthState = {
  accessToken: string | null
  user: CurrentUser | null
  setSession: (accessToken: string, user: CurrentUser) => void
  logout: () => void
}

// Access token is kept in memory only (not localStorage) to limit exposure to
// XSS-based token theft — see docs/ARCHITECTURE.md security section. On a full
// page reload, auth-bootstrap.tsx silently re-derives a session from the
// httpOnly refresh-token cookie instead.
export const useAuthStore = create<AuthState>((set) => ({
  accessToken: null,
  user: null,
  setSession: (accessToken, user) => set({ accessToken, user }),
  logout: () => set({ accessToken: null, user: null }),
}))
