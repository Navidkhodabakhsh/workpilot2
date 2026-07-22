import { useEffect, useState } from "react"
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query"
import { Plus, Trash2 } from "lucide-react"

import { Button } from "@/components/ui/button"
import { Dialog, DialogContent, DialogDescription, DialogHeader, DialogTitle, DialogTrigger } from "@/components/ui/dialog"
import { Input } from "@/components/ui/input"
import { JalaliDateInput } from "@/components/ui/jalali-date-input"
import { Label } from "@/components/ui/label"
import { Select } from "@/components/ui/select"
import { Textarea } from "@/components/ui/textarea"
import {
  createCalendarEvent,
  createCalendarEventCategory,
  deleteCalendarEvent,
  listCalendarEventCategories,
  updateCalendarEvent,
  type CalendarEvent,
  type CalendarEventType,
} from "@/features/calendar/api"
import { EVENT_TYPE_LABEL } from "@/features/calendar/constants"
import type { Project } from "@/lib/types"

function NewCategoryDialog({ onCreated }: { onCreated: (categoryId: string) => void }) {
  const [open, setOpen] = useState(false)
  const [name, setName] = useState("")
  const [color, setColor] = useState("#64748b")
  const queryClient = useQueryClient()
  const mutation = useMutation({
    mutationFn: () => createCalendarEventCategory({ name, color }),
    onSuccess: (category) => {
      queryClient.invalidateQueries({ queryKey: ["calendar-event-categories"] })
      setOpen(false)
      setName("")
      onCreated(category.id)
    },
  })
  return (
    <Dialog open={open} onOpenChange={setOpen}>
      <DialogTrigger asChild>
        <Button type="button" variant="outline" size="icon" aria-label="دسته‌بندی جدید">
          <Plus className="size-4" />
        </Button>
      </DialogTrigger>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>دسته‌بندی جدید رویداد</DialogTitle>
          <DialogDescription>یک برچسب و رنگ دلخواه برای رویدادهای مشابه بسازید.</DialogDescription>
        </DialogHeader>
        <div className="flex flex-col gap-4">
          <div className="flex flex-col gap-2">
            <Label htmlFor="new-event-category-name" required>نام دسته‌بندی</Label>
            <Input id="new-event-category-name" value={name} onChange={(e) => setName(e.target.value)} />
          </div>
          <div className="flex flex-col gap-2">
            <Label htmlFor="new-event-category-color" required>رنگ</Label>
            <Input id="new-event-category-color" type="color" value={color} onChange={(e) => setColor(e.target.value)} className="h-11" />
          </div>
          {mutation.isError && <p className="text-sm text-danger">ساخت دسته‌بندی انجام نشد.</p>}
          <Button disabled={name.trim().length < 2 || mutation.isPending} onClick={() => mutation.mutate()}>
            ذخیره دسته‌بندی
          </Button>
        </div>
      </DialogContent>
    </Dialog>
  )
}

function toDateInput(d: Date): string {
  const y = d.getFullYear()
  const m = String(d.getMonth() + 1).padStart(2, "0")
  const day = String(d.getDate()).padStart(2, "0")
  return `${y}-${m}-${day}`
}
function toTimeInput(d: Date): string {
  return `${String(d.getHours()).padStart(2, "0")}:${String(d.getMinutes()).padStart(2, "0")}`
}
// All-day events are anchored at UTC midnight of the picked date rather than
// local midnight -- the calendar grid buckets events by UTC-field date keys
// (see calendar-utils.ts), so an all-day event must round-trip through the
// exact same UTC day or it lands on the wrong cell for viewers ahead of UTC.
// Timed events keep local-time construction: the picked "HH:MM" is a real
// wall-clock time that should convert through the browser's own timezone.
function combine(date: string, time: string, allDay: boolean): string {
  if (allDay) {
    const [y, m, d] = date.split("-").map(Number)
    const [hh, mm] = (time || "00:00").split(":").map(Number)
    return new Date(Date.UTC(y, m - 1, d, hh, mm)).toISOString()
  }
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
  const [categoryId, setCategoryId] = useState("")
  const [error, setError] = useState<string | null>(null)

  const { data: categories } = useQuery({
    queryKey: ["calendar-event-categories"],
    queryFn: listCalendarEventCategories,
    enabled: open,
  })

  useEffect(() => {
    if (!open) return
    setError(null)
    if (editingEvent) {
      setTitle(editingEvent.title)
      setDescription(editingEvent.description ?? "")
      setEventType(editingEvent.event_type)
      setProjectId(editingEvent.project_id ?? "")
      setCategoryId(editingEvent.category_id ?? "")
    } else {
      setTitle("")
      setDescription("")
      setEventType(canManageOrgWide ? "meeting" : "reminder")
      setProjectId("")
      setCategoryId("")
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
        category_id: categoryId || undefined,
        start_at: combine(startDate, allDay ? "00:00" : startTime, allDay),
        end_at: combine(endDate, allDay ? "23:59" : endTime, allDay),
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
        category_id: categoryId || null,
        start_at: combine(startDate, allDay ? "00:00" : startTime, allDay),
        end_at: combine(endDate, allDay ? "23:59" : endTime, allDay),
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
            <Label htmlFor="event-title" required>عنوان</Label>
            <Input id="event-title" value={title} onChange={(e) => setTitle(e.target.value)} />
          </div>

          {!isEdit && (
            <div className="flex flex-col gap-2">
              <Label htmlFor="event-type" required>نوع رویداد</Label>
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
              <Label htmlFor="event-project">پروژه</Label>
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

          <div className="flex flex-col gap-2">
            <Label htmlFor="event-category">دسته‌بندی</Label>
            <div className="flex gap-2">
              <Select id="event-category" value={categoryId} onChange={(e) => setCategoryId(e.target.value)} className="flex-1">
                <option value="">بدون دسته‌بندی</option>
                {categories?.map((category) => (
                  <option key={category.id} value={category.id}>
                    {category.name}
                  </option>
                ))}
              </Select>
              <NewCategoryDialog onCreated={setCategoryId} />
            </div>
          </div>

          <label className="flex items-center gap-2 text-sm">
            <input type="checkbox" className="size-4" checked={allDay} onChange={(e) => setAllDay(e.target.checked)} />
            تمام روز
          </label>

          <div className="grid grid-cols-2 gap-4">
            <div className="flex flex-col gap-2">
              <Label htmlFor="event-start-date" required>تاریخ شروع</Label>
              <JalaliDateInput id="event-start-date" value={startDate} onChange={setStartDate} />
              {!allDay && (
                <Input type="time" value={startTime} onChange={(e) => setStartTime(e.target.value)} />
              )}
            </div>
            <div className="flex flex-col gap-2">
              <Label htmlFor="event-end-date" required>تاریخ پایان</Label>
              <JalaliDateInput id="event-end-date" value={endDate} onChange={setEndDate} />
              {!allDay && <Input type="time" value={endTime} onChange={(e) => setEndTime(e.target.value)} />}
            </div>
          </div>

          <div className="flex flex-col gap-2">
            <Label htmlFor="event-description">توضیحات</Label>
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
