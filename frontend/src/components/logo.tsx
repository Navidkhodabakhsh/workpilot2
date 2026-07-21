import { cn } from "@/lib/utils"

/** Tadvin Hesab brand mark -- a checkmark built from two linked diamond
 * facets (the short arm) and a long diagonal stroke (the long arm), with a
 * notch at the fold. Two color modes: the default brand-blue mark (for
 * placing on a light/white background) and `inverted` (white mark with a
 * blue notch) for sitting directly on a dark blue surface like the sidebar,
 * with no separate contrast badge underneath it. */
export function LogoMark({ className, inverted }: { className?: string; inverted?: boolean }) {
  const shapeColor = inverted ? "#ffffff" : "#1D4FD7"
  const notchColor = inverted ? "#1D4FD7" : "#ffffff"
  return (
    <svg viewBox="2 -14 100 100" className={cn("size-5", className)} aria-hidden="true">
      <rect x="0" y="0" width="27" height="27" rx="4.5" fill={shapeColor} transform="translate(14.5,10.5) rotate(45 13.5 13.5)" />
      <rect x="0" y="0" width="27" height="27" rx="4.5" fill={shapeColor} transform="translate(22.5,32.5) rotate(45 13.5 13.5)" />
      <rect x="0" y="-9" width="68" height="18" rx="8.5" fill={shapeColor} transform="translate(38,60) rotate(-40)" />
      <circle cx="40" cy="54" r="4.4" fill={notchColor} />
    </svg>
  )
}
