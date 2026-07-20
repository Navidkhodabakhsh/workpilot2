import { Badge } from "@/components/ui/badge"
import { EmptyState } from "@/components/ui/empty-state"
import { JALALI_WEEKDAY_FULL_LABELS, toJalali, toPersianDigits } from "@/lib/jalali"
import { dateKey } from "@/features/calendar/calendar-utils"
import type { CalendarItem } from "@/features/calendar/types"

// One consistent color for every day header, and a separate consistent
// color for every task/event row -- day identity comes from the date and
// weekday label, not from hue, so color stays simple instead of turning
// into a second (confusing) coding scheme layered on top of the type
// filters above.
const DAY_COLOR = "var(--color-primary)"
const ITEM_DOT_COLOR = "var(--color-info)"

export function AgendaView({
  days,
  today,
  itemsByDay,
  onSelectItem,
}: {
  days: Date[]
  today: Date
  itemsByDay: Record<string, CalendarItem[]>
  onSelectItem: (item: CalendarItem) => void
}) {
  const todayKey = dateKey(today)
  const activeDays = days.filter((d) => (itemsByDay[dateKey(d)]?.length ?? 0) > 0)

  if (activeDays.length === 0) {
    return <EmptyState message="رویدادی برای این بازه ثبت نشده است." />
  }

  return (
    <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 xl:grid-cols-3">
      {activeDays.map((day) => {
        const key = dateKey(day)
        const items = itemsByDay[key]
        const { jd } = toJalali(day)
        const weekdayLabel = JALALI_WEEKDAY_FULL_LABELS[(day.getUTCDay() + 1) % 7]
        const isToday = key === todayKey

        return (
          <div key={key} className="flex flex-col overflow-hidden rounded-xl border border-border">
            <div
              className="flex items-center gap-2 px-3 py-2"
              style={{ backgroundColor: `color-mix(in oklab, ${DAY_COLOR} ${isToday ? 22 : 10}%, transparent)` }}
            >
              <span
                className="flex size-8 shrink-0 items-center justify-center rounded-full text-sm font-bold text-white"
                style={{ backgroundColor: DAY_COLOR }}
              >
                {toPersianDigits(jd)}
              </span>
              <span className="text-sm font-semibold">{weekdayLabel}</span>
              {isToday && (
                <Badge variant="primary" className="ms-auto">
                  امروز
                </Badge>
              )}
            </div>
            <div className="flex flex-col gap-2 p-3">
              {items.map((item) => (
                <button
                  key={item.id}
                  type="button"
                  onClick={() => onSelectItem(item)}
                  className="flex items-center gap-2 rounded-lg border border-border bg-card p-2.5 text-start text-sm shadow-xs transition-colors hover:bg-muted/40"
                >
                  <span className="size-2 shrink-0 rounded-full" style={{ backgroundColor: ITEM_DOT_COLOR }} />
                  {item.time && (
                    <span className="shrink-0 text-xs tabular-nums text-muted-foreground">
                      {toPersianDigits(item.time)}
                    </span>
                  )}
                  <span className="truncate font-medium">{item.title}</span>
                </button>
              ))}
            </div>
          </div>
        )
      })}
    </div>
  )
}
