// Plain HTML/CSS ranked bar list -- no axis, no gridlines: the row label
// and the value beside each bar already say everything an axis would, and
// for a "top N" ranking the exact scale markings aren't the point, the
// relative order and magnitude are. Bar length is % of the largest value
// in the set; each row's own color comes from CATEGORICAL_COLORS (fixed
// order, cycled), reusing the app's existing semantic tokens rather than
// introducing a separate chart-only palette. Validated with the dataviz
// skill's CVD checker; the worst adjacent pair lands just under the
// normal-vision floor, which is why every row also gets a direct label
// (name + value) -- identity never depends on color alone here.
const CATEGORICAL_COLORS = [
  "var(--color-primary)",
  "var(--color-success)",
  "var(--color-leave)",
  "var(--color-warning)",
  "var(--color-danger)",
]

export function HorizontalBarList({
  items,
}: {
  items: { id: string; label: string; value: number; displayValue: string }[]
}) {
  const max = Math.max(...items.map((i) => i.value), 1)

  return (
    <div className="flex flex-col gap-3">
      {items.map((item, index) => (
        <div key={item.id} className="flex items-center gap-3">
          <p className="w-24 shrink-0 truncate text-sm text-muted-foreground sm:w-28" title={item.label}>
            {item.label}
          </p>
          <div className="h-2.5 min-w-0 flex-1 overflow-hidden rounded-full bg-muted">
            <div
              className="h-full rounded-full transition-[width] duration-700 ease-out"
              style={{
                width: `${Math.max((item.value / max) * 100, 3)}%`,
                backgroundColor: CATEGORICAL_COLORS[index % CATEGORICAL_COLORS.length],
              }}
            />
          </div>
          <span className="w-14 shrink-0 text-end text-sm font-medium tabular-nums">{item.displayValue}</span>
        </div>
      ))}
    </div>
  )
}
