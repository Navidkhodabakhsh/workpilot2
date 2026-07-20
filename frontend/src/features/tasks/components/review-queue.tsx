import { useState } from "react"
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query"
import { CheckCircle2, Clock3, XCircle } from "lucide-react"

import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { EmptyState } from "@/components/ui/empty-state"
import { Textarea } from "@/components/ui/textarea"
import { getWorklogReport } from "@/features/reports/api"
import { approveWorklog, rejectWorklog } from "@/features/worklogs/api"

export function ReviewQueue() {
  const queryClient = useQueryClient()
  const [rejectingId, setRejectingId] = useState<string | null>(null)
  const [comment, setComment] = useState("")
  const { data, isLoading } = useQuery({
    queryKey: ["worklog-report", "pending-review"],
    queryFn: () => getWorklogReport({ status: "submitted" }),
  })
  const refresh = () => {
    queryClient.invalidateQueries({ queryKey: ["worklog-report"], exact: false })
    queryClient.invalidateQueries({ queryKey: ["tasks"], exact: false })
    queryClient.invalidateQueries({ queryKey: ["dashboard-summary"], exact: false })
  }
  const approveMutation = useMutation({ mutationFn: approveWorklog, onSuccess: refresh })
  const rejectMutation = useMutation({
    mutationFn: ({ id, reason }: { id: string; reason: string }) => rejectWorklog(id, reason),
    onSuccess: () => {
      refresh()
      setRejectingId(null)
      setComment("")
    },
  })

  return (
    <Card className="overflow-hidden border-warning/25 bg-warning/[0.025]">
      <CardHeader>
        <CardTitle className="flex items-center gap-2 text-base"><Clock3 className="size-5 text-warning" />ساعت‌های در انتظار تأیید</CardTitle>
      </CardHeader>
      <CardContent className="flex flex-col gap-3">
        {isLoading && <p className="text-sm text-muted-foreground">در حال دریافت گزارش‌ها...</p>}
        {!isLoading && !data?.items.length && <EmptyState className="h-28" message="ساعت ثبت‌شده‌ای در انتظار تأیید نیست." />}
        {data?.items.map((item) => (
          <div key={item.worklog_id} className="flex flex-col gap-3 rounded-xl border border-border/70 bg-card p-4">
            <div className="flex flex-col justify-between gap-2 sm:flex-row sm:items-start">
              <div><p className="font-medium">{item.task_title}</p><p className="text-sm text-muted-foreground">{item.user_full_name} · {item.project_name}</p></div>
              <Badge variant="warning" className="w-fit"><Clock3 className="size-3" />{(item.time_spent_minutes / 60).toLocaleString("fa-IR", { maximumFractionDigits: 2 })} ساعت</Badge>
            </div>
            <p className="text-sm leading-6">{item.activity_description}</p>
            {rejectingId === item.worklog_id ? (
              <div className="flex flex-col gap-2"><Textarea value={comment} onChange={(event) => setComment(event.target.value)} placeholder="دلیل رد یا اصلاح موردنیاز..." /><div className="flex gap-2"><Button size="sm" variant="destructive" disabled={comment.trim().length < 2 || rejectMutation.isPending} onClick={() => rejectMutation.mutate({ id: item.worklog_id, reason: comment })}>ثبت رد</Button><Button size="sm" variant="ghost" onClick={() => setRejectingId(null)}>انصراف</Button></div></div>
            ) : (
              <div className="flex gap-2"><Button size="sm" disabled={approveMutation.isPending} onClick={() => approveMutation.mutate(item.worklog_id)}><CheckCircle2 className="size-4" />تأیید ساعت</Button><Button size="sm" variant="outline" onClick={() => setRejectingId(item.worklog_id)}><XCircle className="size-4" />رد</Button></div>
            )}
          </div>
        ))}
      </CardContent>
    </Card>
  )
}
