import { Plus } from "lucide-react"

import { Button } from "@/components/ui/button"
import { Dialog, DialogContent, DialogHeader, DialogTitle } from "@/components/ui/dialog"
import { JALALI_MONTH_NAMES, parseIsoDate, toJalali, toPersianDigits } from "@/lib/jalali"
import type { CalendarItem } from "@/features/calendar/types"

export function DayEventsDialog({
  open,
  onOpenChange,
  dateKey,
  items,
  onSelectItem,
  onCreateEvent,
}: {
  open: boolean
  onOpenChange: (open: boolean) => void
  dateKey: string | null
  items: CalendarItem[]
  onSelectItem: (item: CalendarItem) => void
  onCreateEvent: () => void
}) {
  if (!dateKey) return null
  const { jy, jm, jd } = toJalali(parseIsoDate(dateKey))

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>
            {toPersianDigits(jd)} {JALALI_MONTH_NAMES[jm - 1]} {toPersianDigits(jy)}
          </DialogTitle>
        </DialogHeader>
        <div className="flex flex-col gap-2">
          {items.length === 0 && <p className="text-sm text-muted-foreground">رویدادی در این روز نیست.</p>}
          {items.map((item) => (
            <button
              key={item.id}
              type="button"
              onClick={() => onSelectItem(item)}
              className="flex items-center gap-2 rounded-lg border border-border p-2.5 text-start text-sm transition-colors hover:bg-muted/40"
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
        <Button type="button" variant="outline" onClick={onCreateEvent}>
          <Plus className="size-4" />
          افزودن رویداد
        </Button>
      </DialogContent>
    </Dialog>
  )
}
