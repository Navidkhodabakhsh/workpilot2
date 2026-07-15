import type { ApprovalStatus, TaskStatus } from "@/lib/types"

export const STATUS_LABEL: Record<TaskStatus, string> = {
  todo: "برای انجام",
  in_progress: "در حال انجام",
  completed: "تکمیل‌شده",
  archived: "بایگانی‌شده",
}

export const STATUS_VARIANT: Record<TaskStatus, "default" | "info" | "success" | "danger"> = {
  todo: "default",
  in_progress: "info",
  completed: "success",
  archived: "danger",
}

export const STATUS_COLUMNS: { value: TaskStatus; label: string }[] = [
  { value: "todo", label: STATUS_LABEL.todo },
  { value: "in_progress", label: STATUS_LABEL.in_progress },
  { value: "completed", label: STATUS_LABEL.completed },
  { value: "archived", label: STATUS_LABEL.archived },
]

export const APPROVAL_LABEL: Record<ApprovalStatus, string> = {
  pending: "در انتظار تأیید",
  approved: "تأییدشده",
  rejected: "ردشده",
}

export const APPROVAL_VARIANT: Record<ApprovalStatus, "warning" | "success" | "danger"> = {
  pending: "warning",
  approved: "success",
  rejected: "danger",
}

export const PRIORITY_LABEL: Record<string, string> = { low: "کم", medium: "متوسط", high: "بالا" }
export const PRIORITY_VARIANT: Record<string, "default" | "warning" | "danger"> = {
  low: "default",
  medium: "warning",
  high: "danger",
}
