import { fromJalali, jalaliMonthLength, toIsoDateString } from "@/lib/jalali"

export function groupByDateKey<T>(items: T[], keyOf: (item: T) => string): Record<string, T[]> {
  const map: Record<string, T[]> = {}
  for (const item of items) {
    const key = keyOf(item)
    ;(map[key] ??= []).push(item)
  }
  return map
}

/** Saturday on/before the given date, at UTC midnight -- consistent with the
 * UTC-anchored Date objects the Jalali grid helpers hand back (see
 * `@/lib/jalali`), so day keys built from either source always line up. */
export function startOfWeek(date: Date): Date {
  const start = new Date(date)
  const offset = (start.getUTCDay() + 1) % 7
  start.setUTCDate(start.getUTCDate() - offset)
  start.setUTCHours(0, 0, 0, 0)
  return start
}

export function addDays(date: Date, amount: number): Date {
  const d = new Date(date)
  d.setUTCDate(d.getUTCDate() + amount)
  return d
}

export function daysInRange(start: Date, count: number): Date[] {
  return Array.from({ length: count }, (_, i) => addDays(start, i))
}

/** The real Jalali-calendar days of a given month (no leading/trailing
 * padding from adjacent months), as UTC-anchored Dates. */
export function jalaliMonthDays(jy: number, jm: number): Date[] {
  const start = fromJalali(jy, jm, 1)
  return daysInRange(start, jalaliMonthLength(jy, jm))
}

export function dateKey(date: Date): string {
  return toIsoDateString(date)
}
