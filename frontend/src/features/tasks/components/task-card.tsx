import { useMutation, useQueryClient } from "@tanstack/react-query"
import { MessageSquare } from "lucide-react"

import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { Card, CardContent } from "@/components/ui/card"
import { Select } from "@/components/ui/select"
import { updateTaskStatus } from "@/features/tasks/api"
import { TaskDetailDialog } from "@/features/tasks/components/task-detail-dialog"
import { LogWorkDialog } from "@/features/worklogs/components/log-work-dialog"
import { useAuthStore } from "@/features/auth/auth-store"
import type { OrgUser, Task, TaskStatus } from "@/lib/types"

const STATUS_OPTIONS: { value: TaskStatus; label: string }[] = [
  { value: "todo", label: "برای انجام" },
  { value: "in_progress", label: "در حال انجام" },
  { value: "in_review", label: "در بازبینی" },
  { value: "done", label: "انجام‌شده" },
  { value: "blocked", label: "معطل" },
]

const PRIORITY_LABEL: Record<string, string> = { low: "کم", medium: "متوسط", high: "بالا" }
const PRIORITY_VARIANT: Record<string, "default" | "warning" | "danger"> = {
  low: "default",
  medium: "warning",
  high: "danger",
}

export function TaskCard({ task, users }: { task: Task; users: OrgUser[] }) {
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
        {assignee && <p className="text-sm text-muted-foreground">{assignee.full_name}</p>}
        <Select
          value={task.status}
          onChange={(e) => mutation.mutate(e.target.value as TaskStatus)}
          disabled={mutation.isPending}
        >
          {STATUS_OPTIONS.map((opt) => (
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
        {isOwnTask && <LogWorkDialog taskId={task.id} projectId={task.project_id} />}
      </CardContent>
    </Card>
  )
}
