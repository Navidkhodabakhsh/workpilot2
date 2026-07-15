import { describe, expect, it } from "vitest"
import { computeDateRange } from "./date-presets"

// Wednesday, July 15, 2026.
const NOW = new Date(2026, 6, 15)

describe("computeDateRange", () => {
  it("today", () => {
    expect(computeDateRange("today", NOW)).toEqual({ from: "2026-07-15", to: "2026-07-15" })
  })

  it("yesterday", () => {
    expect(computeDateRange("yesterday", NOW)).toEqual({ from: "2026-07-14", to: "2026-07-14" })
  })

  it("this_week starts on Saturday", () => {
    const range = computeDateRange("this_week", NOW)
    expect(range).toEqual({ from: "2026-07-11", to: "2026-07-17" })
    expect(new Date(range.from).getDay()).toBe(6) // Saturday
  })

  it("last_week is the seven days before this_week", () => {
    expect(computeDateRange("last_week", NOW)).toEqual({ from: "2026-07-04", to: "2026-07-10" })
  })

  it("this_month", () => {
    expect(computeDateRange("this_month", NOW)).toEqual({ from: "2026-07-01", to: "2026-07-31" })
  })

  it("last_month", () => {
    expect(computeDateRange("last_month", NOW)).toEqual({ from: "2026-06-01", to: "2026-06-30" })
  })

  it("last_month rolls back across a year boundary", () => {
    expect(computeDateRange("last_month", new Date(2026, 0, 15))).toEqual({ from: "2025-12-01", to: "2025-12-31" })
  })

  it("this_quarter", () => {
    expect(computeDateRange("this_quarter", NOW)).toEqual({ from: "2026-07-01", to: "2026-09-30" })
  })

  it("this_year", () => {
    expect(computeDateRange("this_year", NOW)).toEqual({ from: "2026-01-01", to: "2026-12-31" })
  })
})
