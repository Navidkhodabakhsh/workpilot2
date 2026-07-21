import { useState } from "react"
import { useMutation, useQueryClient } from "@tanstack/react-query"
import { Controller, useForm } from "react-hook-form"
import { zodResolver } from "@hookform/resolvers/zod"
import { z } from "zod"
import { Pencil } from "lucide-react"

import { Button } from "@/components/ui/button"
import { Dialog, DialogContent, DialogDescription, DialogHeader, DialogTitle, DialogTrigger } from "@/components/ui/dialog"
import { Input } from "@/components/ui/input"
import { JalaliDateInput } from "@/components/ui/jalali-date-input"
import { Label } from "@/components/ui/label"
import { Select } from "@/components/ui/select"
import { Textarea } from "@/components/ui/textarea"
import { useAuthStore } from "@/features/auth/auth-store"
import { updateTask } from "@/features/tasks/api"
import type { OrgUser, Task, UserRole } from "@/lib/types"

const schema = z.object({
  title: z.string().min(2, "عنوان تسک را وارد کنید"),
  description: z.string().optional(),
  assignee_id: z.string().optional(),
  priority: z.enum(["low", "medium", "high"]),
  value: z.enum(["low", "medium", "high"]),
  estimated_hours: z.string().optional(),
  start_date: z.string().optional(),
  deadline: z.string().optional(),
})
type FormValues = z.infer<typeof schema>

const roleRank: Record<UserRole, number> = {
  platform_admin: 4,
  org_admin: 3,
  project_manager: 2,
  employee: 1,
}

export function EditTaskDialog({ task, users }: { task: Task; users: OrgUser[] }) {
  const [open, setOpen] = useState(false)
  const currentUser = useAuthStore((state) => state.user)
  const queryClient = useQueryClient()
  const canAssign = !!task.project_id && (currentUser?.role === "org_admin" || currentUser?.role === "project_manager")
  const assigneeOptions = users.filter((user) => {
    if (!currentUser || !user.is_active) return false
    return user.id === currentUser.id || user.id === task.assignee_id || roleRank[user.role] < roleRank[currentUser.role]
  })

  const form = useForm<FormValues>({ resolver: zodResolver(schema) })
  const resetForm = () => form.reset({
    title: task.title,
    description: task.description ?? "",
    assignee_id: task.assignee_id ?? "",
    priority: task.priority,
    value: task.value,
    estimated_hours: task.estimated_hours?.toString() ?? "",
    start_date: task.start_date ?? "",
    deadline: task.deadline ?? "",
  })

  const mutation = useMutation({
    mutationFn: (values: FormValues) => updateTask(task.id, {
      title: values.title,
      description: values.description || null,
      priority: values.priority,
      value: values.value,
      estimated_hours: values.estimated_hours ? Number(values.estimated_hours) : null,
      start_date: values.start_date || null,
      deadline: values.deadline || null,
      ...(canAssign && values.assignee_id && values.assignee_id !== task.assignee_id
        ? { assignee_id: values.assignee_id }
        : {}),
    }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["tasks"], exact: false })
      queryClient.invalidateQueries({ queryKey: ["task", task.id] })
      setOpen(false)
    },
  })

  return (
    <Dialog
      open={open}
      onOpenChange={(nextOpen) => {
        setOpen(nextOpen)
        if (nextOpen) {
          resetForm()
          mutation.reset()
        }
      }}
    >
      <DialogTrigger asChild>
        <Button variant="outline" size="sm">
          <Pencil className="size-4" />
          ویرایش تسک
        </Button>
      </DialogTrigger>
      <DialogContent className="max-h-[90vh] overflow-y-auto">
        <DialogHeader>
          <DialogTitle>ویرایش تسک</DialogTitle>
          <DialogDescription>اطلاعات، ارزش، زمان تخمینی و مسئول تسک را اصلاح کنید.</DialogDescription>
        </DialogHeader>
        <form className="flex flex-col gap-4" onSubmit={form.handleSubmit((values) => mutation.mutate(values))}>
          <div className="flex flex-col gap-2">
            <Label htmlFor={`edit-task-title-${task.id}`} required>عنوان</Label>
            <Input id={`edit-task-title-${task.id}`} {...form.register("title")} />
            {form.formState.errors.title && <p className="text-sm text-danger">{form.formState.errors.title.message}</p>}
          </div>
          <div className="flex flex-col gap-2">
            <Label htmlFor={`edit-task-description-${task.id}`}>توضیحات</Label>
            <Textarea id={`edit-task-description-${task.id}`} {...form.register("description")} />
          </div>
          <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
            <div className="flex flex-col gap-2">
              <Label required>ارزش تسک</Label>
              <Select {...form.register("value")}>
                <option value="low">کم</option>
                <option value="medium">متوسط</option>
                <option value="high">زیاد</option>
              </Select>
            </div>
            <div className="flex flex-col gap-2">
              <Label required>اولویت</Label>
              <Select {...form.register("priority")}>
                <option value="low">کم</option>
                <option value="medium">متوسط</option>
                <option value="high">زیاد</option>
              </Select>
            </div>
          </div>
          {canAssign && (
            <div className="flex flex-col gap-2">
              <Label>مسئول انجام</Label>
              <Select {...form.register("assignee_id")}>
                {assigneeOptions.map((user) => <option key={user.id} value={user.id}>{user.full_name}</option>)}
              </Select>
            </div>
          )}
          <div className="flex flex-col gap-2">
            <Label>زمان تخمینی (ساعت)</Label>
            <Input type="number" min="0" step="0.25" inputMode="decimal" {...form.register("estimated_hours")} />
          </div>
          <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
            <div className="flex flex-col gap-2">
              <Label>تاریخ شروع</Label>
              <Controller control={form.control} name="start_date" render={({ field }) => <JalaliDateInput value={field.value ?? ""} onChange={field.onChange} />} />
            </div>
            <div className="flex flex-col gap-2">
              <Label>مهلت انجام</Label>
              <Controller control={form.control} name="deadline" render={({ field }) => <JalaliDateInput value={field.value ?? ""} onChange={field.onChange} />} />
            </div>
          </div>
          {mutation.isError && <p className="rounded-lg bg-danger/10 p-3 text-sm text-danger">ذخیره تغییرات انجام نشد؛ دسترسی یا اطلاعات واردشده را بررسی کنید.</p>}
          <Button type="submit" disabled={mutation.isPending}>
            {mutation.isPending ? "در حال ذخیره..." : "ذخیره تغییرات تسک"}
          </Button>
        </form>
      </DialogContent>
    </Dialog>
  )
}
