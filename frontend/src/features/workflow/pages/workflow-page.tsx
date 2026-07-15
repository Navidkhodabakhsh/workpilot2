import { useQuery } from "@tanstack/react-query"

import { listAllTasks } from "@/features/tasks/api"
import { STATUS_COLUMNS } from "@/features/tasks/constants"
import { listProjects } from "@/features/projects/api"
import { listOrgUsers } from "@/features/users/api"
import { TaskCard } from "@/features/tasks/components/task-card"

export function WorkflowPage() {
  const { data: tasks } = useQuery({ queryKey: ["all-tasks"], queryFn: () => listAllTasks() })
  const { data: projects } = useQuery({ queryKey: ["projects"], queryFn: listProjects })
  const { data: users } = useQuery({ queryKey: ["org-users"], queryFn: listOrgUsers })

  if (!tasks || !projects || !users) {
    return <p className="text-muted-foreground">در حال بارگذاری...</p>
  }

  const projectName = (id: string | null) => projects.find((p) => p.id === id)?.name ?? "—"
  // Personal tasks (no project) have no place on a cross-project ops board --
  // they belong on the "My Personal Tasks" tab of the Tasks page instead.
  const projectTasks = tasks.filter((t) => t.project_id !== null)

  return (
    <div className="flex flex-col gap-4">
      <div>
        <h1 className="text-2xl font-bold">گردش کار</h1>
        <p className="text-muted-foreground">تختهٔ کانبان همهٔ وظایف در پروژه‌هایی که به آن‌ها دسترسی دارید</p>
      </div>

      {/* Cross-project Kanban: same column-per-status pattern as the
          per-project board (project-detail-page.tsx), horizontally
          scrollable on small screens by design. */}
      <div className="flex gap-4 overflow-x-auto pb-2">
        {STATUS_COLUMNS.map((col) => {
          const columnTasks = projectTasks.filter((t) => t.status === col.value)
          return (
            <div key={col.value} className="w-72 shrink-0">
              <div className="mb-2 flex items-center gap-2">
                <h2 className="font-semibold">{col.label}</h2>
                <span className="text-sm text-muted-foreground">({columnTasks.length})</span>
              </div>
              <div className="flex flex-col gap-3">
                {columnTasks.map((task) => (
                  <TaskCard key={task.id} task={task} users={users} projectName={projectName(task.project_id)} />
                ))}
                {columnTasks.length === 0 && <p className="text-sm text-muted-foreground">وظیفه‌ای نیست</p>}
              </div>
            </div>
          )
        })}
      </div>
    </div>
  )
}
