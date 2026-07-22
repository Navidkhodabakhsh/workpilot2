import { useMemo, useState } from "react"
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query"
import { Controller, useForm } from "react-hook-form"
import { zodResolver } from "@hookform/resolvers/zod"
import { z } from "zod"
import { CheckSquare, Plus, Search } from "lucide-react"
import { useSearchParams } from "react-router-dom"

import { PageHeader } from "@/components/layout/page-header"
import { Button } from "@/components/ui/button"
import { Card, CardContent } from "@/components/ui/card"
import { Dialog, DialogContent, DialogDescription, DialogHeader, DialogTitle, DialogTrigger } from "@/components/ui/dialog"
import { EmptyState } from "@/components/ui/empty-state"
import { Input } from "@/components/ui/input"
import { JalaliDateInput } from "@/components/ui/jalali-date-input"
import { Label } from "@/components/ui/label"
import { Select } from "@/components/ui/select"
import { Skeleton } from "@/components/ui/skeleton"
import { Textarea } from "@/components/ui/textarea"
import { useAuthStore } from "@/features/auth/auth-store"
import { useDepartmentStore } from "@/features/departments/department-store"
import { listProjects } from "@/features/projects/api"
import { createTask, getTask, listAllTasks } from "@/features/tasks/api"
import { ReviewQueue } from "@/features/tasks/components/review-queue"
import { TaskWorkflowCard } from "@/features/tasks/components/task-workflow-card"
import { TaskDetailDialog } from "@/features/tasks/components/task-detail-dialog"
import { ACTIVE_STATUS_COLUMNS, VALUE_LABEL } from "@/features/tasks/workflow-constants"
import { listOrgUsers } from "@/features/users/api"
import { normalizeNumericString } from "@/lib/numeric-input"
import type { OrgUser, Project, TaskStatus, UserRole } from "@/lib/types"

type Tab = "self_created" | "assigned_to_me" | "pending"
const rank: Record<UserRole, number> = { platform_admin: 4, org_admin: 3, project_manager: 2, employee: 1 }
const schema = z.object({
  title: z.string().min(2, "عنوان وظیفه را وارد کنید"),
  description: z.string().optional(),
  project_id: z.string().optional(),
  assignee_id: z.string().optional(),
  value: z.enum(["low", "medium", "high"]),
  start_date: z.string().optional(),
  deadline: z.string().optional(),
  estimated_hours: z.string().optional(),
})
type FormValues = z.infer<typeof schema>

