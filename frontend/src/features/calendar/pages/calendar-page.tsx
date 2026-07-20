import { useMemo, useState } from "react"
import { useQuery } from "@tanstack/react-query"
import { CalendarCheck, ChevronLeft, ChevronRight, Plus } from "lucide-react"

import { Button } from "@/components/ui/button"
import { Select } from "@/components/ui/select"
import { listCalendarEvents, type CalendarEvent, type CalendarEventType } from "@/features/calendar/api"
import { EVENT_TYPE_COLOR, EVENT_TYPE_LABEL, TASK_EVENT_COLOR } from "@/features/calendar/constants"
import { EventFormDialog } from "@/features/calendar/components/event-form-dialog"
import { MonthView } from "@/features/calendar/components/month-view"
import { AgendaView } from "@/features/calendar/components/agenda-view"
import { DayEventsDialog } from "@/features/calendar/components/day-events-dialog"
import { TaskDetailDialog } from "@/features/tasks/components/task-detail-dialog"
import { listAllTasks } from "@/features/tasks/api"
import { listProjects } from "@/features/projects/api"
import { useAuthStore } from "@/features/auth/auth-store"
import type { Task } from "@/lib/types"
import type { CalendarItem } from "@/features/calendar/types"
import {
  addDays,
  dateKey,
  daysInRange,
  groupByDateKey,
  jalaliMonthDays,
  startOfWeek,
} from "@/features/calendar/calendar-utils"
import { JALALI_MONTH_NAMES, fromJalali, getJalaliMonthGrid, parseIsoDate, toJalali, toPersianDigits } from "@/lib/jalali"

type ViewMode = "month" | "agenda"
type AgendaRange = "week" | "month"

// "leave" is deliberately excluded: leave is now handled by the dedicated
// Leave Request workflow (/leave) and must never appear on the calendar.
const FILTERABLE_TYPES: (CalendarEventType | "task")[] = ["task", "meeting", "holiday", "reminder"]
const FILTER_LABEL: Record<CalendarEventType | "task", string> = { task: "مهلت وظایف", ...EVENT_TYPE_LABEL }
const FILTER_COLOR: Record<CalendarEventType | "task", string> = { task: TASK_EVENT_COLOR, ...EVENT_TYPE_COLOR }

const CURRENT_JALALI_YEAR = toJalali(new Date()).jy
const YEAR_OPTIONS = Array.from({ length: 9 }, (_, i) => CURRENT_JALALI_YEAR - 3 + i)

function timeLabel(iso: string): string {
  return new Date(iso).toLocaleTimeString("fa-IR", { hour: "2-digit", minute: "2-digit" })
}

function weekRangeLabel(weekStart: Date): string {
  const weekEnd = addDays(weekStart, 6)
  const a = toJalali(weekStart)
  const b = toJalali(weekEnd)
  if (a.jm === b.jm) {
    return `${toPersianDigits(a.jd)} تا ${toPersianDigits(b.jd)} ${JALALI_MONTH_NAMES[a.jm - 1]} ${toPersianDigits(a.jy)}`
  }
  return `${toPersianDigits(a.jd)} ${JALALI_MONTH_NAMES[a.jm - 1]} تا ${toPersianDigits(b.jd)} ${JALALI_MONTH_NAMES[b.jm - 1]} ${toPersianDigits(b.jy)}`
}

function tabClass(active: boolean): string {
  return (
    "rounded-md px-3 py-1.5 text-sm font-medium transition-colors " +
    (active ? "bg-primary text-primary-foreground shadow-sm" : "text-muted-foreground hover:bg-background")
  )
}

