export type UserRole = "platform_admin" | "org_admin" | "project_manager" | "employee"
export type ProjectStatus = "active" | "completed" | "archived"
export type TaskPriority = "low" | "medium" | "high"
export type TaskStatus = "todo" | "in_progress" | "completed" | "archived"
export type ApprovalStatus = "pending" | "approved" | "rejected"

export type Project = {
  id: string
  organization_id: string
  name: string
  description: string | null
  cooperation_start_date: string | null
  start_date: string | null
  end_date: string | null
  status: ProjectStatus
  created_by_id: string
  manager_id: string | null
  created_at: string
}

export type Task = {
  id: string
  organization_id: string
  project_id: string | null
  parent_task_id: string | null
  assignee_id: string | null
  created_by_id: string
  title: string
  description: string | null
  priority: TaskPriority
  status: TaskStatus
  approval_status: ApprovalStatus | null
  progress_percent: number
  estimated_hours: number | null
  actual_hours: number
  deadline: string | null
  created_at: string
}

export type TaskActivity = {
  id: string
  task_id: string
  actor_user_id: string | null
  actor_full_name: string | null
  action: string
  extra_metadata: Record<string, unknown>
  created_at: string
}

export type OrgUser = {
  id: string
  organization_id: string | null
  email: string
  phone_number: string | null
  full_name: string
  role: UserRole
  is_active: boolean
  has_password: boolean
}

export type ProjectMember = {
  id: string
  project_id: string
  user_id: string
}

export type WorkLogStatus = "draft" | "submitted" | "approved" | "rejected"

export type WorkLog = {
  id: string
  organization_id: string
  task_id: string
  user_id: string
  activity_description: string
  time_spent_minutes: number
  progress_percent: number
  log_date: string
  status: WorkLogStatus
  reviewed_by_id: string | null
  review_comment: string | null
  created_at: string
}
