import type { ReactNode } from "react"

export function AuthLayout({ children }: { children: ReactNode }) {
  return (
    <div className="relative flex min-h-svh items-center justify-center overflow-hidden bg-gradient-to-br from-primary to-secondary p-4">
      <div
        className="pointer-events-none absolute inset-0 bg-[radial-gradient(circle_at_top,_hsl(0_0%_100%/0.18),_transparent_55%)]"
        aria-hidden="true"
      />
      <div className="relative z-10 flex w-full max-w-sm flex-col items-center gap-6">
        <span className="text-2xl font-bold tracking-tight text-white">WorkPilot</span>
        {children}
      </div>
    </div>
  )
}
