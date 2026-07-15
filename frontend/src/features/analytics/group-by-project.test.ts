import { describe, expect, it } from "vitest"
import { groupApprovedHoursByProject } from "./group-by-project"
import type { WorkLogReportRow } from "@/features/reports/api"

function makeRow(overrides: Partial<WorkLogReportRow>): WorkLogReportRow {
  return {
    worklog_id: "1",
    task_id: "t1",
    task_title: "Task",
    project_id: "p1",
    project_name: "Project A",
    user_id: "u1",
    user_full_name: "User",
    activity_description: "work",
    time_spent_minutes: 60,
    progress_percent: 50,
    log_date: "2026-07-14",
    status: "approved",
    created_at: "2026-07-14T00:00:00Z",
    ...overrides,
  }
}

describe("groupApprovedHoursByProject", () => {
  it("sums approved hours per project", () => {
    const rows = [
      makeRow({ project_name: "Project A", time_spent_minutes: 60 }),
      makeRow({ project_name: "Project A", time_spent_minutes: 120 }),
      makeRow({ project_name: "Project B", time_spent_minutes: 30 }),
    ]
    const result = groupApprovedHoursByProject(rows)
    expect(result).toEqual([
      { project_name: "Project A", approved_hours: 3 },
      { project_name: "Project B", approved_hours: 0.5 },
    ])
  })

  it("excludes non-approved worklogs", () => {
    const rows = [makeRow({ status: "submitted", time_spent_minutes: 120 })]
    expect(groupApprovedHoursByProject(rows)).toEqual([])
  })

  it("sorts projects descending by hours", () => {
    const rows = [
      makeRow({ project_name: "Small", time_spent_minutes: 30 }),
      makeRow({ project_name: "Big", time_spent_minutes: 300 }),
    ]
    const result = groupApprovedHoursByProject(rows)
    expect(result.map((r) => r.project_name)).toEqual(["Big", "Small"])
  })
})
