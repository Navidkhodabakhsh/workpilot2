import type { LucideIcon } from "lucide-react"

const TONE_CLASS = {
  primary: "bg-primary/10 text-primary",
  secondary: "bg-secondary/10 text-secondary",
  info: "bg-info/10 text-info",
  success: "bg-success/10 text-success",
  warning: "bg-warning/10 text-warning",
  danger: "bg-danger/10 text-danger",
  leave: "bg-leave/10 text-leave",
  accent: "bg-accent/10 text-accent",
} as const

/** The colored icon-badge + title pairing used on the dashboard's stat
 * cards, reused here as the standard page header across every module so
 * the same visual language carries through the whole app, not just the
 * dashboard. */
export function PageHeader({
  icon: Icon,
  tone,
  title,
  description,
}: {
  icon: LucideIcon
  tone: keyof typeof TONE_CLASS
  title: string
  description?: string
}) {
  return (
    <div className="flex items-center gap-3">
      <div className={`flex size-11 shrink-0 items-center justify-center rounded-full ${TONE_CLASS[tone]}`}>
        <Icon className="size-5" aria-hidden="true" />
      </div>
      <div>
        <h1 className="text-2xl font-bold">{title}</h1>
        {description && <p className="text-muted-foreground">{description}</p>}
      </div>
    </div>
  )
}
