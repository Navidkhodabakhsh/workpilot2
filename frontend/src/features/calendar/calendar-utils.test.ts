import { describe, expect, it } from "vitest"
import { addDays, dateKey, daysInRange, groupByDateKey, jalaliMonthDays, startOfWeek } from "./calendar-utils"

describe("groupByDateKey", () => {
  it("groups items by the key function", () => {
    const items = [{ day: "2026-07-20", id: "1" }, { day: "2026-07-20", id: "2" }, { day: "2026-07-21", id: "3" }]
    const grouped = groupByDateKey(items, (i) => i.day)
    expect(grouped["2026-07-20"]).toHaveLength(2)
    expect(grouped["2026-07-21"]).toHaveLength(1)
  })

  it("returns an empty object for an empty list", () => {
    expect(groupByDateKey([], () => "x")).toEqual({})
  })
})

describe("startOfWeek", () => {
  it("returns the same day when already a Saturday", () => {
    // 2026-07-18 is a Saturday.
    const saturday = new Date(Date.UTC(2026, 6, 18))
    expect(dateKey(startOfWeek(saturday))).toBe("2026-07-18")
  })

  it("rewinds to the preceding Saturday", () => {
    // 2026-07-21 is a Tuesday.
    const tuesday = new Date(Date.UTC(2026, 6, 21))
    expect(dateKey(startOfWeek(tuesday))).toBe("2026-07-18")
  })
})

describe("addDays / daysInRange", () => {
  it("adds days across a month boundary", () => {
    const d = new Date(Date.UTC(2026, 6, 30))
    expect(dateKey(addDays(d, 3))).toBe("2026-08-02")
  })

  it("produces a contiguous run of the requested length", () => {
    const start = new Date(Date.UTC(2026, 6, 18))
    const days = daysInRange(start, 7)
    expect(days).toHaveLength(7)
    expect(dateKey(days[0])).toBe("2026-07-18")
    expect(dateKey(days[6])).toBe("2026-07-24")
  })
})

describe("jalaliMonthDays", () => {
  it("returns exactly the days in the given Jalali month, no padding", () => {
    // Farvardin (month 1) always has 31 days.
    const days = jalaliMonthDays(1404, 1)
    expect(days).toHaveLength(31)
  })
})
