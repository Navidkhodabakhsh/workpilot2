import type { Notification } from "@/features/notifications/api"

export function notificationMessage(notification: Notification): string {
  const { type, payload } = notification
  switch (type) {
    case "task_created":
      return `وظیفهٔ «${payload.task_title}» به شما تخصیص داده شد`
    case "deadline_approaching":
      return `مهلت وظیفهٔ «${payload.task_title}» نزدیک است (${payload.deadline})`
    case "report_submitted":
      return `گزارش کاری جدیدی برای «${payload.task_title}» ارسال شد`
    case "report_reviewed":
      return payload.status === "approved"
        ? "گزارش کاری شما تأیید شد"
        : `گزارش کاری شما رد شد: ${payload.review_comment ?? ""}`
    default:
      return "اعلان جدید"
  }
}
