import { useState } from "react"
import { useQuery } from "@tanstack/react-query"

import { Badge } from "@/components/ui/badge"
import { Card, CardContent } from "@/components/ui/card"
import { EmptyState } from "@/components/ui/empty-state"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Select } from "@/components/ui/select"
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table"
import { getWorklogReport } from "@/features/reports/api"
import { listProjects } from "@/features/projects/api"
import { listOrgUsers } from "@/features/users/api"
import type { WorkLogStatus } from "@/lib/types"

const STATUS_LABEL: Record<string, string> = {
  draft: "پیش‌نویس",
  submitted: "در انتظار تأیید",
  approved: "تأییدشده",
  rejected: "ردشده",
}
const STATUS_VARIANT: Record<string, "default" | "warning" | "success" | "danger"> = {
  draft: "default",
  submitted: "warning",
  approved: "success",
  rejected: "danger",
}

export function ReportsPage() {
  const [projectId, setProjectId] = useState("")
  const [userId, setUserId] = useState("")
  const [status, setStatus] = useState<WorkLogStatus | "">("")
  const [dateFrom, setDateFrom] = useState("")
  const [dateTo, setDateTo] = useState("")

  const { data: projects } = useQuery({ queryKey: ["projects"], queryFn: listProjects })
  const { data: users } = useQuery({ queryKey: ["org-users"], queryFn: listOrgUsers })

  const { data: report, isLoading } = useQuery({
    queryKey: ["worklog-report", projectId, userId, status, dateFrom, dateTo],
    queryFn: () =>
      getWorklogReport({
        project_id: projectId || undefined,
        user_id: userId || undefined,
        status: status || undefined,
        date_from: dateFrom || undefined,
        date_to: dateTo || undefined,
      }),
  })

  return (
    <div className="flex flex-col gap-4">
      <div>
        <h1 className="text-2xl font-bold">گزارش‌ها</h1>
        <p className="text-muted-foreground">فهرست گزارش‌های کاری ثبت‌شده در پروژه‌هایی که به آن‌ها دسترسی دارید</p>
      </div>

      <Card>
        <CardContent className="grid grid-cols-1 gap-3 pt-6 sm:grid-cols-2 lg:grid-cols-5">
          <div className="flex flex-col gap-1.5">
            <Label htmlFor="report-project">پروژه</Label>
            <Select id="report-project" value={projectId} onChange={(e) => setProjectId(e.target.value)}>
              <option value="">همه</option>
              {projects?.map((p) => (
                <option key={p.id} value={p.id}>
                  {p.name}
                </option>
              ))}
            </Select>
          </div>
          <div className="flex flex-col gap-1.5">
            <Label htmlFor="report-user">کاربر</Label>
            <Select id="report-user" value={userId} onChange={(e) => setUserId(e.target.value)}>
              <option value="">همه</option>
              {users?.map((u) => (
                <option key={u.id} value={u.id}>
                  {u.full_name}
                </option>
              ))}
            </Select>
          </div>
          <div className="flex flex-col gap-1.5">
            <Label htmlFor="report-status">وضعیت</Label>
            <Select id="report-status" value={status} onChange={(e) => setStatus(e.target.value as WorkLogStatus | "")}>
              <option value="">همه</option>
              {Object.entries(STATUS_LABEL).map(([value, label]) => (
                <option key={value} value={value}>
                  {label}
                </option>
              ))}
            </Select>
          </div>
          <div className="flex flex-col gap-1.5">
            <Label htmlFor="report-from">از تاریخ</Label>
            <Input id="report-from" type="date" value={dateFrom} onChange={(e) => setDateFrom(e.target.value)} />
          </div>
          <div className="flex flex-col gap-1.5">
            <Label htmlFor="report-to">تا تاریخ</Label>
            <Input id="report-to" type="date" value={dateTo} onChange={(e) => setDateTo(e.target.value)} />
          </div>
        </CardContent>
      </Card>

      {isLoading && <p className="text-muted-foreground">در حال بارگذاری...</p>}

      {!isLoading && report && report.items.length === 0 && (
        <EmptyState message="گزارشی با این فیلترها یافت نشد." />
      )}

      {!isLoading && report && report.items.length > 0 && (
        <>
          <p className="text-sm text-muted-foreground">
            مجموع: <span className="font-medium text-foreground">{report.total_hours}</span> ساعت در{" "}
            {report.items.length} گزارش
          </p>
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>وظیفه</TableHead>
                <TableHead>پروژه</TableHead>
                <TableHead>کاربر</TableHead>
                <TableHead>دقیقه</TableHead>
                <TableHead>پیشرفت</TableHead>
                <TableHead>تاریخ</TableHead>
                <TableHead>وضعیت</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {report.items.map((row) => (
                <TableRow key={row.worklog_id}>
                  <TableCell className="font-medium">{row.task_title}</TableCell>
                  <TableCell>{row.project_name}</TableCell>
                  <TableCell>{row.user_full_name}</TableCell>
                  <TableCell>{row.time_spent_minutes}</TableCell>
                  <TableCell>{row.progress_percent}٪</TableCell>
                  <TableCell>{new Date(row.log_date).toLocaleDateString("fa-IR")}</TableCell>
                  <TableCell>
                    <Badge variant={STATUS_VARIANT[row.status]}>{STATUS_LABEL[row.status]}</Badge>
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </>
      )}
    </div>
  )
}
