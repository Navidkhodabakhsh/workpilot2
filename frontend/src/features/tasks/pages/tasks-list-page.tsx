import { useMemo, useState } from "react"
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query"
import { Controller, useForm } from "react-hook-form"
import { zodResolver } from "@hookform/resolvers/zod"
import { z } from "zod"
import { useSearchParams } from "react-router-dom"
import { Plus, Search } from "lucide-react"

import { Button } from "@/components/ui/button"
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog"
import { Card, CardContent } from "@/components/ui/card"
import { EmptyState } from "@/components/ui/empty-state"
import { Input } from "@/components/ui/input"
import { JalaliDateInput } from "@/components/ui/jalali-date-input"
import { Label } from "@/components/ui/label"
import { Select } from "@/components/ui/select"
import { Skeleton } from "@/components/ui/skeleton"
import { createTask, getTask, listAllTasks } from "@/features/tasks/api"
import type { TaskFilters } from "@/features/tasks/api"
import { PRIORITY_LABEL, STATUS_COLUMNS } from "@/features/tasks/constants"
import { TaskCard } from "@/features/tasks/components/task-card"
import { TaskDetailDialog } from "@/features/tasks/components/task-detail-dialog"
import { buildTaskTree, flattenTaskTree } from "@/features/tasks/task-tree"
import { listProjects } from "@/features/projects/api"
import { listOrgUsers } from "@/features/users/api"
import { useDepartmentStore } from "@/features/departments/department-store"
import { useAuthStore } from "@/features/auth/auth-store"
import type { OrgUser, Project, TaskStatus } from "@/lib/types"

type MainTab = "mine" | "assigned_by_me" | "pending_approval"

const createSchema = z.object({
  title: z.string().min(2, "عنوان وظیفه را وارد کنید"),
  project_id: z.string().optional(),
  assignee_id: z.string().optional(),
  priority: z.enum(["low", "medium", "high"]),
  start_date: z.string().optional(),
  deadline: z.string().optional(),
  estimated_hours: z.string().optional(),
})
type CreateFormValues = z.infer<typeof createSchema>

