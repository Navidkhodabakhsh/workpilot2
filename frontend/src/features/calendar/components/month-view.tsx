import { JALALI_WEEKDAY_LABELS, getJalaliMonthGrid, toJalali, toPersianDigits } from "@/lib/jalali"
import { dateKey } from "@/features/calendar/calendar-utils"
import type { CalendarItem } from "@/features/calendar/types"
import { cn } from "@/lib/utils"

const MAX_VISIBLE_PER_DAY = 3

export function MonthView({
  jy,
  jm,
  today,
  itemsByDay,
  onSelectDay,
}: {
  jy: number
  jm: number
  today: Date
  itemsByDay: Record<string, CalendarItem[]>
  onSelectDay: (key: string) => void
}) {
  const grid = getJalaliMonthGrid(jy, jm)
  const todayKey = dateKey(today)

  return (
    <div className="overflow-hidden rounded-xl border border-border">
      <div className="grid grid-cols-7 border-b border-border bg-muted/40">
        {JALALI_WEEKDAY_LABELS.map((w) => (
          <div key={w} className="py-2 text-center text-xs font-medium text-muted-foreground">
            {w}
          </div>
        ))}
      </div>
      <div className="grid grid-cols-7">
        {grid.map((date, i) => {
          const key = dateKey(date)
          const { jm: cellJm, jd: cellJd } = toJalali(date)
          const inMonth = cellJm === jm
          const isToday = key === todayKey
          const items = itemsByDay[key] ?? []
          const visible = items.slice(0, MAX_VISIBLE_PER_DAY)
          const overflow = items.length - visible.length

          return (
            <button
              type="button"
              key={key}
              onClick={() => onSelectDay(key)}
              className={cn(
                "flex min-h-24 flex-col items-stretch gap-1 border-b border-e border-border p-1.5 text-start transition-colors hover:bg-muted/40 sm:min-h-28",
                (i + 1) % 7 === 0 && "border-e-0",
                i >= 35 && "border-b-0",
                !inMonth && "bg-muted/10 text-muted-foreground/50"
              )}
            >
              <span
                className={cn(
                  "self-end text-xs font-medium",
                  isToday && "flex size-5 items-center justify-center rounded-full bg-primary text-primary-foreground"
                )}
              >
                {toPersianDigits(cellJd)}
              </span>
              <div className="flex flex-col gap-0.5">
                {visible.map((item) => (
                  <span
                    key={item.id}
                    className="truncate rounded px-1 py-0.5 text-start text-[10px] font-medium text-white"
                    style={{ backgroundColor: item.color }}
                  >
                    {item.title}
                  </span>
                ))}
                {overflow > 0 && (
                  <span className="px-1 text-[10px] text-muted-foreground">{toPersianDigits(overflow)}+ بیشتر</span>
                )}
              </div>
            </button>
          )
        })}
      </div>
    </div>
  )
}
