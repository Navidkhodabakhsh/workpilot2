import type { ReactElement, ReactNode } from "react"
import { useQuery } from "@tanstack/react-query"
import { Link } from "react-router-dom"
import { Area, AreaChart, Bar, BarChart, Cell, Pie, PieChart, ResponsiveContainer, Tooltip, XAxis, YAxis } from "recharts"
import { CheckCircle2, ClipboardList, Clock, FolderKanban, LayoutDashboard, ListChecks, Users } from "lucide-react"

import { PageHeader } from "@/components/layout/page-header"
import { AnimatedNumber } from "@/components/ui/animated-number"
import { Badge } from "@/components/ui/badge"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { EmptyState } from "@/components/ui/empty-state"
import { Skeleton } from "@/components/ui/skeleton"
import { getDashboardSummary } from "@/features/dashboard/api"
import type { StatusCount } from "@/features/dashboard/api"
import { hoursByProject } from "@/features/dashboard/chart-utils"
import { listOrgUsers } from "@/features/users/api"
import { listAllTasks } from "@/features/tasks/api"
import { getWorklogReport } from "@/features/reports/api"
import { PRIORITY_LABEL, PRIORITY_VARIANT } from "@/features/tasks/constants"
import { useAuthStore } from "@/features/auth/auth-store"
import { useDepartmentStore } from "@/features/departments/department-store"
import { toPersianDigits } from "@/lib/jalali"

const STATUS_LABEL: Record<string, string> = {
  todo: "برای انجام",
  in_progress: "در حال انجام",
  completed: "تکمیل‌شده",
  archived: "بایگانی‌شده",
}
const STATUS_COLOR: Record<string, string> = {
  todo: "var(--color-muted-foreground)",
  in_progress: "var(--color-info)",
  completed: "var(--color-success)",
  archived: "var(--color-danger)",
}
const WORKLOG_STATUS_LABEL: Record<string, string> = {
  draft: "پیش‌نویس",
  submitted: "در انتظار تأیید",
  approved: "تأییدشده",
  rejected: "ردشده",
}

// Same fixed, validated categorical order used across the dashboard's
// per-item colored charts (roadmap, project-hours bars) -- validated with
// the dataviz skill's CVD checker; every row also carries a direct label
// (name + value), so identity never depends on color alone.
const CATEGORICAL_COLORS = [
  "var(--color-primary)",
  "var(--color-success)",
  "var(--color-leave)",
  "var(--color-warning)",
  "var(--color-danger)",
]

const STAT_TONE_CLASS: Record<string, string> = {
  primary: "bg-primary/10 text-primary",
  secondary: "bg-secondary/10 text-secondary",
  info: "bg-info/10 text-info",
  success: "bg-success/10 text-success",
}

function StatCard({
  icon: Icon,
  label,
  value,
  tone,
  to,
}: {
  icon: typeof FolderKanban
  label: string
  value: string | number
  tone: "primary" | "secondary" | "info" | "success"
  to?: string
}) {
  const content = (
    <CardContent className="flex items-center gap-3 pt-6">
      <div
        className={`flex size-11 shrink-0 items-center justify-center rounded-full transition-transform group-hover:scale-105 ${STAT_TONE_CLASS[tone]}`}
      >
        <Icon className="size-5" />
      </div>
      <div>
        <p className="text-2xl font-bold tabular-nums">
          {typeof value === "number" ? <AnimatedNumber value={value} /> : value}
        </p>
        <p className="text-sm text-muted-foreground">{label}</p>
      </div>
    </CardContent>
  )

  if (to) {
    return (
      <Link to={to}>
        <Card className="group transition-all duration-200 hover:-translate-y-0.5 hover:shadow-md">{content}</Card>
      </Link>
    )
  }
  return <Card>{content}</Card>
}

function StatCardSkeleton() {
  return (
    <Card>
      <CardContent className="flex items-center gap-3 pt-6">
        <Skeleton className="size-11 shrink-0 rounded-full" />
        <div className="flex flex-1 flex-col gap-2">
          <Skeleton className="h-6 w-16" />
          <Skeleton className="h-3.5 w-24" />
        </div>
      </CardContent>
    </Card>
  )
}

