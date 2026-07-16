import { useMemo, useState } from "react"
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query"
import { useForm } from "react-hook-form"
import { zodResolver } from "@hookform/resolvers/zod"
import { z } from "zod"
import { useSearchParams } from "react-router-dom"
import { ChevronDown, ChevronLeft, MessageSquare, Plus, Search } from "lucide-react"

import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog"
import { EmptyState } from "@/components/ui/empty-state"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Select } from "@/components/ui/select"
import { createTask, getTask, listAllTasks } from "@/features/tasks/api"
import type { TaskFilters } from "@/features/tasks/api"
import {
  APPROVAL_LABEL,
  APPROVAL_VARIANT,
  PRIORITY_LABEL,
  PRIORITY_VARIANT,
  STATUS_LABEL,
  STATUS_VARIANT,
} from "@/features/tasks/constants"
import { TaskDetailDialog } from "@/features/tasks/components/task-detail-dialog"
import { buildTaskTree, flattenTaskTree, type TaskTreeNode } from "@/features/tasks/task-tree"
import { listProjects } from "@/features/projects/api"
import { listOrgUsers } from "@/features/users/api"
import { useAuthStore } from "@/features/auth/auth-store"
import type { OrgUser, Project, Task } from "@/lib/types"

type TabKey = "assigned" | "personal" | "pending_approval" | "completed" | "rejected" | "overdue"

