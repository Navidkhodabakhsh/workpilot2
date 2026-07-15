import { describe, expect, it } from "vitest"
import { getMonthGridDates, groupTasksByDate, toDateKey } from "./calendar-utils"

describe("toDateKey", () => {
  it("formats a local date as YYYY-MM-DD without timezone drift", () => {
    expect(toDateKey(new Date(2026, 6, 5))).toBe("2026-07-05")
  })

  it("zero-pads single-digit months and days", () => {
    expect(toDateKey(new Date(2026, 0, 9))).toBe("2026-01-09")
  })
})

describe("groupTasksByDate", () => {
  it("groups tasks by their deadline", () => {
    const tasks = [
      { id: "1", deadline: "2026-07-20" },
      { id: "2", deadline: "2026-07-20" },
      { id: "3", deadline: "2026-07-21" },
    ]
    const grouped = groupTasksByDate(tasks)
    expect(grouped["2026-07-20"]).toHaveLength(2)
    expect(grouped["2026-07-21"]).toHaveLength(1)
  })

  it("skips tasks with no deadline", () => {
    const tasks = [{ id: "1", deadline: null }]
    expect(groupTasksByDate(tasks)).toEqual({})
  })
})

describe("getMonthGridDates", () => {
  it("returns a 42-cell grid", () => {
    expect(getMonthGridDates(2026, 6)).toHaveLength(42)
  })

  it("starts the grid on a Saturday", () => {
    const grid = getMonthGridDates(2026, 6)
    expect(grid[0].getDay()).toBe(6) // Saturday
  })

  it("includes every day of the target month", () => {
    const grid = getMonthGridDates(2026, 6) // July 2026 has 31 days
    const julyDates = grid.filter((d) => d.getMonth() === 6)
    expect(julyDates).toHaveLength(31)
  })
})
