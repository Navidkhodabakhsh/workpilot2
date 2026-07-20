import { useState } from "react"
import { useMutation, useQueryClient } from "@tanstack/react-query"
import { Archive, CalendarDays, MessageSquare, UserPen } from "lucide-react"

import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { Card, CardContent } from "@/components/ui/card"
import { ConfirmDialog } from "@/components/ui/confirm-dialog"
import { Select } from "@/components/ui/select"
import { updateTaskStatus } from "@/features/tasks/api"
import {
  APPROVAL_LABEL,
  APPROVAL_VARIANT,
  PRIORITY_LABEL,
  PRIORITY_VARIANT,
  STATUS_COLUMNS,
  STATUS_LABEL,
  STATUS_VARIANT,
} from "@/features/tasks/constants"
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
  /** Shown as a badge when the card appears in a cross-project context (e.g. the Tasks list, not scoped to one project's page). */
  projectName?: string
}) {
  const queryClient = useQueryClient()
  const currentUserId = useAuthStore((s) => s.user?.id)
  const assignee = users.find((u) => u.id === task.assignee_id)
  const isOwnTask = task.assignee_id === currentUserId
  const [archivePromptOpen, setArchivePromptOpen] = useState(false)

  const mutation = useMutation({
    mutationFn: (status: TaskStatus) => updateTaskStatus(task.id, status),
    onSuccess: (updated) => {
      queryClient.invalidateQueries({ queryKey: ["tasks"], exact: false })
      if (updated.status === "completed") setArchivePromptOpen(true)
    },
  })

  const archiveMutation = useMutation({
    mutationFn: () => updateTaskStatus(task.id, "archived"),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["tasks"], exact: false })
      setArchivePromptOpen(false)
    },
  })

  return (
    <Card className="border-border/70 transition-shadow hover:shadow-sm">
      <CardContent className="flex flex-col gap-2.5 pt-5">
        <div className="flex items-start justify-between gap-2">
          <p className="font-medium leading-snug">{task.title}</p>
          <Badge variant={PRIORITY_VARIANT[task.priority]} className="shrink-0">
            {PRIORITY_LABEL[task.priority]}
          </Badge>
        </div>

        <div className="flex flex-wrap items-center gap-1.5">
          {projectName && <Badge variant="info">{projectName}</Badge>}
          {!task.project_id && <Badge variant="secondary">شخصی</Badge>}
          {task.approval_status && (
            <Badge variant={APPROVAL_VARIANT[task.approval_status]}>{APPROVAL_LABEL[task.approval_status]}</Badge>
          )}
        </div>

        <div className="flex flex-col gap-1 text-xs text-muted-foreground">
          {assignee && <p>مسئول: {assignee.full_name}</p>}
          {task.created_by_full_name && (
            <p className="flex items-center gap-1">
              <UserPen className="size-3" aria-hidden="true" />
              ثبت‌کننده: {task.created_by_full_name}
            </p>
          )}
          {(task.start_date || task.deadline) && (
            <p className="flex items-center gap-1">
              <CalendarDays className="size-3" aria-hidden="true" />
              {task.start_date ? new Date(task.start_date).toLocaleDateString("fa-IR") : "—"}
              {" تا "}
              {task.deadline ? new Date(task.deadline).toLocaleDateString("fa-IR") : "—"}
            </p>
          )}
        </div>

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

        {isOwnTask ? (
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
        ) : (
          <Badge variant={STATUS_VARIANT[task.status]} className="w-fit">
            {STATUS_LABEL[task.status]}
          </Badge>
        )}

        <div className="flex flex-wrap items-center gap-2">
          <TaskDetailDialog
            task={task}
            trigger={
              <Button variant="outline" size="sm">
                <MessageSquare className="size-4" />
                نظرات و فایل‌ها
              </Button>
            }
          />
          {isOwnTask && task.status === "completed" && (
            <Button
              variant="outline"
              size="sm"
              onClick={() => archiveMutation.mutate()}
              disabled={archiveMutation.isPending}
            >
              <Archive className="size-4" />
              انتقال به بایگانی
            </Button>
          )}
        </div>
        {isOwnTask && task.project_id && <LogWorkDialog taskId={task.id} projectId={task.project_id} />}
      </CardContent>

      <ConfirmDialog
        open={archivePromptOpen}
        onOpenChange={setArchivePromptOpen}
        title="انتقال به بایگانی؟"
        description="این وظیفه به‌عنوان تکمیل‌شده علامت خورد. آیا می‌خواهید همین حالا آن را به بایگانی منتقل کنید؟ در غیر این صورت بعداً هم می‌توانید این کار را انجام دهید."
        confirmLabel="انتقال به بایگانی"
        cancelLabel="فعلاً نه"
        onConfirm={() => archiveMutation.mutate()}
        isConfirming={archiveMutation.isPending}
      />
    </Card>
  )
}
