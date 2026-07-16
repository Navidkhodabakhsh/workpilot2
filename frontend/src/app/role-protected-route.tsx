import { Navigate, Outlet } from "react-router-dom"

import { useAuthStore } from "@/features/auth/auth-store"
import type { UserRole } from "@/lib/types"

export function RoleProtectedRoute({ allowedRoles }: { allowedRoles: UserRole[] }) {
  const role = useAuthStore((s) => s.user?.role)
  if (!role || !allowedRoles.includes(role)) {
    return <Navigate to="/" replace />
  }
  return <Outlet />
}
