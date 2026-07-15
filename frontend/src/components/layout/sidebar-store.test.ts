import { beforeEach, describe, expect, it } from "vitest"
import { useSidebarStore } from "./sidebar-store"

describe("useSidebarStore", () => {
  beforeEach(() => {
    useSidebarStore.setState({ collapsed: false })
  })

  it("starts expanded", () => {
    expect(useSidebarStore.getState().collapsed).toBe(false)
  })

  it("toggle flips the collapsed flag", () => {
    useSidebarStore.getState().toggle()
    expect(useSidebarStore.getState().collapsed).toBe(true)
    useSidebarStore.getState().toggle()
    expect(useSidebarStore.getState().collapsed).toBe(false)
  })
})
