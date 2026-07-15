import { useMutation, useQueryClient } from "@tanstack/react-query"
import { MessageSquare } from "lucide-react"

import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { Card, CardContent } from "@/components/ui/card"
import { Select } from "@/components/ui/select"
import { updateTaskStatus } from "@/features/tasks/api"
import { APPROVAL_LABEL, APPROVAL_VARIANT, PRIORITY_LABEL, PRIORITY_VARIANT, STATUS_COLUMNS } from "@/features/tasks/constants"
import { TaskDetailDialog } from "@/features/tasks/components/task-detail-dialog"
import { LogWorkDialog } from "@/features/worklogs/components/log-work-dialog"
import { useAuthStore } from "@/features/auth/auth-store"
import type { OrgUser, Task, TaskStatus } from "@/lib/types"

export function TaskCard({
  task,
  users,
  projectName,
}: {
  task: Task
  users: OrgUser[]
  /** Shown as a badge when the card appears in a cross-project context (Workflow board). */
  projectName?: string
}) {
  const queryClient = useQueryClient()
  const currentUserId = useAuthStore((s) => s.user?.id)
  const assignee = users.find((u) => u.id === task.assignee_id)
  const isOwnTask = task.assignee_id === currentUserId

  const mutation = useMutation({
    mutationFn: (status: TaskStatus) => updateTaskStatus(task.id, status),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ["tasks"], exact: false }),
  })

  return (
    <Card>
      <CardContent className="flex flex-col gap-3 pt-6">
        <div className="flex items-start justify-between gap-2">
          <p className="font-medium">{task.title}</p>
          <Badge variant={PRIORITY_VARIANT[task.priority]} className="shrink-0">
            {PRIORITY_LABEL[task.priority]}
          </Badge>
        </div>
        <div className="flex flex-wrap items-center gap-2">
          {projectName && <Badge variant="info">{projectName}</Badge>}
          {!task.project_id && <Badge variant="secondary">شخصی</Badge>}
          {task.approval_status && (
            <Badge variant={APPROVAL_VARIANT[task.approval_status]}>{APPROVAL_LABEL[task.approval_status]}</Badge>
          )}
        </div>
        {assignee && <p className="text-sm text-muted-foreground">{assignee.full_name}</p>}

        {task.progress_percent > 0 && (
          <div className="flex flex-col gap-1">
            <div className="h-1.5 w-full overflow-hidden rounded-full bg-muted">
              <div
                className="h-full rounded-full bg-primary transition-[width]"
                style={{ width: `${task.progress_percent}%` }}
              />
            </div>
            <span className="text-xs text-muted-foreground">{task.progress_percent}% پیشرفت</span>
          </div>
        )}

        <Select
          value={task.status}
          onChange={(e) => mutation.mutate(e.target.value as TaskStatus)}
          disabled={mutation.isPending}
        >
          {STATUS_COLUMNS.map((opt) => (
            <option key={opt.value} value={opt.value}>
              {opt.label}
            </option>
          ))}
        </Select>
        <div className="flex items-center gap-2">
          <TaskDetailDialog
            task={task}
            trigger={
              <Button variant="outline" size="sm">
                <MessageSquare className="size-4" />
                نظرات و فایل‌ها
              </Button>
            }
          />
        </div>
        {isOwnTask && task.project_id && <LogWorkDialog taskId={task.id} projectId={task.project_id} />}
      </CardContent>
    </Card>
  )
}
