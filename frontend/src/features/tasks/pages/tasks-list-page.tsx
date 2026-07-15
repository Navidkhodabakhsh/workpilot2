import { useMemo, useState } from "react"
import { useQuery } from "@tanstack/react-query"
import { Link } from "react-router-dom"

import { Badge } from "@/components/ui/badge"
import { EmptyState } from "@/components/ui/empty-state"
import { Select } from "@/components/ui/select"
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table"
import { listAllTasks } from "@/features/tasks/api"
import { listProjects } from "@/features/projects/api"
import { listOrgUsers } from "@/features/users/api"
import type { TaskStatus } from "@/lib/types"

const STATUS_LABEL: Record<string, string> = {
  todo: "برای انجام",
  in_progress: "در حال انجام",
  in_review: "در بازبینی",
  done: "انجام‌شده",
  blocked: "معطل",
}
const STATUS_VARIANT: Record<string, "default" | "info" | "warning" | "success" | "danger"> = {
  todo: "default",
  in_progress: "info",
  in_review: "warning",
  done: "success",
  blocked: "danger",
}
const PRIORITY_LABEL: Record<string, string> = { low: "کم", medium: "متوسط", high: "بالا" }
const PRIORITY_VARIANT: Record<string, "default" | "warning" | "danger"> = {
  low: "default",
  medium: "warning",
  high: "danger",
}

export function TasksListPage() {
  const [projectFilter, setProjectFilter] = useState("")
  const [statusFilter, setStatusFilter] = useState<TaskStatus | "">("")

  const { data: tasks, isLoading } = useQuery({
    queryKey: ["all-tasks", statusFilter],
    queryFn: () => listAllTasks(statusFilter ? { status: statusFilter } : undefined),
  })
  const { data: projects } = useQuery({ queryKey: ["projects"], queryFn: listProjects })
  const { data: users } = useQuery({ queryKey: ["org-users"], queryFn: listOrgUsers })

  const projectName = useMemo(() => {
    const map = new Map((projects ?? []).map((p) => [p.id, p.name]))
    return (id: string) => map.get(id) ?? "—"
  }, [projects])
  const assigneeName = useMemo(() => {
    const map = new Map((users ?? []).map((u) => [u.id, u.full_name]))
    return (id: string | null) => (id ? (map.get(id) ?? "—") : "بدون مسئول")
  }, [users])

  const filteredTasks = (tasks ?? []).filter((t) => !projectFilter || t.project_id === projectFilter)

  return (
    <div className="flex flex-col gap-4">
      <div>
        <h1 className="text-2xl font-bold">کارها</h1>
        <p className="text-muted-foreground">فهرست همهٔ وظایف در پروژه‌هایی که به آن‌ها دسترسی دارید</p>
      </div>

      <div className="flex flex-col gap-3 sm:flex-row">
        <Select value={projectFilter} onChange={(e) => setProjectFilter(e.target.value)} className="sm:max-w-64">
          <option value="">همهٔ پروژه‌ها</option>
          {projects?.map((p) => (
            <option key={p.id} value={p.id}>
              {p.name}
            </option>
          ))}
        </Select>
        <Select
          value={statusFilter}
          onChange={(e) => setStatusFilter(e.target.value as TaskStatus | "")}
          className="sm:max-w-48"
        >
          <option value="">همهٔ وضعیت‌ها</option>
          {Object.entries(STATUS_LABEL).map(([value, label]) => (
            <option key={value} value={value}>
              {label}
            </option>
          ))}
        </Select>
      </div>

      {isLoading && <p className="text-muted-foreground">در حال بارگذاری...</p>}

      {!isLoading && filteredTasks.length === 0 && <EmptyState message="وظیفه‌ای یافت نشد." />}

      {!isLoading && filteredTasks.length > 0 && (
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>عنوان</TableHead>
              <TableHead>پروژه</TableHead>
              <TableHead>مسئول</TableHead>
              <TableHead>اولویت</TableHead>
              <TableHead>وضعیت</TableHead>
              <TableHead>مهلت</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {filteredTasks.map((task) => (
              <TableRow key={task.id}>
                <TableCell className="font-medium">{task.title}</TableCell>
                <TableCell>
                  <Link to={`/projects/${task.project_id}`} className="text-primary hover:underline">
                    {projectName(task.project_id)}
                  </Link>
                </TableCell>
                <TableCell>{assigneeName(task.assignee_id)}</TableCell>
                <TableCell>
                  <Badge variant={PRIORITY_VARIANT[task.priority]}>{PRIORITY_LABEL[task.priority]}</Badge>
                </TableCell>
                <TableCell>
                  <Badge variant={STATUS_VARIANT[task.status]}>{STATUS_LABEL[task.status]}</Badge>
                </TableCell>
                <TableCell>{task.deadline ? new Date(task.deadline).toLocaleDateString("fa-IR") : "—"}</TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      )}
    </div>
  )
}
