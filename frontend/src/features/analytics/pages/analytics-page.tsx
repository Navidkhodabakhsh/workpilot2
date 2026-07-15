import { useState } from "react"
import { useQuery } from "@tanstack/react-query"
import { Bar, BarChart, CartesianGrid, Cell, LabelList, ResponsiveContainer, Tooltip, XAxis, YAxis } from "recharts"

import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { EmptyState } from "@/components/ui/empty-state"
import { Select } from "@/components/ui/select"
import { groupApprovedHoursByProject } from "@/features/analytics/group-by-project"
import { getWorklogReport, getWorklogTrend } from "@/features/reports/api"

const PROJECT_COLORS = [
  "var(--color-primary)",
  "var(--color-secondary)",
  "var(--color-info)",
  "var(--color-warning)",
  "var(--color-success)",
]

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

  const projectHours = report ? groupApprovedHoursByProject(report.items) : []

  return (
    <div className="flex flex-col gap-4">
      <div>
        <h1 className="text-2xl font-bold">تحلیل‌ها</h1>
        <p className="text-muted-foreground">روند ساعات کاری تأییدشده در طول زمان و مقایسهٔ پروژه‌ها</p>
      </div>

      <Card>
        <CardHeader className="flex flex-row items-center justify-between">
          <CardTitle className="text-base">روند ساعات کاری تأییدشده</CardTitle>
          <Select value={groupBy} onChange={(e) => setGroupBy(e.target.value as "week" | "month")} className="w-32">
            <option value="week">هفتگی</option>
            <option value="month">ماهانه</option>
          </Select>
        </CardHeader>
        <CardContent>
          {isTrendLoading && <p className="text-muted-foreground">در حال بارگذاری...</p>}
          {!isTrendLoading && (!trend || trend.items.length === 0) && (
            <EmptyState className="h-[220px]" message="هنوز داده‌ای برای نمایش روند وجود ندارد." />
          )}
          {!isTrendLoading && trend && trend.items.length > 0 && (
            <ResponsiveContainer width="100%" height={220}>
              <BarChart data={trend.items}>
                <CartesianGrid strokeDasharray="3 3" vertical={false} />
                <XAxis
                  dataKey="period"
                  tick={{ fontSize: 12 }}
                  tickFormatter={(v) => new Date(v).toLocaleDateString("fa-IR")}
                />
                <YAxis tick={{ fontSize: 12 }} />
                <Tooltip labelFormatter={(v) => new Date(v).toLocaleDateString("fa-IR")} />
                <Bar dataKey="approved_hours" fill="var(--color-primary)" radius={[4, 4, 0, 0]}>
                  <LabelList dataKey="approved_hours" position="top" style={{ fontSize: 12 }} />
                </Bar>
              </BarChart>
            </ResponsiveContainer>
          )}
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle className="text-base">مقایسهٔ ساعات کاری بین پروژه‌ها</CardTitle>
        </CardHeader>
        <CardContent>
          {isReportLoading && <p className="text-muted-foreground">در حال بارگذاری...</p>}
          {!isReportLoading && projectHours.length === 0 && (
            <EmptyState className="h-[220px]" message="هنوز گزارش کاری تأییدشده‌ای وجود ندارد." />
          )}
          {!isReportLoading && projectHours.length > 0 && (
            <ResponsiveContainer width="100%" height={220}>
              <BarChart data={projectHours}>
                <CartesianGrid strokeDasharray="3 3" vertical={false} />
                <XAxis dataKey="project_name" tick={{ fontSize: 12 }} />
                <YAxis tick={{ fontSize: 12 }} />
                <Tooltip />
                <Bar dataKey="approved_hours" radius={[4, 4, 0, 0]}>
                  <LabelList dataKey="approved_hours" position="top" style={{ fontSize: 12 }} />
                  {projectHours.map((entry, index) => (
                    <Cell key={entry.project_name} fill={PROJECT_COLORS[index % PROJECT_COLORS.length]} />
                  ))}
                </Bar>
              </BarChart>
            </ResponsiveContainer>
          )}
        </CardContent>
      </Card>
    </div>
  )
}
