// Jalali (Persian) calendar helpers built entirely on Intl.DateTimeFormat --
// no date-math dependency, matching the approach already used in
// features/calendar/calendar-utils.ts. Intl only converts Gregorian->Jalali
// for display, so fromJalali() below does a small local search to invert it.

const PART_FORMATTER = new Intl.DateTimeFormat("en-US-u-ca-persian-nu-latn", {
  year: "numeric",
  month: "numeric",
  day: "numeric",
})

export type JalaliDate = { jy: number; jm: number; jd: number }

export function toJalali(date: Date): JalaliDate {
  const parts = PART_FORMATTER.formatToParts(date)
  const get = (type: string) => Number(parts.find((p) => p.type === type)?.value)
  return { jy: get("year"), jm: get("month"), jd: get("day") }
}

// Cumulative day count at the start of each Jalali month in a non-leap year
// (months 1-6 have 31 days, 7-11 have 30, 12 has 29 or 30) -- used only to
// build a close estimate before the exact search below corrects it.
const JALALI_MONTH_START_OFFSET = [0, 31, 62, 93, 124, 155, 186, 216, 246, 276, 306, 336]

/** Finds the Gregorian date matching a given Jalali calendar date. Starts
 * from an estimate anchored on Nowruz (~March 21) of the corresponding
 * Gregorian year, then searches outward day by day since Jalali and
 * Gregorian days are in 1:1 correspondence and always converge nearby. */
export function fromJalali(jy: number, jm: number, jd: number): Date {
  const nowruzEstimate = Date.UTC(jy + 621, 2, 21)
  const estimate = new Date(nowruzEstimate + (JALALI_MONTH_START_OFFSET[jm - 1] + jd - 1) * 86400000)
  for (let offset = -10; offset <= 10; offset++) {
    const candidate = new Date(estimate)
    candidate.setUTCDate(candidate.getUTCDate() + offset)
    const got = toJalali(candidate)
    if (got.jy === jy && got.jm === jm && got.jd === jd) {
      return candidate
    }
  }
  throw new Error(`Could not resolve Jalali date ${jy}/${jm}/${jd}`)
}

export function jalaliMonthLength(jy: number, jm: number): number {
  const thisMonthStart = fromJalali(jy, jm, 1)
  const nextMonth = jm === 12 ? { jy: jy + 1, jm: 1 } : { jy, jm: jm + 1 }
  const nextMonthStart = fromJalali(nextMonth.jy, nextMonth.jm, 1)
  return Math.round((nextMonthStart.getTime() - thisMonthStart.getTime()) / 86400000)
}

export const JALALI_MONTH_NAMES = [
  "فروردین",
  "اردیبهشت",
  "خرداد",
  "تیر",
  "مرداد",
  "شهریور",
  "مهر",
  "آبان",
  "آذر",
  "دی",
  "بهمن",
  "اسفند",
]

export const JALALI_WEEKDAY_LABELS = ["ش", "ی", "د", "س", "چ", "پ", "ج"]

export const JALALI_WEEKDAY_FULL_LABELS = [
  "شنبه",
  "یکشنبه",
  "دوشنبه",
  "سه‌شنبه",
  "چهارشنبه",
  "پنجشنبه",
  "جمعه",
]

const PERSIAN_DIGITS = ["۰", "۱", "۲", "۳", "۴", "۵", "۶", "۷", "۸", "۹"]

export function toPersianDigits(value: string | number): string {
  return String(value).replace(/[0-9]/g, (d) => PERSIAN_DIGITS[Number(d)])
}

export function toIsoDateString(date: Date): string {
  const y = date.getUTCFullYear()
  const m = String(date.getUTCMonth() + 1).padStart(2, "0")
  const d = String(date.getUTCDate()).padStart(2, "0")
  return `${y}-${m}-${d}`
}

/** Parses a "YYYY-MM-DD" Gregorian date string as a UTC-midnight Date,
 * avoiding local-timezone off-by-one shifts. */
export function parseIsoDate(iso: string): Date {
  const [y, m, d] = iso.split("-").map(Number)
  return new Date(Date.UTC(y, m - 1, d))
}

export function formatJalaliDisplay(iso: string): string {
  if (!iso) return ""
  const { jy, jm, jd } = toJalali(parseIsoDate(iso))
  return toPersianDigits(`${jy}/${String(jm).padStart(2, "0")}/${String(jd).padStart(2, "0")}`)
}

/** 42-cell (6-week) grid covering the given Jalali month, starting on
 * Saturday, returned as Gregorian Dates (each cell's real calendar date). */
export function getJalaliMonthGrid(jy: number, jm: number): Date[] {
  const firstOfMonth = fromJalali(jy, jm, 1)
  const startOffset = (firstOfMonth.getUTCDay() + 1) % 7
  const gridStart = new Date(firstOfMonth)
  gridStart.setUTCDate(gridStart.getUTCDate() - startOffset)
  return Array.from({ length: 42 }, (_, i) => {
    const d = new Date(gridStart)
    d.setUTCDate(gridStart.getUTCDate() + i)
    return d
  })
}
