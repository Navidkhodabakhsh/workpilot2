import { useState } from "react"
import { useParams } from "react-router-dom"
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query"
import { useForm } from "react-hook-form"
import { zodResolver } from "@hookform/resolvers/zod"
import { z } from "zod"
import { Pencil, Plus, UserPlus, X } from "lucide-react"

import { Badge } from "@/components/ui/badge"
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
import {
  addProjectMember,
  getProject,
  listProjectMembers,
  removeProjectMember,
  updateProject,
} from "@/features/projects/api"
import { createTask, listTasks } from "@/features/tasks/api"
import { STATUS_COLUMNS } from "@/features/tasks/constants"
import { listOrgUsers } from "@/features/users/api"
import { TaskCard } from "@/features/tasks/components/task-card"
import { PendingApprovals } from "@/features/worklogs/components/pending-approvals"
import { ExportDialog } from "@/features/exports/components/export-dialog"
import { PaymentsSection } from "@/features/payments/components/payments-section"
import { useAuthStore } from "@/features/auth/auth-store"

const schema = z.object({
  title: z.string().min(2, "عنوان وظیفه را وارد کنید"),
  assignee_id: z.string().optional(),
})
type FormValues = z.infer<typeof schema>

const editSchema = z.object({
  name: z.string().min(2, "نام پروژه را وارد کنید"),
  description: z.string().optional(),
  cooperation_start_date: z.string().optional(),
  start_date: z.string().optional(),
  end_date: z.string().optional(),
  manager_id: z.string().optional(),
})
type EditFormValues = z.infer<typeof editSchema>

