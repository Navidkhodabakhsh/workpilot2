import { describe, expect, it } from "vitest"
import {
  formatJalaliDisplay,
  fromJalali,
  getJalaliMonthGrid,
  jalaliMonthLength,
  toIsoDateString,
  toJalali,
  toPersianDigits,
} from "./jalali"

describe("toJalali / fromJalali", () => {
  it("converts a known Nowruz date correctly", () => {
    expect(toJalali(new Date(Date.UTC(2025, 2, 21)))).toEqual({ jy: 1404, jm: 1, jd: 1 })
  })

  it("round-trips fromJalali(toJalali(d)) back to the same date", () => {
    const original = new Date(Date.UTC(2026, 6, 16))
    const { jy, jm, jd } = toJalali(original)
    expect(fromJalali(jy, jm, jd).getTime()).toBe(original.getTime())
  })

  it("round-trips toJalali(fromJalali(...)) back to the same Jalali date", () => {
    expect(toJalali(fromJalali(1405, 4, 25))).toEqual({ jy: 1405, jm: 4, jd: 25 })
  })
})

describe("jalaliMonthLength", () => {
  it("returns 31 for the first six Jalali months", () => {
    expect(jalaliMonthLength(1405, 1)).toBe(31)
  })

  it("returns 30 for months 7-11", () => {
    expect(jalaliMonthLength(1405, 7)).toBe(30)
  })
})

describe("toPersianDigits", () => {
  it("converts ASCII digits to Persian digits", () => {
    expect(toPersianDigits("1405/04/25")).toBe("۱۴۰۵/۰۴/۲۵")
  })
})

describe("formatJalaliDisplay", () => {
  it("formats an ISO Gregorian date string as Jalali with Persian digits", () => {
    expect(formatJalaliDisplay("2026-07-16")).toBe("۱۴۰۵/۰۴/۲۵")
  })

  it("returns an empty string for an empty input", () => {
    expect(formatJalaliDisplay("")).toBe("")
  })
})

describe("toIsoDateString", () => {
  it("formats a UTC date as YYYY-MM-DD", () => {
    expect(toIsoDateString(new Date(Date.UTC(2026, 6, 16)))).toBe("2026-07-16")
  })
})

describe("getJalaliMonthGrid", () => {
  it("returns a 42-cell grid starting on Saturday", () => {
    const grid = getJalaliMonthGrid(1405, 4)
    expect(grid).toHaveLength(42)
    expect(grid[0].getUTCDay()).toBe(6)
  })

  it("includes the 1st of the requested Jalali month somewhere in the grid", () => {
    const grid = getJalaliMonthGrid(1405, 4)
    const hasFirst = grid.some((d) => {
      const { jy, jm, jd } = toJalali(d)
      return jy === 1405 && jm === 4 && jd === 1
    })
    expect(hasFirst).toBe(true)
  })
})
