import { useQuery } from "@tanstack/react-query"
import { MessageSquare } from "lucide-react"

import { Button } from "@/components/ui/button"
import { EmptyState } from "@/components/ui/empty-state"
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table"
import { TaskDetailDialog } from "@/features/tasks/components/task-detail-dialog"
import { listAllTasks } from "@/features/tasks/api"
import { listProjects } from "@/features/projects/api"

export function MessagesPage() {
  const { data: tasks, isLoading } = useQuery({ queryKey: ["all-tasks"], queryFn: () => listAllTasks() })
  const { data: projects } = useQuery({ queryKey: ["projects"], queryFn: listProjects })

  const projectName = (id: string) => projects?.find((p) => p.id === id)?.name ?? "—"

  return (
    <div className="flex flex-col gap-4">
      <div>
        <h1 className="text-2xl font-bold">پیام‌ها</h1>
        <p className="text-muted-foreground">
          نظرات ثبت‌شده روی وظایف پروژه‌هایی که به آن‌ها دسترسی دارید — این بخش گفت‌وگوی متمرکز روی هر وظیفه را نشان
          می‌دهد، نه پیام‌رسانی مستقیم بین افراد
        </p>
      </div>

      {isLoading && <p className="text-muted-foreground">در حال بارگذاری...</p>}

      {!isLoading && (!tasks || tasks.length === 0) && <EmptyState icon={MessageSquare} message="وظیفه‌ای یافت نشد." />}

      {!isLoading && tasks && tasks.length > 0 && (
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>وظیفه</TableHead>
              <TableHead>پروژه</TableHead>
              <TableHead />
            </TableRow>
          </TableHeader>
          <TableBody>
            {tasks.map((task) => (
              <TableRow key={task.id}>
                <TableCell className="font-medium">{task.title}</TableCell>
                <TableCell>{projectName(task.project_id)}</TableCell>
                <TableCell>
                  <TaskDetailDialog
                    task={task}
                    trigger={
                      <Button variant="outline" size="sm">
                        <MessageSquare className="size-4" />
                        مشاهده نظرات
                      </Button>
                    }
                  />
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      )}
    </div>
  )
}
