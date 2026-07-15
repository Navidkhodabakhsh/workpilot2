import { cn } from "@/lib/utils"

/** Tadvin Hesab brand mark -- a rounded checkmark, per the company logo. */
export function LogoMark({ className, notchColor = "#fff" }: { className?: string; notchColor?: string }) {
  return (
    <svg viewBox="0 0 100 100" className={cn("size-5", className)} aria-hidden="true">
      <path
        d="M 20 52 L 42 74 L 82 26"
        fill="none"
        stroke="currentColor"
        strokeWidth="16"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
      <circle cx="30" cy="63" r="4.2" fill={notchColor} />
    </svg>
  )
}
