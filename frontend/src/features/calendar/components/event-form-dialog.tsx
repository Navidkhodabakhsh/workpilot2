import { useEffect, useState } from "react"
import { useMutation, useQueryClient } from "@tanstack/react-query"
import { Trash2 } from "lucide-react"

import { Button } from "@/components/ui/button"
import { Dialog, DialogContent, DialogDescription, DialogHeader, DialogTitle } from "@/components/ui/dialog"
import { Input } from "@/components/ui/input"
import { JalaliDateInput } from "@/components/ui/jalali-date-input"
import { Label } from "@/components/ui/label"
import { Select } from "@/components/ui/select"
import { Textarea } from "@/components/ui/textarea"
import {
  createCalendarEvent,
  deleteCalendarEvent,
  updateCalendarEvent,
  type CalendarEvent,
  type CalendarEventType,
} from "@/features/calendar/api"
import { EVENT_TYPE_LABEL } from "@/features/calendar/constants"
import type { Project } from "@/lib/types"

function toDateInput(d: Date): string {
  const y = d.getFullYear()
  const m = String(d.getMonth() + 1).padStart(2, "0")
  const day = String(d.getDate()).padStart(2, "0")
  return `${y}-${m}-${day}`
}
function toTimeInput(d: Date): string {
  return `${String(d.getHours()).padStart(2, "0")}:${String(d.getMinutes()).padStart(2, "0")}`
}
function combine(date: string, time: string): string {
  return new Date(`${date}T${time || "00:00"}:00`).toISOString()
}

type DraftRange = { start: Date; end: Date; allDay: boolean }

