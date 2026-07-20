import type { ReactElement, ReactNode } from "react"
import { useQuery } from "@tanstack/react-query"
import { Link } from "react-router-dom"
import { Bar, BarChart, Cell, ResponsiveContainer, Tooltip, XAxis, YAxis } from "recharts"
import { CheckCircle2, ClipboardList, Clock, FolderKanban, Users } from "lucide-react"

import { AnimatedNumber } from "@/components/ui/animated-number"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { EmptyState } from "@/components/ui/empty-state"
import { Skeleton } from "@/components/ui/skeleton"
import { getDashboardSummary } from "@/features/dashboard/api"
import type { StatusCount } from "@/features/dashboard/api"
import { hoursByProject, projectProgress } from "@/features/dashboard/chart-utils"
import { HorizontalBarList } from "@/features/dashboard/components/horizontal-bar-list"
import { listOrgUsers } from "@/features/users/api"
import { listProjects } from "@/features/projects/api"
import { listAllTasks } from "@/features/tasks/api"
import { getWorklogReport } from "@/features/reports/api"
import { useAuthStore } from "@/features/auth/auth-store"
import { useDepartmentStore } from "@/features/departments/department-store"

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

export function DashboardPage() {
  const isOrgAdmin = useAuthStore((s) => s.user?.role === "org_admin")
  const selectedDepartmentId = useDepartmentStore((s) => s.selectedDepartmentId)
  const { data, isLoading, isError } = useQuery({
    queryKey: ["dashboard-summary", selectedDepartmentId],
    queryFn: () => getDashboardSummary(selectedDepartmentId),
  })
  const { data: orgUsers } = useQuery({ queryKey: ["org-users"], queryFn: listOrgUsers })
  const { data: projects } = useQuery({ queryKey: ["projects", "dashboard"], queryFn: listProjects })
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
  const teamHoursData = [...data.team_hours].sort((a, b) => b.approved_hours - a.approved_hours)
  const projectHours = worklogReport ? hoursByProject(worklogReport.items) : []
  const progress = tasks && projects ? projectProgress(tasks, projects).slice(0, 8) : []

  return (
    <div className="flex flex-col gap-6">
      <div>
        <h1 className="text-2xl font-bold">داشبورد</h1>
        <p className="text-muted-foreground">نمای کلی از فعالیت‌ها و پروژه‌ها</p>
      </div>

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
            height={240}
          >
            <BarChart data={chartData}>
              <XAxis dataKey="name" hide />
              <YAxis allowDecimals={false} hide />
              <Tooltip />
              <Bar dataKey="value" radius={[6, 6, 0, 0]} animationDuration={700}>
                {chartData.map((entry) => (
                  <Cell key={entry.name} fill={entry.color} />
                ))}
              </Bar>
            </BarChart>
          </ChartCard>

          <ChartCard
            title="مقایسهٔ ساعات کاری اعضای تیم"
            isLoading={false}
            isEmpty={teamHoursData.length === 0}
            emptyMessage="هنوز گزارش کاری تأییدشده‌ای وجود ندارد."
            plain
          >
            <HorizontalBarList
              items={teamHoursData.map((t) => ({
                id: t.user_id,
                label: t.full_name,
                value: t.approved_hours,
                displayValue: String(t.approved_hours),
              }))}
            />
          </ChartCard>

          <ChartCard
            title="ساعات ثبت‌شده به تفکیک پروژه"
            isLoading={isReportLoading}
            isEmpty={projectHours.length === 0}
            emptyMessage="هنوز گزارش کاری تأییدشده‌ای وجود ندارد."
            plain
          >
            <HorizontalBarList
              items={projectHours.map((p) => ({
                id: p.project_id,
                label: p.project_name,
                value: p.hours,
                displayValue: String(p.hours),
              }))}
            />
          </ChartCard>

          <ChartCard
            title="روند پیشرفت پروژه‌ها"
            isLoading={false}
            isEmpty={progress.length === 0}
            emptyMessage="هنوز داده‌ای برای پیشرفت پروژه‌ها وجود ندارد."
            plain
          >
            <HorizontalBarList
              items={progress.map((p) => ({
                id: p.project_id,
                label: p.project_name,
                value: p.percent,
                displayValue: `${p.percent}٪`,
              }))}
            />
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
