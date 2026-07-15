import { create } from "zustand"
import { persist } from "zustand/middleware"

type SidebarState = {
  collapsed: boolean
  toggle: () => void
}

// Pure UI preference (unlike auth-store's deliberately in-memory-only
// access token) -- safe to persist so the choice survives a reload.
export const useSidebarStore = create<SidebarState>()(
  persist(
    (set) => ({
      collapsed: false,
      toggle: () => set((s) => ({ collapsed: !s.collapsed })),
    }),
    { name: "workpilot-sidebar-collapsed" }
  )
)