export function EventFormDialog({
  open,
  onOpenChange,
  draft,
  editingEvent,
  canManageOrgWide,
  projects,
}: {
  open: boolean
  onOpenChange: (open: boolean) => void
  draft?: DraftRange | null
  editingEvent?: CalendarEvent | null
  canManageOrgWide: boolean
  projects: Project[]
}) {
  const queryClient = useQueryClient()
  const isEdit = !!editingEvent
  const source = editingEvent
    ? { start: new Date(editingEvent.start_at), end: new Date(editingEvent.end_at), allDay: editingEvent.all_day }
    : draft

  const [title, setTitle] = useState("")
  const [description, setDescription] = useState("")
  const [eventType, setEventType] = useState<CalendarEventType>("meeting")
  const [allDay, setAllDay] = useState(false)
  const [startDate, setStartDate] = useState("")
  const [startTime, setStartTime] = useState("")
  const [endDate, setEndDate] = useState("")
  const [endTime, setEndTime] = useState("")
  const [projectId, setProjectId] = useState("")
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    if (!open) return
    setError(null)
    if (editingEvent) {
      setTitle(editingEvent.title)
      setDescription(editingEvent.description ?? "")
      setEventType(editingEvent.event_type)
      setProjectId(editingEvent.project_id ?? "")
    } else {
      setTitle("")
      setDescription("")
      setEventType(canManageOrgWide ? "meeting" : "reminder")
      setProjectId("")
    }
    if (source) {
      setAllDay(source.allDay)
      setStartDate(toDateInput(source.start))
      setStartTime(toTimeInput(source.start))
      setEndDate(toDateInput(source.end))
      setEndTime(toTimeInput(source.end))
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [open, editingEvent])

  const invalidate = () => queryClient.invalidateQueries({ queryKey: ["calendar-events"], exact: false })

  const createMutation = useMutation({
    mutationFn: () =>
      createCalendarEvent({
        title,
        description: description || undefined,
        event_type: eventType,
        start_at: combine(startDate, allDay ? "00:00" : startTime),
        end_at: combine(endDate, allDay ? "23:59" : endTime),
        all_day: allDay,
        project_id: eventType === "meeting" ? projectId || undefined : undefined,
      }),
    onSuccess: () => {
      invalidate()
      onOpenChange(false)
    },
    onError: () => setError("ثبت رویداد با خطا مواجه شد"),
  })

  const updateMutation = useMutation({
    mutationFn: () =>
      updateCalendarEvent(editingEvent!.id, {
        title,
        description: description || undefined,
        start_at: combine(startDate, allDay ? "00:00" : startTime),
        end_at: combine(endDate, allDay ? "23:59" : endTime),
        all_day: allDay,
      }),
    onSuccess: () => {
      invalidate()
      onOpenChange(false)
    },
    onError: () => setError("ذخیرهٔ تغییرات با خطا مواجه شد"),
  })

  const deleteMutation = useMutation({
    mutationFn: () => deleteCalendarEvent(editingEvent!.id),
    onSuccess: () => {
      invalidate()
      onOpenChange(false)
    },
    onError: () => setError("حذف رویداد با خطا مواجه شد"),
  })

  function handleSubmit(e: React.FormEvent) {
    e.preventDefault()
    setError(null)
    if (title.trim().length < 2) {
      setError("عنوان را وارد کنید")
      return
    }
    if (isEdit) updateMutation.mutate()
    else createMutation.mutate()
  }

  const busy = createMutation.isPending || updateMutation.isPending || deleteMutation.isPending
  // "leave" is intentionally excluded here: it's now handled by the
  // dedicated Leave Request workflow (/leave), not as a calendar event.
  const availableTypes: CalendarEventType[] = canManageOrgWide ? ["meeting", "holiday", "reminder"] : ["reminder"]

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>{isEdit ? "ویرایش رویداد" : "رویداد جدید"}</DialogTitle>
          <DialogDescription>اطلاعات رویداد را وارد کنید</DialogDescription>
        </DialogHeader>
        <form onSubmit={handleSubmit} className="flex flex-col gap-4">
          <div className="flex flex-col gap-2">
            <Label htmlFor="event-title">عنوان</Label>
            <Input id="event-title" value={title} onChange={(e) => setTitle(e.target.value)} />
          </div>

          {!isEdit && (
            <div className="flex flex-col gap-2">
              <Label htmlFor="event-type">نوع رویداد</Label>
              <Select id="event-type" value={eventType} onChange={(e) => setEventType(e.target.value as CalendarEventType)}>
                {availableTypes.map((t) => (
                  <option key={t} value={t}>
                    {EVENT_TYPE_LABEL[t]}
                  </option>
                ))}
              </Select>
            </div>
          )}

          {!isEdit && eventType === "meeting" && (
            <div className="flex flex-col gap-2">
              <Label htmlFor="event-project">پروژه (اختیاری)</Label>
              <Select id="event-project" value={projectId} onChange={(e) => setProjectId(e.target.value)}>
                <option value="">سراسر سازمان</option>
                {projects.map((p) => (
                  <option key={p.id} value={p.id}>
                    {p.name}
                  </option>
                ))}
              </Select>
            </div>
          )}

          <label className="flex items-center gap-2 text-sm">
            <input type="checkbox" className="size-4" checked={allDay} onChange={(e) => setAllDay(e.target.checked)} />
            تمام روز
          </label>

          <div className="grid grid-cols-2 gap-4">
            <div className="flex flex-col gap-2">
              <Label htmlFor="event-start-date">تاریخ شروع</Label>
              <JalaliDateInput id="event-start-date" value={startDate} onChange={setStartDate} />
              {!allDay && (
                <Input type="time" value={startTime} onChange={(e) => setStartTime(e.target.value)} />
              )}
            </div>
            <div className="flex flex-col gap-2">
              <Label htmlFor="event-end-date">تاریخ پایان</Label>
              <JalaliDateInput id="event-end-date" value={endDate} onChange={setEndDate} />
              {!allDay && <Input type="time" value={endTime} onChange={(e) => setEndTime(e.target.value)} />}
            </div>
          </div>

          <div className="flex flex-col gap-2">
            <Label htmlFor="event-description">توضیحات (اختیاری)</Label>
            <Textarea id="event-description" value={description} onChange={(e) => setDescription(e.target.value)} />
          </div>

          {error && <p className="text-sm text-danger">{error}</p>}

          <div className="flex items-center justify-between gap-2">
            {isEdit ? (
              <Button
                type="button"
                variant="ghost"
                className="text-danger hover:text-danger"
                disabled={busy}
                onClick={() => deleteMutation.mutate()}
              >
                <Trash2 className="size-4" />
                حذف
              </Button>
            ) : (
              <span />
            )}
            <Button type="submit" disabled={busy}>
              {busy ? "در حال ذخیره..." : isEdit ? "ذخیرهٔ تغییرات" : "ایجاد رویداد"}
            </Button>
          </div>
        </form>
      </DialogContent>
    </Dialog>
  )
}
