// Same approach as features/calendar/calendar-utils.ts: date math stays on
// the Gregorian calendar (native Date), only labels are Persian, so no
// Jalali date-math dependency is needed.

export type DateRangePreset =
  | "today"
  | "yesterday"
  | "this_week"
  | "last_week"
  | "this_month"
  | "last_month"
  | "this_quarter"
  | "this_year"
  | "custom"

export const DATE_RANGE_PRESETS: DateRangePreset[] = [
  "today",
  "yesterday",
  "this_week",
  "last_week",
  "this_month",
  "last_month",
  "this_quarter",
  "this_year",
  "custom",
]

export const DATE_RANGE_PRESET_LABEL: Record<DateRangePreset, string> = {
  today: "امروز",
  yesterday: "دیروز",
  this_week: "این هفته",
  last_week: "هفتهٔ قبل",
  this_month: "این ماه",
  last_month: "ماه قبل",
  this_quarter: "این فصل",
  this_year: "سال جاری",
  custom: "بازهٔ دلخواه",
}

function toDateKey(date: Date): string {
  const y = date.getFullYear()
  const m = String(date.getMonth() + 1).padStart(2, "0")
  const d = String(date.getDate()).padStart(2, "0")
  return `${y}-${m}-${d}`
}

/** Saturday is the first day of the week in the Iranian calendar. */
function startOfWeek(date: Date): Date {
  const d = new Date(date)
  d.setDate(d.getDate() - ((d.getDay() + 1) % 7))
  return d
}

export type DateRange = { from: string; to: string }

export function computeDateRange(preset: Exclude<DateRangePreset, "custom">, now: Date = new Date()): DateRange {
  const today = new Date(now.getFullYear(), now.getMonth(), now.getDate())

  switch (preset) {
    case "today":
      return { from: toDateKey(today), to: toDateKey(today) }

    case "yesterday": {
      const d = new Date(today)
      d.setDate(d.getDate() - 1)
      return { from: toDateKey(d), to: toDateKey(d) }
    }

    case "this_week": {
      const start = startOfWeek(today)
      const end = new Date(start)
      end.setDate(start.getDate() + 6)
      return { from: toDateKey(start), to: toDateKey(end) }
    }

    case "last_week": {
      const start = startOfWeek(today)
      start.setDate(start.getDate() - 7)
      const end = new Date(start)
      end.setDate(start.getDate() + 6)
      return { from: toDateKey(start), to: toDateKey(end) }
    }

    case "this_month": {
      const start = new Date(today.getFullYear(), today.getMonth(), 1)
      const end = new Date(today.getFullYear(), today.getMonth() + 1, 0)
      return { from: toDateKey(start), to: toDateKey(end) }
    }

    case "last_month": {
      const start = new Date(today.getFullYear(), today.getMonth() - 1, 1)
      const end = new Date(today.getFullYear(), today.getMonth(), 0)
      return { from: toDateKey(start), to: toDateKey(end) }
    }

    case "this_quarter": {
      const quarter = Math.floor(today.getMonth() / 3)
      const start = new Date(today.getFullYear(), quarter * 3, 1)
      const end = new Date(today.getFullYear(), quarter * 3 + 3, 0)
      return { from: toDateKey(start), to: toDateKey(end) }
    }

    case "this_year": {
      const start = new Date(today.getFullYear(), 0, 1)
      const end = new Date(today.getFullYear(), 11, 31)
      return { from: toDateKey(start), to: toDateKey(end) }
    }
  }
}