function NewTaskDialog({ projects, users }: { projects: Project[]; users: OrgUser[] }) {
  const [open, setOpen] = useState(false)
  const queryClient = useQueryClient()
  const me = useAuthStore((state) => state.user)
  const canAssign = me?.role === "org_admin" || me?.role === "project_manager"
  const form = useForm<FormValues>({
    resolver: zodResolver(schema),
    defaultValues: { title: "", description: "", project_id: "", assignee_id: "", value: "medium", start_date: "", deadline: "", estimated_hours: "" },
  })
  const projectId = form.watch("project_id")
  const candidates = users.filter((user) => me && user.id !== me.id && rank[user.role] < rank[me.role])
  const mutation = useMutation({
    mutationFn: (values: FormValues) => createTask({
      title: values.title,
      description: values.description || undefined,
      project_id: values.project_id || undefined,
      assignee_id: values.project_id ? values.assignee_id || undefined : undefined,
      value: values.value,
      start_date: values.start_date || undefined,
      deadline: values.deadline || undefined,
      estimated_hours: values.estimated_hours ? Number(normalizeNumericString(values.estimated_hours)) : undefined,
    }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["tasks"], exact: false })
      setOpen(false)
      form.reset()
    },
  })

  return (
    <Dialog open={open} onOpenChange={setOpen}>
      <DialogTrigger asChild><Button><Plus className="size-4" />وظیفهٔ جدید</Button></DialogTrigger>
      <DialogContent className="max-h-[90vh] overflow-y-auto">
        <DialogHeader>
          <DialogTitle>ساخت وظیفه</DialogTitle>
          <DialogDescription>وظیفهٔ شخصی یا پروژه‌ای بسازید؛ تخصیص فقط به نقش پایین‌تر ممکن است.</DialogDescription>
        </DialogHeader>
        <form className="flex flex-col gap-4" onSubmit={form.handleSubmit((values) => mutation.mutate(values))}>
          <div className="flex flex-col gap-2"><Label htmlFor="new-task-title" required>عنوان</Label><Input id="new-task-title" {...form.register("title")} />{form.formState.errors.title && <p className="text-sm text-danger">{form.formState.errors.title.message}</p>}</div>
          <div className="flex flex-col gap-2"><Label htmlFor="new-task-description">توضیحات</Label><Textarea id="new-task-description" {...form.register("description")} /></div>
          <div className="flex flex-col gap-2"><Label htmlFor="new-task-project">پروژه</Label><Select id="new-task-project" {...form.register("project_id")}><option value="">شخصی (بدون پروژه)</option>{projects.map((project) => <option key={project.id} value={project.id}>{project.name}</option>)}</Select></div>
          {canAssign && projectId && <div className="flex flex-col gap-2"><Label htmlFor="new-task-assignee">مسئول انجام</Label><Select id="new-task-assignee" {...form.register("assignee_id")}><option value="">خودم</option>{candidates.map((user) => <option key={user.id} value={user.id}>{user.full_name}</option>)}</Select></div>}
          <div className="flex flex-col gap-2"><Label htmlFor="new-task-value">ارزش وظیفه</Label><Select id="new-task-value" {...form.register("value")}><option value="low">کم — قابل تعویق</option><option value="medium">متوسط — اثر مستقیم</option><option value="high">زیاد — حیاتی برای نتیجه</option></Select></div>
          <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
            <div className="flex flex-col gap-2"><Label htmlFor="new-task-start">شروع</Label><Controller control={form.control} name="start_date" render={({ field }) => <JalaliDateInput id="new-task-start" value={field.value ?? ""} onChange={field.onChange} />} /></div>
            <div className="flex flex-col gap-2"><Label htmlFor="new-task-end">پایان</Label><Controller control={form.control} name="deadline" render={({ field }) => <JalaliDateInput id="new-task-end" value={field.value ?? ""} onChange={field.onChange} />} /></div>
          </div>
          <div className="flex flex-col gap-2"><Label htmlFor="new-task-estimate">ساعت تخمینی</Label><Input id="new-task-estimate" type="text" inputMode="decimal" dir="ltr" {...form.register("estimated_hours")} /></div>
          {mutation.isError && <p className="text-sm text-danger">ساخت وظیفه انجام نشد؛ سطح دسترسی یا اطلاعات را بررسی کنید.</p>}
          <Button type="submit" disabled={mutation.isPending}>{mutation.isPending ? "در حال ثبت..." : "ثبت وظیفه"}</Button>
        </form>
      </DialogContent>
    </Dialog>
  )
}

