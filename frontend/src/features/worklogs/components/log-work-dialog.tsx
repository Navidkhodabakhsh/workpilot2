import { useState } from "react"
import { useMutation, useQueryClient } from "@tanstack/react-query"
import { Controller, useForm } from "react-hook-form"
import { zodResolver } from "@hookform/resolvers/zod"
import { z } from "zod"
import { ClipboardList } from "lucide-react"

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
import { createWorklog } from "@/features/worklogs/api"

const schema = z.object({
  activity_description: z.string().min(2, "توضیحات فعالیت را وارد کنید"),
  time_spent_minutes: z.coerce.number().int().positive("زمان باید بیشتر از صفر باشد"),
  progress_percent: z.coerce.number().int().min(0).max(100),
  log_date: z.string().min(1, "تاریخ را انتخاب کنید"),
})
type FormInput = z.input<typeof schema>
type FormValues = z.output<typeof schema>

export function LogWorkDialog({ taskId, projectId }: { taskId: string; projectId: string }) {
  const [open, setOpen] = useState(false)
  const queryClient = useQueryClient()

  const today = new Date().toISOString().slice(0, 10)
  const form = useForm<FormInput, unknown, FormValues>({
    resolver: zodResolver(schema),
    defaultValues: { activity_description: "", time_spent_minutes: 30, progress_percent: 0, log_date: today },
  })

  const mutation = useMutation({
    mutationFn: (values: FormValues) => createWorklog({ task_id: taskId, ...values }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["worklogs", projectId] })
      setOpen(false)
      form.reset()
    },
  })

  return (
    <Dialog open={open} onOpenChange={setOpen}>
      <DialogTrigger asChild>
        <Button variant="outline" size="sm" className="w-full">
          <ClipboardList className="size-4" />
          ثبت گزارش کار
        </Button>
      </DialogTrigger>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>ثبت گزارش کاری</DialogTitle>
          <DialogDescription>فعالیت، زمان صرف‌شده و میزان پیشرفت را ثبت کنید</DialogDescription>
        </DialogHeader>
        <form onSubmit={form.handleSubmit((v) => mutation.mutate(v))} className="flex flex-col gap-4">
          <div className="flex flex-col gap-2">
            <Label htmlFor="activity_description">توضیحات فعالیت</Label>
            <Textarea id="activity_description" {...form.register("activity_description")} />
            {form.formState.errors.activity_description && (
              <p className="text-sm text-danger">{form.formState.errors.activity_description.message}</p>
            )}
          </div>
          <div className="grid grid-cols-2 gap-4">
            <div className="flex flex-col gap-2">
              <Label htmlFor="time_spent_minutes">زمان صرف‌شده (دقیقه)</Label>
              <Input id="time_spent_minutes" type="number" min={1} {...form.register("time_spent_minutes")} />
            </div>
            <div className="flex flex-col gap-2">
              <Label htmlFor="progress_percent">پیشرفت (٪)</Label>
              <Input
                id="progress_percent"
                type="number"
                min={0}
                max={100}
                {...form.register("progress_percent")}
              />
            </div>
          </div>
          <div className="flex flex-col gap-2">
            <Label htmlFor="log_date">تاریخ</Label>
            <Controller
              control={form.control}
              name="log_date"
              render={({ field }) => <JalaliDateInput id="log_date" value={field.value} onChange={field.onChange} />}
            />
          </div>
          <Button type="submit" disabled={mutation.isPending}>
            {mutation.isPending ? "در حال ثبت..." : "ثبت گزارش"}
          </Button>
        </form>
      </DialogContent>
    </Dialog>
  )
}