function ChartCardSkeleton() {
  return (
    <Card className="overflow-hidden">
      <CardHeader>
        <Skeleton className="h-4 w-32" />
      </CardHeader>
      <CardContent className="flex flex-col gap-3">
        {Array.from({ length: 5 }, (_, i) => (
          <div key={i} className="flex items-center gap-3">
            <Skeleton className="h-3.5 w-20 shrink-0" />
            <Skeleton className="h-2.5 flex-1" />
          </div>
        ))}
      </CardContent>
    </Card>
  )
}

function taskStatusChartData(tasksByStatus: StatusCount[]) {
  return tasksByStatus
    .map((s) => ({
      name: STATUS_LABEL[s.status] ?? s.status,
      value: s.count,
      color: STATUS_COLOR[s.status] ?? "var(--color-muted-foreground)",
    }))
    .sort((a, b) => b.value - a.value)
}

function SectionLabel({ children }: { children: string }) {
  return <h2 className="text-xs font-semibold tracking-wide text-muted-foreground uppercase">{children}</h2>
}

function ChartCard({
  title,
  isLoading,
  isEmpty,
  emptyMessage,
  height,
  plain,
  children,
}: {
  title: string
  isLoading: boolean
  isEmpty: boolean
  emptyMessage: string
  height?: number
  plain?: boolean
  children: ReactNode
}) {
  return (
    <Card className="overflow-hidden">
      <CardHeader>
        <CardTitle className="text-base">{title}</CardTitle>
      </CardHeader>
      <CardContent>
        {isLoading && <EmptyState className="h-[240px]" message="در حال بارگذاری..." />}
        {!isLoading && isEmpty && <EmptyState className="h-[220px]" message={emptyMessage} />}
        {!isLoading && !isEmpty && plain && children}
        {!isLoading && !isEmpty && !plain && (
          <ResponsiveContainer width="100%" height={height}>
            {children as ReactElement}
          </ResponsiveContainer>
        )}
      </CardContent>
    </Card>
  )
}

function TaskStatusDonut({ data }: { data: { name: string; value: number; color: string }[] }) {
  const total = data.reduce((sum, d) => sum + d.value, 0)
  return (
    <div className="flex flex-col items-center gap-4 sm:flex-row sm:justify-center">
      <div className="relative h-[190px] w-[190px] shrink-0">
        <ResponsiveContainer width="100%" height="100%">
          <PieChart>
            <Pie
              data={data}
              dataKey="value"
              nameKey="name"
              innerRadius="64%"
              outerRadius="100%"
              paddingAngle={3}
              cornerRadius={8}
              stroke="none"
              animationDuration={700}
            >
              {data.map((d) => (
                <Cell key={d.name} fill={d.color} />
              ))}
            </Pie>
            <Tooltip formatter={(value: any, name: any) => [toPersianDigits(value), name]} />
          </PieChart>
        </ResponsiveContainer>
        <div className="pointer-events-none absolute inset-0 flex flex-col items-center justify-center">
          <span className="text-2xl font-bold tabular-nums">
            <AnimatedNumber value={total} />
          </span>
          <span className="text-xs text-muted-foreground">کل وظایف</span>
        </div>
      </div>
      <div className="flex flex-col gap-2 self-stretch justify-center">
        {data.map((d) => (
          <div key={d.name} className="flex items-center gap-2 text-sm">
            <span className="size-2.5 shrink-0 rounded-full" style={{ backgroundColor: d.color }} />
            <span className="text-muted-foreground">{d.name}</span>
            <span className="ms-auto font-medium tabular-nums">{toPersianDigits(d.value)}</span>
          </div>
        ))}
      </div>
    </div>
  )
}

function TeamHoursTooltip({ active, payload }: any) {
  if (!active || !payload?.length) return null
  const p = payload[0].payload
  return (
    <div className="rounded-lg border border-border bg-card px-3 py-2 text-xs shadow-md">
      <p className="mb-1 font-medium">{p.full_name}</p>
      <p className="tabular-nums">{toPersianDigits(p.approved_hours)} ساعت</p>
    </div>
  )
}

function firstName(fullName: string): string {
  return fullName.trim().split(" ")[0] ?? fullName
}

