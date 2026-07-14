export type UserRole = "platform_admin" | "org_admin" | "project_manager" | "employee"
export type ProjectStatus = "active" | "completed" | "archived"
export type TaskPriority = "low" | "medium" | "high"
export type TaskStatus = "todo" | "in_progress" | "in_review" | "done" | "blocked"

export type Project = {
  id: string
  organization_id: string
  name: string
  description: string | null
  start_date: string | null
  end_date: string | null
  status: ProjectStatus
  created_by_id: string
  created_at: string
}

export type Task = {
  id: string
  organization_id: string
  project_id: string
  parent_task_id: string | null
  assignee_id: string | null
  created_by_id: string
  title: string
  description: string | null
  priority: TaskPriority
  status: TaskStatus
  deadline: string | null
  created_at: string
}

export type OrgUser = {
  id: string
  organization_id: string | null
  email: string
  full_name: string
  role: UserRole
  is_active: boolean
}

export type ProjectMember = {
  id: string
  project_id: string
  user_id: string
}
