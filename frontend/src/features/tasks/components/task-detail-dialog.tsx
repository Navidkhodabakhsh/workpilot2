import { useRef, useState } from "react"
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query"
import { CheckCircle2, History, MessageSquare, Paperclip, Trash2, Upload, XCircle } from "lucide-react"

import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog"
import { Textarea } from "@/components/ui/textarea"
import { createComment, listComments } from "@/features/comments/api"
import {
  deleteAttachment,
  downloadAttachment,
  listTaskAttachments,
  uploadAttachment,
} from "@/features/attachments/api"
import { approveTask, getTaskActivity, rejectTask } from "@/features/tasks/api"
import { APPROVAL_LABEL, APPROVAL_VARIANT, PRIORITY_LABEL, STATUS_LABEL } from "@/features/tasks/constants"
import { useAuthStore } from "@/features/auth/auth-store"
import type { Task } from "@/lib/types"

function formatSize(bytes: number) {
  if (bytes < 1024) return `${bytes} بایت`
  if (bytes < 1024 * 1024) return `${Math.round(bytes / 1024)} کیلوبایت`
  return `${(bytes / (1024 * 1024)).toFixed(1)} مگابایت`
}

const ACTIVITY_LABEL: Record<string, string> = {
  "task.create": "وظیفه ایجاد شد",
  "task.status_change": "وضعیت تغییر کرد",
  "task.assignee_change": "مسئول تغییر کرد",
  "task.priority_change": "اولویت تغییر کرد",
  "task.comment": "نظر ثبت شد",
  "task.attachment": "فایل پیوست شد",
  "task.approve": "تأیید شد",
  "task.reject": "رد شد",
}

function translateValue(action: string, value: string): string {
  if (action === "task.status_change") return STATUS_LABEL[value as keyof typeof STATUS_LABEL] ?? value
  if (action === "task.priority_change") return PRIORITY_LABEL[value] ?? value
  return value
}

function ActivityDescription({ action, metadata }: { action: string; metadata: Record<string, unknown> }) {
  const label = ACTIVITY_LABEL[action] ?? action
  if ((action === "task.status_change" || action === "task.priority_change") && metadata.from && metadata.to) {
    return (
      <span>
        {label}: <span className="text-muted-foreground">{translateValue(action, String(metadata.from))}</span> ←{" "}
        <span className="font-medium">{translateValue(action, String(metadata.to))}</span>
      </span>
    )
  }
  if (action === "task.reject" && metadata.review_comment) {
    return (
      <span>
        {label}: <span className="text-muted-foreground">{String(metadata.review_comment)}</span>
      </span>
    )
  }
  return <span>{label}</span>
}

