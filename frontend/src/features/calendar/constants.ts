import type { CalendarEventType } from "@/features/calendar/api"

export const EVENT_TYPE_LABEL: Record<CalendarEventType, string> = {
  meeting: "جلسه",
  leave: "مرخصی",
  holiday: "تعطیلی",
  reminder: "یادآوری",
}

// Literal CSS custom-property references (not Tailwind classes) so they can
// be handed directly to inline `style` backgroundColor props on calendar
// chips/dots; the browser resolves var(...) at paint time same as anywhere else.
export const EVENT_TYPE_COLOR: Record<CalendarEventType, string> = {
  meeting: "hsl(var(--success))",
  leave: "hsl(var(--leave))",
  holiday: "hsl(var(--danger))",
  reminder: "hsl(var(--warning))",
}

export const TASK_EVENT_COLOR = "hsl(var(--info))"

export const EVENT_TYPE_BADGE_VARIANT: Record<CalendarEventType, "success" | "warning" | "danger" | "default"> = {
  meeting: "success",
  leave: "default",
  holiday: "danger",
  reminder: "warning",
}
