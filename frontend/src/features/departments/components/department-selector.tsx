import { useEffect } from "react"
import { useQuery } from "@tanstack/react-query"
import { Building2 } from "lucide-react"

import { Select } from "@/components/ui/select"
import { listDepartments } from "@/features/departments/api"
import { useDepartmentStore } from "@/features/departments/department-store"
import { useAuthStore } from "@/features/auth/auth-store"

export function DepartmentSelector() {
  const user = useAuthStore((s) => s.user)
  const selectedDepartmentId = useDepartmentStore((s) => s.selectedDepartmentId)
  const setSelectedDepartmentId = useDepartmentStore((s) => s.setSelectedDepartmentId)

  // org_admin oversees the whole organization, so they get a real "all
  // departments" filter across every department. Everyone else only ever
  // acts within the department(s) they're a member of, so this becomes a
  // switcher between just those -- not a view into departments they don't
  // belong to.
  const isOrgAdmin = user?.role === "org_admin"

  const { data: allDepartments } = useQuery({
    queryKey: ["departments"],
    queryFn: listDepartments,
    enabled: isOrgAdmin,
  })

  if (isOrgAdmin) {
    if (!allDepartments || allDepartments.length === 0) return null
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
          {allDepartments.map((d) => (
            <option key={d.id} value={d.id}>
              {d.name}
            </option>
          ))}
        </Select>
      </div>
    )
  }

  const myDepartments = user?.department_memberships ?? []

  // Default the actual filter to the first membership (not just the select's
  // displayed value) so a freshly-loaded dashboard is genuinely scoped to
  // one department from the start, not silently showing "all of them" while
  // the dropdown looks like a specific one is chosen.
  const isMineSelected = myDepartments.some((m) => m.department_id === selectedDepartmentId)
  useEffect(() => {
    if (myDepartments.length >= 2 && !isMineSelected) {
      setSelectedDepartmentId(myDepartments[0].department_id)
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [myDepartments.length, isMineSelected])

  if (myDepartments.length < 2) return null

  return (
    <div className="hidden items-center gap-1.5 sm:flex">
      <Building2 className="size-4 shrink-0 text-muted-foreground" aria-hidden="true" />
      <Select
        aria-label="دپارتمان"
        value={selectedDepartmentId ?? myDepartments[0].department_id}
        onChange={(e) => setSelectedDepartmentId(e.target.value || null)}
        className="h-9 w-40"
      >
        {myDepartments.map((m) => (
          <option key={m.department_id} value={m.department_id}>
            {m.department_name}
          </option>
        ))}
      </Select>
    </div>
  )
}
