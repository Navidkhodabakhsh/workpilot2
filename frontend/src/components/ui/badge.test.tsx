import { describe, expect, it } from "vitest"
import { render, screen } from "@testing-library/react"
import { Badge } from "./badge"

describe("Badge", () => {
  it("renders its children as text", () => {
    render(<Badge>فعال</Badge>)
    expect(screen.getByText("فعال")).toBeInTheDocument()
  })

  it("applies the default variant class when no variant is given", () => {
    render(<Badge>پیش‌فرض</Badge>)
    expect(screen.getByText("پیش‌فرض").className).toContain("bg-muted")
  })

  it("applies a semantic variant class", () => {
    render(<Badge variant="success">تکمیل‌شده</Badge>)
    expect(screen.getByText("تکمیل‌شده").className).toContain("text-success")
  })
})
