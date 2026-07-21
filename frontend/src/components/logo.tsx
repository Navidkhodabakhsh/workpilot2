import { cn } from "@/lib/utils"

/** Tadvin Hesab brand mark -- a checkmark built from two linked diamond
 * facets (the short arm) and a long diagonal stroke (the long arm), with a
 * white notch at the fold. Fixed brand blue, not `currentColor`: this is a
 * literal logo, not a themeable icon, so callers place it on a light/white
 * badge for contrast rather than recoloring it. */
export function LogoMark({ className }: { className?: string }) {
  return (
    <svg viewBox="2 -14 100 100" className={cn("size-5", className)} aria-hidden="true">
      <rect x="0" y="0" width="27" height="27" rx="4.5" fill="#1D4FD7" transform="translate(14.5,10.5) rotate(45 13.5 13.5)" />
      <rect x="0" y="0" width="27" height="27" rx="4.5" fill="#1D4FD7" transform="translate(22.5,32.5) rotate(45 13.5 13.5)" />
      <rect x="0" y="-9" width="68" height="18" rx="8.5" fill="#1D4FD7" transform="translate(38,60) rotate(-40)" />
      <circle cx="40" cy="54" r="4.4" fill="#ffffff" />
    </svg>
  )
}
