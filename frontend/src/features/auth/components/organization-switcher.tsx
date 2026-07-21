import { useState } from "react"
import { useQuery } from "@tanstack/react-query"
import { Building } from "lucide-react"

import { Select } from "@/components/ui/select"
import { listMyOrganizations, switchOrganization } from "@/features/auth/api"
import { useAuthStore } from "@/features/auth/auth-store"

/** Lets an account that belongs to more than one organization switch which
 * one it's currently acting in. Switching re-issues the session (new JWT +
 * refresh cookie scoped to that membership's role/org), so this does a full
 * page reload afterward rather than patching client state in place --
 * dozens of React Query caches across the app are scoped to "the current
 * org" and would otherwise keep showing the previous one's data. */
export function OrganizationSwitcher() {
  const user = useAuthStore((s) => s.user)
  const [switching, setSwitching] = useState(false)

  const { data: organizations } = useQuery({
    queryKey: ["my-organizations"],
    queryFn: listMyOrganizations,
  })

  if (!organizations || organizations.length < 2) return null

  async function handleChange(organizationId: string) {
    if (!organizationId || organizationId === user?.organization_id) return
    setSwitching(true)
    try {
      await switchOrganization(organizationId)
      window.location.assign("/")
    } catch {
      setSwitching(false)
    }
  }

  return (
    <div className="hidden items-center gap-1.5 sm:flex">
      <Building className="size-4 shrink-0 text-muted-foreground" aria-hidden="true" />
      <Select
        aria-label="سازمان"
        value={user?.organization_id ?? ""}
        disabled={switching}
        onChange={(e) => handleChange(e.target.value)}
        className="h-9 w-40"
      >
        {organizations.map((o) => (
          <option key={o.organization_id} value={o.organization_id}>
            {o.organization_name}
          </option>
        ))}
      </Select>
    </div>
  )
}
