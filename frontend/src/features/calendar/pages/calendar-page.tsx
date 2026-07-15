import { useMemo, useRef, useState } from "react"
import { useQuery } from "@tanstack/react-query"
import FullCalendar from "@fullcalendar/react"
import dayGridPlugin from "@fullcalendar/daygrid"
import timeGridPlugin from "@fullcalendar/timegrid"
import listPlugin from "@fullcalendar/list"
import interactionPlugin from "@fullcalendar/interaction"
import faLocale from "@fullcalendar/core/locales/fa"
import type {
  DateSelectArg,
  DatesSetArg,
  EventClickArg,
  EventDropArg,
  EventInput,
} from "@fullcalendar/core"
import type { EventResizeDoneArg } from "@fullcalendar/interaction"
import { ChevronLeft, ChevronRight, Plus } from "lucide-react"

import { Button } from "@/components/ui/button"
import { useMutation, useQueryClient } from "@tanstack/react-query"
import { listCalendarEvents, updateCalendarEvent, type CalendarEvent, type CalendarEventType } from "@/features/calendar/api"
import { EVENT_TYPE_COLOR, EVENT_TYPE_LABEL, TASK_EVENT_COLOR } from "@/features/calendar/constants"
import { EventFormDialog } from "@/features/calendar/components/event-form-dialog"
import { TaskDetailDialog } from "@/features/tasks/components/task-detail-dialog"
import { listAllTasks } from "@/features/tasks/api"
import { listProjects } from "@/features/projects/api"
import { useAuthStore } from "@/features/auth/auth-store"
import type { Task } from "@/lib/types"

type ViewKey = "dayGridMonth" | "timeGridWeek" | "timeGridDay" | "listWeek"
const VIEWS: { key: ViewKey; label: string }[] = [
  { key: "dayGridMonth", label: "ماه" },
  { key: "timeGridWeek", label: "هفته" },
  { key: "timeGridDay", label: "روز" },
  { key: "listWeek", label: "برنامه" },
]

const MONTH_TITLE_FORMATTER = new Intl.DateTimeFormat("fa-IR", { calendar: "persian", month: "long", year: "numeric" })
const DAY_TITLE_FORMATTER = new Intl.DateTimeFormat("fa-IR", {
  calendar: "persian",
  day: "numeric",
  month: "long",
  year: "numeric",
})
const DAY_NUMBER_FORMATTER = new Intl.DateTimeFormat("fa-IR", { calendar: "persian", day: "numeric" })

const FILTERABLE_TYPES: (CalendarEventType | "task")[] = ["task", "meeting", "leave", "holiday", "reminder"]
const FILTER_LABEL: Record<CalendarEventType | "task", string> = { task: "مهلت وظایف", ...EVENT_TYPE_LABEL }
const FILTER_COLOR: Record<CalendarEventType | "task", string> = { task: TASK_EVENT_COLOR, ...EVENT_TYPE_COLOR }

