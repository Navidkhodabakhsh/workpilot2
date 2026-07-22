import { StrictMode } from "react"
import { createRoot } from "react-dom/client"
import { QueryClient, QueryClientProvider } from "@tanstack/react-query"
import { RouterProvider } from "react-router-dom"
import * as Sentry from "@sentry/react"

import { router } from "@/app/router"
import { AuthBootstrap } from "@/app/auth-bootstrap"
import { TooltipProvider } from "@/components/ui/tooltip"
import "@/index.css"

// Opt-in: only reports errors if VITE_SENTRY_DSN is set at build time; the
// app behaves identically without it.
if (import.meta.env.VITE_SENTRY_DSN) {
  Sentry.init({ dsn: import.meta.env.VITE_SENTRY_DSN, sendDefaultPii: false })
}

const queryClient = new QueryClient()

createRoot(document.getElementById("root")!).render(
  <StrictMode>
    <QueryClientProvider client={queryClient}>
      <TooltipProvider delayDuration={300}>
        <AuthBootstrap>
          <RouterProvider router={router} />
        </AuthBootstrap>
      </TooltipProvider>
    </QueryClientProvider>
  </StrictMode>
)
