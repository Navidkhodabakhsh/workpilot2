import { useEffect, useRef, useState } from "react"
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query"
import { Bell } from "lucide-react"

import { Button } from "@/components/ui/button"
import { getUnreadCount, listNotifications, markAllRead, markRead } from "@/features/notifications/api"
import { notificationMessage } from "@/features/notifications/message"

export function NotificationBell() {
  const [open, setOpen] = useState(false)
  const containerRef = useRef<HTMLDivElement>(null)
  const queryClient = useQueryClient()

  const { data: unreadCount } = useQuery({
    queryKey: ["notifications", "unread-count"],
    queryFn: getUnreadCount,
    refetchInterval: 30000,
  })
  const { data: notifications } = useQuery({
    queryKey: ["notifications", "list"],
    queryFn: listNotifications,
    enabled: open,
  })

  const invalidate = () => {
    queryClient.invalidateQueries({ queryKey: ["notifications"] })
  }
  const markReadMutation = useMutation({ mutationFn: markRead, onSuccess: invalidate })
  const markAllReadMutation = useMutation({ mutationFn: markAllRead, onSuccess: invalidate })

  useEffect(() => {
    function handleClickOutside(event: MouseEvent) {
      if (containerRef.current && !containerRef.current.contains(event.target as Node)) {
        setOpen(false)
      }
    }
    document.addEventListener("mousedown", handleClickOutside)
    return () => document.removeEventListener("mousedown", handleClickOutside)
  }, [])

  return (
    <div className="relative" ref={containerRef}>
      <Button variant="ghost" size="icon" aria-label="اعلان‌ها" onClick={() => setOpen((v) => !v)}>
        <Bell className="size-5" />
        {!!unreadCount && (
          <span className="absolute -top-0.5 -end-0.5 flex size-4 items-center justify-center rounded-full bg-danger text-[10px] text-white">
            {unreadCount > 9 ? "9+" : unreadCount}
          </span>
        )}
      </Button>

      {open && (
        <div className="absolute end-0 top-full z-50 mt-2 w-80 max-w-[85vw] rounded-lg border border-border bg-card shadow-lg">
          <div className="flex items-center justify-between border-b border-border p-3">
            <span className="font-medium">اعلان‌ها</span>
            {!!unreadCount && (
              <button
                className="text-xs text-primary hover:underline"
                onClick={() => markAllReadMutation.mutate()}
              >
                علامت‌گذاری همه به‌عنوان خوانده‌شده
              </button>
            )}
          </div>
          <div className="max-h-80 overflow-y-auto">
            {!notifications || notifications.length === 0 ? (
              <p className="p-4 text-sm text-muted-foreground">اعلانی وجود ندارد.</p>
            ) : (
              notifications.map((n) => (
                <button
                  key={n.id}
                  onClick={() => !n.is_read && markReadMutation.mutate(n.id)}
                  className={`block w-full border-b border-border p-3 text-start text-sm last:border-0 hover:bg-muted ${
                    n.is_read ? "text-muted-foreground" : "font-medium"
                  }`}
                >
                  {notificationMessage(n)}
                </button>
              ))
            )}
          </div>
        </div>
      )}
    </div>
  )
}
