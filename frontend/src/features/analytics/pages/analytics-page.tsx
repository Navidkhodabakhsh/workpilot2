import { useState, type ReactElement, type ReactNode } from "react"
import { useQuery } from "@tanstack/react-query"
import {
  Area,
  AreaChart,
  Bar,
  BarChart,
  CartesianGrid,
  Cell,
  LabelList,
  Legend,
  Pie,
  PieChart,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from "recharts"

import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { EmptyState } from "@/components/ui/empty-state"
import { Select } from "@/components/ui/select"
import { groupApprovedHoursByProject } from "@/features/analytics/group-by-project"
import { projectStatusBreakdown, worklogStatusBreakdown } from "@/features/analytics/breakdown-utils"
import { getWorklogReport, getWorklogTrend } from "@/features/reports/api"
import { listProjects } from "@/features/projects/api"

const PROJECT_COLORS = [
  "var(--color-primary)",
  "var(--color-secondary)",
  "var(--color-info)",
  "var(--color-warning)",
  "var(--color-success)",
]

const WORKLOG_STATUS_COLORS = ["var(--color-muted-foreground)", "var(--color-warning)", "var(--color-success)", "var(--color-danger)"]
const PROJECT_STATUS_COLORS = ["var(--color-info)", "var(--color-success)", "var(--color-muted-foreground)"]

function ChartCard({
  title,
  description,
  isLoading,
  isEmpty,
  emptyMessage,
  action,
  children,
}: {
  title: string
  description?: string
  isLoading: boolean
  isEmpty: boolean
  emptyMessage: string
  action?: ReactNode
  children: ReactElement
}) {
  return (
    <Card className="overflow-hidden">
      <CardHeader className="flex flex-row items-start justify-between gap-2">
        <div>
          <CardTitle className="text-base">{title}</CardTitle>
          {description && <p className="mt-1 text-xs text-muted-foreground">{description}</p>}
        </div>
        {action}
      </CardHeader>
      <CardContent>
        {isLoading && <p className="text-muted-foreground">در حال بارگذاری...</p>}
        {!isLoading && isEmpty && <EmptyState className="h-[240px]" message={emptyMessage} />}
        {!isLoading && !isEmpty && (
          <ResponsiveContainer width="100%" height={260}>
            {children}
          </ResponsiveContainer>
        )}
      </CardContent>
    </Card>
  )
}

export function AnalyticsPage() {
  const [groupBy, setGroupBy] = useState<"week" | "month">("week")

  const { data: trend, isLoading: isTrendLoading } = useQuery({
    queryKey: ["worklog-trend", groupBy],
    queryFn: () => getWorklogTrend(groupBy),
  })
  const { data: report, isLoading: isReportLoading } = useQuery({
    queryKey: ["worklog-report", "analytics"],
    queryFn: () => getWorklogReport({}),
  })
  const { data: projects, isLoading: isProjectsLoading } = useQuery({
    queryKey: ["projects", "analytics"],
    queryFn: listProjects,
  })

  const projectHours = report ? groupApprovedHoursByProject(report.items) : []
  const worklogStatuses = report ? worklogStatusBreakdown(report.items) : []
  const projectStatuses = projects ? projectStatusBreakdown(projects) : []

  return (
    <div className="flex flex-col gap-4">
      <div>
        <h1 className="text-2xl font-bold">تحلیل‌ها</h1>
        <p className="text-muted-foreground">روند ساعات کاری، مقایسهٔ پروژه‌ها و وضعیت گزارش‌های کاری</p>
      </div>

      <div className="grid grid-cols-1 gap-4 lg:grid-cols-2">
        <ChartCard
          title="روند ساعات کاری تأییدشده"
          description="مجموع ساعات کاری تأییدشده در بازه‌های زمانی اخیر"
          isLoading={isTrendLoading}
          isEmpty={!trend || trend.items.length === 0}
          emptyMessage="هنوز داده‌ای برای نمایش روند وجود ندارد."
          action={
            <Select value={groupBy} onChange={(e) => setGroupBy(e.target.value as "week" | "month")} className="h-9 w-28">
              <option value="week">هفتگی</option>
              <option value="month">ماهانه</option>
            </Select>
          }
        >
          <AreaChart data={trend?.items ?? []}>
            <defs>
              <linearGradient id="trendGradient" x1="0" y1="0" x2="0" y2="1">
                <stop offset="5%" stopColor="var(--color-primary)" stopOpacity={0.45} />
                <stop offset="95%" stopColor="var(--color-primary)" stopOpacity={0.03} />
              </linearGradient>
            </defs>
            <CartesianGrid strokeDasharray="3 3" vertical={false} />
            <XAxis
              dataKey="period"
              tick={{ fontSize: 12 }}
              tickFormatter={(v) => new Date(v).toLocaleDateString("fa-IR")}
            />
            <YAxis tick={{ fontSize: 12 }} />
            <Tooltip labelFormatter={(v) => new Date(v).toLocaleDateString("fa-IR")} />
            <Area
              type="monotone"
              dataKey="approved_hours"
              name="ساعت کاری"
              stroke="var(--color-primary)"
              strokeWidth={2}
              fill="url(#trendGradient)"
              animationDuration={700}
            />
          </AreaChart>
        </ChartCard>

        <ChartCard
          title="مقایسهٔ ساعات کاری بین پروژه‌ها"
          description="مجموع ساعات کاری تأییدشدهٔ هر پروژه"
          isLoading={isReportLoading}
          isEmpty={projectHours.length === 0}
          emptyMessage="هنوز گزارش کاری تأییدشده‌ای وجود ندارد."
        >
          <BarChart data={projectHours} layout="vertical" margin={{ left: 12 }}>
            <CartesianGrid strokeDasharray="3 3" horizontal={false} />
            <XAxis type="number" tick={{ fontSize: 12 }} />
            <YAxis type="category" dataKey="project_name" width={110} tick={{ fontSize: 12 }} />
            <Tooltip />
            <Bar dataKey="approved_hours" radius={[0, 6, 6, 0]} maxBarSize={26} animationDuration={700}>
              <LabelList dataKey="approved_hours" position="right" style={{ fontSize: 12 }} />
              {projectHours.map((entry, index) => (
                <Cell key={entry.project_name} fill={PROJECT_COLORS[index % PROJECT_COLORS.length]} />
              ))}
            </Bar>
          </BarChart>
        </ChartCard>

        <ChartCard
          title="وضعیت گزارش‌های کاری"
          description="سهم هر وضعیت از کل گزارش‌های کاری ثبت‌شده"
          isLoading={isReportLoading}
          isEmpty={worklogStatuses.length === 0}
          emptyMessage="هنوز گزارش کاری‌ای ثبت نشده است."
        >
          <PieChart>
            <Pie
              data={worklogStatuses}
              dataKey="value"
              nameKey="name"
              innerRadius={55}
              outerRadius={90}
              paddingAngle={2}
              animationDuration={700}
              label={({ name, value }) => `${name}: ${value}`}
            >
              {worklogStatuses.map((entry, index) => (
                <Cell key={entry.name} fill={WORKLOG_STATUS_COLORS[index % WORKLOG_STATUS_COLORS.length]} />
              ))}
            </Pie>
            <Tooltip />
            <Legend />
          </PieChart>
        </ChartCard>

        <ChartCard
          title="وضعیت پروژه‌ها"
          description="سهم هر وضعیت از کل پروژه‌های سازمان"
          isLoading={isProjectsLoading}
          isEmpty={projectStatuses.length === 0}
          emptyMessage="هنوز پروژه‌ای ثبت نشده است."
        >
          <PieChart>
            <Pie
              data={projectStatuses}
              dataKey="value"
              nameKey="name"
              innerRadius={55}
              outerRadius={90}
              paddingAngle={2}
              animationDuration={700}
              label={({ name, value }) => `${name}: ${value}`}
            >
              {projectStatuses.map((entry, index) => (
                <Cell key={entry.name} fill={PROJECT_STATUS_COLORS[index % PROJECT_STATUS_COLORS.length]} />
              ))}
            </Pie>
            <Tooltip />
            <Legend />
          </PieChart>
        </ChartCard>
      </div>
    </div>
  )
}