function CreateTaskDialog({
  trigger,
  defaultProjectId,
  parentTaskId,
  projects,
  users,
  canAssignOthers,
}: {
  trigger: React.ReactNode
  defaultProjectId?: string
  parentTaskId?: string
  projects: Project[]
  users: OrgUser[]
  /** Employees can only ever open personal tasks for themselves -- everyone
   * managing a project (org_admin, or a project_manager who's a member)
   * can hand work to whoever's below them there. */
  canAssignOthers: boolean
}) {
  const [open, setOpen] = useState(false)
  const queryClient = useQueryClient()

  const form = useForm<CreateFormValues>({
    resolver: zodResolver(createSchema),
    defaultValues: {
      title: "",
      project_id: defaultProjectId ?? "",
      assignee_id: "",
      priority: "medium",
      start_date: "",
      deadline: "",
      estimated_hours: "",
    },
  })
  const selectedProject = form.watch("project_id")

  const mutation = useMutation({
    mutationFn: (values: CreateFormValues) =>
      createTask({
        title: values.title,
        project_id: values.project_id || undefined,
        assignee_id: values.project_id ? values.assignee_id || undefined : undefined,
        priority: values.priority,
        start_date: values.start_date || undefined,
        deadline: values.deadline || undefined,
        estimated_hours: values.estimated_hours ? Number(values.estimated_hours) : undefined,
        parent_task_id: parentTaskId,
      }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["tasks"], exact: false })
      setOpen(false)
      form.reset()
    },
  })

  return (
    <Dialog open={open} onOpenChange={setOpen}>
      <DialogTrigger asChild>{trigger}</DialogTrigger>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>{parentTaskId ? "افزودن زیروظیفه" : "وظیفهٔ جدید"}</DialogTitle>
          <DialogDescription>
            {canAssignOthers ? "اطلاعات وظیفه را وارد کنید" : "وظیفهٔ شخصی جدید برای خودتان بسازید"}
          </DialogDescription>
        </DialogHeader>
        <form onSubmit={form.handleSubmit((v) => mutation.mutate(v))} className="flex flex-col gap-4">
          <div className="flex flex-col gap-2">
            <Label htmlFor="title">عنوان</Label>
            <Input id="title" {...form.register("title")} />
            {form.formState.errors.title && (
              <p className="text-sm text-danger">{form.formState.errors.title.message}</p>
            )}
          </div>
          {canAssignOthers && (
            <div className="flex flex-col gap-2">
              <Label htmlFor="project_id">پروژه</Label>
              <Select id="project_id" {...form.register("project_id")} disabled={!!defaultProjectId}>
                <option value="">شخصی (بدون پروژه)</option>
                {projects.map((p) => (
                  <option key={p.id} value={p.id}>
                    {p.name}
                  </option>
                ))}
              </Select>
            </div>
          )}
          {canAssignOthers && selectedProject && (
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
          )}
          <div className="flex flex-col gap-2">
            <Label htmlFor="priority">ارزش وظیفه</Label>
            <Select id="priority" {...form.register("priority")}>
              <option value="low">کم</option>
              <option value="medium">متوسط</option>
              <option value="high">زیاد</option>
            </Select>
          </div>
          <div className="grid grid-cols-2 gap-4">
            <div className="flex flex-col gap-2">
              <Label htmlFor="start_date">تاریخ شروع (اختیاری)</Label>
              <Controller
                control={form.control}
                name="start_date"
                render={({ field }) => <JalaliDateInput id="start_date" value={field.value ?? ""} onChange={field.onChange} />}
              />
            </div>
            <div className="flex flex-col gap-2">
              <Label htmlFor="deadline">تاریخ پایان (اختیاری)</Label>
              <Controller
                control={form.control}
                name="deadline"
                render={({ field }) => <JalaliDateInput id="deadline" value={field.value ?? ""} onChange={field.onChange} />}
              />
            </div>
          </div>
          <div className="flex flex-col gap-2">
            <Label htmlFor="estimated_hours">ساعات تخمینی (اختیاری)</Label>
            <Input id="estimated_hours" type="number" step="0.5" min="0" {...form.register("estimated_hours")} />
          </div>
          <Button type="submit" disabled={mutation.isPending}>
            {mutation.isPending ? "در حال ایجاد..." : "ایجاد وظیفه"}
          </Button>
        </form>
      </DialogContent>
    </Dialog>
  )
}

