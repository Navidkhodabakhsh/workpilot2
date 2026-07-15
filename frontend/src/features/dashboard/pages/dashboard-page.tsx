import { useQuery } from "@tanstack/react-query"
import { Bar, BarChart, CartesianGrid, Cell, LabelList, ResponsiveContainer, Tooltip, XAxis, YAxis } from "recharts"
import { CheckCircle2, ClipboardList, Clock, FolderKanban } from "lucide-react"

import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { EmptyState } from "@/components/ui/empty-state"
import { getDashboardSummary } from "@/features/dashboard/api"
import type { StatusCount } from "@/features/dashboard/api"

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
  in_review: "در بازبینی",
  done: "انجام‌شده",
  blocked: "معطل",
}
const STATUS_COLOR: Record<string, string> = {
  todo: "var(--color-muted-foreground)",
  in_progress: "var(--color-info)",
  in_review: "var(--color-warning)",
  done: "var(--color-success)",
  blocked: "var(--color-danger)",
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
}: {
  icon: typeof FolderKanban
  label: string
  value: string | number
  tone: "primary" | "secondary" | "info" | "success"
}) {
  return (
    <Card>
      <CardContent className="flex items-center gap-3 pt-6">
        <div className={`flex size-11 shrink-0 items-center justify-center rounded-full ${STAT_TONE_CLASS[tone]}`}>
          <Icon className="size-5" />
        </div>
        <div>
          <p className="text-2xl font-bold">{value}</p>
          <p className="text-sm text-muted-foreground">{label}</p>
        </div>
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

export function DashboardPage() {
  const { data, isLoading, isError } = useQuery({ queryKey: ["dashboard-summary"], queryFn: getDashboardSummary })

  if (isLoading) {
    return <p className="text-muted-foreground">در حال بارگذاری داشبورد...</p>
  }
  if (isError || !data) {
    return <p className="text-danger">اتصال به سرور برقرار نشد</p>
  }

  const doneCount = data.tasks_by_status.find((s) => s.status === "done")?.count ?? 0
  const chartData = taskStatusChartData(data.tasks_by_status)

  return (
    <div className="flex flex-col gap-4">
      <div>
        <h1 className="text-2xl font-bold">داشبورد</h1>
        <p className="text-muted-foreground">نمای کلی از فعالیت‌ها و پروژه‌ها</p>
      </div>

      <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
        <StatCard icon={FolderKanban} label="پروژه‌های فعال" value={data.project_count} tone="primary" />
        <StatCard icon={ClipboardList} label="کل وظایف" value={data.task_count} tone="secondary" />
        <StatCard icon={Clock} label="ساعات کاری تأییدشده" value={data.total_approved_hours} tone="info" />
        <StatCard icon={CheckCircle2} label="وظایف انجام‌شده" value={doneCount} tone="success" />
      </div>

      <div className="grid grid-cols-1 gap-4 lg:grid-cols-2">
        <Card>
          <CardHeader>
            <CardTitle className="text-base">وضعیت وظایف</CardTitle>
          </CardHeader>
          <CardContent>
            {chartData.length === 0 ? (
              <EmptyState className="h-[220px]" message="هنوز وظیفه‌ای ثبت نشده است." />
            ) : (
              <ResponsiveContainer width="100%" height={220}>
                <BarChart data={chartData}>
                  <CartesianGrid strokeDasharray="3 3" vertical={false} />
                  <XAxis dataKey="name" tick={{ fontSize: 12 }} />
                  <YAxis allowDecimals={false} tick={{ fontSize: 12 }} />
                  <Tooltip />
                  <Bar dataKey="value" radius={[4, 4, 0, 0]}>
                    <LabelList dataKey="value" position="top" style={{ fontSize: 12 }} />
                    {chartData.map((entry) => (
                      <Cell key={entry.name} fill={entry.color} />
                    ))}
                  </Bar>
                </BarChart>
              </ResponsiveContainer>
            )}
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle className="text-base">ساعات کاری اعضای تیم</CardTitle>
          </CardHeader>
          <CardContent>
            {data.team_hours.length === 0 ? (
              <EmptyState className="h-[220px]" message="هنوز گزارش کاری تأییدشده‌ای وجود ندارد." />
            ) : (
              <ResponsiveContainer width="100%" height={220}>
                <BarChart data={[...data.team_hours].sort((a, b) => b.approved_hours - a.approved_hours)}>
                  <CartesianGrid strokeDasharray="3 3" vertical={false} />
                  <XAxis dataKey="full_name" tick={{ fontSize: 12 }} />
                  <YAxis tick={{ fontSize: 12 }} />
                  <Tooltip />
                  <Bar dataKey="approved_hours" radius={[4, 4, 0, 0]}>
                    <LabelList dataKey="approved_hours" position="top" style={{ fontSize: 12 }} />
                    {data.team_hours.map((entry, index) => (
                      <Cell key={entry.user_id} fill={TEAM_MEMBER_COLORS[index % TEAM_MEMBER_COLORS.length]} />
                    ))}
                  </Bar>
                </BarChart>
              </ResponsiveContainer>
            )}
          </CardContent>
        </Card>
      </div>

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
