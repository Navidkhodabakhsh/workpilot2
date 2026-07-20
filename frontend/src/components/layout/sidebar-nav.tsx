import {
  LayoutDashboard,
  FolderKanban,
  CheckSquare,
  Calendar,
  Users,
  MessageSquare,
  Files,
  Archive,
  CalendarOff,
  Settings,
} from "lucide-react"
import { NavLink } from "react-router-dom"

import { cn } from "@/lib/utils"
import { Tooltip, TooltipContent, TooltipTrigger } from "@/components/ui/tooltip"
import { useAuthStore } from "@/features/auth/auth-store"
import type { UserRole } from "@/lib/types"

type NavItem = {
  to: string
  label: string
  icon: typeof LayoutDashboard
  end?: boolean
  // Omit to show the item to every role.
  allowedRoles?: UserRole[]
}

const NAV_ITEMS: NavItem[] = [
  { to: "/", label: "داشبورد", icon: LayoutDashboard, end: true },
  { to: "/projects", label: "پروژه‌ها", icon: FolderKanban },
  { to: "/tasks", label: "تسک‌ها", icon: CheckSquare },
  { to: "/calendar", label: "تقویم", icon: Calendar },
  { to: "/users", label: "کاربران", icon: Users, allowedRoles: ["org_admin"] },
  { to: "/messages", label: "پیام‌ها", icon: MessageSquare },
  { to: "/files", label: "فایل‌ها", icon: Files },
  { to: "/archive", label: "بایگانی", icon: Archive },
  { to: "/leave", label: "مرخصی", icon: CalendarOff },
  { to: "/settings", label: "تنظیمات", icon: Settings },
]

export function SidebarNav({
  onNavigate,
  collapsed = false,
}: {
  onNavigate?: () => void
  collapsed?: boolean
}) {
  const role = useAuthStore((s) => s.user?.role)
  const items = NAV_ITEMS.filter((item) => !item.allowedRoles || (role && item.allowedRoles.includes(role)))

  return (
    <nav className="flex flex-col gap-1 px-3">
      {items.map(({ to, label, icon: Icon, end }) => {
        const link = (
          // `className` must be a plain string, not react-router's function
          // form: `TooltipTrigger asChild` merges child props through Radix
          // Slot, which stringifies a function className instead of calling
          // it. Active-state styling is driven by the `aria-current="page"`
          // attribute NavLink already sets, via Tailwind's aria-* variant.
          <NavLink
            to={to}
            end={end}
            onClick={onNavigate}
            aria-label={label}
            className={cn(
              "flex min-h-11 items-center gap-3 overflow-hidden rounded-lg px-3 py-2 text-sm font-medium transition-[background-color,color,padding] duration-300 ease-in-out",
              "text-sidebar-foreground/80 hover:bg-sidebar-accent/10 hover:text-sidebar-foreground",
              "aria-[current=page]:bg-sidebar-accent aria-[current=page]:text-sidebar-accent-foreground aria-[current=page]:hover:bg-sidebar-accent",
              collapsed && "justify-center px-0"
            )}
          >
            <Icon className="size-5 shrink-0" aria-hidden="true" />
            {/* Always mounted (never conditionally rendered) so the label can
                crossfade/collapse smoothly instead of popping in and out. */}
            <span
              className={cn(
                "overflow-hidden whitespace-nowrap transition-all duration-300 ease-in-out",
                collapsed ? "max-w-0 opacity-0" : "max-w-[10rem] opacity-100"
              )}
            >
              {label}
            </span>
          </NavLink>
        )

        return (
          // The Tooltip wrapper stays structurally constant across the
          // collapsed/expanded toggle (only its content is conditional) so
          // the NavLink itself never remounts and the label transition above
          // can actually animate instead of jumping.
          <Tooltip key={to}>
            <TooltipTrigger asChild>{link}</TooltipTrigger>
            {collapsed && (
              // Radix `side` is physical, not logical -- the sidebar sits on
              // the RTL-start (visual right) edge, so tooltips point left
              // into the content area.
              <TooltipContent side="left">{label}</TooltipContent>
            )}
          </Tooltip>
        )
      })}
    </nav>
  )
}