export function DashboardPage() {
  const isOrgAdmin = useAuthStore((s) => s.user?.role === "org_admin")
  const selectedDepartmentId = useDepartmentStore((s) => s.selectedDepartmentId)
  const { data, isLoading, isError } = useQuery({
    queryKey: ["dashboard-summary", selectedDepartmentId],
    queryFn: () => getDashboardSummary(selectedDepartmentId),
  })
  const { data: orgUsers } = useQuery({ queryKey: ["org-users"], queryFn: listOrgUsers })
  const { data: tasks } = useQuery({ queryKey: ["tasks", "dashboard-all"], queryFn: () => listAllTasks() })
  const { data: worklogReport, isLoading: isReportLoading } = useQuery({
    queryKey: ["worklog-report", "dashboard"],
    queryFn: () => getWorklogReport({}),
  })

  if (isLoading) {
    return (
      <div className="flex flex-col gap-6">
        <div>
          <Skeleton className="h-8 w-32" />
          <Skeleton className="mt-2 h-4 w-64" />
        </div>
        <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
          {Array.from({ length: 4 }, (_, i) => (
            <StatCardSkeleton key={i} />
          ))}
        </div>
        <div className="grid grid-cols-1 gap-4 lg:grid-cols-2">
          {Array.from({ length: 4 }, (_, i) => (
            <ChartCardSkeleton key={i} />
          ))}
        </div>
      </div>
    )
  }
  if (isError || !data) {
    return <p className="text-danger">اتصال به سرور برقرار نشد</p>
  }

  const doneCount = data.tasks_by_status.find((s) => s.status === "completed")?.count ?? 0
  const chartData = taskStatusChartData(data.tasks_by_status)
  const teamHoursData = [...data.team_hours].sort((a, b) => b.approved_hours - a.approved_hours).slice(0, 8)
  const projectHours = worklogReport ? hoursByProject(worklogReport.items) : []

  const now = new Date()
  const todayIso = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, "0")}-${String(now.getDate()).padStart(2, "0")}`
  const todayTasks = (tasks ?? [])
    .filter((t) => t.deadline && t.deadline <= todayIso && t.status !== "completed" && t.status !== "archived")
    .sort((a, b) => (a.deadline! < b.deadline! ? -1 : 1))
    .slice(0, 5)

  return (
    <div className="flex flex-col gap-6">
      <PageHeader icon={LayoutDashboard} tone="primary" title="داشبورد" description="نمای کلی از فعالیت‌ها و پروژه‌ها" />

      <div className="flex flex-col gap-4">
        <SectionLabel>آمار کلی</SectionLabel>
        <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
          <StatCard icon={FolderKanban} label="پروژه‌های فعال" value={data.project_count} tone="primary" to="/projects" />
          <StatCard icon={ClipboardList} label="کل وظایف" value={data.task_count} tone="secondary" to="/tasks" />
          <StatCard icon={Clock} label="ساعات کاری تأییدشده" value={data.total_approved_hours} tone="info" to="/tasks" />
          {isOrgAdmin ? (
            <StatCard icon={Users} label="کاربران سازمان" value={orgUsers?.length ?? "…"} tone="success" to="/users" />
          ) : (
            <StatCard icon={CheckCircle2} label="وظایف انجام‌شده" value={doneCount} tone="success" to="/tasks" />
          )}
        </div>
      </div>

      <div className="border-t border-border" />

      <div className="flex flex-col gap-4">
        <SectionLabel>نمودارها</SectionLabel>

        <div className="grid grid-cols-1 gap-4 lg:grid-cols-2">
          <ChartCard
            title="وضعیت وظایف"
            isLoading={false}
            isEmpty={chartData.length === 0}
            emptyMessage="هنوز وظیفه‌ای ثبت نشده است."
            plain
          >
            <TaskStatusDonut data={chartData} />
          </ChartCard>

          <Card className="overflow-hidden">
            <CardHeader>
              <CardTitle className="flex items-center gap-2 text-base">
                <ListChecks className="size-4 text-primary" aria-hidden="true" />
                تسک‌های کلیدی امروز
              </CardTitle>
            </CardHeader>
            <CardContent>
              {todayTasks.length === 0 && <EmptyState className="h-[190px]" message="کاری برای امروز باقی نمانده است." />}
              {todayTasks.length > 0 && (
                <div className="flex flex-col gap-2.5">
                  {todayTasks.map((t) => {
                    const overdue = t.deadline! < todayIso
                    return (
                      <Link
                        key={t.id}
                        to="/tasks"
                        className="flex items-center gap-2.5 rounded-lg border border-border/70 p-2.5 text-sm transition-colors hover:bg-muted/50"
                      >
                        <span
                          className={`size-2 shrink-0 rounded-full ${overdue ? "bg-danger" : "bg-warning"}`}
                          aria-hidden="true"
                        />
                        <span className="flex-1 truncate font-medium">{t.title}</span>
                        <Badge variant={PRIORITY_VARIANT[t.priority]}>{PRIORITY_LABEL[t.priority]}</Badge>
                      </Link>
                    )
                  })}
                </div>
              )}
            </CardContent>
          </Card>

          <ChartCard
            title="مقایسهٔ ساعات کاری اعضای تیم"
            isLoading={false}
            isEmpty={teamHoursData.length === 0}
            emptyMessage="هنوز گزارش کاری تأییدشده‌ای وجود ندارد."
            height={260}
          >
            <AreaChart data={teamHoursData} margin={{ top: 8, left: 0, right: 8 }}>
              <defs>
                <linearGradient id="teamHoursGradient" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="5%" stopColor="var(--color-primary)" stopOpacity={0.4} />
                  <stop offset="95%" stopColor="var(--color-primary)" stopOpacity={0.02} />
                </linearGradient>
              </defs>
              <XAxis
                dataKey="full_name"
                tickFormatter={firstName}
                tick={{ fontSize: 11, fill: "var(--color-muted-foreground)" }}
                axisLine={false}
                tickLine={false}
                interval={0}
              />
              <YAxis hide />
              <Tooltip content={<TeamHoursTooltip />} />
              <Area
                type="monotone"
                dataKey="approved_hours"
                stroke="var(--color-primary)"
                strokeWidth={2.5}
                fill="url(#teamHoursGradient)"
                dot={{ r: 3, fill: "var(--color-primary)", strokeWidth: 0 }}
                activeDot={{ r: 5 }}
                animationDuration={700}
              />
            </AreaChart>
          </ChartCard>

          <ChartCard
            title="ساعات ثبت‌شده به تفکیک پروژه"
            isLoading={isReportLoading}
            isEmpty={projectHours.length === 0}
            emptyMessage="هنوز گزارش کاری تأییدشده‌ای وجود ندارد."
            height={260}
          >
            <BarChart data={projectHours} margin={{ top: 8, left: 0, right: 8 }}>
              <defs>
                {projectHours.map((p, i) => (
                  <linearGradient key={p.project_id} id={`projectHoursGradient-${i}`} x1="0" y1="0" x2="0" y2="1">
                    <stop offset="0%" stopColor={CATEGORICAL_COLORS[i % CATEGORICAL_COLORS.length]} stopOpacity={0.95} />
                    <stop offset="100%" stopColor={CATEGORICAL_COLORS[i % CATEGORICAL_COLORS.length]} stopOpacity={0.55} />
                  </linearGradient>
                ))}
              </defs>
              <XAxis
                dataKey="project_name"
                tickFormatter={(v: string) => (v.length > 8 ? `${v.slice(0, 8)}…` : v)}
                tick={{ fontSize: 11, fill: "var(--color-muted-foreground)" }}
                axisLine={false}
                tickLine={false}
                interval={0}
              />
              <YAxis hide />
              <Tooltip formatter={(v: any) => [`${toPersianDigits(v)} ساعت`, ""]} />
              <Bar dataKey="hours" radius={[8, 8, 0, 0]} animationDuration={700}>
                {projectHours.map((p, i) => (
                  <Cell key={p.project_id} fill={`url(#projectHoursGradient-${i})`} />
                ))}
              </Bar>
            </BarChart>
          </ChartCard>
        </div>
      </div>

      <div className="border-t border-border" />

      <Card>
        <CardHeader>
          <CardTitle className="text-base">آخرین فعالیت‌ها</CardTitle>
        </CardHeader>
        <CardContent className="flex flex-col gap-3">
          {data.recent_activity.length === 0 && (
            <p className="text-muted-foreground">هنوز فعالیتی ثبت نشده است.</p>
          )}
          {data.recent_activity.map((item) => (
            <div key={item.worklog_id} className="flex items-start justify-between gap-2 border-b border-border pb-2 last:border-0 last:pb-0">
              <div>
                <p className="text-sm">
                  <span className="font-medium">{item.user_full_name}</span> روی{" "}
                  <span className="font-medium">{item.task_title}</span> گزارش کار ثبت کرد
                </p>
                <span className="text-xs text-muted-foreground">
                  {WORKLOG_STATUS_LABEL[item.status] ?? item.status}
                </span>
              </div>
              <span className="shrink-0 text-xs text-muted-foreground">
                {new Date(item.created_at).toLocaleDateString("fa-IR")}
              </span>
            </div>
          ))}
        </CardContent>
      </Card>
    </div>
  )
}
