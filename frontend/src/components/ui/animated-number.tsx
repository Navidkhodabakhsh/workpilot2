import { useEffect, useRef, useState } from "react"

/** Counts up from the previous value to the new one over ~600ms whenever
 * `value` changes, instead of the number just snapping in place. Keeps
 * `value`'s own decimal precision throughout (including the final frame),
 * and formats with Persian digits to match the rest of the app. */
export function AnimatedNumber({ value, duration = 600 }: { value: number; duration?: number }) {
  const [display, setDisplay] = useState(value)
  const fromRef = useRef(value)
  const frameRef = useRef<number | null>(null)

  useEffect(() => {
    if (!Number.isFinite(value)) {
      setDisplay(value)
      return
    }
    const from = fromRef.current
    const to = value
    if (from === to) return

    const decimals = (String(to).split(".")[1] ?? "").length
    const factor = 10 ** decimals
    const start = performance.now()

    function tick(now: number) {
      const progress = Math.min((now - start) / duration, 1)
      const eased = 1 - (1 - progress) * (1 - progress)
      const current = from + (to - from) * eased
      setDisplay(Math.round(current * factor) / factor)
      if (progress < 1) {
        frameRef.current = requestAnimationFrame(tick)
      } else {
        fromRef.current = to
      }
    }
    frameRef.current = requestAnimationFrame(tick)
    return () => {
      if (frameRef.current !== null) cancelAnimationFrame(frameRef.current)
    }
  }, [value, duration])

  return <>{display.toLocaleString("fa-IR")}</>
}
