import { useState } from "react"
import { describe, expect, it } from "vitest"
import { render, screen } from "@testing-library/react"
import userEvent from "@testing-library/user-event"

import { CurrencyInput } from "./currency-input"

function Harness({ initial = "" }: { initial?: string }) {
  const [value, setValue] = useState(initial)
  return <CurrencyInput value={value} onChange={setValue} />
}

describe("CurrencyInput", () => {
  it("displays the raw digits grouped with Persian thousand separators", () => {
    render(<Harness initial="1234000" />)
    expect(screen.getByRole("textbox")).toHaveValue("۱٬۲۳۴٬۰۰۰")
  })

  it("shows nothing for an empty value", () => {
    render(<Harness initial="" />)
    expect(screen.getByRole("textbox")).toHaveValue("")
  })

  it("reports raw ASCII digits to onChange when typed with a Latin keyboard", async () => {
    render(<Harness />)
    await userEvent.type(screen.getByRole("textbox"), "5000")
    expect(screen.getByRole("textbox")).toHaveValue("۵٬۰۰۰")
  })

  it("accepts Persian-digit keystrokes and normalizes them", async () => {
    render(<Harness />)
    await userEvent.type(screen.getByRole("textbox"), "۵۰۰۰")
    expect(screen.getByRole("textbox")).toHaveValue("۵٬۰۰۰")
  })

  it("strips non-digit characters as they're typed", async () => {
    render(<Harness />)
    await userEvent.type(screen.getByRole("textbox"), "12a3b")
    expect(screen.getByRole("textbox")).toHaveValue("۱۲۳")
  })
})