export function ProjectDetailPage() {
  const { projectId } = useParams<{ projectId: string }>()
  const role = useAuthStore((s) => s.user?.role)
  const isOrgAdmin = role === "org_admin"
  const canManage = role === "org_admin" || role === "project_manager"
  const [open, setOpen] = useState(false)
  const [editOpen, setEditOpen] = useState(false)
  const [addMemberOpen, setAddMemberOpen] = useState(false)
  const [newMemberId, setNewMemberId] = useState("")
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
  const { data: members } = useQuery({
    queryKey: ["project-members", projectId],
    queryFn: () => listProjectMembers(projectId!),
    enabled: !!projectId,
  })

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

  const editForm = useForm<EditFormValues>({ resolver: zodResolver(editSchema) })

  const updateMutation = useMutation({
    mutationFn: (values: EditFormValues) =>
      updateProject(projectId!, {
        ...values,
        cooperation_start_date: values.cooperation_start_date || undefined,
        start_date: values.start_date || undefined,
        end_date: values.end_date || undefined,
        manager_id: values.manager_id || undefined,
      }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["project", projectId] })
      queryClient.invalidateQueries({ queryKey: ["project-members", projectId] })
      setEditOpen(false)
    },
  })

  function openEdit() {
    if (!project) return
    editForm.reset({
      name: project.name,
      description: project.description ?? "",
      cooperation_start_date: project.cooperation_start_date ?? "",
      start_date: project.start_date ?? "",
      end_date: project.end_date ?? "",
      manager_id: project.manager_id ?? "",
    })
    setEditOpen(true)
  }

  const addMemberMutation = useMutation({
    mutationFn: (userId: string) => addProjectMember(projectId!, userId),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["project-members", projectId] })
      setAddMemberOpen(false)
      setNewMemberId("")
    },
  })

  const removeMemberMutation = useMutation({
    mutationFn: (userId: string) => removeProjectMember(projectId!, userId),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ["project-members", projectId] }),
  })

  const memberUsers = (members ?? [])
    .map((m) => users?.find((u) => u.id === m.user_id))
    .filter((u): u is NonNullable<typeof u> => !!u)
  const nonMemberUsers = (users ?? []).filter((u) => !memberUsers.some((m) => m.id === u.id))

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
            <Button variant="secondary" onClick={openEdit}>
              <Pencil className="size-4" />
              ویرایش پروژه
            </Button>
          )}
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

      <Dialog open={editOpen} onOpenChange={setEditOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>ویرایش پروژه</DialogTitle>
            <DialogDescription>اطلاعات پروژه را به‌روزرسانی کنید</DialogDescription>
          </DialogHeader>
          <form
            onSubmit={editForm.handleSubmit((values) => updateMutation.mutate(values))}
            className="flex flex-col gap-4"
          >
            <div className="flex flex-col gap-2">
              <Label htmlFor="edit-name">نام پروژه</Label>
              <Input id="edit-name" {...editForm.register("name")} />
              {editForm.formState.errors.name && (
                <p className="text-sm text-danger">{editForm.formState.errors.name.message}</p>
              )}
            </div>
            <div className="flex flex-col gap-2">
              <Label htmlFor="edit-description">توضیحات</Label>
              <Input id="edit-description" {...editForm.register("description")} />
            </div>
            <div className="grid grid-cols-2 gap-3">
              <div className="flex flex-col gap-2">
                <Label htmlFor="edit-cooperation-start">تاریخ شروع همکاری</Label>
                <Input id="edit-cooperation-start" type="date" {...editForm.register("cooperation_start_date")} />
              </div>
              <div className="flex flex-col gap-2">
                <Label htmlFor="edit-start-date">تاریخ شروع پروژه</Label>
                <Input id="edit-start-date" type="date" {...editForm.register("start_date")} />
              </div>
            </div>
            <div className="flex flex-col gap-2">
              <Label htmlFor="edit-end-date">تاریخ پایان</Label>
              <Input id="edit-end-date" type="date" {...editForm.register("end_date")} />
            </div>
            {isOrgAdmin && (
              <div className="flex flex-col gap-2">
                <Label htmlFor="edit-manager">مدیر پروژه</Label>
                <Select id="edit-manager" {...editForm.register("manager_id")}>
                  <option value="">بدون مدیر مشخص</option>
                  {users
                    .filter((u) => u.role === "org_admin" || u.role === "project_manager")
                    .map((u) => (
                      <option key={u.id} value={u.id}>
                        {u.full_name}
                      </option>
                    ))}
                </Select>
              </div>
            )}
            <Button type="submit" disabled={updateMutation.isPending}>
              {updateMutation.isPending ? "در حال ذخیره..." : "ذخیرهٔ تغییرات"}
            </Button>
          </form>
        </DialogContent>
      </Dialog>

      <div className="rounded-lg border p-4">
        <div className="flex items-center justify-between">
          <h2 className="font-semibold">اعضای پروژه</h2>
          {canManage && (
            <Dialog open={addMemberOpen} onOpenChange={setAddMemberOpen}>
              <DialogTrigger asChild>
                <Button variant="secondary" size="sm">
                  <UserPlus className="size-4" />
                  افزودن عضو
                </Button>
              </DialogTrigger>
              <DialogContent>
                <DialogHeader>
                  <DialogTitle>افزودن عضو به پروژه</DialogTitle>
                  <DialogDescription>یک کاربر سازمان را به این پروژه اضافه کنید</DialogDescription>
                </DialogHeader>
                <div className="flex flex-col gap-4">
                  <Select value={newMemberId} onChange={(e) => setNewMemberId(e.target.value)}>
                    <option value="">انتخاب کاربر</option>
                    {nonMemberUsers.map((u) => (
                      <option key={u.id} value={u.id}>
                        {u.full_name}
                      </option>
                    ))}
                  </Select>
                  <Button
                    disabled={!newMemberId || addMemberMutation.isPending}
                    onClick={() => addMemberMutation.mutate(newMemberId)}
                  >
                    {addMemberMutation.isPending ? "در حال افزودن..." : "افزودن"}
                  </Button>
                </div>
              </DialogContent>
            </Dialog>
          )}
        </div>
        <div className="mt-3 flex flex-wrap gap-2">
          {memberUsers.length === 0 && <p className="text-sm text-muted-foreground">هنوز عضوی اضافه نشده است.</p>}
          {memberUsers.map((u) => (
            <Badge key={u.id} variant="default" className="flex items-center gap-1.5 py-1.5">
              {u.full_name}
              {canManage && (
                <button
                  type="button"
                  aria-label={`حذف ${u.full_name} از پروژه`}
                  onClick={() => removeMemberMutation.mutate(u.id)}
                  className="rounded-full hover:bg-black/10"
                >
                  <X className="size-3" />
                </button>
              )}
            </Badge>
          ))}
        </div>
      </div>

      {isOrgAdmin && <PaymentsSection projectId={projectId!} />}

      {canManage && <PendingApprovals projectId={projectId!} tasks={tasks} users={users} />}

      {/* Kanban board: horizontally scrollable on small screens by design —
          each column keeps a readable min-width instead of squeezing to fit. */}
      <div className="flex gap-4 overflow-x-auto pb-2">
        {STATUS_COLUMNS.map((col) => {
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