export function CalendarPage() {
  const calendarRef = useRef<FullCalendar>(null)
  const queryClient = useQueryClient()
  const role = useAuthStore((s) => s.user?.role)
  const canManageOrgWide = role === "org_admin" || role === "project_manager"

  const [view, setView] = useState<ViewKey>("dayGridMonth")
  const [title, setTitle] = useState("")
  const [range, setRange] = useState(() => {
    const now = new Date()
    return { start: new Date(now.getFullYear(), now.getMonth(), 1), end: new Date(now.getFullYear(), now.getMonth() + 1, 1) }
  })
  const [activeTypes, setActiveTypes] = useState<Set<CalendarEventType | "task">>(new Set(FILTERABLE_TYPES))
  const [projectFilter, setProjectFilter] = useState("")

  const [draft, setDraft] = useState<{ start: Date; end: Date; allDay: boolean } | null>(null)
  const [editingEvent, setEditingEvent] = useState<CalendarEvent | null>(null)
  const [viewingTask, setViewingTask] = useState<Task | null>(null)
  const [formOpen, setFormOpen] = useState(false)

  const { data: events } = useQuery({
    queryKey: ["calendar-events", range.start.toISOString(), range.end.toISOString()],
    queryFn: () => listCalendarEvents(range.start, range.end),
  })
  const { data: tasks } = useQuery({ queryKey: ["tasks", "all"], queryFn: () => listAllTasks() })
  const { data: projects } = useQuery({ queryKey: ["projects"], queryFn: listProjects })

  const updateMutation = useMutation({
    mutationFn: ({ id, payload }: { id: string; payload: { start_at: string; end_at: string } }) =>
      updateCalendarEvent(id, payload),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ["calendar-events"], exact: false }),
  })

  const taskEvents = useMemo<EventInput[]>(() => {
    if (!activeTypes.has("task")) return []
    return (tasks ?? [])
      .filter((t) => t.deadline)
      .filter((t) => !projectFilter || t.project_id === projectFilter)
      .map((t) => ({
        id: `task-${t.id}`,
        title: t.title,
        start: t.deadline!,
        allDay: true,
        editable: false,
        backgroundColor: TASK_EVENT_COLOR,
        borderColor: TASK_EVENT_COLOR,
        extendedProps: { kind: "task", task: t },
      }))
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [tasks, activeTypes, projectFilter])

  const calEvents = useMemo<EventInput[]>(() => {
    return (events ?? [])
      .filter((e) => activeTypes.has(e.event_type))
      .filter((e) => !projectFilter || e.project_id === projectFilter)
      .map((e) => ({
        id: e.id,
        title: e.title,
        start: e.start_at,
        end: e.end_at,
        allDay: e.all_day,
        backgroundColor: EVENT_TYPE_COLOR[e.event_type],
        borderColor: EVENT_TYPE_COLOR[e.event_type],
        extendedProps: { kind: "event", event: e },
      }))
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [events, activeTypes, projectFilter])

  const allEvents = [...taskEvents, ...calEvents]

  function toggleType(t: CalendarEventType | "task") {
    setActiveTypes((prev) => {
      const next = new Set(prev)
      if (next.has(t)) next.delete(t)
      else next.add(t)
      return next
    })
  }

  function handleDatesSet(arg: DatesSetArg) {
    setRange({ start: arg.start, end: arg.end })
    setTitle((arg.view.type === "timeGridDay" ? DAY_TITLE_FORMATTER : MONTH_TITLE_FORMATTER).format(arg.view.currentStart))
  }

  function handleDateClick(arg: DateSelectArg) {
    const start = arg.start
    const end = arg.allDay ? new Date(start.getTime() + 86400000) : arg.end
    setDraft({ start, end, allDay: arg.allDay })
    setEditingEvent(null)
    setFormOpen(true)
  }

  function handleEventClick(arg: EventClickArg) {
    const props = arg.event.extendedProps as { kind: string; task?: Task; event?: CalendarEvent }
    if (props.kind === "task" && props.task) {
      setViewingTask(props.task)
    } else if (props.event) {
      setEditingEvent(props.event)
      setDraft(null)
      setFormOpen(true)
    }
  }

  function handleEventDrop(arg: EventDropArg) {
    const props = arg.event.extendedProps as { kind: string }
    if (props.kind !== "event" || !arg.event.start) {
      arg.revert()
      return
    }
    updateMutation.mutate(
      {
        id: arg.event.id,
        payload: {
          start_at: arg.event.start.toISOString(),
          end_at: (arg.event.end ?? arg.event.start).toISOString(),
        },
      },
      { onError: () => arg.revert() }
    )
  }

  function handleEventResize(arg: EventResizeDoneArg) {
    if (!arg.event.start || !arg.event.end) {
      arg.revert()
      return
    }
    updateMutation.mutate(
      { id: arg.event.id, payload: { start_at: arg.event.start.toISOString(), end_at: arg.event.end.toISOString() } },
      { onError: () => arg.revert() }
    )
  }

  function changeView(v: ViewKey) {
    calendarRef.current?.getApi().changeView(v)
    setView(v)
  }

  return (
    <div className="flex flex-col gap-4">
      <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <h1 className="text-2xl font-bold">تقویم</h1>
          <p className="text-muted-foreground">وظایف، جلسات، مرخصی‌ها و یادآوری‌های سازمان شما</p>
        </div>
        <Button
          onClick={() => {
            const now = new Date()
            setDraft({ start: now, end: new Date(now.getTime() + 3600000), allDay: false })
            setEditingEvent(null)
            setFormOpen(true)
          }}
        >
          <Plus className="size-4" />
          رویداد جدید
        </Button>
      </div>

      <div className="flex flex-col gap-3 lg:flex-row lg:items-center lg:justify-between">
        <div className="flex items-center gap-2">
          <Button variant="outline" size="icon" aria-label="قبلی" onClick={() => calendarRef.current?.getApi().prev()}>
            <ChevronRight className="size-4" />
          </Button>
          <Button variant="outline" size="sm" onClick={() => calendarRef.current?.getApi().today()}>
            امروز
          </Button>
          <Button variant="outline" size="icon" aria-label="بعدی" onClick={() => calendarRef.current?.getApi().next()}>
            <ChevronLeft className="size-4" />
          </Button>
          <span className="min-w-32 font-medium">{title}</span>
        </div>
        <div className="flex gap-1 rounded-lg border border-border p-1">
          {VIEWS.map((v) => (
            <button
              key={v.key}
              onClick={() => changeView(v.key)}
              className={
                "rounded-md px-3 py-1.5 text-sm font-medium transition-colors " +
                (view === v.key ? "bg-primary text-primary-foreground" : "text-muted-foreground hover:bg-muted")
              }
            >
              {v.label}
            </button>
          ))}
        </div>
      </div>

      <div className="flex flex-wrap items-center gap-2">
        {FILTERABLE_TYPES.map((t) => (
          <button
            key={t}
            onClick={() => toggleType(t)}
            className={
              "flex items-center gap-1.5 rounded-full border px-2.5 py-1 text-xs font-medium transition-opacity " +
              (activeTypes.has(t) ? "border-border opacity-100" : "border-border opacity-40")
            }
          >
            <span className="size-2 rounded-full" style={{ backgroundColor: FILTER_COLOR[t] }} />
            {FILTER_LABEL[t]}
          </button>
        ))}
        {projects && projects.length > 0 && (
          <select
            value={projectFilter}
            onChange={(e) => setProjectFilter(e.target.value)}
            className="rounded-full border border-border bg-background px-2.5 py-1 text-xs font-medium"
          >
            <option value="">همهٔ پروژه‌ها</option>
            {projects.map((p) => (
              <option key={p.id} value={p.id}>
                {p.name}
              </option>
            ))}
          </select>
        )}
      </div>

      <div className="calendar-shell rounded-lg border border-border bg-card p-2">
        <FullCalendar
          ref={calendarRef}
          plugins={[dayGridPlugin, timeGridPlugin, listPlugin, interactionPlugin]}
          initialView="dayGridMonth"
          headerToolbar={false}
          height="auto"
          direction="rtl"
          locale={faLocale}
          firstDay={6}
          selectable
          selectMirror
          editable
          events={allEvents}
          select={handleDateClick}
          eventClick={handleEventClick}
          eventDrop={handleEventDrop}
          eventResize={handleEventResize}
          datesSet={handleDatesSet}
          dayCellContent={(arg) => DAY_NUMBER_FORMATTER.format(arg.date)}
          eventDidMount={(info) => {
            info.el.title = info.event.title
          }}
        />
      </div>

      <div className="flex flex-wrap gap-3 text-xs text-muted-foreground">
        {FILTERABLE_TYPES.map((t) => (
          <div key={t} className="flex items-center gap-1.5">
            <span className="size-2 rounded-full" style={{ backgroundColor: FILTER_COLOR[t] }} />
            {FILTER_LABEL[t]}
          </div>
        ))}
      </div>

      <EventFormDialog
        open={formOpen}
        onOpenChange={setFormOpen}
        draft={draft}
        editingEvent={editingEvent}
        canManageOrgWide={canManageOrgWide}
        projects={projects ?? []}
      />

      {viewingTask && (
        <TaskDetailDialog
          task={viewingTask}
          open={viewingTask !== null}
          onOpenChange={(next) => {
            if (!next) setViewingTask(null)
          }}
        />
      )}
    </div>
  )
}
