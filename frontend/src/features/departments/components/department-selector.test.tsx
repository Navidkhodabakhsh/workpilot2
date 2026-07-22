import { QueryClient, QueryClientProvider } from "@tanstack/react-query"
import { render, screen, waitFor } from "@testing-library/react"
import { beforeEach, describe, expect, it, vi } from "vitest"

import { useAuthStore } from "@/features/auth/auth-store"
import { useDepartmentStore } from "@/features/departments/department-store"
import { DepartmentSelector } from "@/features/departments/components/department-selector"
import type { Department, OrgUser } from "@/lib/types"

vi.mock("@/features/departments/api", () => ({
  listDepartments: vi.fn(),
}))

const { listDepartments } = await import("@/features/departments/api")

const allDepartments: Department[] = [
  { id: "dept-1", organization_id: "org-1", name: "حسابداری و مالی", created_at: "2026-01-01T00:00:00Z" },
  { id: "dept-2", organization_id: "org-1", name: "منابع انسانی", created_at: "2026-01-01T00:00:00Z" },
]

const orgAdmin: OrgUser = {
  id: "admin-1",
  organization_id: "org-1",
  phone_number: "09100000001",
  full_name: "مدیر سازمان",
  role: "org_admin",
  is_active: true,
  has_password: true,
  department_id: null,
  department_memberships: [],
}

function renderSelector() {
  const queryClient = new QueryClient({ defaultOptions: { queries: { retry: false } } })
  return render(
    <QueryClientProvider client={queryClient}>
      <DepartmentSelector />
    </QueryClientProvider>,
  )
}

describe("DepartmentSelector (org_admin)", () => {
  beforeEach(() => {
    useDepartmentStore.setState({ selectedDepartmentId: null })
    useAuthStore.setState({ accessToken: "token", user: orgAdmin })
    vi.mocked(listDepartments).mockResolvedValue(allDepartments)
  })

  it("never offers an aggregate 'all departments' option", async () => {
    renderSelector()
    const select = await screen.findByRole("combobox", { name: "دپارتمان" })
    const optionLabels = Array.from(select.querySelectorAll("option")).map((o) => o.textContent)
    expect(optionLabels).toEqual(["حسابداری و مالی", "منابع انسانی"])
    expect(optionLabels).not.toContain("همهٔ دپارتمان‌ها")
  })

  it("auto-selects the first real department instead of defaulting to 'all'", async () => {
    renderSelector()
    await waitFor(() => {
      expect(useDepartmentStore.getState().selectedDepartmentId).toBe("dept-1")
    })
  })

  it("renders nothing when the organization has no departments yet", async () => {
    vi.mocked(listDepartments).mockResolvedValue([])
    renderSelector()
    await waitFor(() => expect(listDepartments).toHaveBeenCalled())
    expect(screen.queryByRole("combobox", { name: "دپارتمان" })).not.toBeInTheDocument()
  })
})
