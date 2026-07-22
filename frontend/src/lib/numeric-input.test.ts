import { describe, expect, it } from "vitest"

import { normalizeNumericString, toAsciiDigits } from "@/lib/numeric-input"

describe("toAsciiDigits", () => {
  it("converts Persian digits to ASCII", () => {
    expect(toAsciiDigits("۰۱۲۳۴۵۶۷۸۹")).toBe("0123456789")
  })

  it("converts Arabic-Indic digits to ASCII", () => {
    expect(toAsciiDigits("٠١٢٣٤٥٦٧٨٩")).toBe("0123456789")
  })

  it("leaves ASCII digits and other characters untouched", () => {
    expect(toAsciiDigits("12.5 abc")).toBe("12.5 abc")
  })

  it("handles mixed Persian/ASCII input", () => {
    expect(toAsciiDigits("۱2۳")).toBe("123")
  })
})

describe("normalizeNumericString", () => {
  it("converts a Persian decimal (٫) to a plain dot", () => {
    expect(normalizeNumericString("۲٫۵")).toBe("2.5")
  })

  it("converts a plain comma to a dot", () => {
    expect(normalizeNumericString("2,5")).toBe("2.5")
  })

  it("converts an Arabic comma (،) to a dot", () => {
    expect(normalizeNumericString("2،5")).toBe("2.5")
  })

  it("trims surrounding whitespace", () => {
    expect(normalizeNumericString("  ۴۵  ")).toBe("45")
  })

  it("passes an already-normalized value through unchanged", () => {
    expect(normalizeNumericString("12.5")).toBe("12.5")
  })
})
