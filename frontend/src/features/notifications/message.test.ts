import { describe, expect, it } from "vitest"
import { notificationMessage } from "./message"
import type { Notification } from "./api"

function makeNotification(overrides: Partial<Notification>): Notification {
  return {
    id: "1",
    type: "task_created",
    payload: {},
    is_read: false,
    created_at: "2026-07-14T00:00:00Z",
    ...overrides,
  }
}

describe("notificationMessage", () => {
  it("formats a task assignment notification with the task title", () => {
    const message = notificationMessage(
      makeNotification({ type: "task_created", payload: { task_title: "طراحی داشبورد" } }),
    )
    expect(message).toContain("طراحی داشبورد")
    expect(message).toContain("تخصیص داده شد")
  })

  it("formats a deadline-approaching notification with the task title and deadline", () => {
    const message = notificationMessage(
      makeNotification({
        type: "deadline_approaching",
        payload: { task_title: "بازبینی کد", deadline: "2026-07-20" },
      }),
    )
    expect(message).toContain("بازبینی کد")
    expect(message).toContain("2026-07-20")
  })

  it("formats an approved report review without a comment", () => {
    const message = notificationMessage(
      makeNotification({ type: "report_reviewed", payload: { status: "approved" } }),
    )
    expect(message).toBe("گزارش کاری شما تأیید شد")
  })

  it("formats a rejected report review including the review comment", () => {
    const message = notificationMessage(
      makeNotification({
        type: "report_reviewed",
        payload: { status: "rejected", review_comment: "جزئیات بیشتری اضافه کنید" },
      }),
    )
    expect(message).toContain("رد شد")
    expect(message).toContain("جزئیات بیشتری اضافه کنید")
  })

  it("formats a comment notification with the author and task title", () => {
    const message = notificationMessage(
      makeNotification({
        type: "comment_added",
        payload: { author_full_name: "سارا احمدی", task_title: "بازطراحی صفحه اصلی" },
      }),
    )
    expect(message).toContain("سارا احمدی")
    expect(message).toContain("بازطراحی صفحه اصلی")
  })

  it("falls back to a generic message for an unknown notification type", () => {
    const message = notificationMessage(
      makeNotification({ type: "something_new" as Notification["type"], payload: {} }),
    )
    expect(message).toBe("اعلان جدید")
  })
})
