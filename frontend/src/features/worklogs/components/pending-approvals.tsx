import { useState } from "react"
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query"
import { Clock } from "lucide-react"

import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { Card, CardContent } from "@/components/ui/card"
import { Textarea } from "@/components/ui/textarea"
import { approveWorklog, listWorklogs, rejectWorklog } from "@/features/worklogs/api"
import type { OrgUser, Task } from "@/lib/types"

export function PendingApprovals({
  projectId,
  tasks,
  users,
}: {
  projectId: string
  tasks: Task[]
  users: OrgUser[]
}) {
  const queryClient = useQueryClient()
  const [rejectingId, setRejectingId] = useState<string | null>(null)
  const [comment, setComment] = useState("")

  const { data: pending } = useQuery({
    queryKey: ["worklogs", projectId, "submitted"],
    queryFn: () => listWorklogs(projectId, "submitted"),
  })

  const invalidate = () => queryClient.invalidateQueries({ queryKey: ["worklogs", projectId] })

  const approveMutation = useMutation({
    mutationFn: (id: string) => approveWorklog(id),
    onSuccess: invalidate,
  })
  const rejectMutation = useMutation({
    mutationFn: ({ id, reviewComment }: { id: string; reviewComment: string }) => rejectWorklog(id, reviewComment),
    onSuccess: () => {
      invalidate()
      setRejectingId(null)
      setComment("")
    },
  })

  if (!pending || pending.length === 0) {
    return null
  }

  return (
    <div className="flex flex-col gap-3">
      <h2 className="flex items-center gap-2 text-lg font-semibold">
        <span className="flex size-7 shrink-0 items-center justify-center rounded-full bg-warning/15 text-warning">
          <Clock className="size-4" aria-hidden="true" />
        </span>
        گزارش‌های در انتظار تأیید ({pending.length})
      </h2>
      <div className="flex flex-col gap-3">
        {pending.map((log) => {
          const task = tasks.find((t) => t.id === log.task_id)
          const author = users.find((u) => u.id === log.user_id)
          const hours = Math.round((log.time_spent_minutes / 60) * 10) / 10
          return (
            <Card
              key={log.id}
              className="overflow-hidden border-border/70 border-s-4 transition-shadow hover:shadow-md"
              style={{ borderInlineStartColor: "var(--color-warning)" }}
            >
              <CardContent className="flex flex-col gap-3 pt-6">
                <div className="flex flex-col justify-between gap-2 sm:flex-row sm:items-start">
                  <div>
                    <p className="font-medium">{task?.title ?? "وظیفهٔ حذف‌شده"}</p>
                    <p className="text-sm text-muted-foreground">
                      {author?.full_name} — {log.progress_percent}٪ پیشرفت
                    </p>
                  </div>
                  <div className="flex shrink-0 items-center gap-2">
                    <Badge variant="warning" className="gap-1 tabular-nums">
                      <Clock className="size-3" aria-hidden="true" />
                      {hours} ساعت
                    </Badge>
                    <span className="text-sm text-muted-foreground">{log.log_date}</span>
                  </div>
                </div>
                <p className="text-sm">{log.activity_description}</p>

                {rejectingId === log.id ? (
                  <div className="flex flex-col gap-2">
                    <Textarea
                      placeholder="دلیل رد گزارش را بنویسید..."
                      value={comment}
                      onChange={(e) => setComment(e.target.value)}
                    />
                    <div className="flex gap-2">
                      <Button
                        size="sm"
                        variant="destructive"
                        disabled={comment.trim().length < 2 || rejectMutation.isPending}
                        onClick={() => rejectMutation.mutate({ id: log.id, reviewComment: comment })}
                      >
                        ثبت رد گزارش
                      </Button>
                      <Button size="sm" variant="ghost" onClick={() => setRejectingId(null)}>
                        انصراف
                      </Button>
                    </div>
                  </div>
                ) : (
                  <div className="flex gap-2">
                    <Button
                      size="sm"
                      onClick={() => approveMutation.mutate(log.id)}
                      disabled={approveMutation.isPending}
                    >
                      تأیید
                    </Button>
                    <Button size="sm" variant="outline" onClick={() => setRejectingId(log.id)}>
                      درخواست اصلاح
                    </Button>
                  </div>
                )}
              </CardContent>
            </Card>
          )
        })}
      </div>
    </div>
  )
}
