import { toPersianDigits } from "@/lib/jalali"

const CATEGORICAL_COLORS = [
  "var(--color-primary)",
  "var(--color-success)",
  "var(--color-leave)",
  "var(--color-warning)",
  "var(--color-danger)",
]

export type RoadmapItem = {
  id: string
  name: string
  start: Date
  end: Date
  percent: number
}

/** A compact Gantt-style timeline: one row per project, a duration bar
 * positioned within the shared window of all projects shown, colored per
 * project, with the completion percent labeled directly on the row (never
 * color alone) so nothing here depends on reading bar position precisely. */
export function ProjectRoadmap({ items }: { items: RoadmapItem[] }) {
  const rangeStart = Math.min(...items.map((p) => p.start.getTime()))
  const rangeEnd = Math.max(...items.map((p) => p.end.getTime()))
  const span = Math.max(rangeEnd - rangeStart, 86400000)

  return (
    <div className="flex flex-col gap-3">
      {items.map((item, index) => {
        const leftPct = ((item.start.getTime() - rangeStart) / span) * 100
        const widthPct = Math.max(((item.end.getTime() - item.start.getTime()) / span) * 100, 3)
        const color = CATEGORICAL_COLORS[index % CATEGORICAL_COLORS.length]
        return (
          <div key={item.id} className="flex items-center gap-3">
            <p className="w-28 shrink-0 truncate text-sm text-muted-foreground sm:w-36" title={item.name}>
              {item.name}
            </p>
            <div className="relative h-6 min-w-0 flex-1 rounded-full bg-muted">
              <div
                className="absolute inset-y-0 flex items-center justify-end overflow-hidden rounded-full px-2 shadow-sm transition-[inset-inline-start,width] duration-700 ease-out"
                style={{
                  insetInlineStart: `${leftPct}%`,
                  width: `${widthPct}%`,
                  background: `linear-gradient(90deg, color-mix(in oklab, ${color} 70%, transparent), ${color})`,
                }}
              >
                {widthPct > 14 && (
                  <span className="truncate text-[10px] font-medium text-white">
                    {toPersianDigits(item.percent)}٪
                  </span>
                )}
              </div>
            </div>
            {widthPct <= 14 && (
              <span className="w-9 shrink-0 text-end text-xs font-medium tabular-nums">
                {toPersianDigits(item.percent)}٪
              </span>
            )}
          </div>
        )
      })}
    </div>
  )
}
