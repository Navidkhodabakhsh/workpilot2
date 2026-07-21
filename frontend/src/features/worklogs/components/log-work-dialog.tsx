import { useMemo, useState } from "react"
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query"
import { Controller, useForm } from "react-hook-form"
import { zodResolver } from "@hookform/resolvers/zod"
import { z } from "zod"
import { CheckCircle2, Clock3, Hourglass, XCircle } from "lucide-react"

import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { JalaliDateInput } from "@/components/ui/jalali-date-input"
import { Label } from "@/components/ui/label"
import { Textarea } from "@/components/ui/textarea"
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog"
import { createWorklog, listTaskWorklogs } from "@/features/worklogs/api"
import type { WorkLogStatus } from "@/lib/types"

const schema = z.object({
  activity_description: z.string().min(2, "توضیحات فعالیت را وارد کنید"),
  time_spent_hours: z.coerce.number().positive("زمان باید بیشتر از صفر باشد").max(24, "زمان هر گزارش حداکثر ۲۴ ساعت است"),
  progress_percent: z.coerce.number().int().min(0).max(100),
  log_date: z.string().min(1, "تاریخ را انتخاب کنید"),
})
type FormInput = z.input<typeof schema>
type FormValues = z.output<typeof schema>

const STATUS_LABEL: Record<WorkLogStatus, string> = {
  draft: "پیش‌نویس",
  submitted: "منتظر تأیید",
  approved: "تأییدشده",
  rejected: "ردشده",
}
const STATUS_VARIANT: Record<WorkLogStatus, "secondary" | "warning" | "success" | "danger"> = {
  draft: "secondary",
  submitted: "warning",
  approved: "success",
  rejected: "danger",
}

const formatHours = (minutes: number) => (minutes / 60).toLocaleString("fa-IR", { maximumFractionDigits: 2 })

