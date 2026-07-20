import { describe, expect, it } from "vitest"
import { hoursByProject } from "./chart-utils"
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

describe("hoursByProject", () => {
  it("sums approved hours per project and ignores non-approved rows", () => {
    const rows = [
      makeRow({ project_id: "p1", project_name: "Alpha", time_spent_minutes: 60, status: "approved" }),
      makeRow({ project_id: "p1", project_name: "Alpha", time_spent_minutes: 120, status: "approved" }),
      makeRow({ project_id: "p2", project_name: "Beta", time_spent_minutes: 60, status: "submitted" }),
    ]
    expect(hoursByProject(rows)).toEqual([{ project_id: "p1", project_name: "Alpha", hours: 3 }])
  })

  it("sorts descending and respects the limit", () => {
    const rows = [
      makeRow({ project_id: "p1", project_name: "Alpha", time_spent_minutes: 60 }),
      makeRow({ project_id: "p2", project_name: "Beta", time_spent_minutes: 180 }),
    ]
    const result = hoursByProject(rows, 1)
    expect(result).toHaveLength(1)
    expect(result[0].project_name).toBe("Beta")
  })
})
