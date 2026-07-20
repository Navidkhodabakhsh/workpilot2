import { describe, expect, it } from "vitest"
import { buildTaskTree, flattenTaskTree } from "./task-tree"
import type { Task } from "@/lib/types"

function makeTask(overrides: Partial<Task> & { id: string }): Task {
  return {
    organization_id: "org1",
    project_id: "proj1",
    parent_task_id: null,
    assignee_id: null,
    created_by_id: "user1",
    created_by_full_name: null,
    title: overrides.id,
    description: null,
    priority: "medium",
    value: "medium",
    status: "todo",
    approval_status: null,
    progress_percent: 0,
    estimated_hours: null,
    actual_hours: 0,
    pending_hours: 0,
    total_logged_hours: 0,
    start_date: null,
    deadline: null,
    created_at: "2026-01-01T00:00:00Z",
    ...overrides,
  }
}

describe("buildTaskTree", () => {
  it("nests children under their parent", () => {
    const tasks = [
      makeTask({ id: "parent" }),
      makeTask({ id: "child", parent_task_id: "parent" }),
      makeTask({ id: "grandchild", parent_task_id: "child" }),
    ]
    const tree = buildTaskTree(tasks)
    expect(tree).toHaveLength(1)
    expect(tree[0].id).toBe("parent")
    expect(tree[0].depth).toBe(0)
    expect(tree[0].children[0].id).toBe("child")
    expect(tree[0].children[0].depth).toBe(1)
    expect(tree[0].children[0].children[0].id).toBe("grandchild")
    expect(tree[0].children[0].children[0].depth).toBe(2)
  })

  it("treats a task whose parent is missing from the list as a root", () => {
    const tasks = [makeTask({ id: "orphan", parent_task_id: "does-not-exist" })]
    const tree = buildTaskTree(tasks)
    expect(tree).toHaveLength(1)
    expect(tree[0].id).toBe("orphan")
    expect(tree[0].depth).toBe(0)
  })

  it("keeps unrelated tasks as separate roots", () => {
    const tasks = [makeTask({ id: "a" }), makeTask({ id: "b" })]
    const tree = buildTaskTree(tasks)
    expect(tree.map((t) => t.id)).toEqual(["a", "b"])
  })
})

describe("flattenTaskTree", () => {
  it("flattens depth-first, parent before children", () => {
    const tasks = [
      makeTask({ id: "a" }),
      makeTask({ id: "a1", parent_task_id: "a" }),
      makeTask({ id: "a2", parent_task_id: "a" }),
      makeTask({ id: "b" }),
    ]
    const flat = flattenTaskTree(buildTaskTree(tasks))
    expect(flat.map((t) => t.id)).toEqual(["a", "a1", "a2", "b"])
  })
})
