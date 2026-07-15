import type { LucideIcon } from "lucide-react"
import { Inbox } from "lucide-react"

import { cn } from "@/lib/utils"

function EmptyState({
  icon: Icon = Inbox,
  message,
  className,
}: {
  icon?: LucideIcon
  message: string
  className?: string
}) {
  return (
    <div className={cn("flex flex-col items-center justify-center gap-2 py-10 text-muted-foreground", className)}>
      <Icon className="size-8" />
      <p className="text-sm">{message}</p>
    </div>
  )
}

export { EmptyState }
