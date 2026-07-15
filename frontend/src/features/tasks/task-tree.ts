import type { Task } from "@/lib/types"

export type TaskTreeNode = Task & { children: TaskTreeNode[]; depth: number }

/** Builds a parent/child tree from a flat task list via parent_task_id.
 * A task whose parent isn't present in the given list (e.g. the parent
 * didn't match the active tab's filter) is treated as a root, so it's
 * never silently dropped from the view. */
export function buildTaskTree(tasks: Task[]): TaskTreeNode[] {
  const byId = new Map<string, TaskTreeNode>(tasks.map((t) => [t.id, { ...t, children: [], depth: 0 }]))
  const roots: TaskTreeNode[] = []

  for (const node of byId.values()) {
    const parent = node.parent_task_id ? byId.get(node.parent_task_id) : undefined
    if (parent) {
      parent.children.push(node)
    } else {
      roots.push(node)
    }
  }

  function assignDepth(nodes: TaskTreeNode[], depth: number) {
    for (const node of nodes) {
      node.depth = depth
      assignDepth(node.children, depth + 1)
    }
  }
  assignDepth(roots, 0)

  return roots
}

/** Depth-first flatten, preserving parent-before-children order, for
 * rendering the tree as a flat list of indented rows. */
export function flattenTaskTree(nodes: TaskTreeNode[]): TaskTreeNode[] {
  const out: TaskTreeNode[] = []
  function walk(list: TaskTreeNode[]) {
    for (const node of list) {
      out.push(node)
      walk(node.children)
    }
  }
  walk(nodes)
  return out
}
