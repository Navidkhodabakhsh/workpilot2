import type { ReactElement } from "react"
import { useQuery } from "@tanstack/react-query"
import { Link } from "react-router-dom"
import {
  Area,
  AreaChart,
  Bar,
  BarChart,
  CartesianGrid,
  Cell,
  LabelList,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from "recharts"
import { CheckCircle2, ClipboardList, Clock, FolderKanban, Users } from "lucide-react"

import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { EmptyState } from "@/components/ui/empty-state"
import { getDashboardSummary } from "@/features/dashboard/api"
import type { StatusCount } from "@/features/dashboard/api"
import { hoursByProject, projectProgress, userProductivity, weeklyActivity } from "@/features/dashboard/chart-utils"
import { listOrgUsers } from "@/features/users/api"
import { listProjects } from "@/features/projects/api"
import { listAllTasks } from "@/features/tasks/api"
import { getWorklogReport } from "@/features/reports/api"
import { useAuthStore } from "@/features/auth/auth-store"

const TEAM_MEMBER_COLORS = [
  "var(--color-primary)",
  "var(--color-secondary)",
  "var(--color-info)",
  "var(--color-warning)",
  "var(--color-success)",
]

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
      <div className={`flex size-11 shrink-0 items-center justify-center rounded-full ${STAT_TONE_CLASS[tone]}`}>
        <Icon className="size-5" />
      </div>
      <div>
        <p className="text-2xl font-bold">{value}</p>
        <p className="text-sm text-muted-foreground">{label}</p>
      </div>
    </CardContent>
  )

  if (to) {
    return (
      <Link to={to}>
        <Card className="transition-shadow hover:shadow-md">{content}</Card>
      </Link>
    )
  }
  return <Card>{content}</Card>
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
  children,
}: {
  title: string
  isLoading: boolean
  isEmpty: boolean
  emptyMessage: string
  height: number
  children: ReactElement
}) {
  return (
    <Card className="overflow-hidden">
      <CardHeader>
        <CardTitle className="text-base">{title}</CardTitle>
      </CardHeader>
      <CardContent>
        {isLoading && <EmptyState className="h-[240px]" message="در حال بارگذاری..." />}
        {!isLoading && isEmpty && <EmptyState className="h-[220px]" message={emptyMessage} />}
        {!isLoading && !isEmpty && (
          <ResponsiveContainer width="100%" height={height}>
            {children}
          </ResponsiveContainer>
        )}
      </CardContent>
    </Card>
  )
}

function ProductivityTooltip({ active, payload }: any) {
  if (!active || !payload?.length) return null
  const p = payload[0].payload
  return (
    <div className="rounded-lg border border-border bg-card px-3 py-2 text-xs shadow-md">
      <p className="mb-1 font-medium">{p.full_name}</p>
      <p>ساعت کاری: {p.hours}</p>
      <p>تعداد وظایف: {p.task_count}</p>
      <p>درصد تکمیل: {p.completion_percent}٪</p>
    </div>
  )
}

