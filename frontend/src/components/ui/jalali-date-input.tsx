import { useEffect, useRef, useState } from "react"
import { CalendarDays, ChevronLeft, ChevronRight } from "lucide-react"

import { cn } from "@/lib/utils"
import {
  JALALI_MONTH_NAMES,
  JALALI_WEEKDAY_LABELS,
  formatJalaliDisplay,
  getJalaliMonthGrid,
  parseIsoDate,
  toIsoDateString,
  toJalali,
  toPersianDigits,
} from "@/lib/jalali"

/** A text-like date field that displays and lets the user pick dates in the
 * Jalali (Persian) calendar, while still producing/accepting plain
 * "YYYY-MM-DD" Gregorian ISO strings -- the same shape every existing
 * `<input type="date">` in this app already reads and writes, so it's a
 * drop-in replacement with no backend/schema changes required. */
export function JalaliDateInput({
  id,
  value,
  onChange,
  placeholder = "انتخاب تاریخ",
  className,
  disabled = false,
}: {
  id?: string
  value: string
  onChange: (iso: string) => void
  placeholder?: string
  className?: string
  disabled?: boolean
}) {
  const [open, setOpen] = useState(false)
  const [view, setView] = useState<"days" | "months" | "years">("days")
  const [yearRangeStart, setYearRangeStart] = useState(0)
  const containerRef = useRef<HTMLDivElement>(null)
  const today = new Date()
  const selected = value ? parseIsoDate(value) : null
  const [viewJalali, setViewJalali] = useState(() => toJalali(selected ?? today))

  useEffect(() => {
    if (!open) return
    function handleClickOutside(e: MouseEvent) {
      if (containerRef.current && !containerRef.current.contains(e.target as Node)) {
        setOpen(false)
      }
    }
    function handleEscape(e: KeyboardEvent) {
      if (e.key === "Escape") setOpen(false)
    }
    document.addEventListener("mousedown", handleClickOutside)
    document.addEventListener("keydown", handleEscape)
    return () => {
      document.removeEventListener("mousedown", handleClickOutside)
      document.removeEventListener("keydown", handleEscape)
    }
  }, [open])

  function openPicker() {
    setViewJalali(toJalali(selected ?? today))
    setView("days")
    setOpen(true)
  }

  function changeMonth(delta: number) {
    let { jy, jm } = viewJalali
    jm += delta
    if (jm > 12) {
      jm = 1
      jy += 1
    } else if (jm < 1) {
      jm = 12
      jy -= 1
    }
    setViewJalali({ jy, jm, jd: 1 })
  }

  function openYearGrid() {
    setYearRangeStart(viewJalali.jy - 5)
    setView("years")
  }

  const grid = getJalaliMonthGrid(viewJalali.jy, viewJalali.jm)
  const selectedIso = value
  const YEARS_PER_PAGE = 12

  return (
    <div className={cn("relative", className)} ref={containerRef}>
      <button
        type="button"
        id={id}
        disabled={disabled}
        onClick={() => (open ? setOpen(false) : openPicker())}
        className={cn(
          "border-input bg-background flex h-11 sm:h-9 w-full items-center justify-between gap-2 rounded-md border px-3 py-1 text-sm shadow-xs transition-colors outline-none",
          "focus-visible:border-ring focus-visible:ring-ring/50 focus-visible:ring-2",
          "disabled:pointer-events-none disabled:cursor-not-allowed disabled:opacity-50"
        )}
      >
        <span className={value ? "" : "text-muted-foreground"}>
          {value ? formatJalaliDisplay(value) : placeholder}
        </span>
        <CalendarDays className="size-4 shrink-0 text-muted-foreground" aria-hidden="true" />
      </button>

      {open && (
        <div className="absolute top-full z-[60] mt-1 w-72 rounded-lg border border-border bg-card p-3 shadow-lg">
          {view === "days" && (
            <>
              <div className="mb-2 flex items-center justify-between">
                <button
                  type="button"
                  onClick={() => changeMonth(-1)}
                  className="rounded-md p-1 text-muted-foreground hover:bg-muted"
                  aria-label="ماه قبل"
                >
                  <ChevronRight className="size-4" />
                </button>
                <div className="flex items-center gap-1 text-sm font-medium">
                  <button
                    type="button"
                    onClick={() => setView("months")}
                    className="rounded-md px-1.5 py-0.5 hover:bg-muted"
                  >
                    {JALALI_MONTH_NAMES[viewJalali.jm - 1]}
                  </button>
                  <button type="button" onClick={openYearGrid} className="rounded-md px-1.5 py-0.5 hover:bg-muted">
                    {toPersianDigits(viewJalali.jy)}
                  </button>
                </div>
                <button
                  type="button"
                  onClick={() => changeMonth(1)}
                  className="rounded-md p-1 text-muted-foreground hover:bg-muted"
                  aria-label="ماه بعد"
                >
                  <ChevronLeft className="size-4" />
                </button>
              </div>

              <div className="grid grid-cols-7 gap-1 text-center text-xs text-muted-foreground">
                {JALALI_WEEKDAY_LABELS.map((w) => (
                  <span key={w} className="py-1">
                    {w}
                  </span>
                ))}
              </div>
              <div className="grid grid-cols-7 gap-1">
                {grid.map((date) => {
                  const iso = toIsoDateString(date)
                  const cellJalali = toJalali(date)
                  const inCurrentMonth = cellJalali.jm === viewJalali.jm
                  const isSelected = iso === selectedIso
                  const isToday = iso === toIsoDateString(today)
                  return (
                    <button
                      key={iso}
                      type="button"
                      onClick={() => {
                        onChange(iso)
                        setOpen(false)
                      }}
                      className={cn(
                        "flex size-8 items-center justify-center rounded-md text-xs transition-colors",
                        inCurrentMonth ? "text-foreground" : "text-muted-foreground/40",
                        isSelected ? "bg-primary text-primary-foreground" : "hover:bg-muted",
                        isToday && !isSelected && "border border-primary/50"
                      )}
                    >
                      {toPersianDigits(cellJalali.jd)}
                    </button>
                  )
                })}
              </div>

              <div className="mt-2 flex items-center justify-between border-t border-border pt-2">
                <button
                  type="button"
                  className="text-xs font-medium text-primary hover:underline"
                  onClick={() => {
                    onChange(toIsoDateString(today))
                    setOpen(false)
                  }}
                >
                  امروز
                </button>
                {value && (
                  <button
                    type="button"
                    className="text-xs text-muted-foreground hover:underline"
                    onClick={() => {
                      onChange("")
                      setOpen(false)
                    }}
                  >
                    پاک کردن
                  </button>
                )}
              </div>
            </>
          )}

          {view === "months" && (
            <>
              <div className="mb-2 flex items-center justify-between">
                <button
                  type="button"
                  onClick={() => setViewJalali((v) => ({ ...v, jy: v.jy - 1 }))}
                  className="rounded-md p-1 text-muted-foreground hover:bg-muted"
                  aria-label="سال قبل"
                >
                  <ChevronRight className="size-4" />
                </button>
                <button
                  type="button"
                  onClick={openYearGrid}
                  className="rounded-md px-1.5 py-0.5 text-sm font-medium hover:bg-muted"
                >
                  {toPersianDigits(viewJalali.jy)}
                </button>
                <button
                  type="button"
                  onClick={() => setViewJalali((v) => ({ ...v, jy: v.jy + 1 }))}
                  className="rounded-md p-1 text-muted-foreground hover:bg-muted"
                  aria-label="سال بعد"
                >
                  <ChevronLeft className="size-4" />
                </button>
              </div>
              <div className="grid grid-cols-3 gap-1.5">
                {JALALI_MONTH_NAMES.map((name, idx) => (
                  <button
                    key={name}
                    type="button"
                    onClick={() => {
                      setViewJalali((v) => ({ ...v, jm: idx + 1 }))
                      setView("days")
                    }}
                    className={cn(
                      "rounded-md py-2 text-xs transition-colors",
                      idx + 1 === viewJalali.jm ? "bg-primary text-primary-foreground" : "hover:bg-muted"
                    )}
                  >
                    {name}
                  </button>
                ))}
              </div>
            </>
          )}

          {view === "years" && (
            <>
              <div className="mb-2 flex items-center justify-between">
                <button
                  type="button"
                  onClick={() => setYearRangeStart((y) => y - YEARS_PER_PAGE)}
                  className="rounded-md p-1 text-muted-foreground hover:bg-muted"
                  aria-label="بازه قبل"
                >
                  <ChevronRight className="size-4" />
                </button>
                <span className="text-sm font-medium">
                  {toPersianDigits(yearRangeStart)} - {toPersianDigits(yearRangeStart + YEARS_PER_PAGE - 1)}
                </span>
                <button
                  type="button"
                  onClick={() => setYearRangeStart((y) => y + YEARS_PER_PAGE)}
                  className="rounded-md p-1 text-muted-foreground hover:bg-muted"
                  aria-label="بازه بعد"
                >
                  <ChevronLeft className="size-4" />
                </button>
              </div>
              <div className="grid grid-cols-3 gap-1.5">
                {Array.from({ length: YEARS_PER_PAGE }, (_, i) => yearRangeStart + i).map((y) => (
                  <button
                    key={y}
                    type="button"
                    onClick={() => {
                      setViewJalali((v) => ({ ...v, jy: y }))
                      setView("months")
                    }}
                    className={cn(
                      "rounded-md py-2 text-xs transition-colors",
                      y === viewJalali.jy ? "bg-primary text-primary-foreground" : "hover:bg-muted"
                    )}
                  >
                    {toPersianDigits(y)}
                  </button>
                ))}
              </div>
            </>
          )}
        </div>
      )}
    </div>
  )
}
