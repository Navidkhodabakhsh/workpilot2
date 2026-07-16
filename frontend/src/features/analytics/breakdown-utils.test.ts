import { describe, expect, it } from "vitest"
import { projectStatusBreakdown, worklogStatusBreakdown } from "./breakdown-utils"
import type { WorkLogReportRow } from "@/features/reports/api"

function makeRow(overrides: Partial<WorkLogReportRow>): WorkLogReportRow {
  return {
    worklog_id: "w1",
    task_id: "t1",
    task_title: "Task",
    project_id: "p1",
    project_name: "Project 1",
    user_id: "u1",
    user_full_name: "User One",
    activity_description: "",
    time_spent_minutes: 60,
    progress_percent: 0,
    log_date: "2026-07-13",
    status: "approved",
    created_at: "2026-07-13T00:00:00Z",
    ...overrides,
  }
}

describe("worklogStatusBreakdown", () => {
  it("counts rows per status and skips statuses with zero rows", () => {
    const rows = [
      makeRow({ status: "approved" }),
      makeRow({ status: "approved" }),
      makeRow({ status: "submitted" }),
    ]
    expect(worklogStatusBreakdown(rows)).toEqual([
      { name: "در انتظار تأیید", value: 1 },
      { name: "تأییدشده", value: 2 },
    ])
  })

  it("returns an empty array for no rows", () => {
    expect(worklogStatusBreakdown([])).toEqual([])
  })
})

describe("projectStatusBreakdown", () => {
  it("counts projects per status", () => {
    const projects = [{ status: "active" as const }, { status: "active" as const }, { status: "completed" as const }]
    expect(projectStatusBreakdown(projects)).toEqual([
      { name: "فعال", value: 2 },
      { name: "تکمیل‌شده", value: 1 },
    ])
  })
})
