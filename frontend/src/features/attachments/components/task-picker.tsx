import { useEffect, useRef, useState } from "react"
import { Search } from "lucide-react"

import { Input } from "@/components/ui/input"
import type { Project, Task } from "@/lib/types"

/** Searchable, project-grouped task picker -- a plain <select> with a few
 * hundred tasks in one flat list (the old UI) makes finding one by scrolling
 * alone impractical once a project has any real amount of history. */
export function TaskPicker({
  id,
  tasks,
  projects,
  value,
  onChange,
}: {
  id?: string
  tasks: Task[]
  projects: Project[]
  value: string
  onChange: (taskId: string) => void
}) {
  const [query, setQuery] = useState("")
  const [open, setOpen] = useState(false)
  const containerRef = useRef<HTMLDivElement>(null)

  useEffect(() => {
    function handleClickOutside(event: MouseEvent) {
      if (containerRef.current && !containerRef.current.contains(event.target as Node)) {
        setOpen(false)
      }
    }
    document.addEventListener("mousedown", handleClickOutside)
    return () => document.removeEventListener("mousedown", handleClickOutside)
  }, [])

  const selectedTask = tasks.find((t) => t.id === value)
  const projectName = (id: string | null) => (id ? (projects.find((p) => p.id === id)?.name ?? "—") : "شخصی")

  const filtered = tasks.filter((t) => !query.trim() || t.title.toLowerCase().includes(query.trim().toLowerCase()))
  const groups = new Map<string, Task[]>()
  for (const t of filtered) {
    const key = t.project_id ?? "__personal__"
    const arr = groups.get(key) ?? []
    arr.push(t)
    groups.set(key, arr)
  }
  const orderedGroupKeys = Array.from(groups.keys()).sort((a, b) => projectName(a === "__personal__" ? null : a).localeCompare(projectName(b === "__personal__" ? null : b)))

  return (
    <div ref={containerRef} className="relative">
      <div className="relative">
        <Search className="pointer-events-none absolute start-3 top-1/2 size-4 -translate-y-1/2 text-muted-foreground" />
        <Input
          id={id}
          value={open ? query : (selectedTask?.title ?? "")}
          onChange={(e) => {
            setQuery(e.target.value)
            if (value) onChange("")
          }}
          onFocus={() => {
            setOpen(true)
            setQuery("")
          }}
          placeholder="جست‌وجوی وظیفه..."
          className="ps-9"
          autoComplete="off"
        />
      </div>

      {open && (
        <div className="absolute start-0 end-0 top-full z-50 mt-1 max-h-72 overflow-y-auto rounded-lg border border-border bg-card p-1 shadow-lg">
          {filtered.length === 0 && <p className="p-3 text-sm text-muted-foreground">وظیفه‌ای یافت نشد.</p>}
          {orderedGroupKeys.map((key) => (
            <div key={key} className="mb-1 last:mb-0">
              <p className="px-2 py-1 text-xs font-semibold text-muted-foreground">
                {key === "__personal__" ? "شخصی" : projectName(key)}
              </p>
              {groups.get(key)!.map((t) => (
                <button
                  key={t.id}
                  type="button"
                  onClick={() => {
                    onChange(t.id)
                    setOpen(false)
                    setQuery("")
                  }}
                  className="flex w-full items-center rounded-md px-2 py-1.5 text-start text-sm hover:bg-muted"
                >
                  {t.title}
                </button>
              ))}
            </div>
          ))}
        </div>
      )}
    </div>
  )
}
