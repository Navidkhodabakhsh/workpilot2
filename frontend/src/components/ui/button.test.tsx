import { describe, expect, it, vi } from "vitest"
import { render, screen } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { Button } from "./button"

describe("Button", () => {
  it("renders its children as button text", () => {
    render(<Button>ثبت گزارش</Button>)
    expect(screen.getByRole("button", { name: "ثبت گزارش" })).toBeInTheDocument()
  })

  it("calls onClick when clicked", async () => {
    const onClick = vi.fn()
    render(<Button onClick={onClick}>کلیک کنید</Button>)
    await userEvent.click(screen.getByRole("button", { name: "کلیک کنید" }))
    expect(onClick).toHaveBeenCalledTimes(1)
  })

  it("does not call onClick when disabled", async () => {
    const onClick = vi.fn()
    render(
      <Button onClick={onClick} disabled>
        غیرفعال
      </Button>,
    )
    await userEvent.click(screen.getByRole("button", { name: "غیرفعال" }))
    expect(onClick).not.toHaveBeenCalled()
  })

  it("applies the destructive variant class", () => {
    render(<Button variant="destructive">حذف</Button>)
    expect(screen.getByRole("button", { name: "حذف" }).className).toContain("bg-danger")
  })
})
