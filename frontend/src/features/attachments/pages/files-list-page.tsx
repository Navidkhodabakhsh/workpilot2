import { useRef, useState } from "react"
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query"
import { Link } from "react-router-dom"
import { Plus, Upload } from "lucide-react"

import { Button } from "@/components/ui/button"
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog"
import { EmptyState } from "@/components/ui/empty-state"
import { Label } from "@/components/ui/label"
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table"
import { downloadAttachment, listOrgAttachments, uploadAttachment } from "@/features/attachments/api"
import { TaskPicker } from "@/features/attachments/components/task-picker"
import { listAllTasks } from "@/features/tasks/api"
import { listProjects } from "@/features/projects/api"

function formatSize(bytes: number) {
  if (bytes < 1024) return `${bytes} بایت`
  if (bytes < 1024 * 1024) return `${Math.round(bytes / 1024)} کیلوبایت`
  return `${(bytes / (1024 * 1024)).toFixed(1)} مگابایت`
}

function UploadFileDialog() {
  const [open, setOpen] = useState(false)
  const [taskId, setTaskId] = useState("")
  const [error, setError] = useState<string | null>(null)
  const fileInputRef = useRef<HTMLInputElement>(null)
  const queryClient = useQueryClient()

  const { data: tasks } = useQuery({ queryKey: ["tasks", "all"], queryFn: () => listAllTasks(), enabled: open })
  const { data: projects } = useQuery({ queryKey: ["projects"], queryFn: listProjects, enabled: open })

  const uploadMutation = useMutation({
    mutationFn: (file: File) => uploadAttachment(taskId, file),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["org-attachments"] })
      setOpen(false)
      setTaskId("")
      if (fileInputRef.current) fileInputRef.current.value = ""
    },
    onError: () => setError("آپلود فایل با خطا مواجه شد؛ دوباره تلاش کنید"),
  })

  function handleSubmit(event: React.FormEvent) {
    event.preventDefault()
    setError(null)
    const file = fileInputRef.current?.files?.[0]
    if (!taskId) {
      setError("یک وظیفه را انتخاب کنید")
      return
    }
    if (!file) {
      setError("یک فایل انتخاب کنید")
      return
    }
    uploadMutation.mutate(file)
  }

  return (
    <Dialog open={open} onOpenChange={setOpen}>
      <DialogTrigger asChild>
        <Button>
          <Plus className="size-4" />
          افزودن فایل
        </Button>
      </DialogTrigger>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>افزودن فایل</DialogTitle>
          <DialogDescription>فایل را به یکی از وظایف پیوست کنید</DialogDescription>
        </DialogHeader>
        <form onSubmit={handleSubmit} className="flex flex-col gap-4">
          <div className="flex flex-col gap-2">
            <Label htmlFor="attachment-task">وظیفه</Label>
            <TaskPicker
              id="attachment-task"
              tasks={tasks ?? []}
              projects={projects ?? []}
              value={taskId}
              onChange={setTaskId}
            />
          </div>
          <div className="flex flex-col gap-2">
            <Label htmlFor="attachment-file">فایل</Label>
            <input
              id="attachment-file"
              ref={fileInputRef}
              type="file"
              className="text-sm file:me-3 file:rounded-md file:border-0 file:bg-muted file:px-3 file:py-1.5 file:text-sm file:font-medium hover:file:bg-muted/80"
            />
          </div>
          {error && <p className="text-sm text-danger">{error}</p>}
          <Button type="submit" disabled={uploadMutation.isPending}>
            <Upload className="size-4" />
            {uploadMutation.isPending ? "در حال آپلود..." : "آپلود"}
          </Button>
        </form>
      </DialogContent>
    </Dialog>
  )
}

export function FilesListPage() {
  const { data: attachments, isLoading } = useQuery({
    queryKey: ["org-attachments"],
    queryFn: listOrgAttachments,
  })

  return (
    <div className="flex flex-col gap-4">
      <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <h1 className="text-2xl font-bold">فایل‌ها</h1>
          <p className="text-muted-foreground">همهٔ فایل‌های پیوست‌شده به وظایف پروژه‌هایی که به آن‌ها دسترسی دارید</p>
        </div>
        <UploadFileDialog />
      </div>

      {isLoading && <p className="text-muted-foreground">در حال بارگذاری...</p>}

      {!isLoading && (!attachments || attachments.length === 0) && (
        <EmptyState message="هنوز فایلی پیوست نشده است." />
      )}

      {!isLoading && attachments && attachments.length > 0 && (
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>فایل</TableHead>
              <TableHead>وظیفه</TableHead>
              <TableHead>آپلودکننده</TableHead>
              <TableHead>حجم</TableHead>
              <TableHead>تاریخ</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {attachments.map((a) => (
              <TableRow key={a.id}>
                <TableCell className="font-medium">
                  <button
                    onClick={() => downloadAttachment(a.id, a.original_filename)}
                    className="text-primary hover:underline"
                  >
                    {a.original_filename}
                  </button>
                </TableCell>
                <TableCell>
                  {a.project_id ? (
                    <Link to={`/projects/${a.project_id}`} className="hover:underline">
                      {a.task_title}
                    </Link>
                  ) : (
                    a.task_title
                  )}
                </TableCell>
                <TableCell>{a.uploaded_by_full_name}</TableCell>
                <TableCell>{formatSize(a.size_bytes)}</TableCell>
                <TableCell>{new Date(a.created_at).toLocaleDateString("fa-IR")}</TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      )}
    </div>
  )
}
