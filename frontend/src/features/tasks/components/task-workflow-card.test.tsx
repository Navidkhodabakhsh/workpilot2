import { QueryClient, QueryClientProvider } from "@tanstack/react-query"
import { render, screen } from "@testing-library/react"
import { describe, expect, it } from "vitest"

import { useAuthStore } from "@/features/auth/auth-store"
import { TaskWorkflowCard } from "@/features/tasks/components/task-workflow-card"
import type { OrgUser, Task } from "@/lib/types"

const user: OrgUser = {
  id: "user-1",
  organization_id: "org-1",
  phone_number: "09120000002",
  full_name: "کاربر تست",
  role: "employee",
  is_active: true,
  has_password: true,
  department_id: null,
  department_memberships: [],
}

const task: Task = {
  id: "task-1",
  organization_id: "org-1",
  project_id: "project-1",
  parent_task_id: null,
  assignee_id: user.id,
  created_by_id: user.id,
  created_by_full_name: user.full_name,
  title: "تسک قابل ویرایش",
  description: null,
  priority: "medium",
  value: "high",
  status: "in_progress",
  approval_status: null,
  progress_percent: 20,
  estimated_hours: 4,
  actual_hours: 1,
  pending_hours: 0.5,
  total_logged_hours: 1.5,
  start_date: null,
  deadline: null,
  created_at: "2026-07-20T00:00:00Z",
}

const manager: OrgUser = {
  id: "user-2",
  organization_id: "org-1",
  phone_number: "09120000003",
  full_name: "مدیر پروژه",
  role: "project_manager",
  is_active: true,
  has_password: true,
  department_id: null,
  department_memberships: [],
}

const taskCreatedByManagerForSomeoneElse: Task = {
  ...task,
  id: "task-2",
  assignee_id: user.id,
  created_by_id: manager.id,
  created_by_full_name: manager.full_name,
}

describe("TaskWorkflowCard", () => {
  it("renders editing and time-logging controls for the assignee", () => {
    useAuthStore.setState({
      accessToken: "token",
      user: { ...user, department_memberships: [] },
    })
    const queryClient = new QueryClient({ defaultOptions: { queries: { retry: false } } })
    render(
      <QueryClientProvider client={queryClient}>
        <TaskWorkflowCard task={task} users={[user]} />
      </QueryClientProvider>,
    )

    expect(screen.getByText("زمان مصرف‌شده:")).toBeInTheDocument()
    expect(screen.getByRole("button", { name: /ویرایش تسک/ })).toBeEnabled()
    expect(screen.getByRole("button", { name: /ثبت و مشاهده ساعت/ })).toBeEnabled()
  })

  it("only offers read-only hour viewing to the task's creator when they aren't the assignee", () => {
    useAuthStore.setState({
      accessToken: "token",
      user: { ...manager, department_memberships: [] },
    })
    const queryClient = new QueryClient({ defaultOptions: { queries: { retry: false } } })
    render(
      <QueryClientProvider client={queryClient}>
        <TaskWorkflowCard task={taskCreatedByManagerForSomeoneElse} users={[user, manager]} />
      </QueryClientProvider>,
    )

    expect(screen.getByRole("button", { name: "مشاهده ساعت‌های تسک" })).toBeEnabled()
    expect(screen.queryByRole("button", { name: "ثبت و مشاهده ساعت" })).not.toBeInTheDocument()
  })
})
