import { toPersianDigits } from "@/lib/jalali"

const CATEGORICAL_COLORS = [
  "var(--color-primary)",
  "var(--color-success)",
  "var(--color-leave)",
  "var(--color-warning)",
  "var(--color-danger)",
]

export type RoadmapItem = { id: string; name: string; percent: number }

/** One progress bar per project, every bar starting from the same edge and
 * filling by its own completion percent -- a shared-timeline Gantt (bars
 * offset by actual start/end dates) read as messy/inconsistent, so this
 * keeps the richer gradient styling but drops the date positioning. */
export function ProjectRoadmap({ items }: { items: RoadmapItem[] }) {
  return (
    <div className="flex flex-col gap-3">
      {items.map((item, index) => {
        const color = CATEGORICAL_COLORS[index % CATEGORICAL_COLORS.length]
        return (
          <div key={item.id} className="flex items-center gap-3">
            <p className="w-28 shrink-0 truncate text-sm text-muted-foreground sm:w-36" title={item.name}>
              {item.name}
            </p>
            <div className="h-3 min-w-0 flex-1 overflow-hidden rounded-full bg-muted">
              <div
                className="h-full rounded-full transition-[width] duration-700 ease-out"
                style={{
                  width: `${Math.max(item.percent, 3)}%`,
                  background: `linear-gradient(90deg, color-mix(in oklab, ${color} 65%, transparent), ${color})`,
                }}
              />
            </div>
            <span className="w-10 shrink-0 text-end text-xs font-medium tabular-nums">
              {toPersianDigits(item.percent)}٪
            </span>
          </div>
        )
      })}
    </div>
  )
}
