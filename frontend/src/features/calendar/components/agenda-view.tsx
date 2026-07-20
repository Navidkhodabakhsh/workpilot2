import { EmptyState } from "@/components/ui/empty-state"
import { JALALI_WEEKDAY_FULL_LABELS, toJalali, toPersianDigits } from "@/lib/jalali"
import { dateKey } from "@/features/calendar/calendar-utils"
import type { CalendarItem } from "@/features/calendar/types"

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
    <div className="flex flex-col gap-3">
      {activeDays.map((day) => {
        const key = dateKey(day)
        const items = itemsByDay[key]
        const { jd } = toJalali(day)
        const weekdayLabel = JALALI_WEEKDAY_FULL_LABELS[(day.getUTCDay() + 1) % 7]
        const isToday = key === todayKey

        return (
          <div key={key} className="flex gap-3">
            <div
              className={`flex w-14 shrink-0 flex-col items-center justify-center gap-0.5 rounded-lg py-2 ${
                isToday ? "bg-primary text-primary-foreground" : "bg-muted/50 text-foreground"
              }`}
            >
              <span className="text-lg font-bold leading-none">{toPersianDigits(jd)}</span>
              <span className="text-[10px] opacity-80">{weekdayLabel}</span>
            </div>
            <div className="flex flex-1 flex-col gap-2 border-s border-border ps-3">
              {items.map((item) => (
                <button
                  key={item.id}
                  type="button"
                  onClick={() => onSelectItem(item)}
                  className="flex items-center gap-2 rounded-lg border border-border bg-card p-2.5 text-start text-sm shadow-xs transition-colors hover:bg-muted/40"
                >
                  <span className="size-2 shrink-0 rounded-full" style={{ backgroundColor: item.color }} />
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
