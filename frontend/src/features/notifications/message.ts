import type { Notification } from "@/features/notifications/api"

export function notificationMessage(notification: Notification): string {
  const { type, payload } = notification
  switch (type) {
    case "task_created":
      return `وظیفهٔ «${payload.task_title}» به شما تخصیص داده شد`
    case "deadline_approaching":
      return `مهلت وظیفهٔ «${payload.task_title}» نزدیک است (${payload.deadline})`
    case "report_submitted":
      if (payload.kind === "task_approval") return `تسک «${payload.task_title}» منتظر تأیید شماست`
      return `گزارش کاری جدیدی برای «${payload.task_title}» ارسال شد`
    case "report_reviewed":
      return payload.status === "approved"
        ? "گزارش کاری شما تأیید شد"
        : `گزارش کاری شما رد شد: ${payload.review_comment ?? ""}`
    case "comment_added":
      return `${payload.author_full_name} روی «${payload.task_title}» نظر جدیدی ثبت کرد`
    case "event_reminder":
      return `یادآوری رویداد «${payload.title}» نزدیک است`
    case "leave_reviewed":
      return payload.status === "approved"
        ? "درخواست مرخصی شما تأیید شد"
        : `درخواست مرخصی شما رد شد: ${payload.review_comment ?? ""}`
    default:
      return "اعلان جدید"
  }
}

// Where clicking a notification should take the user, if anywhere -- task
// notifications open that task's detail dialog via a query param the tasks
// list page reads on mount (see tasks-list-page.tsx).
export function notificationTaskId(notification: Notification): string | null {
  const { task_id } = notification.payload
  return typeof task_id === "string" ? task_id : null
}
