import { useMutation, useQueryClient } from "@tanstack/react-query"
import { CalendarDays, Clock3, MessageSquare, UserPen } from "lucide-react"

import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { Card, CardContent } from "@/components/ui/card"
import { Select } from "@/components/ui/select"
import { useAuthStore } from "@/features/auth/auth-store"
import { TaskDetailDialog } from "@/features/tasks/components/task-detail-dialog"
import { EditTaskDialog } from "@/features/tasks/components/edit-task-dialog"
import {
  APPROVAL_LABEL,
  APPROVAL_VARIANT,
  STATUS_COLOR,
  STATUS_LABEL,
  STATUS_VARIANT,
} from "@/features/tasks/constants"
import { ACTIVE_STATUS_COLUMNS, VALUE_LABEL, VALUE_VARIANT } from "@/features/tasks/workflow-constants"
import { updateTaskStatus } from "@/features/tasks/api"
import { LogWorkDialog } from "@/features/worklogs/components/log-work-dialog"
import type { OrgUser, Task, TaskStatus } from "@/lib/types"

export function TaskWorkflowCard({ task, users, projectName }: { task: Task; users: OrgUser[]; projectName?: string }) {
  const queryClient = useQueryClient()
  const currentUser = useAuthStore((state) => state.user)
  const currentUserId = currentUser?.id
  const assignee = users.find((user) => user.id === task.assignee_id)
  const isAssignee = task.assignee_id === currentUserId
  // Only the assignee actually performs the work and logs hours; the task
  // creator (typically the manager who assigned it) reviews/approves instead.
  const canLog = isAssignee
  const isManager = currentUser?.role === "org_admin" || currentUser?.role === "project_manager"
  const canEdit = isAssignee || task.created_by_id === currentUserId || isManager
  const canViewHours = canLog || isManager
  const statusMutation = useMutation({
    mutationFn: (status: TaskStatus) => updateTaskStatus(task.id, status),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ["tasks"], exact: false }),
  })

  return (
    <Card className="group overflow-hidden border-border/70 border-s-4 transition-all hover:-translate-y-0.5 hover:shadow-md" style={{ borderInlineStartColor: STATUS_COLOR[task.status] }}>
      <CardContent className="flex flex-col gap-3 pt-5">
        <div className="flex items-start justify-between gap-2">
          <p className="font-semibold leading-6">{task.title}</p>
          <Badge variant={VALUE_VARIANT[task.value]} className="shrink-0">{VALUE_LABEL[task.value]}</Badge>
        </div>
        <div className="flex flex-wrap gap-1.5">
          {projectName && <Badge variant="info">{projectName}</Badge>}
          {!task.project_id && <Badge variant="secondary">شخصی</Badge>}
          {task.approval_status && <Badge variant={APPROVAL_VARIANT[task.approval_status]}>{APPROVAL_LABEL[task.approval_status]}</Badge>}
        </div>
        {task.description && <p className="line-clamp-2 text-sm leading-6 text-muted-foreground">{task.description}</p>}
        <div className="flex flex-col gap-1.5 rounded-lg bg-muted/45 p-2.5 text-xs text-muted-foreground">
          {assignee && <p>مسئول انجام: <span className="font-medium text-foreground">{assignee.full_name}</span></p>}
          {task.created_by_id !== currentUserId && task.created_by_full_name && <p className="flex items-center gap-1.5"><UserPen className="size-3.5" />محول‌کننده: <span className="font-medium text-foreground">{task.created_by_full_name}</span></p>}
          {task.created_by_id === currentUserId && <p className="flex items-center gap-1.5"><UserPen className="size-3.5" />ساخته‌شده توسط شما</p>}
          {(task.start_date || task.deadline) && <p className="flex items-center gap-1.5"><CalendarDays className="size-3.5" />{task.start_date ? new Date(task.start_date).toLocaleDateString("fa-IR") : "—"} تا {task.deadline ? new Date(task.deadline).toLocaleDateString("fa-IR") : "—"}</p>}
        </div>
        <div className="rounded-xl border border-primary/15 bg-primary/[0.035] p-3">
          <div className="flex items-center gap-2 text-xs text-muted-foreground">
            <Clock3 className="size-4 text-primary" />
            <span>زمان مصرف‌شده:</span>
            <span className="text-base font-bold text-foreground">{task.total_logged_hours.toLocaleString("fa-IR", { maximumFractionDigits: 2 })} ساعت</span>
          </div>
          <div className="mt-2 grid grid-cols-2 gap-2 ps-6 text-xs">
            <p className="rounded-md bg-success/10 px-2 py-1.5 text-success">تأییدشده: {task.actual_hours.toLocaleString("fa-IR", { maximumFractionDigits: 2 })} ساعت</p>
            <p className="rounded-md bg-warning/10 px-2 py-1.5 text-warning">منتظر تأیید: {task.pending_hours.toLocaleString("fa-IR", { maximumFractionDigits: 2 })} ساعت</p>
          </div>
        </div>
        {task.progress_percent > 0 && <div className="flex flex-col gap-1"><div className="h-2 overflow-hidden rounded-full bg-muted"><div className="h-full rounded-full bg-primary transition-[width]" style={{ width: `${task.progress_percent}%` }} /></div><span className="text-xs text-muted-foreground">{task.progress_percent.toLocaleString("fa-IR")}٪ پیشرفت</span></div>}
        {isAssignee && task.status !== "archived" ? <Select value={task.status} onChange={(event) => statusMutation.mutate(event.target.value as TaskStatus)} disabled={statusMutation.isPending}>{ACTIVE_STATUS_COLUMNS.map((item) => <option key={item.value} value={item.value}>{item.label}</option>)}</Select> : <Badge variant={STATUS_VARIANT[task.status]} className="w-fit">{STATUS_LABEL[task.status]}</Badge>}
        <div className="flex flex-wrap gap-2">
          <TaskDetailDialog task={task} trigger={<Button variant="outline" size="sm"><MessageSquare className="size-4" />جزئیات و بررسی</Button>} />
          {canEdit && task.status !== "archived" && <EditTaskDialog task={task} users={users} />}
        </div>
        {canViewHours && <LogWorkDialog taskId={task.id} projectId={task.project_id} readOnly={!canLog || task.status === "archived"} />}
      </CardContent>
    </Card>
  )
}
