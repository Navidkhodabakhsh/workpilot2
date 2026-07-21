import * as React from "react"

import { cn } from "@/lib/utils"

function Label({
  className,
  required,
  children,
  ...props
}: React.ComponentProps<"label"> & { required?: boolean }) {
  return (
    <label
      data-slot="label"
      className={cn(
        "flex items-center gap-2 text-sm leading-none font-medium select-none",
        className
      )}
      {...props}
    >
      {children}
      {required && (
        <span className="text-danger" aria-hidden="true">
          *
        </span>
      )}
    </label>
  )
}

export { Label }
