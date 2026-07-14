import {
  LayoutDashboard,
  FolderKanban,
  CheckSquare,
  BarChart3,
  Calendar,
  Users,
  Workflow,
  LineChart,
  MessageSquare,
  Files,
  Settings,
} from "lucide-react"
import { NavLink } from "react-router-dom"

import { cn } from "@/lib/utils"

type NavItem = {
  to: string
  label: string
  icon: typeof LayoutDashboard
  end?: boolean
}

const NAV_ITEMS: NavItem[] = [
  { to: "/", label: "داشبورد", icon: LayoutDashboard, end: true },
  { to: "/projects", label: "پروژه‌ها", icon: FolderKanban },
  { to: "/tasks", label: "کارها", icon: CheckSquare },
  { to: "/reports", label: "گزارش‌ها", icon: BarChart3 },
  { to: "/calendar", label: "تقویم", icon: Calendar },
  { to: "/users", label: "کاربران", icon: Users },
  { to: "/workflow", label: "گردش کار", icon: Workflow },
  { to: "/analytics", label: "تحلیل‌ها", icon: LineChart },
  { to: "/messages", label: "پیام‌ها", icon: MessageSquare },
  { to: "/files", label: "فایل‌ها", icon: Files },
  { to: "/settings", label: "تنظیمات", icon: Settings },
]

export function SidebarNav({ onNavigate }: { onNavigate?: () => void }) {
  return (
    <nav className="flex flex-col gap-1 px-3">
      {NAV_ITEMS.map(({ to, label, icon: Icon, end }) => (
        <NavLink
          key={to}
          to={to}
          end={end}
          onClick={onNavigate}
          className={({ isActive }) =>
            cn(
              "flex min-h-11 items-center gap-3 rounded-lg px-3 py-2 text-sm font-medium transition-colors",
              isActive
                ? "bg-sidebar-accent text-sidebar-accent-foreground"
                : "text-sidebar-foreground/80 hover:bg-sidebar-accent/10 hover:text-sidebar-foreground"
            )
          }
        >
          <Icon className="size-5 shrink-0" aria-hidden="true" />
          <span>{label}</span>
        </NavLink>
      ))}
    </nav>
  )
}
