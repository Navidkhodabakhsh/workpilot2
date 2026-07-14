import { useState } from "react"
import { useParams } from "react-router-dom"
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query"
import { useForm } from "react-hook-form"
import { zodResolver } from "@hookform/resolvers/zod"
import { z } from "zod"
import { Plus } from "lucide-react"

import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Select } from "@/components/ui/select"
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog"
import { getProject } from "@/features/projects/api"
import { createTask, listTasks } from "@/features/tasks/api"
import { listOrgUsers } from "@/features/users/api"
import { TaskCard } from "@/features/tasks/components/task-card"
import { PendingApprovals } from "@/features/worklogs/components/pending-approvals"
import { ExportDialog } from "@/features/exports/components/export-dialog"
import { useAuthStore } from "@/features/auth/auth-store"
import type { TaskStatus } from "@/lib/types"

const COLUMNS: { value: TaskStatus; label: string }[] = [
  { value: "todo", label: "برای انجام" },
  { value: "in_progress", label: "در حال انجام" },
  { value: "in_review", label: "در بازبینی" },
  { value: "done", label: "انجام‌شده" },
  { value: "blocked", label: "معطل" },
]

const schema = z.object({
  title: z.string().min(2, "عنوان وظیفه را وارد کنید"),
  assignee_id: z.string().optional(),
})
type FormValues = z.infer<typeof schema>

export function ProjectDetailPage() {
  const { projectId } = useParams<{ projectId: string }>()
  const role = useAuthStore((s) => s.user?.role)
  const canManage = role === "org_admin" || role === "project_manager"
  const [open, setOpen] = useState(false)
  const queryClient = useQueryClient()

  const { data: project } = useQuery({
    queryKey: ["project", projectId],
    queryFn: () => getProject(projectId!),
    enabled: !!projectId,
  })
  const { data: tasks } = useQuery({
    queryKey: ["tasks", projectId],
    queryFn: () => listTasks(projectId!),
    enabled: !!projectId,
  })
  const { data: users } = useQuery({ queryKey: ["org-users"], queryFn: listOrgUsers })

  const form = useForm<FormValues>({ resolver: zodResolver(schema), defaultValues: { title: "", assignee_id: "" } })

  const createMutation = useMutation({
    mutationFn: (values: FormValues) =>
      createTask({
        project_id: projectId!,
        title: values.title,
        assignee_id: values.assignee_id || undefined,
      }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["tasks", projectId] })
      setOpen(false)
      form.reset()
    },
  })

  if (!project || !tasks || !users) {
    return <p className="text-muted-foreground">در حال بارگذاری...</p>
  }

  return (
    <div className="flex flex-col gap-4">
      <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <h1 className="text-2xl font-bold">{project.name}</h1>
          <p className="text-muted-foreground">{project.description || "بدون توضیحات"}</p>
        </div>
        <div className="flex flex-wrap gap-2">
          <ExportDialog projectId={projectId!} />
          {canManage && (
          <Dialog open={open} onOpenChange={setOpen}>
            <DialogTrigger asChild>
              <Button>
                <Plus className="size-4" />
                وظیفهٔ جدید
              </Button>
            </DialogTrigger>
            <DialogContent>
              <DialogHeader>
                <DialogTitle>ایجاد وظیفهٔ جدید</DialogTitle>
                <DialogDescription>عنوان و مسئول وظیفه را مشخص کنید</DialogDescription>
              </DialogHeader>
              <form
                onSubmit={form.handleSubmit((values) => createMutation.mutate(values))}
                className="flex flex-col gap-4"
              >
                <div className="flex flex-col gap-2">
                  <Label htmlFor="title">عنوان وظیفه</Label>
                  <Input id="title" {...form.register("title")} />
                  {form.formState.errors.title && (
                    <p className="text-sm text-danger">{form.formState.errors.title.message}</p>
                  )}
                </div>
                <div className="flex flex-col gap-2">
                  <Label htmlFor="assignee_id">مسئول (اختیاری)</Label>
                  <Select id="assignee_id" {...form.register("assignee_id")}>
                    <option value="">بدون مسئول</option>
                    {users.map((u) => (
                      <option key={u.id} value={u.id}>
                        {u.full_name}
                      </option>
                    ))}
                  </Select>
                </div>
                <Button type="submit" disabled={createMutation.isPending}>
                  {createMutation.isPending ? "در حال ایجاد..." : "ایجاد وظیفه"}
                </Button>
              </form>
            </DialogContent>
          </Dialog>
          )}
        </div>
      </div>

      {canManage && <PendingApprovals projectId={projectId!} tasks={tasks} users={users} />}

      {/* Kanban board: horizontally scrollable on small screens by design —
          each column keeps a readable min-width instead of squeezing to fit. */}
      <div className="flex gap-4 overflow-x-auto pb-2">
        {COLUMNS.map((col) => {
          const columnTasks = tasks.filter((t) => t.status === col.value)
          return (
            <div key={col.value} className="w-72 shrink-0">
              {/* count sits directly beside its own label (not spread to the
                  column's far edge) so it can't be misread as belonging to
                  the adjacent column when scanning across an RTL row */}
              <div className="mb-2 flex items-center gap-2">
                <h2 className="font-semibold">{col.label}</h2>
                <span className="text-sm text-muted-foreground">({columnTasks.length})</span>
              </div>
              <div className="flex flex-col gap-3">
                {columnTasks.map((task) => (
                  <TaskCard key={task.id} task={task} users={users} />
                ))}
                {columnTasks.length === 0 && (
                  <p className="text-sm text-muted-foreground">وظیفه‌ای نیست</p>
                )}
              </div>
            </div>
          )
        })}
      </div>
    </div>
  )
}
