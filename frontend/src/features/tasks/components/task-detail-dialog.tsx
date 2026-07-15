import { useRef, useState } from "react"
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query"
import { MessageSquare, Paperclip, Trash2, Upload } from "lucide-react"

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
import { useAuthStore } from "@/features/auth/auth-store"
import type { Task } from "@/lib/types"

function formatSize(bytes: number) {
  if (bytes < 1024) return `${bytes} بایت`
  if (bytes < 1024 * 1024) return `${Math.round(bytes / 1024)} کیلوبایت`
  return `${(bytes / (1024 * 1024)).toFixed(1)} مگابایت`
}

export function TaskDetailDialog({ task, trigger }: { task: Task; trigger: React.ReactNode }) {
  const [open, setOpen] = useState(false)
  const [commentBody, setCommentBody] = useState("")
  const fileInputRef = useRef<HTMLInputElement>(null)
  const currentUserId = useAuthStore((s) => s.user?.id)
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

  const commentMutation = useMutation({
    mutationFn: (body: string) => createComment(task.id, body),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["comments", task.id] })
      setCommentBody("")
    },
  })
  const uploadMutation = useMutation({
    mutationFn: (file: File) => uploadAttachment(task.id, file),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["attachments", task.id] })
      queryClient.invalidateQueries({ queryKey: ["org-attachments"] })
    },
  })
  const deleteMutation = useMutation({
    mutationFn: (attachmentId: string) => deleteAttachment(attachmentId),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["attachments", task.id] })
      queryClient.invalidateQueries({ queryKey: ["org-attachments"] })
    },
  })

  return (
    <Dialog open={open} onOpenChange={setOpen}>
      <DialogTrigger asChild>{trigger}</DialogTrigger>
      <DialogContent className="max-w-lg">
        <DialogHeader>
          <DialogTitle>{task.title}</DialogTitle>
          <DialogDescription>نظرات و فایل‌های پیوست این وظیفه</DialogDescription>
        </DialogHeader>

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
      </DialogContent>
    </Dialog>
  )
}
