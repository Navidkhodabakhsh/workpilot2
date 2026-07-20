import type { TaskStatus } from "@/lib/types"

export const ACTIVE_STATUS_COLUMNS: { value: Exclude<TaskStatus, "archived">; label: string }[] = [
  { value: "todo", label: "برای انجام" },
  { value: "in_progress", label: "در حال انجام" },
  { value: "completed", label: "انجام‌شده؛ منتظر تأیید" },
]

export const VALUE_LABEL: Record<string, string> = {
  low: "ارزش کم",
  medium: "ارزش متوسط",
  high: "ارزش زیاد",
}

export const VALUE_VARIANT: Record<string, "default" | "info" | "success"> = {
  low: "default",
  medium: "info",
  high: "success",
}
