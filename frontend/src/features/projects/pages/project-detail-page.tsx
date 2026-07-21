import { useState } from "react"
import { useParams } from "react-router-dom"
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query"
import { Controller, useForm } from "react-hook-form"
import { zodResolver } from "@hookform/resolvers/zod"
import { z } from "zod"
import { Archive, FolderKanban, Pencil, Plus, Users, UserPlus, X } from "lucide-react"

import { PageHeader } from "@/components/layout/page-header"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { ConfirmDialog } from "@/components/ui/confirm-dialog"
import { Input } from "@/components/ui/input"
import { JalaliDateInput } from "@/components/ui/jalali-date-input"
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
import { TaskWorkflowCard } from "@/features/tasks/components/task-workflow-card"
import { EmptyState } from "@/components/ui/empty-state"
import type { TaskStatus } from "@/lib/types"
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
  start_date: z.string().optional(),
  end_date: z.string().optional(),
  manager_id: z.string().optional(),
  status: z.enum(["active", "completed", "archived"]),
})
type EditFormValues = z.infer<typeof editSchema>

export function ProjectDetailPage() {
  const { projectId } = useParams<{ projectId: string }>()
  const role = useAuthStore((s) => s.user?.role)
  const isOrgAdmin = role === "org_admin"
  const canManage = role === "org_admin" || role === "project_manager"
  const [open, setOpen] = useState(false)
  const [editOpen, setEditOpen] = useState(false)
  const [membersOpen, setMembersOpen] = useState(false)
  const [newMemberId, setNewMemberId] = useState("")
  const [statusFilter, setStatusFilter] = useState<"all" | TaskStatus>("all")
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
  const [archivePromptOpen, setArchivePromptOpen] = useState(false)

  const updateMutation = useMutation({
    mutationFn: (values: EditFormValues) =>
      updateProject(projectId!, {
        ...values,
        start_date: values.start_date || undefined,
        end_date: values.end_date || undefined,
        manager_id: values.manager_id || undefined,
      }),
    onSuccess: (updated) => {
      queryClient.invalidateQueries({ queryKey: ["project", projectId] })
      queryClient.invalidateQueries({ queryKey: ["project-members", projectId] })
      setEditOpen(false)
      if (updated.status === "completed") setArchivePromptOpen(true)
    },
  })

  const archiveMutation = useMutation({
    mutationFn: () => updateProject(projectId!, { status: "archived" }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["project", projectId] })
      setArchivePromptOpen(false)
    },
  })

  function openEdit() {
    if (!project) return
    editForm.reset({
      name: project.name,
      description: project.description ?? "",
      start_date: project.start_date ?? "",
      end_date: project.end_date ?? "",
      manager_id: project.manager_id ?? "",
      status: project.status,
    })
    setEditOpen(true)
  }

  const addMemberMutation = useMutation({
    mutationFn: (userId: string) => addProjectMember(projectId!, userId),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["project-members", projectId] })
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
        <PageHeader
          icon={FolderKanban}
          tone="primary"
          title={project.name}
          description={project.description || "بدون توضیحات"}
        />
        <div className="flex flex-wrap items-center gap-2">
          {/* Compact member cluster instead of a full-width box -- click to
              manage. Overlapping circles are a deliberately small footprint
              since this is secondary to the task board below, not the main
              content of the page. */}
          <button
            type="button"
            onClick={() => setMembersOpen(true)}
            className="flex items-center gap-2 rounded-full border border-border py-1 ps-1 pe-3 hover:bg-muted"
          >
            <div className="flex -space-x-2 space-x-reverse">
              {memberUsers.slice(0, 4).map((u) => (
                <div
                  key={u.id}
                  title={u.full_name}
                  className="flex size-7 items-center justify-center rounded-full border-2 border-card bg-primary text-[11px] font-semibold text-primary-foreground"
                >
                  {u.full_name.trim().charAt(0)}
                </div>
              ))}
              {memberUsers.length === 0 && (
                <div className="flex size-7 items-center justify-center rounded-full border-2 border-card bg-muted text-muted-foreground">
                  <Users className="size-3.5" />
                </div>
              )}
            </div>
            <span className="text-sm text-muted-foreground">
              {memberUsers.length > 4 ? `+${memberUsers.length - 4} ` : ""}
              {memberUsers.length === 0 ? "بدون عضو" : "عضو"}
            </span>
          </button>
          <ExportDialog projectId={projectId!} />
          {canManage && (
            <Button variant="secondary" onClick={openEdit}>
              <Pencil className="size-4" />
              ویرایش پروژه
            </Button>
          )}
          {canManage && project.status === "completed" && (
            <Button variant="secondary" onClick={() => archiveMutation.mutate()} disabled={archiveMutation.isPending}>
              <Archive className="size-4" />
              انتقال به بایگانی
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
                  <Label htmlFor="title" required>عنوان وظیفه</Label>
                  <Input id="title" {...form.register("title")} />
                  {form.formState.errors.title && (
                    <p className="text-sm text-danger">{form.formState.errors.title.message}</p>
                  )}
                </div>
                <div className="flex flex-col gap-2">
                  <Label htmlFor="assignee_id">مسئول</Label>
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
              <Label htmlFor="edit-name" required>نام پروژه</Label>
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
                <Label htmlFor="edit-start-date">تاریخ شروع پروژه</Label>
                <Controller
                  control={editForm.control}
                  name="start_date"
                  render={({ field }) => <JalaliDateInput id="edit-start-date" value={field.value ?? ""} onChange={field.onChange} />}
                />
              </div>
              <div className="flex flex-col gap-2">
                <Label htmlFor="edit-end-date">تاریخ پایان</Label>
                <Controller
                  control={editForm.control}
                  name="end_date"
                  render={({ field }) => <JalaliDateInput id="edit-end-date" value={field.value ?? ""} onChange={field.onChange} />}
                />
              </div>
            </div>
            <div className="flex flex-col gap-2">
              <Label htmlFor="edit-status" required>وضعیت</Label>
              <Select id="edit-status" {...editForm.register("status")}>
                <option value="active">فعال</option>
                <option value="completed">تکمیل‌شده</option>
                <option value="archived">بایگانی‌شده</option>
              </Select>
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

      <ConfirmDialog
        open={archivePromptOpen}
        onOpenChange={setArchivePromptOpen}
        title="انتقال به بایگانی؟"
        description="این پروژه به‌عنوان تکمیل‌شده علامت خورد. آیا می‌خواهید همین حالا آن را به بایگانی منتقل کنید؟ در غیر این صورت بعداً هم می‌توانید این کار را انجام دهید."
        confirmLabel="انتقال به بایگانی"
        cancelLabel="فعلاً نه"
        onConfirm={() => archiveMutation.mutate()}
        isConfirming={archiveMutation.isPending}
      />

      <Dialog open={membersOpen} onOpenChange={setMembersOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>اعضای پروژه</DialogTitle>
            <DialogDescription>مدیریت کاربرانی که به این پروژه دسترسی دارند</DialogDescription>
          </DialogHeader>
          <div className="flex flex-col gap-4">
            <div className="flex flex-wrap gap-2">
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
            {canManage && (
              <div className="flex flex-col gap-2 border-t border-border pt-4">
                <Label htmlFor="add-member">افزودن عضو</Label>
                <div className="flex gap-2">
                  <Select id="add-member" value={newMemberId} onChange={(e) => setNewMemberId(e.target.value)} className="flex-1">
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
                    <UserPlus className="size-4" />
                    {addMemberMutation.isPending ? "در حال افزودن..." : "افزودن"}
                  </Button>
                </div>
              </div>
            )}
          </div>
        </DialogContent>
      </Dialog>

      {isOrgAdmin && <PaymentsSection projectId={projectId!} />}

      {canManage && <PendingApprovals projectId={projectId!} tasks={tasks} users={users} />}

      {/* Same status-pill-filter + card pattern as the main Tasks page,
          instead of a separate four-column Kanban -- one consistent way to
          look at tasks across the app. What actually shows up here is
          already scoped server-side (an employee only ever gets their own
          tasks on this board, even though they're a full project member). */}
      <div className="flex flex-wrap gap-2">
        <button
          onClick={() => setStatusFilter("all")}
          className={
            "rounded-full border px-3 py-1 text-xs font-medium transition-colors " +
            (statusFilter === "all"
              ? "border-primary bg-primary/10 text-primary"
              : "border-border text-muted-foreground hover:border-foreground/30")
          }
        >
          همه ({tasks.length})
        </button>
        {STATUS_COLUMNS.map((col) => {
          const count = tasks.filter((t) => t.status === col.value).length
          return (
            <button
              key={col.value}
              onClick={() => setStatusFilter(col.value)}
              className={
                "rounded-full border px-3 py-1 text-xs font-medium transition-colors " +
                (statusFilter === col.value
                  ? "border-primary bg-primary/10 text-primary"
                  : "border-border text-muted-foreground hover:border-foreground/30")
              }
            >
              {col.label} ({count})
            </button>
          )
        })}
      </div>

      {(() => {
        const visible = tasks.filter((t) => statusFilter === "all" || t.status === statusFilter)
        if (visible.length === 0) return <EmptyState message="وظیفه‌ای در این بخش نیست." />
        return (
          <div className="grid grid-cols-1 gap-3 sm:grid-cols-2 xl:grid-cols-3">
            {visible.map((task) => (
              <TaskWorkflowCard key={task.id} task={task} users={users} />
            ))}
          </div>
        )
      })()}
    </div>
  )
}
