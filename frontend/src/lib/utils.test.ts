import { describe, expect, it } from "vitest"
import { cn } from "./utils"

describe("cn", () => {
  it("joins simple class names", () => {
    expect(cn("a", "b")).toBe("a b")
  })

  it("drops falsy values", () => {
    expect(cn("a", false && "b", undefined, null, "c")).toBe("a c")
  })

  it("resolves conflicting tailwind utilities to the last one", () => {
    expect(cn("px-2", "px-4")).toBe("px-4")
  })

  it("merges conditional object syntax", () => {
    expect(cn("base", { active: true, hidden: false })).toBe("base active")
  })
})
