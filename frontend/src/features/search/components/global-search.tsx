import { useEffect, useRef, useState } from "react"
import { useQuery } from "@tanstack/react-query"
import { useNavigate } from "react-router-dom"
import { Search } from "lucide-react"

import { globalSearch } from "@/features/search/api"

export function GlobalSearch() {
  const [query, setQuery] = useState("")
  const [debouncedQuery, setDebouncedQuery] = useState("")
  const [open, setOpen] = useState(false)
  const containerRef = useRef<HTMLDivElement>(null)
  const navigate = useNavigate()

  useEffect(() => {
    const timer = setTimeout(() => setDebouncedQuery(query), 300)
    return () => clearTimeout(timer)
  }, [query])

  const { data, isFetching } = useQuery({
    queryKey: ["search", debouncedQuery],
    queryFn: () => globalSearch(debouncedQuery),
    enabled: debouncedQuery.trim().length >= 2,
  })

  useEffect(() => {
    function handleClickOutside(event: MouseEvent) {
      if (containerRef.current && !containerRef.current.contains(event.target as Node)) {
        setOpen(false)
      }
    }
    document.addEventListener("mousedown", handleClickOutside)
    return () => document.removeEventListener("mousedown", handleClickOutside)
  }, [])

  function go(path: string) {
    setOpen(false)
    setQuery("")
    navigate(path)
  }

  const hasQuery = debouncedQuery.trim().length >= 2
  const hasResults = !!data && (data.projects.length > 0 || data.tasks.length > 0 || data.users.length > 0)

  return (
    <div ref={containerRef} className="relative min-w-0 flex-1">
      <div className="flex items-center gap-2 rounded-md border border-input bg-background px-3 py-2">
        <Search className="size-4 shrink-0 text-muted-foreground" />
        <input
          type="search"
          value={query}
          onChange={(e) => {
            setQuery(e.target.value)
            setOpen(true)
          }}
          onFocus={() => setOpen(true)}
          placeholder="جست‌وجو در پروژه‌ها، کارها، کاربران..."
          className="w-full min-w-0 bg-transparent text-sm outline-none placeholder:text-muted-foreground"
        />
      </div>

      {open && hasQuery && (
        <div className="absolute start-0 top-full z-50 mt-2 w-full min-w-72 rounded-lg border border-border bg-card shadow-lg">
          {isFetching && <p className="p-4 text-sm text-muted-foreground">در حال جست‌وجو...</p>}
          {!isFetching && !hasResults && (
            <p className="p-4 text-sm text-muted-foreground">نتیجه‌ای یافت نشد.</p>
          )}
          {!isFetching && data && (
            <div className="max-h-80 overflow-y-auto py-1">
              {data.projects.length > 0 && (
                <SearchGroup title="پروژه‌ها">
                  {data.projects.map((p) => (
                    <SearchResultRow key={p.id} onClick={() => go(`/projects/${p.id}`)}>
                      {p.name}
                    </SearchResultRow>
                  ))}
                </SearchGroup>
              )}
              {data.tasks.length > 0 && (
                <SearchGroup title="کارها">
                  {data.tasks.map((t) => (
                    <SearchResultRow key={t.id} onClick={() => go(`/projects/${t.project_id}`)}>
                      {t.title}
                    </SearchResultRow>
                  ))}
                </SearchGroup>
              )}
              {data.users.length > 0 && (
                <SearchGroup title="کاربران">
                  {data.users.map((u) => (
                    <SearchResultRow key={u.id} onClick={() => go("/users")}>
                      {u.full_name}
                    </SearchResultRow>
                  ))}
                </SearchGroup>
              )}
            </div>
          )}
        </div>
      )}
    </div>
  )
}

function SearchGroup({ title, children }: { title: string; children: React.ReactNode }) {
  return (
    <div>
      <p className="px-3 pt-2 text-xs font-medium text-muted-foreground">{title}</p>
      {children}
    </div>
  )
}

function SearchResultRow({ children, onClick }: { children: React.ReactNode; onClick: () => void }) {
  return (
    <button
      onClick={onClick}
      className="block w-full px-3 py-2 text-start text-sm hover:bg-muted"
    >
      {children}
    </button>
  )
}