export function TasksListPage() {
  const currentUserId = useAuthStore((s) => s.user?.id)
  const role = useAuthStore((s) => s.user?.role)
  const canAssignOthers = role === "org_admin" || role === "project_manager"
  const canApprove = role === "org_admin" || role === "project_manager"

  const [searchParams, setSearchParams] = useSearchParams()
  const linkedTaskId = searchParams.get("task")
  const { data: linkedTask } = useQuery({
    queryKey: ["task", linkedTaskId],
    queryFn: () => getTask(linkedTaskId!),
    enabled: !!linkedTaskId,
  })

  const [tab, setTab] = useState<MainTab>("mine")
  const [statusFilter, setStatusFilter] = useState<"all" | TaskStatus>("all")
  const [search, setSearch] = useState("")
  const [projectFilter, setProjectFilter] = useState("")
  const [priorityFilter, setPriorityFilter] = useState("")
  const [sortBy, setSortBy] = useState<"deadline" | "priority" | "created_at">("deadline")

  const filters = useMemo<TaskFilters>(() => {
    if (tab === "pending_approval") return { approval_status: "pending" }
    return {}
    // "mine" and "assigned_by_me" both need the unfiltered set so we can
    // slice it two different ways client-side (assignee vs creator) without
    // two round-trips.
  }, [tab])

  const { data: rawTasks, isLoading } = useQuery({
    queryKey: ["tasks", "list", tab],
    queryFn: () => listAllTasks(filters),
  })
  const { data: projects } = useQuery({ queryKey: ["projects"], queryFn: listProjects })
  const { data: users } = useQuery({ queryKey: ["org-users"], queryFn: listOrgUsers })
  const selectedDepartmentId = useDepartmentStore((s) => s.selectedDepartmentId)

  const byTab = useMemo(() => {
    const all = rawTasks ?? []
    if (tab === "mine") return all.filter((t) => t.assignee_id === currentUserId)
    if (tab === "assigned_by_me") return all.filter((t) => t.created_by_id === currentUserId && t.assignee_id !== currentUserId)
    return all
  }, [rawTasks, tab, currentUserId])

  const filtered = byTab
    .filter((t) => statusFilter === "all" || t.status === statusFilter)
    .filter((t) => !projectFilter || t.project_id === projectFilter)
    .filter((t) => !priorityFilter || t.priority === priorityFilter)
    .filter((t) => !search.trim() || t.title.toLowerCase().includes(search.trim().toLowerCase()))
    .filter((t) => {
      // Personal tasks (no project) have no department to scope by, so they
      // stay visible under any department filter.
      if (!selectedDepartmentId || !t.project_id) return true
      return projects?.find((p) => p.id === t.project_id)?.department_id === selectedDepartmentId
    })

  const priorityOrder: Record<string, number> = { high: 0, medium: 1, low: 2 }
  const sorted = [...filtered].sort((a, b) => {
    if (sortBy === "priority") return priorityOrder[a.priority] - priorityOrder[b.priority]
    if (sortBy === "deadline") {
      if (!a.deadline) return 1
      if (!b.deadline) return -1
      return a.deadline.localeCompare(b.deadline)
    }
    return b.created_at.localeCompare(a.created_at)
  })
  // Parent-before-children order (and a bit of visual indent for subtasks
  // below) without a collapsible tree -- keeps related work grouped while
  // every card stays a full, independently-actionable TaskCard.
  const ordered = flattenTaskTree(buildTaskTree(sorted))

  const statusCounts = STATUS_COLUMNS.reduce<Record<string, number>>((acc, col) => {
    acc[col.value] = byTab.filter((t) => t.status === col.value).length
    return acc
  }, {})

  return (
    <div className="flex flex-col gap-4">
      {linkedTask && (
        <TaskDetailDialog
          task={linkedTask}
          open
          onOpenChange={(next) => {
            if (!next) {
              searchParams.delete("task")
              setSearchParams(searchParams, { replace: true })
            }
          }}
        />
      )}
      <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <h1 className="text-2xl font-bold">تسک‌ها</h1>
          <p className="text-muted-foreground">مدیریت وظایف پروژه‌ای و شخصی شما</p>
        </div>
        {projects && users && (
          <CreateTaskDialog
            projects={projects}
            users={users}
            canAssignOthers={canAssignOthers}
            trigger={
              <Button>
                <Plus className="size-4" />
                وظیفهٔ جدید
              </Button>
            }
          />
        )}
      </div>

      {/* Two ways a task lands with you: you opened it yourself, or someone
          handed it to you -- plus a manager-only queue for the approvals
          waiting on them specifically. */}
      <div className="grid grid-cols-2 gap-2 sm:inline-flex sm:w-fit sm:gap-1 sm:rounded-lg sm:bg-muted sm:p-1 sm:[grid-template-columns:none]">
        <button
          onClick={() => setTab("mine")}
          className={
            "rounded-md px-4 py-2 text-sm font-medium transition-colors " +
            (tab === "mine" ? "bg-card text-foreground shadow-sm" : "text-muted-foreground hover:text-foreground")
          }
        >
          تسک‌های من
        </button>
        <button
          onClick={() => setTab("assigned_by_me")}
          className={
            "rounded-md px-4 py-2 text-sm font-medium transition-colors " +
            (tab === "assigned_by_me" ? "bg-card text-foreground shadow-sm" : "text-muted-foreground hover:text-foreground")
          }
        >
          تسک‌هایی که محول کرده‌ام
        </button>
        {canApprove && (
          <button
            onClick={() => setTab("pending_approval")}
            className={
              "col-span-2 rounded-md px-4 py-2 text-sm font-medium transition-colors sm:col-span-1 " +
              (tab === "pending_approval" ? "bg-card text-foreground shadow-sm" : "text-muted-foreground hover:text-foreground")
            }
          >
            در انتظار تأیید من
          </button>
        )}
      </div>

      {tab !== "pending_approval" && (
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
            همه ({byTab.length})
          </button>
          {STATUS_COLUMNS.map((col) => (
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
              {col.label} ({statusCounts[col.value] ?? 0})
            </button>
          ))}
        </div>
      )}

      <div className="flex flex-col gap-3 lg:flex-row lg:items-center">
        <div className="relative min-w-0 flex-1 lg:max-w-xs">
          <Search className="absolute start-3 top-1/2 size-4 -translate-y-1/2 text-muted-foreground" />
          <Input
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder="جست‌وجو در عنوان وظایف..."
            className="ps-9"
          />
        </div>
        <Select value={projectFilter} onChange={(e) => setProjectFilter(e.target.value)} className="lg:max-w-48">
          <option value="">همهٔ پروژه‌ها</option>
          {projects?.map((p) => (
            <option key={p.id} value={p.id}>
              {p.name}
            </option>
          ))}
        </Select>
        <Select value={priorityFilter} onChange={(e) => setPriorityFilter(e.target.value)} className="lg:max-w-40">
          <option value="">همهٔ ارزش‌ها</option>
          <option value="high">{PRIORITY_LABEL.high}</option>
          <option value="medium">{PRIORITY_LABEL.medium}</option>
          <option value="low">{PRIORITY_LABEL.low}</option>
        </Select>
        <Select value={sortBy} onChange={(e) => setSortBy(e.target.value as typeof sortBy)} className="lg:max-w-40">
          <option value="deadline">مرتب‌سازی: مهلت</option>
          <option value="priority">مرتب‌سازی: ارزش</option>
          <option value="created_at">مرتب‌سازی: تاریخ ایجاد</option>
        </Select>
      </div>

      {isLoading && (
        <div className="grid grid-cols-1 gap-3 sm:grid-cols-2 xl:grid-cols-3">
          {Array.from({ length: 6 }, (_, i) => (
            <Card key={i} className="border-border/70">
              <CardContent className="flex flex-col gap-2.5 pt-5">
                <Skeleton className="h-4 w-3/4" />
                <Skeleton className="h-3.5 w-1/2" />
                <div className="flex gap-1.5">
                  <Skeleton className="h-5 w-14 rounded-full" />
                  <Skeleton className="h-5 w-14 rounded-full" />
                </div>
              </CardContent>
            </Card>
          ))}
        </div>
      )}

      {!isLoading && ordered.length === 0 && (
        <EmptyState
          message={
            tab === "pending_approval"
              ? "هیچ وظیفه‌ای در انتظار تأیید شما نیست."
              : tab === "assigned_by_me"
                ? "هنوز وظیفه‌ای به کس دیگری محول نکرده‌اید."
                : "وظیفه‌ای در این بخش یافت نشد."
          }
        />
      )}

      {!isLoading && ordered.length > 0 && users && (
        <div className="grid grid-cols-1 gap-3 sm:grid-cols-2 xl:grid-cols-3">
          {ordered.map((task) => (
            <div key={task.id} style={{ marginInlineStart: task.depth * 16 }} className="flex flex-col gap-1.5">
              {task.parent_task_id && <p className="ps-1 text-xs text-muted-foreground">زیروظیفه</p>}
              <TaskCard task={task} users={users} projectName={projects?.find((p) => p.id === task.project_id)?.name} />
              {canAssignOthers && (
                <CreateTaskDialog
                  projects={projects ?? []}
                  users={users}
                  canAssignOthers={canAssignOthers}
                  defaultProjectId={task.project_id ?? undefined}
                  parentTaskId={task.id}
                  trigger={
                    <Button variant="ghost" size="sm" className="w-fit self-end text-xs text-muted-foreground">
                      <Plus className="size-3.5" />
                      افزودن زیروظیفه
                    </Button>
                  }
                />
              )}
            </div>
          ))}
        </div>
      )}
    </div>
  )
}
