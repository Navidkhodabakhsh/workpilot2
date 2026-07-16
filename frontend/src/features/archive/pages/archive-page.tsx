import { useState } from "react"
import { useQuery } from "@tanstack/react-query"
import { Link } from "react-router-dom"
import { Archive as ArchiveIcon } from "lucide-react"

import { Badge } from "@/components/ui/badge"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { EmptyState } from "@/components/ui/empty-state"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Select } from "@/components/ui/select"
import { listProjects } from "@/features/projects/api"
import { listAllTasks } from "@/features/tasks/api"
import { PRIORITY_LABEL, PRIORITY_VARIANT } from "@/features/tasks/constants"

export function ArchivePage() {
  const { data: projects } = useQuery({ queryKey: ["projects"], queryFn: listProjects })
  const { data: archivedTasks, isLoading: tasksLoading } = useQuery({
    queryKey: ["tasks", "archived"],
    queryFn: () => listAllTasks({ status: "archived" }),
  })

  const [projectFilter, setProjectFilter] = useState("")
  const [dateFrom, setDateFrom] = useState("")
  const [dateTo, setDateTo] = useState("")

  const archivedProjects = (projects ?? []).filter((p) => p.status === "archived")

  const filteredTasks = (archivedTasks ?? []).filter((t) => {
    if (projectFilter && t.project_id !== projectFilter) return false
    if (dateFrom && (!t.deadline || t.deadline < dateFrom)) return false
    if (dateTo && (!t.deadline || t.deadline > dateTo)) return false
    return true
  })

  const projectName = (id: string | null) => (id ? (projects?.find((p) => p.id === id)?.name ?? "—") : "شخصی")

  return (
    <div className="flex flex-col gap-6">
      <div>
        <h1 className="text-2xl font-bold">بایگانی</h1>
        <p className="text-muted-foreground">پروژه‌ها و تسک‌های بایگانی‌شده</p>
      </div>

      <div className="flex flex-col gap-3">
        <h2 className="font-semibold">پروژه‌های بایگانی‌شده</h2>
        {archivedProjects.length === 0 ? (
          <EmptyState icon={ArchiveIcon} message="هیچ پروژهٔ بایگانی‌شده‌ای وجود ندارد." />
        ) : (
          <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
            {archivedProjects.map((p) => (
              <Link key={p.id} to={`/projects/${p.id}`}>
                <Card className="h-full transition-shadow hover:shadow-md">
                  <CardHeader>
                    <CardTitle className="text-base">{p.name}</CardTitle>
                  </CardHeader>
                  <CardContent>
                    <p className="line-clamp-2 text-sm text-muted-foreground">{p.description || "بدون توضیحات"}</p>
                  </CardContent>
                </Card>
              </Link>
            ))}
          </div>
        )}
      </div>

      <div className="border-t border-border" />

      <div className="flex flex-col gap-3">
        <h2 className="font-semibold">تسک‌های بایگانی‌شده</h2>
        <div className="flex flex-wrap items-end gap-3">
          <div className="flex flex-col gap-1.5">
            <Label htmlFor="archive-project-filter">پروژه</Label>
            <Select
              id="archive-project-filter"
              value={projectFilter}
              onChange={(e) => setProjectFilter(e.target.value)}
              className="w-48"
            >
              <option value="">همهٔ پروژه‌ها</option>
              {projects?.map((p) => (
                <option key={p.id} value={p.id}>
                  {p.name}
                </option>
              ))}
            </Select>
          </div>
          <div className="flex flex-col gap-1.5">
            <Label htmlFor="archive-date-from">از تاریخ (مهلت)</Label>
            <Input id="archive-date-from" type="date" value={dateFrom} onChange={(e) => setDateFrom(e.target.value)} />
          </div>
          <div className="flex flex-col gap-1.5">
            <Label htmlFor="archive-date-to">تا تاریخ (مهلت)</Label>
            <Input id="archive-date-to" type="date" value={dateTo} onChange={(e) => setDateTo(e.target.value)} />
          </div>
        </div>

        {tasksLoading && <p className="text-muted-foreground">در حال بارگذاری...</p>}
        {!tasksLoading && filteredTasks.length === 0 && (
          <EmptyState icon={ArchiveIcon} message="تسکی با این فیلترها یافت نشد." />
        )}
        {!tasksLoading && filteredTasks.length > 0 && (
          <div className="flex flex-col gap-2">
            {filteredTasks.map((t) => (
              <div
                key={t.id}
                className="flex flex-col gap-1.5 rounded-lg border border-border/70 bg-card p-3 sm:flex-row sm:items-center sm:justify-between"
              >
                <div className="flex flex-col gap-1">
                  <p className="font-medium">{t.title}</p>
                  <div className="flex flex-wrap items-center gap-1.5">
                    <Badge variant="info">{projectName(t.project_id)}</Badge>
                    <Badge variant={PRIORITY_VARIANT[t.priority]}>{PRIORITY_LABEL[t.priority]}</Badge>
                  </div>
                </div>
                <span className="text-xs text-muted-foreground">
                  {t.deadline ? new Date(t.deadline).toLocaleDateString("fa-IR") : "بدون مهلت"}
                </span>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  )
}