export function CalendarPage() {
  const role = useAuthStore((s) => s.user?.role)
  const canManageOrgWide = role === "org_admin" || role === "project_manager"

  const today = new Date()
  const [view, setView] = useState<ViewMode>("month")
  const [agendaRange, setAgendaRange] = useState<AgendaRange>("week")
  const [jalaliCursor, setJalaliCursor] = useState(() => {
    const { jy, jm } = toJalali(today)
    return { jy, jm }
  })
  const [weekAnchor, setWeekAnchor] = useState(() => startOfWeek(today))

  const [activeTypes, setActiveTypes] = useState<Set<CalendarEventType | "task">>(new Set(FILTERABLE_TYPES))
  const [projectFilter, setProjectFilter] = useState("")

  const [draft, setDraft] = useState<{ start: Date; end: Date; allDay: boolean } | null>(null)
  const [editingEvent, setEditingEvent] = useState<CalendarEvent | null>(null)
  const [viewingTask, setViewingTask] = useState<Task | null>(null)
  const [viewingDayKey, setViewingDayKey] = useState<string | null>(null)
  const [formOpen, setFormOpen] = useState(false)

  // The set of Gregorian days actually rendered by the active view --
  // drives both the fetch range and the day grouping below.
  const displayDays = useMemo(() => {
    if (view === "month") return getJalaliMonthGrid(jalaliCursor.jy, jalaliCursor.jm)
    if (agendaRange === "week") return daysInRange(weekAnchor, 7)
    return jalaliMonthDays(jalaliCursor.jy, jalaliCursor.jm)
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [view, agendaRange, jalaliCursor.jy, jalaliCursor.jm, weekAnchor])

  const rangeStart = displayDays[0]
  const rangeEnd = addDays(displayDays[displayDays.length - 1], 1)

  const { data: events } = useQuery({
    queryKey: ["calendar-events", dateKey(rangeStart), dateKey(rangeEnd)],
    queryFn: () => listCalendarEvents(rangeStart, rangeEnd),
  })
  const { data: tasks } = useQuery({ queryKey: ["tasks", "all"], queryFn: () => listAllTasks() })
  const { data: projects } = useQuery({ queryKey: ["projects"], queryFn: listProjects })

  const itemsByDay = useMemo(() => {
    const items: CalendarItem[] = []

    if (activeTypes.has("task")) {
      for (const t of tasks ?? []) {
        if (!t.deadline) continue
        if (projectFilter && t.project_id !== projectFilter) continue
        items.push({ id: `task-${t.id}`, kind: "task", title: t.title, color: TASK_EVENT_COLOR, time: null, task: t })
      }
    }

    for (const e of events ?? []) {
      if (!activeTypes.has(e.event_type)) continue
      if (projectFilter && e.project_id !== projectFilter) continue
      items.push({
        id: e.id,
        kind: "event",
        title: e.title,
        color: EVENT_TYPE_COLOR[e.event_type],
        time: e.all_day ? null : timeLabel(e.start_at),
        event: e,
      })
    }

    // Defensive de-dupe by id -- guards the UI even if upstream data ever
    // repeats an event.
    const seen = new Set<string>()
    const deduped = items.filter((item) => (seen.has(item.id) ? false : (seen.add(item.id), true)))

    const keyOfItem = (item: CalendarItem) =>
      item.kind === "task" ? item.task.deadline! : dateKey(new Date(item.event.start_at))
    const grouped = groupByDateKey(deduped, keyOfItem)
    for (const key of Object.keys(grouped)) {
      grouped[key].sort((a, b) => (a.time ?? "").localeCompare(b.time ?? ""))
    }
    return grouped
  }, [tasks, events, activeTypes, projectFilter])

  function toggleType(t: CalendarEventType | "task") {
    setActiveTypes((prev) => {
      const next = new Set(prev)
      if (next.has(t)) next.delete(t)
      else next.add(t)
      return next
    })
  }

  function navigate(direction: 1 | -1) {
    if (view === "agenda" && agendaRange === "week") {
      setWeekAnchor((prev) => addDays(prev, direction * 7))
      return
    }
    let { jy, jm } = jalaliCursor
    jm += direction
    if (jm > 12) {
      jm = 1
      jy += 1
    } else if (jm < 1) {
      jm = 12
      jy -= 1
    }
    setJalaliCursor({ jy, jm })
    setWeekAnchor(startOfWeek(fromJalali(jy, jm, 1)))
  }

  function goToday() {
    const { jy, jm } = toJalali(today)
    setJalaliCursor({ jy, jm })
    setWeekAnchor(startOfWeek(today))
  }

  function changeMonth(jm: number) {
    setJalaliCursor((prev) => ({ ...prev, jm }))
    setWeekAnchor(startOfWeek(fromJalali(jalaliCursor.jy, jm, 1)))
  }

  function changeYear(jy: number) {
    setJalaliCursor((prev) => ({ ...prev, jy }))
    setWeekAnchor(startOfWeek(fromJalali(jy, jalaliCursor.jm, 1)))
  }

  function openNewEventForm(start: Date) {
    setDraft({ start, end: addDays(start, 1), allDay: true })
    setEditingEvent(null)
    setFormOpen(true)
  }

  function handleSelectItem(item: CalendarItem) {
    setViewingDayKey(null)
    if (item.kind === "task") {
      setViewingTask(item.task)
    } else {
      setEditingEvent(item.event)
      setDraft(null)
      setFormOpen(true)
    }
  }

  const title =
    view === "agenda" && agendaRange === "week"
      ? weekRangeLabel(weekAnchor)
      : `${JALALI_MONTH_NAMES[jalaliCursor.jm - 1]} ${toPersianDigits(jalaliCursor.jy)}`

  return (
    <div className="flex flex-col gap-4">
      <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <h1 className="text-2xl font-bold">تقویم</h1>
          <p className="text-muted-foreground">وظایف، جلسات، مرخصی‌ها و یادآوری‌های سازمان شما</p>
        </div>
        <Button onClick={() => openNewEventForm(today)}>
          <Plus className="size-4" />
          رویداد جدید
        </Button>
      </div>

      <div className="flex flex-col gap-3 rounded-xl border border-border bg-card p-3 shadow-sm">
        <div className="flex flex-wrap items-center justify-between gap-3">
          <div className="flex flex-wrap items-center gap-2">
            <Button variant="outline" size="icon" aria-label="قبلی" onClick={() => navigate(-1)}>
              <ChevronRight className="size-4" />
            </Button>
            <Button variant="ghost" size="sm" className="gap-1.5 px-2.5" onClick={goToday}>
              <CalendarCheck className="size-4" />
              امروز
            </Button>
            <Button variant="outline" size="icon" aria-label="بعدی" onClick={() => navigate(1)}>
              <ChevronLeft className="size-4" />
            </Button>
            <Select
              aria-label="ماه"
              value={jalaliCursor.jm}
              onChange={(e) => changeMonth(Number(e.target.value))}
              className="h-9 w-auto"
            >
              {JALALI_MONTH_NAMES.map((name, idx) => (
                <option key={name} value={idx + 1}>
                  {name}
                </option>
              ))}
            </Select>
            <Select
              aria-label="سال"
              value={jalaliCursor.jy}
              onChange={(e) => changeYear(Number(e.target.value))}
              className="h-9 w-auto"
            >
              {YEAR_OPTIONS.map((y) => (
                <option key={y} value={y}>
                  {toPersianDigits(y)}
                </option>
              ))}
            </Select>
          </div>

          <div className="flex items-center gap-2">
            {view === "agenda" && (
              <div className="flex gap-1 rounded-lg bg-muted p-1">
                <button type="button" onClick={() => setAgendaRange("week")} className={tabClass(agendaRange === "week")}>
                  هفته
                </button>
                <button type="button" onClick={() => setAgendaRange("month")} className={tabClass(agendaRange === "month")}>
                  ماه
                </button>
              </div>
            )}
            <div className="flex gap-1 rounded-lg bg-muted p-1">
              <button type="button" onClick={() => setView("month")} className={tabClass(view === "month")}>
                ماه
              </button>
              <button type="button" onClick={() => setView("agenda")} className={tabClass(view === "agenda")}>
                برنامه
              </button>
            </div>
          </div>
        </div>
        <p className="text-sm font-medium">{title}</p>
      </div>

      <div className="flex flex-wrap items-center gap-2">
        {FILTERABLE_TYPES.map((t) => {
          const active = activeTypes.has(t)
          return (
            <button
              key={t}
              onClick={() => toggleType(t)}
              className={
                "flex items-center gap-1.5 rounded-full border px-2.5 py-1 text-xs font-medium transition-all " +
                (active ? "border-transparent" : "border-border text-muted-foreground opacity-60 hover:opacity-100")
              }
              style={active ? { backgroundColor: `color-mix(in oklab, ${FILTER_COLOR[t]} 14%, transparent)` } : undefined}
            >
              <span className="size-2 rounded-full" style={{ backgroundColor: FILTER_COLOR[t] }} />
              {FILTER_LABEL[t]}
            </button>
          )
        })}
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

      {view === "month" ? (
        <MonthView
          jy={jalaliCursor.jy}
          jm={jalaliCursor.jm}
          today={today}
          itemsByDay={itemsByDay}
          onSelectDay={setViewingDayKey}
        />
      ) : (
        <div className="rounded-xl border border-border bg-card p-3 shadow-sm">
          <AgendaView days={displayDays} today={today} itemsByDay={itemsByDay} onSelectItem={handleSelectItem} />
        </div>
      )}

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

      <DayEventsDialog
        open={viewingDayKey !== null}
        onOpenChange={(next) => {
          if (!next) setViewingDayKey(null)
        }}
        dateKey={viewingDayKey}
        items={viewingDayKey ? itemsByDay[viewingDayKey] ?? [] : []}
        onSelectItem={handleSelectItem}
        onCreateEvent={() => {
          if (viewingDayKey) openNewEventForm(parseIsoDate(viewingDayKey))
        }}
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