export function TaskDetailDialog({ task, trigger }: { task: Task; trigger: React.ReactNode }) {
  const [open, setOpen] = useState(false)
  const [commentBody, setCommentBody] = useState("")
  const [rejecting, setRejecting] = useState(false)
  const [rejectComment, setRejectComment] = useState("")
  const fileInputRef = useRef<HTMLInputElement>(null)
  const currentUserId = useAuthStore((s) => s.user?.id)
  const role = useAuthStore((s) => s.user?.role)
  const canReview = task.project_id !== null && (role === "org_admin" || role === "project_manager")
  const queryClient = useQueryClient()

  const { data: comments } = useQuery({
    queryKey: ["comments", task.id],
    queryFn: () => listComments(task.id),
    enabled: open,
  })
  const { data: attachments } = useQuery({
    queryKey: ["attachments", task.id],
    queryFn: () => listTaskAttachments(task.id),
    enabled: open,
  })
  const { data: activity } = useQuery({
    queryKey: ["task-activity", task.id],
    queryFn: () => getTaskActivity(task.id),
    enabled: open,
  })

  const commentMutation = useMutation({
    mutationFn: (body: string) => createComment(task.id, body),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["comments", task.id] })
      queryClient.invalidateQueries({ queryKey: ["task-activity", task.id] })
      setCommentBody("")
    },
  })
  const uploadMutation = useMutation({
    mutationFn: (file: File) => uploadAttachment(task.id, file),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["attachments", task.id] })
      queryClient.invalidateQueries({ queryKey: ["org-attachments"] })
      queryClient.invalidateQueries({ queryKey: ["task-activity", task.id] })
    },
  })
  const deleteMutation = useMutation({
    mutationFn: (attachmentId: string) => deleteAttachment(attachmentId),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["attachments", task.id] })
      queryClient.invalidateQueries({ queryKey: ["org-attachments"] })
    },
  })
  const approveMutation = useMutation({
    mutationFn: () => approveTask(task.id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["tasks"], exact: false })
      queryClient.invalidateQueries({ queryKey: ["task-activity", task.id] })
    },
  })
  const rejectMutation = useMutation({
    mutationFn: (comment: string) => rejectTask(task.id, comment),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["tasks"], exact: false })
      queryClient.invalidateQueries({ queryKey: ["task-activity", task.id] })
      setRejecting(false)
      setRejectComment("")
    },
  })

  return (
    <Dialog open={open} onOpenChange={setOpen}>
      <DialogTrigger asChild>{trigger}</DialogTrigger>
      <DialogContent className="max-h-[85vh] max-w-lg overflow-y-auto">
        <DialogHeader>
          <DialogTitle>{task.title}</DialogTitle>
          <DialogDescription>نظرات، فایل‌ها و تاریخچهٔ این وظیفه</DialogDescription>
        </DialogHeader>

        {canReview && task.approval_status === "pending" && (
          <div className="flex flex-col gap-2 rounded-md border border-warning/30 bg-warning/10 p-3">
            <div className="flex items-center justify-between gap-2">
              <p className="text-sm font-medium">این وظیفه در انتظار تأیید است</p>
              <Badge variant={APPROVAL_VARIANT.pending}>{APPROVAL_LABEL.pending}</Badge>
            </div>
            {rejecting ? (
              <div className="flex flex-col gap-2">
                <Textarea
                  placeholder="دلیل رد را بنویسید..."
                  value={rejectComment}
                  onChange={(e) => setRejectComment(e.target.value)}
                />
                <div className="flex gap-2">
                  <Button
                    size="sm"
                    variant="destructive"
                    disabled={rejectComment.trim().length < 2 || rejectMutation.isPending}
                    onClick={() => rejectMutation.mutate(rejectComment)}
                  >
                    ثبت رد
                  </Button>
                  <Button size="sm" variant="ghost" onClick={() => setRejecting(false)}>
                    انصراف
                  </Button>
                </div>
              </div>
            ) : (
              <div className="flex gap-2">
                <Button size="sm" disabled={approveMutation.isPending} onClick={() => approveMutation.mutate()}>
                  <CheckCircle2 className="size-4" />
                  تأیید
                </Button>
                <Button size="sm" variant="outline" onClick={() => setRejecting(true)}>
                  <XCircle className="size-4" />
                  رد
                </Button>
              </div>
            )}
          </div>
        )}

        <div className="flex flex-col gap-2">
          <h3 className="flex items-center gap-2 text-sm font-semibold">
            <MessageSquare className="size-4" />
            نظرات
          </h3>
          <div className="flex max-h-48 flex-col gap-2 overflow-y-auto rounded-md border border-border p-2">
            {comments?.length === 0 && <p className="text-sm text-muted-foreground">هنوز نظری ثبت نشده است.</p>}
            {comments?.map((c) => (
              <div key={c.id} className="border-b border-border pb-2 text-sm last:border-0 last:pb-0">
                <p>
                  <span className="font-medium">{c.author_full_name}</span>{" "}
                  <span className="text-xs text-muted-foreground">
                    {new Date(c.created_at).toLocaleString("fa-IR")}
                  </span>
                </p>
                <p className="text-muted-foreground">{c.body}</p>
              </div>
            ))}
          </div>
          <div className="flex gap-2">
            <Textarea
              placeholder="نظر خود را بنویسید..."
              value={commentBody}
              onChange={(e) => setCommentBody(e.target.value)}
              className="min-h-16"
            />
          </div>
          <Button
            size="sm"
            className="self-end"
            disabled={commentBody.trim().length === 0 || commentMutation.isPending}
            onClick={() => commentMutation.mutate(commentBody)}
          >
            ارسال نظر
          </Button>
        </div>

        <div className="flex flex-col gap-2">
          <h3 className="flex items-center gap-2 text-sm font-semibold">
            <Paperclip className="size-4" />
            فایل‌های پیوست
          </h3>
          <div className="flex flex-col gap-2 rounded-md border border-border p-2">
            {attachments?.length === 0 && <p className="text-sm text-muted-foreground">فایلی پیوست نشده است.</p>}
            {attachments?.map((a) => (
              <div key={a.id} className="flex items-center justify-between gap-2 text-sm">
                <button
                  onClick={() => downloadAttachment(a.id, a.original_filename)}
                  className="truncate text-primary hover:underline"
                >
                  {a.original_filename}
                </button>
                <div className="flex shrink-0 items-center gap-2 text-xs text-muted-foreground">
                  <span>{formatSize(a.size_bytes)}</span>
                  {a.uploaded_by_id === currentUserId && (
                    <button
                      onClick={() => deleteMutation.mutate(a.id)}
                      aria-label="حذف فایل"
                      className="text-danger hover:text-danger/80"
                    >
                      <Trash2 className="size-4" />
                    </button>
                  )}
                </div>
              </div>
            ))}
          </div>
          <input
            ref={fileInputRef}
            type="file"
            className="hidden"
            onChange={(e) => {
              const file = e.target.files?.[0]
              if (file) uploadMutation.mutate(file)
              e.target.value = ""
            }}
          />
          <Button
            size="sm"
            variant="outline"
            className="self-end"
            disabled={uploadMutation.isPending}
            onClick={() => fileInputRef.current?.click()}
          >
            <Upload className="size-4" />
            {uploadMutation.isPending ? "در حال آپلود..." : "افزودن فایل"}
          </Button>
        </div>

        <div className="flex flex-col gap-2">
          <h3 className="flex items-center gap-2 text-sm font-semibold">
            <History className="size-4" />
            تاریخچه
          </h3>
          <div className="flex max-h-48 flex-col gap-2 overflow-y-auto rounded-md border border-border p-2">
            {activity?.length === 0 && <p className="text-sm text-muted-foreground">فعالیتی ثبت نشده است.</p>}
            {activity?.map((entry) => (
              <div key={entry.id} className="border-b border-border pb-2 text-sm last:border-0 last:pb-0">
                <p>
                  <span className="font-medium">{entry.actor_full_name ?? "سیستم"}</span>{" "}
                  <span className="text-xs text-muted-foreground">
                    {new Date(entry.created_at).toLocaleString("fa-IR")}
                  </span>
                </p>
                <p className="text-muted-foreground">
                  <ActivityDescription action={entry.action} metadata={entry.extra_metadata} />
                </p>
              </div>
            ))}
          </div>
        </div>
      </DialogContent>
    </Dialog>
  )
}
