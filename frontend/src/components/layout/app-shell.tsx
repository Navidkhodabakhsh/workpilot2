import { useEffect, useState } from "react"
import { Outlet, useLocation, useNavigate } from "react-router-dom"
import { Loader2, LogOut, Menu, PanelLeftClose, PanelLeftOpen, X } from "lucide-react"

import { SidebarNav } from "@/components/layout/sidebar-nav"
import { useSidebarStore } from "@/components/layout/sidebar-store"
import { AccountMenu } from "@/components/layout/account-menu"
import { LogoMark } from "@/components/logo"
import { Button } from "@/components/ui/button"
import { cn } from "@/lib/utils"
import { GlobalSearch } from "@/features/search/components/global-search"
import { NotificationBell } from "@/features/notifications/components/notification-bell"
import { DepartmentSelector } from "@/features/departments/components/department-selector"
import { OrganizationSwitcher } from "@/features/auth/components/organization-switcher"
import { logoutRequest } from "@/features/auth/api"
import { useAuthStore } from "@/features/auth/auth-store"

/**
 * Responsive app shell (mobile-first): sidebar is a fixed panel from `lg:` up
 * and a slide-in drawer below it, per docs/UI-DESIGN.md. Uses logical flex
 * ordering so it renders on the natural RTL side without left/right hacks.
 */
export function AppShell() {
  const [mobileNavOpen, setMobileNavOpen] = useState(false)
  const [loggingOut, setLoggingOut] = useState(false)
  const collapsed = useSidebarStore((s) => s.collapsed)
  const toggleCollapsed = useSidebarStore((s) => s.toggle)
  const logout = useAuthStore((s) => s.logout)
  const navigate = useNavigate()
  const location = useLocation()

  useEffect(() => {
    if (!mobileNavOpen) return
    function handleEscape(event: KeyboardEvent) {
      if (event.key === "Escape") setMobileNavOpen(false)
    }
    document.addEventListener("keydown", handleEscape)
    return () => document.removeEventListener("keydown", handleEscape)
  }, [mobileNavOpen])

  async function handleLogout() {
    if (loggingOut) return
    setLoggingOut(true)
    try {
      // Races the API call against a timeout so a slow/unreachable server
      // can never leave the button (and the user) stuck -- local state is
      // cleared and the redirect happens either way.
      await Promise.race([logoutRequest(), new Promise((resolve) => setTimeout(resolve, 5000))])
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
          <div className="flex size-9 shrink-0 items-center justify-center rounded-lg bg-white shadow-sm">
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
        <div className="relative min-h-0 flex-1 overflow-y-auto">
          <div className="sidebar-scrollbar h-full overflow-y-auto">
            <SidebarNav collapsed={collapsed} />
          </div>
          {/* Scroll affordance without a visible scrollbar track/thumb --
              just a soft fade at each edge over whatever's currently
              underneath it. */}
          <div className="pointer-events-none absolute inset-x-0 top-0 h-6 bg-gradient-to-b from-sidebar to-transparent" aria-hidden="true" />
          <div className="pointer-events-none absolute inset-x-0 bottom-0 h-6 bg-gradient-to-t from-sidebar to-transparent" aria-hidden="true" />
        </div>
        <div className="relative flex shrink-0 flex-col gap-1 border-t border-sidebar-border/60 px-3 pt-3 pb-1">
          <Button
            variant="ghost"
            className={cn(
              "flex h-11 items-center gap-3 overflow-hidden text-sidebar-foreground/80 hover:bg-sidebar-accent/10 hover:text-sidebar-foreground",
              collapsed ? "justify-center px-0" : "justify-start px-3"
            )}
            onClick={handleLogout}
            disabled={loggingOut}
            aria-label="خروج از حساب"
          >
            {loggingOut ? (
              <Loader2 className="size-5 shrink-0 animate-spin" aria-hidden="true" />
            ) : (
              <LogOut className="size-5 shrink-0" aria-hidden="true" />
            )}
            <span
              className={cn(
                "overflow-hidden whitespace-nowrap transition-all duration-300 ease-in-out",
                collapsed ? "max-w-0 opacity-0" : "max-w-[10rem] opacity-100"
              )}
            >
              {loggingOut ? "در حال خروج..." : "خروج از حساب"}
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
              <div className="flex size-9 shrink-0 items-center justify-center rounded-lg bg-white shadow-sm">
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
          <div className="min-h-0 flex-1 overflow-y-auto">
            <SidebarNav onNavigate={() => setMobileNavOpen(false)} />
          </div>
          <div className="shrink-0 border-t border-sidebar-border/60 px-3 pt-3">
            <Button
              variant="ghost"
              className="flex h-11 w-full items-center justify-start gap-3 text-sidebar-foreground/80 hover:bg-sidebar-accent/10 hover:text-sidebar-foreground"
              onClick={handleLogout}
              disabled={loggingOut}
              aria-label="خروج از حساب"
            >
              {loggingOut ? (
                <Loader2 className="size-5 shrink-0 animate-spin" aria-hidden="true" />
              ) : (
                <LogOut className="size-5 shrink-0" aria-hidden="true" />
              )}
              <span>{loggingOut ? "در حال خروج..." : "خروج از حساب"}</span>
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

          {/* ms-auto pushes this to the true edge of the header even though
              GlobalSearch caps out at max-w-md well before filling the row --
              without it, this group floats wherever the search box happens
              to end instead of reaching the edge. */}
          <div className="ms-auto flex shrink-0 items-center gap-3">
            <OrganizationSwitcher />
            <DepartmentSelector />
            <NotificationBell />
            <AccountMenu onLogout={handleLogout} />
          </div>
        </header>

        <main className="flex-1 overflow-y-auto p-4 sm:p-6">
          {/* Keyed on the path so each route swap remounts this wrapper and
              replays the entrance animation -- a cheap way to get a page
              transition without a routing/animation library. */}
          <div key={location.pathname} className="animate-in fade-in-0 slide-in-from-bottom-1 duration-300">
            <Outlet />
          </div>
        </main>
      </div>
    </div>
  )
}
