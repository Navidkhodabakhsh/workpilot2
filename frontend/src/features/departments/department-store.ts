import { create } from "zustand"
import { persist } from "zustand/middleware"

type DepartmentFilterState = {
  /** null means "all departments" (no filter). */
  selectedDepartmentId: string | null
  setSelectedDepartmentId: (id: string | null) => void
}

// Pure UI preference -- safe to persist so the choice survives a reload,
// same pattern as sidebar-store.ts.
export const useDepartmentStore = create<DepartmentFilterState>()(
  persist(
    (set) => ({
      selectedDepartmentId: null,
      setSelectedDepartmentId: (id) => set({ selectedDepartmentId: id }),
    }),
    { name: "workpilot-selected-department" }
  )
)