const TABS: { key: TabKey; label: string }[] = [
  { key: "assigned", label: "به من محول‌شده" },
  { key: "personal", label: "تسک‌های شخصی من" },
  { key: "pending_approval", label: "در انتظار تأیید" },
  { key: "completed", label: "تکمیل‌شده" },
  { key: "rejected", label: "ردشده" },
  { key: "overdue", label: "سررسیدگذشته" },
]

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
}: {
  trigger: React.ReactNode
  defaultProjectId?: string
  parentTaskId?: string
  projects: Project[]
  users: OrgUser[]
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
          <DialogDescription>اطلاعات وظیفه را وارد کنید</DialogDescription>
        </DialogHeader>
        <form onSubmit={form.handleSubmit((v) => mutation.mutate(v))} className="flex flex-col gap-4">
          <div className="flex flex-col gap-2">
            <Label htmlFor="title">عنوان</Label>
            <Input id="title" {...form.register("title")} />
            {form.formState.errors.title && (
              <p className="text-sm text-danger">{form.formState.errors.title.message}</p>
            )}
          </div>
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
          {selectedProject && (
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
            <Label htmlFor="priority">اولویت</Label>
            <Select id="priority" {...form.register("priority")}>
              <option value="low">کم</option>
              <option value="medium">متوسط</option>
              <option value="high">بالا</option>
            </Select>
          </div>
          <div className="grid grid-cols-2 gap-4">
            <div className="flex flex-col gap-2">
              <Label htmlFor="start_date">تاریخ شروع (اختیاری)</Label>
              <Input id="start_date" type="date" {...form.register("start_date")} />
            </div>
            <div className="flex flex-col gap-2">
              <Label htmlFor="deadline">تاریخ پایان (اختیاری)</Label>
              <Input id="deadline" type="date" {...form.register("deadline")} />
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

/** Depth-first rows, skipping the subtree of any id in `collapsedIds`. */
function visibleRows(rows: TaskTreeNode[], collapsedIds: Set<string>): TaskTreeNode[] {
  const out: TaskTreeNode[] = []
  let hideUntilDepth: number | null = null
  for (const row of rows) {
    if (hideUntilDepth !== null) {
      if (row.depth > hideUntilDepth) continue
      hideUntilDepth = null
    }
    out.push(row)
    if (collapsedIds.has(row.id) && row.children.length > 0) {
      hideUntilDepth = row.depth
    }
  }
  return out
}

export function TasksListPage() {
  const currentUserId = useAuthStore((s) => s.user?.id)
  const [searchParams, setSearchParams] = useSearchParams()
  const linkedTaskId = searchParams.get("task")
  const { data: linkedTask } = useQuery({
    queryKey: ["task", linkedTaskId],
    queryFn: () => getTask(linkedTaskId!),
    enabled: !!linkedTaskId,
  })
  const [tab, setTab] = useState<TabKey>("assigned")
  const [search, setSearch] = useState("")
  const [projectFilter, setProjectFilter] = useState("")
  const [priorityFilter, setPriorityFilter] = useState("")
  const [sortBy, setSortBy] = useState<"deadline" | "priority" | "created_at">("deadline")
  const [groupByProject, setGroupByProject] = useState(false)
  const [collapsedIds, setCollapsedIds] = useState<Set<string>>(new Set())

  const filters = useMemo<TaskFilters>(() => {
    switch (tab) {
      case "assigned":
        return currentUserId ? { assignee_id: currentUserId } : {}
      case "personal":
        return { personal_only: true }
      case "pending_approval":
        return { approval_status: "pending" }
      case "completed":
        return { status: "completed" }
      case "rejected":
        return { approval_status: "rejected" }
      case "overdue":
        return { overdue: true }
    }
  }, [tab, currentUserId])

  const { data: rawTasks, isLoading } = useQuery({
    queryKey: ["tasks", "list", tab, currentUserId],
    queryFn: () => listAllTasks(filters),
    enabled: tab !== "assigned" || !!currentUserId,
  })
  const { data: projects } = useQuery({ queryKey: ["projects"], queryFn: listProjects })
  const { data: users } = useQuery({ queryKey: ["org-users"], queryFn: listOrgUsers })

  const projectName = (id: string | null) => (id ? (projects?.find((p) => p.id === id)?.name ?? "—") : "شخصی")
  const assigneeName = (id: string | null) => (id ? (users?.find((u) => u.id === id)?.full_name ?? "—") : "بدون مسئول")

  // "Assigned to me" also matches personal tasks (they're self-assigned too)
  // -- exclude those here so the tab stays about project work specifically.
  const tasks = tab === "assigned" ? (rawTasks ?? []).filter((t) => t.project_id !== null) : (rawTasks ?? [])

  const filtered = tasks
    .filter((t) => !projectFilter || t.project_id === projectFilter)
    .filter((t) => !priorityFilter || t.priority === priorityFilter)
    .filter((t) => !search.trim() || t.title.toLowerCase().includes(search.trim().toLowerCase()))

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

  const groups = useMemo(() => {
    if (!groupByProject) {
      return [{ key: "all", label: null as string | null, rows: flattenTaskTree(buildTaskTree(sorted)) }]
    }
    const byProject = new Map<string, Task[]>()
    for (const t of sorted) {
      const key = t.project_id ?? "__personal__"
      const arr = byProject.get(key) ?? []
      arr.push(t)
      byProject.set(key, arr)
    }
    return Array.from(byProject.entries()).map(([key, list]) => ({
      key,
      label: key === "__personal__" ? "شخصی" : projectName(key),
      rows: flattenTaskTree(buildTaskTree(list)),
    }))
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [sorted, groupByProject, projects])

  function toggleCollapse(id: string) {
    setCollapsedIds((prev) => {
      const next = new Set(prev)
      if (next.has(id)) next.delete(id)
      else next.add(id)
      return next
    })
  }

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
            trigger={
              <Button>
                <Plus className="size-4" />
                وظیفهٔ جدید
              </Button>
            }
          />
        )}
      </div>

      <div className="flex gap-1 overflow-x-auto border-b border-border">
        {TABS.map((t) => (
          <button
            key={t.key}
            onClick={() => setTab(t.key)}
            className={
              "shrink-0 border-b-2 px-3 py-2 text-sm font-medium transition-colors " +
              (tab === t.key
                ? "border-primary text-primary"
                : "border-transparent text-muted-foreground hover:text-foreground")
            }
          >
            {t.label}
          </button>
        ))}
      </div>

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
          <option value="">همهٔ اولویت‌ها</option>
          <option value="high">بالا</option>
          <option value="medium">متوسط</option>
          <option value="low">کم</option>
        </Select>
        <Select value={sortBy} onChange={(e) => setSortBy(e.target.value as typeof sortBy)} className="lg:max-w-40">
          <option value="deadline">مرتب‌سازی: مهلت</option>
          <option value="priority">مرتب‌سازی: اولویت</option>
          <option value="created_at">مرتب‌سازی: تاریخ ایجاد</option>
        </Select>
        <label className="flex shrink-0 items-center gap-2 text-sm">
          <input
            type="checkbox"
            checked={groupByProject}
            onChange={(e) => setGroupByProject(e.target.checked)}
            className="size-4"
          />
          گروه‌بندی بر اساس پروژه
        </label>
      </div>

      {isLoading && <p className="text-muted-foreground">در حال بارگذاری...</p>}

      {!isLoading && sorted.length === 0 && <EmptyState message="وظیفه‌ای در این بخش یافت نشد." />}

      {!isLoading &&
        sorted.length > 0 &&
        groups.map((group) => (
          <div key={group.key} className="flex flex-col gap-2">
            {group.label && <h2 className="font-semibold">{group.label}</h2>}
            <div className="flex flex-col gap-2">
              {visibleRows(group.rows, collapsedIds).map((task) => (
                <div
                  key={task.id}
                  className="flex flex-col gap-2.5 rounded-lg border border-border/70 bg-card p-3 transition-shadow hover:shadow-sm sm:flex-row sm:items-center sm:justify-between"
                >
                  <div className="flex min-w-0 items-start gap-1.5" style={{ paddingInlineStart: task.depth * 20 }}>
                    {task.children.length > 0 ? (
                      <button
                        onClick={() => toggleCollapse(task.id)}
                        aria-label={collapsedIds.has(task.id) ? "باز کردن زیروظایف" : "بستن زیروظایف"}
                        className="mt-0.5 shrink-0 text-muted-foreground hover:text-foreground"
                      >
                        {collapsedIds.has(task.id) ? (
                          <ChevronLeft className="size-4" />
                        ) : (
                          <ChevronDown className="size-4" />
                        )}
                      </button>
                    ) : (
                      <span className="mt-0.5 inline-block size-4 shrink-0" />
                    )}
                    <div className="flex min-w-0 flex-col gap-1.5">
                      <p className="truncate font-medium">{task.title}</p>
                      <div className="flex flex-wrap items-center gap-1.5">
                        {!groupByProject &&
                          (task.project_id ? (
                            <Badge variant="info">{projectName(task.project_id)}</Badge>
                          ) : (
                            <Badge variant="secondary">شخصی</Badge>
                          ))}
                        <Badge variant={PRIORITY_VARIANT[task.priority]}>{PRIORITY_LABEL[task.priority]}</Badge>
                        <Badge variant={STATUS_VARIANT[task.status]}>{STATUS_LABEL[task.status]}</Badge>
                        {task.approval_status && (
                          <Badge variant={APPROVAL_VARIANT[task.approval_status]}>
                            {APPROVAL_LABEL[task.approval_status]}
                          </Badge>
                        )}
                      </div>
                      <div className="flex flex-wrap gap-x-3 gap-y-0.5 text-xs text-muted-foreground">
                        <span>مسئول: {assigneeName(task.assignee_id)}</span>
                        {task.created_by_full_name && <span>ثبت‌کننده: {task.created_by_full_name}</span>}
                        {(task.start_date || task.deadline) && (
                          <span>
                            {task.start_date ? new Date(task.start_date).toLocaleDateString("fa-IR") : "—"}
                            {" تا "}
                            {task.deadline ? new Date(task.deadline).toLocaleDateString("fa-IR") : "—"}
                          </span>
                        )}
                      </div>
                    </div>
                  </div>

                  <div className="flex shrink-0 items-center gap-3 ps-6 sm:ps-0">
                    <div className="flex items-center gap-2">
                      <div className="h-1.5 w-14 overflow-hidden rounded-full bg-muted">
                        <div
                          className="h-full rounded-full bg-primary"
                          style={{ width: `${task.progress_percent}%` }}
                        />
                      </div>
                      <span className="text-xs text-muted-foreground">{task.progress_percent}%</span>
                    </div>
                    <div className="flex items-center gap-1">
                      <TaskDetailDialog
                        task={task}
                        trigger={
                          <Button variant="ghost" size="icon" aria-label="نظرات و فایل‌ها">
                            <MessageSquare className="size-4" />
                          </Button>
                        }
                      />
                      {projects && users && (
                        <CreateTaskDialog
                          projects={projects}
                          users={users}
                          defaultProjectId={task.project_id ?? undefined}
                          parentTaskId={task.id}
                          trigger={
                            <Button variant="ghost" size="icon" aria-label="افزودن زیروظیفه">
                              <Plus className="size-4" />
                            </Button>
                          }
                        />
                      )}
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </div>
        ))}
    </div>
  )
}
