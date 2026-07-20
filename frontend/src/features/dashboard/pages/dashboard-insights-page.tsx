import { useState } from "react"
import { useQuery } from "@tanstack/react-query"
import { Link } from "react-router-dom"
import { Cell, Pie, PieChart, ResponsiveContainer, Tooltip } from "recharts"
import { CheckCircle2, ChevronLeft, ClipboardList, Clock3, FolderKanban, Landmark, LayoutDashboard, SlidersHorizontal } from "lucide-react"

import { PageHeader } from "@/components/layout/page-header"
import { AnimatedNumber } from "@/components/ui/animated-number"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { EmptyState } from "@/components/ui/empty-state"
import { JalaliDateInput } from "@/components/ui/jalali-date-input"
import { Label } from "@/components/ui/label"
import { Skeleton } from "@/components/ui/skeleton"
import { getDashboardSummary } from "@/features/dashboard/api"
import { useAuthStore } from "@/features/auth/auth-store"
import { useDepartmentStore } from "@/features/departments/department-store"
import { STATUS_COLOR, STATUS_LABEL } from "@/features/tasks/constants"
import type { TaskStatus } from "@/lib/types"

const BAR_COLORS = ["var(--color-primary)", "var(--color-success)", "var(--color-info)", "var(--color-warning)", "var(--color-secondary)"]

function Stat({ icon: Icon, value, label, tone }: { icon: typeof Clock3; value: number; label: string; tone: string }) {
  return <Card className="overflow-hidden border-border/70"><CardContent className="flex items-center gap-3 pt-6"><div className={`flex size-11 items-center justify-center rounded-2xl ${tone}`}><Icon className="size-5" /></div><div><p className="text-2xl font-bold tabular-nums"><AnimatedNumber value={value} /></p><p className="text-sm text-muted-foreground">{label}</p></div></CardContent></Card>
}

function PercentRows({ rows, kind }: { rows: { id: string; name: string; hours: number; percent: number }[]; kind: "member" | "project" }) {
  if (!rows.length) return <EmptyState className="h-44" message={kind === "member" ? "عضوی در این محدوده نیست." : "پروژه‌ای در این محدوده نیست."} />
  return <div className="flex flex-col gap-4">{rows.map((row, index) => <div key={row.id} className="grid grid-cols-[minmax(6rem,9rem)_1fr_auto] items-center gap-3"><div className="min-w-0"><p className="truncate text-sm font-medium">{row.name}</p><p className="text-xs text-muted-foreground">{row.hours.toLocaleString("fa-IR", { maximumFractionDigits: 2 })} ساعت</p></div><div className="h-4 overflow-hidden rounded-full bg-muted shadow-inner"><div className="h-full rounded-full transition-[width] duration-700" style={{ width: `${row.percent > 0 ? Math.max(row.percent, 3) : 0}%`, background: `linear-gradient(90deg, color-mix(in oklab, ${BAR_COLORS[index % BAR_COLORS.length]} 65%, white), ${BAR_COLORS[index % BAR_COLORS.length]})` }} /></div><span className="w-12 text-end text-sm font-bold tabular-nums">{row.percent.toLocaleString("fa-IR")}٪</span></div>)}</div>
}