export function DashboardPage() {
  const isOrgAdmin = useAuthStore((s) => s.user?.role === "org_admin")
  const { data, isLoading, isError } = useQuery({ queryKey: ["dashboard-summary"], queryFn: getDashboardSummary })
  const { data: orgUsers } = useQuery({ queryKey: ["org-users"], queryFn: listOrgUsers })
  const { data: projects } = useQuery({ queryKey: ["projects", "dashboard"], queryFn: listProjects })
  const { data: tasks } = useQuery({ queryKey: ["tasks", "dashboard-all"], queryFn: () => listAllTasks() })
  const { data: worklogReport, isLoading: isReportLoading } = useQuery({
    queryKey: ["worklog-report", "dashboard"],
    queryFn: () => getWorklogReport({}),
  })

  if (isLoading) {
    return <p className="text-muted-foreground">در حال بارگذاری داشبورد...</p>
  }
  if (isError || !data) {
    return <p className="text-danger">اتصال به سرور برقرار نشد</p>
  }

  const doneCount = data.tasks_by_status.find((s) => s.status === "completed")?.count ?? 0
  const chartData = taskStatusChartData(data.tasks_by_status)
  const teamHoursData = [...data.team_hours].sort((a, b) => b.approved_hours - a.approved_hours)
  const projectHours = worklogReport ? hoursByProject(worklogReport.items) : []
  const productivity =
    worklogReport && tasks && orgUsers
      ? userProductivity(worklogReport.items, tasks, orgUsers).slice(0, 8)
      : []
  const activity = worklogReport ? weeklyActivity(worklogReport.items) : []
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
          <StatCard icon={Clock} label="ساعات کاری تأییدشده" value={data.total_approved_hours} tone="info" to="/reports" />
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
              <CartesianGrid strokeDasharray="3 3" vertical={false} />
              <XAxis dataKey="name" tick={{ fontSize: 12 }} />
              <YAxis allowDecimals={false} tick={{ fontSize: 12 }} />
              <Tooltip />
              <Bar dataKey="value" radius={[6, 6, 0, 0]} animationDuration={700}>
                <LabelList dataKey="value" position="top" style={{ fontSize: 12 }} />
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
            height={240}
          >
            <BarChart data={teamHoursData} layout="vertical" margin={{ left: 12 }}>
              <CartesianGrid strokeDasharray="3 3" horizontal={false} />
              <XAxis type="number" tick={{ fontSize: 12 }} />
              <YAxis type="category" dataKey="full_name" width={90} tick={{ fontSize: 12 }} />
              <Tooltip />
              <Bar dataKey="approved_hours" radius={[0, 6, 6, 0]} maxBarSize={26} animationDuration={700}>
                <LabelList dataKey="approved_hours" position="right" style={{ fontSize: 12 }} />
                {teamHoursData.map((entry, index) => (
                  <Cell key={entry.user_id} fill={TEAM_MEMBER_COLORS[index % TEAM_MEMBER_COLORS.length]} />
                ))}
              </Bar>
            </BarChart>
          </ChartCard>

          <ChartCard
            title="ساعات ثبت‌شده به تفکیک پروژه"
            isLoading={isReportLoading}
            isEmpty={projectHours.length === 0}
            emptyMessage="هنوز گزارش کاری تأییدشده‌ای وجود ندارد."
            height={240}
          >
            <BarChart data={projectHours} layout="vertical" margin={{ left: 12 }}>
              <CartesianGrid strokeDasharray="3 3" horizontal={false} />
              <XAxis type="number" tick={{ fontSize: 12 }} />
              <YAxis type="category" dataKey="project_name" width={110} tick={{ fontSize: 12 }} />
              <Tooltip />
              <Bar dataKey="hours" fill="var(--color-info)" radius={[0, 6, 6, 0]} maxBarSize={26} animationDuration={700}>
                <LabelList dataKey="hours" position="right" style={{ fontSize: 12 }} />
              </Bar>
            </BarChart>
          </ChartCard>

          <ChartCard
            title="بهره‌وری کاربران"
            isLoading={isReportLoading}
            isEmpty={productivity.length === 0}
            emptyMessage="هنوز داده‌ای برای بهره‌وری وجود ندارد."
            height={240}
          >
            <BarChart data={productivity} layout="vertical" margin={{ left: 12 }}>
              <CartesianGrid strokeDasharray="3 3" horizontal={false} />
              <XAxis type="number" tick={{ fontSize: 12 }} />
              <YAxis type="category" dataKey="full_name" width={90} tick={{ fontSize: 12 }} />
              <Tooltip content={<ProductivityTooltip />} />
              <Bar dataKey="hours" fill="var(--color-secondary)" radius={[0, 6, 6, 0]} maxBarSize={26} animationDuration={700}>
                {productivity.map((entry, index) => (
                  <Cell key={entry.user_id} fill={TEAM_MEMBER_COLORS[index % TEAM_MEMBER_COLORS.length]} />
                ))}
              </Bar>
            </BarChart>
          </ChartCard>

          <ChartCard
            title="فعالیت هفتگی تیم"
            isLoading={isReportLoading}
            isEmpty={activity.length === 0}
            emptyMessage="هنوز فعالیتی برای نمایش روند هفتگی وجود ندارد."
            height={240}
          >
            <AreaChart data={activity}>
              <defs>
                <linearGradient id="activityGradient" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="5%" stopColor="var(--color-primary)" stopOpacity={0.4} />
                  <stop offset="95%" stopColor="var(--color-primary)" stopOpacity={0.02} />
                </linearGradient>
              </defs>
              <CartesianGrid strokeDasharray="3 3" vertical={false} />
              <XAxis
                dataKey="week_start"
                tick={{ fontSize: 12 }}
                tickFormatter={(v) => new Date(v).toLocaleDateString("fa-IR")}
              />
              <YAxis allowDecimals={false} tick={{ fontSize: 12 }} />
              <Tooltip labelFormatter={(v) => new Date(v).toLocaleDateString("fa-IR")} />
              <Area
                type="monotone"
                dataKey="active_users"
                name="کاربران فعال"
                stroke="var(--color-primary)"
                fill="url(#activityGradient)"
                strokeWidth={2}
                animationDuration={700}
              />
            </AreaChart>
          </ChartCard>

          <ChartCard
            title="روند پیشرفت پروژه‌ها"
            isLoading={false}
            isEmpty={progress.length === 0}
            emptyMessage="هنوز داده‌ای برای پیشرفت پروژه‌ها وجود ندارد."
            height={240}
          >
            <BarChart data={progress} layout="vertical" margin={{ left: 12 }}>
              <CartesianGrid strokeDasharray="3 3" horizontal={false} />
              <XAxis type="number" domain={[0, 100]} tick={{ fontSize: 12 }} />
              <YAxis type="category" dataKey="project_name" width={110} tick={{ fontSize: 12 }} />
              <Tooltip formatter={(v) => `${v}٪`} />
              <Bar dataKey="percent" fill="var(--color-success)" radius={[0, 6, 6, 0]} maxBarSize={26} animationDuration={700}>
                <LabelList dataKey="percent" position="right" formatter={(v) => `${v}٪`} style={{ fontSize: 12 }} />
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
