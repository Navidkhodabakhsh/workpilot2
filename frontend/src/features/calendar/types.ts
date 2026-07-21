import type { CalendarEvent } from "@/features/calendar/api"
import type { Task } from "@/lib/types"

/** A calendar event and a task deadline are unified into one displayable
 * shape so the agenda list doesn't need to know which kind of thing it's
 * rendering. */
export type CalendarItem =
  | { id: string; kind: "task"; title: string; time: string | null; color: string; task: Task }
  | { id: string; kind: "event"; title: string; time: string | null; color: string; event: CalendarEvent }