export function TasksWorkflowPage() {
  const [searchParams, setSearchParams] = useSearchParams()
  const linkedTaskId = searchParams.get("task")
  const { data: linkedTask } = useQuery({
    queryKey: ["task", linkedTaskId],
    queryFn: () => getTask(linkedTaskId!),
    enabled: !!linkedTaskId,
  })
  const me = useAuthStore((state) => state.user)
  const selectedDepartmentId = useDepartmentStore((state) => state.selectedDepartmentId)
  const isOrgAdmin = me?.role === "org_admin"
  const canReview = isOrgAdmin || me?.role === "project_manager"
  const [tab, setTab] = useState<Tab>("self_created")
  const [status, setStatus] = useState<"all" | TaskStatus>("all")
  const [search, setSearch] = useState("")
  const [projectId, setProjectId] = useState("")
  const [value, setValue] = useState("")
  const { data: tasks, isLoading } = useQuery({
    queryKey: ["tasks", "workflow", tab],
    queryFn: () => listAllTasks(tab === "pending" ? { approval_status: "pending" } : undefined),
  })
  const { data: projects } = useQuery({ queryKey: ["projects"], queryFn: listProjects })
  const { data: users } = useQuery({ queryKey: ["org-users"], queryFn: listOrgUsers })

  const visible = useMemo(() => (tasks ?? [])
    .filter((task) => {
      if (tab === "self_created") return task.created_by_id === me?.id && task.status !== "archived"
      if (tab === "assigned_to_me") return task.assignee_id === me?.id && task.created_by_id !== me?.id && task.status !== "archived"
      return true
    })
    .filter((task) => status === "all" || task.status === status)
    .filter((task) => !projectId || task.project_id === projectId)
    .filter((task) => !value || task.value === value)
    .filter((task) => !search.trim() || task.title.toLowerCase().includes(search.trim().toLowerCase()))
    .filter((task) => !selectedDepartmentId || !task.project_id || projects?.find((project) => project.id === task.project_id)?.department_id === selectedDepartmentId),
    // Newest first, exactly as the API already returns them -- no client
    // sort here, so a freshly created task shows up at the top instead of
    // being reshuffled by deadline.
    [tasks, tab, me?.id, status, projectId, value, search, selectedDepartmentId, projects])

  return (
    <div className="flex flex-col gap-5">
      {linkedTask && <TaskDetailDialog task={linkedTask} open onOpenChange={(open) => { if (!open) { searchParams.delete("task"); setSearchParams(searchParams, { replace: true }) } }} />}
      <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between"><PageHeader icon={CheckSquare} tone="secondary" title="تسک‌ها" description="وظیفه، ساعت مصرف‌شده و تأیید مدیر در یک مسیر" />{projects && users && <NewTaskDialog projects={projects} users={users} />}</div>
      <div className="grid grid-cols-2 gap-1 rounded-xl border border-border/70 bg-muted/40 p-1 sm:inline-flex sm:w-fit">
        <button className={`rounded-lg px-4 py-2.5 text-sm font-medium ${tab === "self_created" ? "bg-card shadow-sm" : "text-muted-foreground"}`} onClick={() => setTab("self_created")}>ساخته‌شده توسط من</button>
        {/* An org_admin oversees every task in the organization already, so a
            personal "assigned to me" view doesn't add anything meaningful. */}
        {!isOrgAdmin && <button className={`rounded-lg px-4 py-2.5 text-sm font-medium ${tab === "assigned_to_me" ? "bg-card shadow-sm" : "text-muted-foreground"}`} onClick={() => setTab("assigned_to_me")}>محول‌شده به من</button>}
        {canReview && <button className={`col-span-2 rounded-lg px-4 py-2.5 text-sm font-medium ${tab === "pending" ? "bg-warning/15 text-warning" : "text-muted-foreground"}`} onClick={() => setTab("pending")}>در انتظار تأیید من</button>}
      </div>
      {tab !== "pending" && <div className="flex flex-wrap gap-2"><button className={`rounded-full border px-3 py-1 text-xs ${status === "all" ? "border-primary bg-primary/10 text-primary" : "border-border"}`} onClick={() => setStatus("all")}>همه</button>{ACTIVE_STATUS_COLUMNS.map((column) => <button key={column.value} className={`rounded-full border px-3 py-1 text-xs ${status === column.value ? "border-primary bg-primary/10 text-primary" : "border-border"}`} onClick={() => setStatus(column.value)}>{column.label}</button>)}</div>}
      <Card className="border-border/70"><CardContent className="flex flex-col gap-3 pt-5 lg:flex-row"><div className="relative flex-1"><Search className="absolute start-3 top-1/2 size-4 -translate-y-1/2 text-muted-foreground" /><Input value={search} onChange={(event) => setSearch(event.target.value)} placeholder="جست‌وجوی تسک..." aria-label="جست‌وجوی تسک" className="ps-9" /></div><Select aria-label="فیلتر پروژه" value={projectId} onChange={(event) => setProjectId(event.target.value)}><option value="">همهٔ پروژه‌ها</option>{projects?.map((project) => <option key={project.id} value={project.id}>{project.name}</option>)}</Select><Select aria-label="فیلتر ارزش تسک" value={value} onChange={(event) => setValue(event.target.value)}><option value="">همهٔ ارزش‌ها</option><option value="high">{VALUE_LABEL.high}</option><option value="medium">{VALUE_LABEL.medium}</option><option value="low">{VALUE_LABEL.low}</option></Select></CardContent></Card>
      {isLoading && <div className="grid grid-cols-1 gap-3 sm:grid-cols-2 xl:grid-cols-3">{Array.from({ length: 6 }, (_, i) => <Card key={i}><CardContent className="flex flex-col gap-3 pt-5"><Skeleton className="h-4 w-2/3" /><Skeleton className="h-4 w-1/2" /><Skeleton className="h-8 w-full" /></CardContent></Card>)}</div>}
      {!isLoading && visible.length === 0 && <EmptyState message={tab === "pending" ? "تسکی در انتظار تأیید شما نیست." : tab === "assigned_to_me" ? "هنوز کسی تسکی به شما محول نکرده است." : "تسکی در این بخش نیست."} />}
      {!isLoading && visible.length > 0 && users && <div className="grid grid-cols-1 gap-3 sm:grid-cols-2 xl:grid-cols-3">{visible.map((task) => <TaskWorkflowCard key={task.id} task={task} users={users} projectName={projects?.find((project) => project.id === task.project_id)?.name} />)}</div>}
      {tab === "pending" && <ReviewQueue />}
    </div>
  )
}
