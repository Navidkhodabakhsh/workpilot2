import { useState } from "react"
import { Outlet } from "react-router-dom"
import { Menu, X, Search } from "lucide-react"

import { SidebarNav } from "@/components/layout/sidebar-nav"
import { Button } from "@/components/ui/button"
import { NotificationBell } from "@/features/notifications/components/notification-bell"
import { useAuthStore } from "@/features/auth/auth-store"

/**
 * Responsive app shell (mobile-first): sidebar is a fixed panel from `lg:` up
 * and a slide-in drawer below it, per docs/UI-DESIGN.md. Uses logical flex
 * ordering so it renders on the natural RTL side without left/right hacks.
 */
export function AppShell() {
  const [mobileNavOpen, setMobileNavOpen] = useState(false)
  const user = useAuthStore((s) => s.user)

  return (
    <div className="flex min-h-svh flex-col lg:flex-row">
      {/* Desktop sidebar */}
      <aside className="hidden w-64 shrink-0 flex-col border-e border-sidebar-border bg-sidebar py-4 lg:flex">
        <div className="px-4 pb-4 text-xl font-bold text-sidebar-foreground">WorkPilot</div>
        <div className="flex-1 overflow-y-auto">
          <SidebarNav />
        </div>
      </aside>

      {/* Mobile drawer */}
      {mobileNavOpen && (
        <div className="fixed inset-0 z-50 lg:hidden">
          <div
            className="absolute inset-0 bg-black/40"
            onClick={() => setMobileNavOpen(false)}
            aria-hidden="true"
          />
          <div className="absolute inset-y-0 end-0 flex w-72 max-w-[85vw] flex-col bg-sidebar py-4">
            <div className="flex items-center justify-between px-4 pb-4">
              <span className="text-xl font-bold text-sidebar-foreground">WorkPilot</span>
              <Button
                variant="ghost"
                size="icon"
                className="text-sidebar-foreground hover:bg-sidebar-accent/10"
                onClick={() => setMobileNavOpen(false)}
                aria-label="بستن منو"
              >
                <X className="size-5" />
              </Button>
            </div>
            <div className="flex-1 overflow-y-auto">
              <SidebarNav onNavigate={() => setMobileNavOpen(false)} />
            </div>
          </div>
        </div>
      )}

      <div className="flex min-w-0 flex-1 flex-col">
        {/* Topbar */}
        <header className="flex h-16 items-center gap-3 border-b border-border bg-card px-4">
          <Button
            variant="ghost"
            size="icon"
            className="lg:hidden"
            onClick={() => setMobileNavOpen(true)}
            aria-label="باز کردن منو"
          >
            <Menu className="size-5" />
          </Button>

          <div className="hidden flex-1 items-center gap-2 rounded-md border border-input bg-background px-3 py-2 sm:flex">
            <Search className="size-4 text-muted-foreground" />
            <input
              type="search"
              placeholder="جست‌وجو در پروژه‌ها، کارها، کاربران..."
              className="w-full bg-transparent text-sm outline-none placeholder:text-muted-foreground"
            />
          </div>

          <div className="flex flex-1 items-center justify-end gap-2 sm:flex-none">
            <NotificationBell />
            {user && (
              <div className="hidden text-end sm:block">
                <div className="text-sm font-medium">{user.full_name}</div>
                <div className="text-xs text-muted-foreground">{user.role}</div>
              </div>
            )}
          </div>
        </header>

        <main className="flex-1 overflow-y-auto p-4 sm:p-6">
          <Outlet />
        </main>
      </div>
    </div>
  )
}
