import { apiClient } from "@/lib/api-client"

export type CalendarEventType = "meeting" | "leave" | "holiday" | "reminder"

export type CalendarEvent = {
  id: string
  organization_id: string
  created_by_id: string
  project_id: string | null
  user_id: string | null
  title: string
  description: string | null
  event_type: CalendarEventType
  start_at: string
  end_at: string
  all_day: boolean
  created_at: string
}

export async function listCalendarEvents(start: Date, end: Date) {
  const { data } = await apiClient.get<CalendarEvent[]>("/api/v1/calendar-events", {
    params: { start: start.toISOString(), end: end.toISOString() },
  })
  return data
}

export async function createCalendarEvent(payload: {
  title: string
  description?: string
  event_type: CalendarEventType
  start_at: string
  end_at: string
  all_day?: boolean
  project_id?: string
  user_id?: string
}) {
  const { data } = await apiClient.post<CalendarEvent>("/api/v1/calendar-events", payload)
  return data
}

export async function updateCalendarEvent(
  eventId: string,
  payload: Partial<{
    title: string
    description: string
    start_at: string
    end_at: string
    all_day: boolean
  }>
) {
  const { data } = await apiClient.patch<CalendarEvent>(`/api/v1/calendar-events/${eventId}`, payload)
  return data
}

export async function deleteCalendarEvent(eventId: string) {
  await apiClient.delete(`/api/v1/calendar-events/${eventId}`)
}
