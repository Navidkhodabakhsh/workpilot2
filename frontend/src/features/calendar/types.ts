import type { CalendarEvent } from "@/features/calendar/api"
import type { Task } from "@/lib/types"

/** A calendar event and a task deadline are unified into one displayable
 * shape so the month grid and the agenda list don't need to know which
 * kind of thing they're rendering. */
export type CalendarItem =
  | { id: string; kind: "task"; title: string; color: string; time: string | null; task: Task }
  | { id: string; kind: "event"; title: string; color: string; time: string | null; event: CalendarEvent }
