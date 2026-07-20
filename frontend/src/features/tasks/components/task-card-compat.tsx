import { TaskWorkflowCard } from "@/features/tasks/components/task-workflow-card"
import type { OrgUser, Task } from "@/lib/types"

/** Replaces the retired card on legacy project screens with the live workflow card. */
export function TaskCard({
  task,
  users,
  projectName,
}: {
  task: Task
  users: OrgUser[]
  projectName?: string
}) {
  return <TaskWorkflowCard task={task} users={users} projectName={projectName} />
}
