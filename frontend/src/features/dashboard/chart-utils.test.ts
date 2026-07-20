import { describe, expect, it } from "vitest"
import { hoursByProject, projectProgress } from "./chart-utils"
import type { WorkLogReportRow } from "@/features/reports/api"
import type { Task } from "@/lib/types"

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

function makeTask(overrides: Partial<Task>): Task {
  return {
    id: "t1",
    organization_id: "org1",
    project_id: "p1",
    parent_task_id: null,
    title: "Task",
    description: null,
    assignee_id: "u1",
    created_by_id: "u1",
    created_by_full_name: null,
    priority: "medium",
    status: "completed",
    approval_status: null,
    progress_percent: 0,
    deadline: null,
    start_date: null,
    estimated_hours: null,
    actual_hours: 0,
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

describe("projectProgress", () => {
  it("computes completion percent per project and excludes projects with no tasks", () => {
    const tasks = [
      makeTask({ id: "t1", project_id: "p1", status: "completed" }),
      makeTask({ id: "t2", project_id: "p1", status: "todo" }),
    ]
    const projects = [
      { id: "p1", name: "Alpha" },
      { id: "p2", name: "Beta" },
    ]
    expect(projectProgress(tasks, projects)).toEqual([{ project_id: "p1", project_name: "Alpha", percent: 50 }])
  })
})
