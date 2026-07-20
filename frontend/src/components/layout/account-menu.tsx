import { useEffect, useRef, useState } from "react"
import { useNavigate } from "react-router-dom"
import { useQuery } from "@tanstack/react-query"
import { ChevronDown, KeyRound, LogOut, UserRound } from "lucide-react"

import { getMyOrganization } from "@/features/settings/api"
import { useAuthStore } from "@/features/auth/auth-store"
import { ROLE_LABEL } from "@/lib/role-labels"

export function AccountMenu({ onLogout }: { onLogout: () => void }) {
  const user = useAuthStore((s) => s.user)
  const [open, setOpen] = useState(false)
  const containerRef = useRef<HTMLDivElement>(null)
  const navigate = useNavigate()

  // Only fetched once the menu is actually opened -- the org name isn't
  // needed anywhere else in the topbar.
  const { data: organization } = useQuery({
    queryKey: ["organization", "me"],
    queryFn: getMyOrganization,
    enabled: open,
  })

  useEffect(() => {
    function handleClickOutside(event: MouseEvent) {
      if (containerRef.current && !containerRef.current.contains(event.target as Node)) {
        setOpen(false)
      }
    }
    document.addEventListener("mousedown", handleClickOutside)
    return () => document.removeEventListener("mousedown", handleClickOutside)
  }, [])

  if (!user) return null

  return (
    <div className="relative" ref={containerRef}>
      <button
        type="button"
        onClick={() => setOpen((v) => !v)}
        aria-label="حساب کاربری"
        className="flex items-center gap-2 rounded-lg px-2 py-1.5 hover:bg-muted"
      >
        {/* Icon side first in DOM so it lands next to the rest of the
            topbar (RTL: first child renders on the right) -- the name
            stays last, at the outer/left end of the button. */}
        <div className="flex size-8 shrink-0 items-center justify-center rounded-full bg-primary text-xs font-semibold text-primary-foreground">
          {user.full_name.trim().charAt(0)}
        </div>
        <ChevronDown className="hidden size-4 text-muted-foreground sm:block" aria-hidden="true" />
        <div className="hidden text-end sm:block">
          <div className="text-sm font-medium leading-tight">{user.full_name}</div>
          <div className="text-xs leading-tight text-muted-foreground">{ROLE_LABEL[user.role]}</div>
        </div>
      </button>

      {open && (
        <div className="absolute end-0 top-full z-50 mt-2 w-64 max-w-[85vw] rounded-lg border border-border bg-card p-1 shadow-lg">
          <div className="border-b border-border px-3 py-2">
            <div className="font-medium">{user.full_name}</div>
            <div className="text-sm text-muted-foreground">{ROLE_LABEL[user.role]}</div>
            <div className="text-xs text-muted-foreground">{organization?.name ?? "…"}</div>
          </div>
          <button
            type="button"
            className="flex w-full items-center gap-2 rounded-md px-3 py-2 text-start text-sm hover:bg-muted"
            onClick={() => {
              setOpen(false)
              navigate("/settings")
            }}
          >
            <UserRound className="size-4" aria-hidden="true" />
            پروفایل
          </button>
          <button
            type="button"
            className="flex w-full items-center gap-2 rounded-md px-3 py-2 text-start text-sm hover:bg-muted"
            onClick={() => {
              setOpen(false)
              navigate("/settings")
            }}
          >
            <KeyRound className="size-4" aria-hidden="true" />
            تغییر رمز عبور
          </button>
          <button
            type="button"
            className="flex w-full items-center gap-2 rounded-md px-3 py-2 text-start text-sm text-danger hover:bg-danger/10"
            onClick={() => {
              setOpen(false)
              onLogout()
            }}
          >
            <LogOut className="size-4" aria-hidden="true" />
            خروج از حساب
          </button>
        </div>
      )}
    </div>
  )
}
