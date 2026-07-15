import { useMemo, useState } from "react"
import { useQuery } from "@tanstack/react-query"
import { ChevronLeft, ChevronRight } from "lucide-react"

import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { getMonthGridDates, groupTasksByDate, toDateKey } from "@/features/calendar/calendar-utils"
import { listAllTasks } from "@/features/tasks/api"

const WEEKDAY_LABELS = ["ش", "ی", "د", "س", "چ", "پ", "ج"]
const MONTH_FORMATTER = new Intl.DateTimeFormat("fa-IR", { calendar: "persian", month: "long", year: "numeric" })
const DAY_FORMATTER = new Intl.DateTimeFormat("fa-IR", { calendar: "persian", day: "numeric" })

export function CalendarPage() {
  const [cursor, setCursor] = useState(() => new Date())
  const { data: tasks } = useQuery({ queryKey: ["all-tasks"], queryFn: () => listAllTasks() })

  const grid = useMemo(() => getMonthGridDates(cursor.getFullYear(), cursor.getMonth()), [cursor]);
  const tasksByDate = useMemo(() => groupTasksByDate(tasks ?? []), [tasks])
  const today = toDateKey(new Date())

  return (
    <div className="flex flex-col gap-4">
      <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <h1 className="text-2xl font-bold">تقویم</h1>
          <p className="text-muted-foreground">مهلت وظایف در پروژه‌هایی که به آن‌ها دسترسی دارید</p>
        </div>
        <div className="flex items-center gap-2">
          <Button
            variant="outline"
            size="icon"
            aria-label="ماه قبل"
            onClick={() => setCursor((c) => new Date(c.getFullYear(), c.getMonth() - 1, 1))}
          >
            <ChevronRight className="size-4" />
          </Button>
          <span className="min-w-32 text-center font-medium">{MONTH_FORMATTER.format(cursor)}</span>
          <Button
            variant="outline"
            size="icon"
            aria-label="ماه بعد"
            onClick={() => setCursor((c) => new Date(c.getFullYear(), c.getMonth() + 1, 1))}
          >
            <ChevronLeft className="size-4" />
          </Button>
        </div>
      </div>

      <div className="grid grid-cols-7 gap-px overflow-hidden rounded-lg border border-border bg-border text-center text-xs font-medium text-muted-foreground">
        {WEEKDAY_LABELS.map((d) => (
          <div key={d} className="bg-card py-2">
            {d}
          </div>
        ))}
      </div>
      <div className="grid grid-cols-7 gap-px overflow-hidden rounded-lg border border-border bg-border">
        {grid.map((date) => {
          const key = toDateKey(date)
          const dayTasks = tasksByDate[key] ?? []
          const inCurrentMonth = date.getMonth() === cursor.getMonth()
          return (
            <div
              key={key}
              className={`flex min-h-24 flex-col gap-1 p-1.5 ${
                inCurrentMonth ? "bg-card" : "bg-muted/40"
              } ${key === today ? "ring-2 ring-inset ring-primary" : ""}`}
            >
              <span className={`text-xs ${inCurrentMonth ? "text-foreground" : "text-muted-foreground"}`}>
                {DAY_FORMATTER.format(date)}
              </span>
              <div className="flex flex-col gap-1">
                {dayTasks.slice(0, 2).map((t) => (
                  <Badge key={t.id} variant="info" className="justify-start truncate">
                    {t.title}
                  </Badge>
                ))}
                {dayTasks.length > 2 && (
                  <span className="text-xs text-muted-foreground">+{dayTasks.length - 2} مورد دیگر</span>
                )}
              </div>
            </div>
          )
        })}
      </div>
    </div>
  )
}
