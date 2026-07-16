import { useQuery } from "@tanstack/react-query"
import { Building2 } from "lucide-react"

import { Select } from "@/components/ui/select"
import { listDepartments } from "@/features/departments/api"
import { useDepartmentStore } from "@/features/departments/department-store"

export function DepartmentSelector() {
  const { data: departments } = useQuery({ queryKey: ["departments"], queryFn: listDepartments })
  const selectedDepartmentId = useDepartmentStore((s) => s.selectedDepartmentId)
  const setSelectedDepartmentId = useDepartmentStore((s) => s.setSelectedDepartmentId)

  if (!departments || departments.length === 0) return null

  return (
    <div className="hidden items-center gap-1.5 sm:flex">
      <Building2 className="size-4 shrink-0 text-muted-foreground" aria-hidden="true" />
      <Select
        aria-label="دپارتمان"
        value={selectedDepartmentId ?? ""}
        onChange={(e) => setSelectedDepartmentId(e.target.value || null)}
        className="h-9 w-40"
      >
        <option value="">همهٔ دپارتمان‌ها</option>
        {departments.map((d) => (
          <option key={d.id} value={d.id}>
            {d.name}
          </option>
        ))}
      </Select>
    </div>
  )
}