export function DashboardInsightsPage() {
  const role = useAuthStore((state) => state.user?.role)
  const canUseFinance = role === "org_admin" || role === "project_manager"
  const departmentId = useDepartmentStore((state) => state.selectedDepartmentId)
  const [dateFrom, setDateFrom] = useState("")
  const [dateTo, setDateTo] = useState("")
  const { data, isLoading, isError } = useQuery({
    queryKey: ["dashboard-summary", departmentId, dateFrom, dateTo],
    queryFn: () => getDashboardSummary(departmentId, dateFrom, dateTo),
  })
  if (isError) return <p className="text-danger">دریافت اطلاعات داشبورد انجام نشد.</p>
  const chartData = (data?.tasks_by_status ?? []).map((item) => ({ name: STATUS_LABEL[item.status as TaskStatus] ?? item.status, value: item.count, color: STATUS_COLOR[item.status as TaskStatus] }))
  const completed = data?.tasks_by_status.find((item) => item.status === "completed")?.count ?? 0

  return <div className="flex flex-col gap-6">
    <PageHeader icon={LayoutDashboard} tone="primary" title="داشبورد" description="تصویر واقعی از وظایف و ساعت‌های تأییدشده" />
    {canUseFinance && <Link to="/finance" className="group rounded-xl outline-none focus-visible:ring-2 focus-visible:ring-primary"><Card className="border-success/25 bg-gradient-to-l from-success/[0.09] to-transparent transition-shadow group-hover:shadow-md"><CardContent className="flex items-center gap-3 pt-5"><div className="flex size-11 items-center justify-center rounded-2xl bg-success/15 text-success"><Landmark className="size-5" /></div><div className="flex-1"><p className="font-bold">دفتر درآمد و هزینه</p><p className="text-sm text-muted-foreground">ثبت سند، گروه‌بندی و مشاهده مانده مالی</p></div><span className="flex items-center gap-1 text-sm font-medium text-success">ورود<ChevronLeft className="size-4" /></span></CardContent></Card></Link>}
    <Card className="border-primary/15 bg-gradient-to-l from-primary/[0.06] to-transparent"><CardContent className="flex flex-col gap-4 pt-5 sm:flex-row sm:items-end"><div className="flex items-center gap-2 self-start text-sm font-semibold"><SlidersHorizontal className="size-4 text-primary" />بازه گزارش ساعت</div><div className="grid flex-1 grid-cols-1 gap-3 sm:grid-cols-2"><div className="flex flex-col gap-1.5"><Label htmlFor="dashboard-from">از تاریخ</Label><JalaliDateInput id="dashboard-from" value={dateFrom} onChange={setDateFrom} /></div><div className="flex flex-col gap-1.5"><Label htmlFor="dashboard-to">تا تاریخ</Label><JalaliDateInput id="dashboard-to" value={dateTo} onChange={setDateTo} /></div></div>{(dateFrom || dateTo) && <button className="text-sm text-primary hover:underline" onClick={() => { setDateFrom(""); setDateTo("") }}>پاک‌کردن بازه</button>}</CardContent></Card>
    {isLoading ? <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">{Array.from({ length: 4 }, (_, i) => <Skeleton key={i} className="h-24 rounded-xl" />)}</div> : data && <>
      <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4"><Stat icon={FolderKanban} value={data.project_count} label="پروژه‌های قابل مشاهده" tone="bg-primary/10 text-primary" /><Stat icon={ClipboardList} value={data.task_count} label="تسک‌های فعال" tone="bg-secondary/10 text-secondary" /><Stat icon={Clock3} value={data.total_approved_hours} label="ساعت تأییدشده" tone="bg-info/10 text-info" /><Stat icon={CheckCircle2} value={completed} label="منتظر تأیید نهایی" tone="bg-success/10 text-success" /></div>
      <div className="grid grid-cols-1 gap-4 lg:grid-cols-2">
        <Card className="overflow-hidden"><CardHeader><CardTitle className="text-base">وضعیت تسک‌ها</CardTitle></CardHeader><CardContent>{chartData.length === 0 ? <EmptyState className="h-56" message="تسکی ثبت نشده است." /> : <div className="flex flex-col items-center gap-4 sm:flex-row sm:justify-center"><div className="relative h-48 w-48"><ResponsiveContainer width="100%" height="100%"><PieChart><Pie data={chartData} dataKey="value" innerRadius="62%" outerRadius="100%" paddingAngle={3} cornerRadius={7} stroke="none">{chartData.map((item) => <Cell key={item.name} fill={item.color} />)}</Pie><Tooltip /></PieChart></ResponsiveContainer><div className="pointer-events-none absolute inset-0 flex flex-col items-center justify-center"><span className="text-2xl font-bold">{data.task_count.toLocaleString("fa-IR")}</span><span className="text-xs text-muted-foreground">تسک فعال</span></div></div><div className="flex min-w-40 flex-col gap-2">{chartData.map((item) => <div key={item.name} className="flex items-center gap-2 text-sm"><span className="size-2.5 rounded-full" style={{ backgroundColor: item.color }} /><span className="text-muted-foreground">{item.name}</span><span className="ms-auto font-semibold">{item.value.toLocaleString("fa-IR")}</span></div>)}</div></div>}</CardContent></Card>
        <Card className="overflow-hidden"><CardHeader><CardTitle className="text-base">ساعت کاری اعضا</CardTitle><p className="text-xs text-muted-foreground">فقط ساعت‌های تأییدشده در بازه انتخابی</p></CardHeader><CardContent><PercentRows kind="member" rows={data.team_hours.map((item) => ({ id: item.user_id, name: item.full_name, hours: item.approved_hours, percent: item.percent }))} /></CardContent></Card>
        <Card className="overflow-hidden lg:col-span-2"><CardHeader><CardTitle className="text-base">ساعت مصرف‌شده برای هر پروژه</CardTitle><p className="text-xs text-muted-foreground">طول هر نوار سهم پروژه از کل ساعت تأییدشده را نشان می‌دهد.</p></CardHeader><CardContent><PercentRows kind="project" rows={data.project_hours.map((item) => ({ id: item.project_id, name: item.project_name, hours: item.approved_hours, percent: item.percent }))} /></CardContent></Card>
      </div>
      <Card><CardHeader><CardTitle className="text-base">آخرین ثبت ساعت‌ها</CardTitle></CardHeader><CardContent className="flex flex-col divide-y divide-border/70">{data.recent_activity.length === 0 && <EmptyState className="h-28" message="هنوز ساعتی ثبت نشده است." />}{data.recent_activity.map((item) => <div key={item.worklog_id} className="flex items-center justify-between gap-3 py-3"><div><p className="text-sm"><span className="font-semibold">{item.user_full_name}</span> روی «{item.task_title}» ساعت ثبت کرد.</p><p className="text-xs text-muted-foreground">{item.status === "approved" ? "تأییدشده" : item.status === "submitted" ? "منتظر تأیید" : "بررسی‌شده"}</p></div><span className="shrink-0 text-xs text-muted-foreground">{new Date(item.created_at).toLocaleDateString("fa-IR")}</span></div>)}</CardContent></Card>
    </>}
  </div>
}
