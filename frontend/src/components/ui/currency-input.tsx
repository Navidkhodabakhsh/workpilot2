import * as React from "react"

import { Input } from "@/components/ui/input"

const PERSIAN_DIGITS = "۰۱۲۳۴۵۶۷۸۹"

function toAsciiDigits(value: string) {
  return value.replace(/[۰-۹]/g, (digit) => String(PERSIAN_DIGITS.indexOf(digit)))
}

function onlyDigits(value: string) {
  return toAsciiDigits(value).replace(/[^\d]/g, "")
}

function normalizeDigits(rawDigits: string) {
  if (!rawDigits) return ""
  const value = Number(rawDigits)
  return Number.isFinite(value) ? String(value) : ""
}

function formatGrouped(rawDigits: string) {
  return rawDigits ? Number(rawDigits).toLocaleString("fa-IR") : ""
}

type CurrencyInputProps = {
  id?: string
  value: string
  onChange: (rawDigits: string) => void
  placeholder?: string
  className?: string
  disabled?: boolean
}

export const CurrencyInput = React.forwardRef<HTMLInputElement, CurrencyInputProps>(
  ({ id, value, onChange, placeholder, className, disabled }, forwardedRef) => {
    const innerRef = React.useRef<HTMLInputElement>(null)
    const pendingCaret = React.useRef<number | null>(null)
    const formatted = formatGrouped(value)

    React.useImperativeHandle(forwardedRef, () => innerRef.current as HTMLInputElement)

    React.useLayoutEffect(() => {
      if (pendingCaret.current !== null && innerRef.current) {
        innerRef.current.setSelectionRange(pendingCaret.current, pendingCaret.current)
        pendingCaret.current = null
      }
    }, [formatted])

    function handleChange(event: React.ChangeEvent<HTMLInputElement>) {
      const caretBefore = event.target.selectionStart ?? event.target.value.length
      const digitsBeforeCaret = onlyDigits(event.target.value.slice(0, caretBefore)).length

      const rawDigits = normalizeDigits(onlyDigits(event.target.value))
      onChange(rawDigits)

      const nextFormatted = formatGrouped(rawDigits)
      let seen = 0
      let caretAfter = nextFormatted.length
      for (let i = 0; i < nextFormatted.length; i++) {
        if (/\d/.test(toAsciiDigits(nextFormatted[i]))) {
          seen++
          if (seen === digitsBeforeCaret) {
            caretAfter = i + 1
            break
          }
        }
      }
      if (digitsBeforeCaret === 0) caretAfter = 0
      pendingCaret.current = caretAfter
    }

    return (
      <Input
        id={id}
        ref={innerRef}
        type="text"
        inputMode="numeric"
        dir="ltr"
        placeholder={placeholder}
        className={className}
        disabled={disabled}
        value={formatted}
        onChange={handleChange}
      />
    )
  }
)
CurrencyInput.displayName = "CurrencyInput"
