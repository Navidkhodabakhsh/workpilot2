import type { ReactNode } from "react"
import { CheckCircle2, ShieldCheck, Sparkles } from "lucide-react"

import { LogoMark } from "@/components/logo"

const HIGHLIGHTS = [
  { icon: Sparkles, label: "مدیریت پروژه و وظایف در یک‌جا" },
  { icon: ShieldCheck, label: "دسترسی مبتنی بر نقش و امنیت سطح‌بالا" },
  { icon: CheckCircle2, label: "گزارش‌گیری و تأیید ساعات کاری تیم" },
]

/**
 * Split-screen layout: form panel sits on the RTL-start (visual right) edge
 * to match every other "start"-anchored surface in the app (sidebar, drawer);
 * the brand panel occupies the visual left and is hidden below `lg:` so the
 * mobile experience is just the form, full-bleed -- with a compact logo of
 * its own above the card so mobile isn't left with zero brand presence.
 */
export function AuthLayout({ children }: { children: ReactNode }) {
  return (
    <div className="flex min-h-svh flex-col lg:flex-row">
      <div className="flex flex-1 items-center justify-center bg-background p-6 sm:p-10">
        <div className="flex w-full max-w-sm flex-col gap-6">
          <div className="flex items-center justify-center gap-2 lg:hidden">
            <div className="flex size-10 shrink-0 items-center justify-center rounded-xl bg-white shadow-md ring-1 ring-border">
              <LogoMark className="size-6" />
            </div>
            <span className="text-lg font-bold">Tadvin Hesab</span>
          </div>
          <div className="animate-in fade-in-0 slide-in-from-bottom-2 duration-500">{children}</div>
        </div>
      </div>

      <div className="relative hidden overflow-hidden bg-gradient-to-br from-primary via-primary to-secondary lg:flex lg:w-[42%] lg:shrink-0 lg:flex-col lg:items-center lg:justify-center">
        <div
          className="pointer-events-none absolute inset-0 bg-[radial-gradient(circle_at_top,_hsl(0_0%_100%/0.18),_transparent_55%)]"
          aria-hidden="true"
        />
        <div
          className="animate-auth-float-a pointer-events-none absolute -top-16 start-1/4 size-72 rounded-full bg-white/10 blur-3xl"
          aria-hidden="true"
        />
        <div
          className="animate-auth-float-b pointer-events-none absolute -bottom-24 end-0 size-96 rounded-full bg-white/10 blur-3xl"
          aria-hidden="true"
        />
        <div
          className="pointer-events-none absolute inset-0 opacity-[0.07]"
          aria-hidden="true"
          style={{
            backgroundImage:
              "linear-gradient(hsl(0 0% 100%) 1px, transparent 1px), linear-gradient(90deg, hsl(0 0% 100%) 1px, transparent 1px)",
            backgroundSize: "40px 40px",
          }}
        />

        <div className="relative z-10 flex flex-col items-center gap-5 px-10 text-center">
          <div className="flex size-16 items-center justify-center rounded-2xl bg-white shadow-lg">
            <LogoMark className="size-9" />
          </div>
          <h1 className="text-3xl font-bold tracking-tight text-primary-foreground">Tadvin Hesab</h1>
          <p className="max-w-xs text-primary-foreground/80">
            پلتفرم یکپارچهٔ مدیریت پروژه، وظایف و عملکرد تیم — ساخته‌شده برای سازمان‌های حرفه‌ای
          </p>
          <ul className="mt-2 flex w-full max-w-xs flex-col gap-3">
            {HIGHLIGHTS.map(({ icon: Icon, label }) => (
              <li
                key={label}
                className="flex items-center gap-3 rounded-xl bg-white/10 px-4 py-2.5 text-start text-sm text-primary-foreground/90 backdrop-blur-sm"
              >
                <Icon className="size-4 shrink-0" aria-hidden="true" />
                {label}
              </li>
            ))}
          </ul>
        </div>
      </div>
    </div>
  )
}
