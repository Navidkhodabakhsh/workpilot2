import { useEffect, useState } from "react"
import { Outlet, useNavigate } from "react-router-dom"
import { LogOut, Menu, PanelLeftClose, PanelLeftOpen, X } from "lucide-react"

import { SidebarNav } from "@/components/layout/sidebar-nav"
import { useSidebarStore } from "@/components/layout/sidebar-store"
import { AccountMenu } from "@/components/layout/account-menu"
import { LogoMark } from "@/components/logo"
import { Button } from "@/components/ui/button"
import { cn } from "@/lib/utils"
import { GlobalSearch } from "@/features/search/components/global-search"
import { NotificationBell } from "@/features/notifications/components/notification-bell"
import { DepartmentSelector } from "@/features/departments/components/department-selector"
import { logoutRequest } from "@/features/auth/api"
import { useAuthStore } from "@/features/auth/auth-store"

/**
 * Responsive app shell (mobile-first): sidebar is a fixed panel from `lg:` up
 * and a slide-in drawer below it, per docs/UI-DESIGN.md. Uses logical flex
 * ordering so it renders on the natural RTL side without left/right hacks.
 */
export function AppShell() {
  const [mobileNavOpen, setMobileNavOpen] = useState(false)
  const collapsed = useSidebarStore((s) => s.collapsed)
  const toggleCollapsed = useSidebarStore((s) => s.toggle)
  const logout = useAuthStore((s) => s.logout)
  const navigate = useNavigate()

  useEffect(() => {
    if (!mobileNavOpen) return
    function handleEscape(event: KeyboardEvent) {
      if (event.key === "Escape") setMobileNavOpen(false)
    }
    document.addEventListener("keydown", handleEscape)
    return () => document.removeEventListener("keydown", handleEscape)
  }, [mobileNavOpen])

  async function handleLogout() {
    try {
      await logoutRequest()
    } finally {
      logout()
      navigate("/login", { replace: true })
    }
  }

  return (
    <div className="flex h-svh flex-col overflow-hidden lg:flex-row">
      {/* Desktop sidebar */}
      <aside
        className={cn(
          "relative hidden shrink-0 flex-col overflow-hidden border-e border-sidebar-border bg-sidebar py-4 transition-[width] duration-300 ease-in-out lg:flex",
          collapsed ? "w-20" : "w-64"
        )}
      >
        <div
          className="pointer-events-none absolute inset-0 bg-[radial-gradient(circle_at_top,_hsl(var(--color-blue-500)/0.35),_transparent_60%)]"
          aria-hidden="true"
        />
        <div
          className={cn(
            "relative flex items-center gap-3 overflow-hidden px-4 pb-4 transition-all duration-300 ease-in-out",
            collapsed && "justify-center px-0"
          )}
        >
          <div className="flex size-9 shrink-0 items-center justify-center rounded-lg bg-secondary text-secondary-foreground">
            <LogoMark className="size-5" />
          </div>
          <span
            className={cn(
              "overflow-hidden whitespace-nowrap text-xl font-bold text-sidebar-foreground transition-all duration-300 ease-in-out",
              collapsed ? "max-w-0 opacity-0" : "max-w-[10rem] opacity-100"
            )}
          >
            Tadvin
          </span>
        </div>
        <div className="relative flex-1 overflow-y-auto">
          <SidebarNav collapsed={collapsed} />
        </div>
        <div className="relative flex flex-col gap-1 border-t border-sidebar-border/60 px-3 pt-3 pb-1">
          <Button
            variant="ghost"
            className={cn(
              "flex h-11 items-center gap-3 overflow-hidden text-sidebar-foreground/80 hover:bg-sidebar-accent/10 hover:text-sidebar-foreground",
              collapsed ? "justify-center px-0" : "justify-start px-3"
            )}
            onClick={handleLogout}
            aria-label="خروج از حساب"
          >
            <LogOut className="size-5 shrink-0" aria-hidden="true" />
            <span
              className={cn(
                "overflow-hidden whitespace-nowrap transition-all duration-300 ease-in-out",
                collapsed ? "max-w-0 opacity-0" : "max-w-[10rem] opacity-100"
              )}
            >
              خروج از حساب
            </span>
          </Button>
          <Button
            variant="ghost"
            size="icon"
            className="w-full text-sidebar-foreground hover:bg-sidebar-accent/10"
            onClick={toggleCollapsed}
            aria-label={collapsed ? "باز کردن منو" : "جمع کردن منو"}
          >
            {collapsed ? <PanelLeftOpen className="size-5" /> : <PanelLeftClose className="size-5" />}
          </Button>
        </div>
      </aside>

      {/* Mobile drawer -- stays mounted (off-screen via transform) instead of
          conditionally rendered so open/close can actually animate. */}
      <div
        className={cn(
          "fixed inset-0 z-50 lg:hidden",
          mobileNavOpen ? "pointer-events-auto" : "pointer-events-none"
        )}
      >
        <div
          className={cn(
            "absolute inset-0 bg-black/40 transition-opacity duration-300",
            mobileNavOpen ? "opacity-100" : "opacity-0"
          )}
          onClick={() => setMobileNavOpen(false)}
          aria-hidden="true"
        />
        <div
          className={cn(
            // `start-0` (not `end-0`) so the drawer opens on the same
            // physical side as the desktop sidebar -- under this app's
            // permanent RTL direction, inset-inline-start resolves to the
            // right edge, matching the `<aside>` above.
            "absolute inset-y-0 start-0 flex w-72 max-w-[85vw] flex-col bg-sidebar py-4 transition-transform duration-300 ease-in-out",
            mobileNavOpen ? "translate-x-0" : "translate-x-full"
          )}
        >
          <div className="flex items-center justify-between px-4 pb-4">
            <div className="flex items-center gap-3">
              <div className="flex size-9 shrink-0 items-center justify-center rounded-lg bg-secondary text-secondary-foreground">
                <LogoMark className="size-5" />
              </div>
              <span className="text-xl font-bold text-sidebar-foreground">Tadvin</span>
            </div>
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
          <div className="border-t border-sidebar-border/60 px-3 pt-3">
            <Button
              variant="ghost"
              className="flex h-11 w-full items-center justify-start gap-3 text-sidebar-foreground/80 hover:bg-sidebar-accent/10 hover:text-sidebar-foreground"
              onClick={handleLogout}
              aria-label="خروج از حساب"
            >
              <LogOut className="size-5 shrink-0" aria-hidden="true" />
              <span>خروج از حساب</span>
            </Button>
          </div>
        </div>
      </div>

      <div className="flex min-w-0 flex-1 flex-col overflow-hidden">
        {/* Topbar */}
        <header className="flex h-16 shrink-0 items-center gap-3 border-b border-border bg-card px-4">
          <Button
            variant="ghost"
            size="icon"
            className="lg:hidden"
            onClick={() => setMobileNavOpen(true)}
            aria-label="باز کردن منو"
          >
            <Menu className="size-5" />
          </Button>

          <GlobalSearch />

          <div className="flex shrink-0 items-center justify-end gap-3">
            <DepartmentSelector />
            <NotificationBell />
            <AccountMenu onLogout={handleLogout} />
          </div>
        </header>

        <main className="flex-1 overflow-y-auto p-4 sm:p-6">
          <Outlet />
        </main>
      </div>
    </div>
  )
}