export function LogWorkDialog({
  taskId,
  projectId,
  readOnly = false,
}: {
  taskId: string
  projectId?: string | null
  readOnly?: boolean
}) {
  const [open, setOpen] = useState(false)
  const [successHours, setSuccessHours] = useState<number | null>(null)
  const queryClient = useQueryClient()
  const today = new Date().toISOString().slice(0, 10)
  const form = useForm<FormInput, unknown, FormValues>({
    resolver: zodResolver(schema),
    defaultValues: { activity_description: "", time_spent_hours: 0.5, progress_percent: 0, log_date: today },
  })

  const { data: worklogs, isLoading, isError: historyError } = useQuery({
    queryKey: ["task-worklogs", taskId],
    queryFn: () => listTaskWorklogs(taskId),
    enabled: open,
  })
  const totals = useMemo(() => {
    const rows = worklogs ?? []
    return {
      total: rows.filter((row) => row.status !== "rejected").reduce((sum, row) => sum + row.time_spent_minutes, 0),
      approved: rows.filter((row) => row.status === "approved").reduce((sum, row) => sum + row.time_spent_minutes, 0),
      pending: rows.filter((row) => row.status === "submitted").reduce((sum, row) => sum + row.time_spent_minutes, 0),
    }
  }, [worklogs])

  const mutation = useMutation({
    mutationFn: ({ time_spent_hours, ...values }: FormValues) => createWorklog({
      task_id: taskId,
      ...values,
      time_spent_minutes: Math.round(time_spent_hours * 60),
    }),
    onSuccess: (created) => {
      if (projectId) queryClient.invalidateQueries({ queryKey: ["worklogs", projectId] })
      queryClient.invalidateQueries({ queryKey: ["task-worklogs", taskId] })
      queryClient.invalidateQueries({ queryKey: ["tasks"], exact: false })
      queryClient.invalidateQueries({ queryKey: ["task", taskId] })
      queryClient.invalidateQueries({ queryKey: ["dashboard-summary"], exact: false })
      queryClient.invalidateQueries({ queryKey: ["worklog-report"], exact: false })
      setSuccessHours(created.time_spent_minutes / 60)
      form.reset({ activity_description: "", time_spent_hours: 0.5, progress_percent: created.progress_percent, log_date: today })
    },
  })

  return (
    <Dialog
      open={open}
      onOpenChange={(nextOpen) => {
        setOpen(nextOpen)
        if (nextOpen) {
          setSuccessHours(null)
          mutation.reset()
        }
      }}
    >
      <DialogTrigger asChild>
        <Button variant={readOnly ? "outline" : "default"} size="sm" className="w-full">
          <Clock3 className="size-4" />
          {readOnly ? "مشاهده ساعت‌های تسک" : "ثبت و مشاهده ساعت"}
        </Button>
      </DialogTrigger>
      <DialogContent className="max-h-[92vh] max-w-2xl overflow-y-auto">
        <DialogHeader>
          <DialogTitle>ساعت‌های مصرف‌شده تسک</DialogTitle>
          <DialogDescription>زمان ثبت‌شده فوراً در تسک دیده می‌شود و پس از تأیید مدیر وارد نمودارها خواهد شد.</DialogDescription>
        </DialogHeader>

        <div className="grid grid-cols-3 gap-2">
          <div className="rounded-xl border border-primary/20 bg-primary/[0.04] p-3 text-center"><Clock3 className="mx-auto mb-1 size-5 text-primary" /><p className="font-bold">{formatHours(totals.total)}</p><p className="text-xs text-muted-foreground">کل ثبت‌شده</p></div>
          <div className="rounded-xl border border-success/20 bg-success/[0.04] p-3 text-center"><CheckCircle2 className="mx-auto mb-1 size-5 text-success" /><p className="font-bold">{formatHours(totals.approved)}</p><p className="text-xs text-muted-foreground">تأییدشده</p></div>
          <div className="rounded-xl border border-warning/20 bg-warning/[0.04] p-3 text-center"><Hourglass className="mx-auto mb-1 size-5 text-warning" /><p className="font-bold">{formatHours(totals.pending)}</p><p className="text-xs text-muted-foreground">منتظر تأیید</p></div>
        </div>

        {!readOnly ? (
          <form onSubmit={form.handleSubmit((values) => mutation.mutate(values))} className="flex flex-col gap-4 rounded-xl border border-border/70 p-4">
            <p className="font-semibold">ثبت ساعت جدید</p>
            <div className="flex flex-col gap-2">
              <Label htmlFor={`activity-description-${taskId}`} required>توضیحات فعالیت</Label>
              <Textarea id={`activity-description-${taskId}`} {...form.register("activity_description")} />
              {form.formState.errors.activity_description && <p className="text-sm text-danger">{form.formState.errors.activity_description.message}</p>}
            </div>
            <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
              <div className="flex flex-col gap-2">
                <Label htmlFor={`time-spent-hours-${taskId}`} required>زمان صرف‌شده (ساعت)</Label>
                <Input id={`time-spent-hours-${taskId}`} type="number" min={0.05} max={24} step={0.25} inputMode="decimal" {...form.register("time_spent_hours")} />
                <p className="text-xs text-muted-foreground">مثلاً ۲ برای دو ساعت یا ۰٫۵ برای نیم ساعت</p>
                {form.formState.errors.time_spent_hours && <p className="text-sm text-danger">{form.formState.errors.time_spent_hours.message}</p>}
              </div>
              <div className="flex flex-col gap-2">
                <Label htmlFor={`progress-percent-${taskId}`} required>پیشرفت تسک (٪)</Label>
                <Input id={`progress-percent-${taskId}`} type="number" min={0} max={100} {...form.register("progress_percent")} />
                {form.formState.errors.progress_percent && <p className="text-sm text-danger">{form.formState.errors.progress_percent.message}</p>}
              </div>
            </div>
            <div className="flex flex-col gap-2">
              <Label htmlFor={`log-date-${taskId}`} required>تاریخ گزارش</Label>
              <Controller control={form.control} name="log_date" render={({ field }) => <JalaliDateInput id={`log-date-${taskId}`} value={field.value} onChange={field.onChange} />} />
              {form.formState.errors.log_date && <p className="text-sm text-danger">{form.formState.errors.log_date.message}</p>}
            </div>
            {successHours !== null && <p className="rounded-lg bg-success/10 p-3 text-sm text-success"><CheckCircle2 className="me-1 inline size-4" />{successHours.toLocaleString("fa-IR", { maximumFractionDigits: 2 })} ساعت با موفقیت ثبت شد.</p>}
            {mutation.isError && <p className="rounded-lg bg-danger/10 p-3 text-sm text-danger"><XCircle className="me-1 inline size-4" />ثبت ساعت انجام نشد؛ دسترسی، تاریخ و مقدار زمان را بررسی کنید.</p>}
            <Button type="submit" disabled={mutation.isPending}>{mutation.isPending ? "در حال ثبت ساعت..." : "ثبت ساعت روی تسک"}</Button>
          </form>
        ) : (
          <p className="rounded-lg bg-muted p-3 text-sm text-muted-foreground">این تسک فقط برای مشاهده باز است؛ روی تسک بایگانی‌شده یا تسکی که متعلق به شما نیست امکان ثبت ساعت جدید وجود ندارد.</p>
        )}

        <div className="flex flex-col gap-2">
          <p className="font-semibold">تاریخچه گزارش ساعت</p>
          {isLoading && <p className="text-sm text-muted-foreground">در حال دریافت گزارش‌ها...</p>}
          {historyError && <p className="rounded-lg bg-danger/10 p-3 text-sm text-danger">دریافت تاریخچه ساعت انجام نشد.</p>}
          {!isLoading && !historyError && worklogs?.length === 0 && <p className="rounded-lg border border-dashed p-5 text-center text-sm text-muted-foreground">هنوز ساعتی روی این تسک ثبت نشده است.</p>}
          {worklogs?.map((row) => (
            <div key={row.id} className="flex flex-col gap-2 rounded-xl border border-border/70 p-3 sm:flex-row sm:items-center">
              <div className="min-w-0 flex-1"><p className="text-sm font-medium">{row.activity_description}</p><p className="text-xs text-muted-foreground">{new Date(row.log_date).toLocaleDateString("fa-IR")} · پیشرفت {row.progress_percent.toLocaleString("fa-IR")}٪</p>{row.review_comment && <p className="mt-1 text-xs text-danger">نظر مدیر: {row.review_comment}</p>}</div>
              <div className="flex shrink-0 items-center gap-2"><span className="font-bold">{formatHours(row.time_spent_minutes)} ساعت</span><Badge variant={STATUS_VARIANT[row.status]}>{STATUS_LABEL[row.status]}</Badge></div>
            </div>
          ))}
        </div>
      </DialogContent>
    </Dialog>
  )
}
