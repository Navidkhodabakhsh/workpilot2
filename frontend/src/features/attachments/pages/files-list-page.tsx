import { useQuery } from "@tanstack/react-query"
import { Link } from "react-router-dom"

import { EmptyState } from "@/components/ui/empty-state"
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table"
import { downloadAttachment, listOrgAttachments } from "@/features/attachments/api"

function formatSize(bytes: number) {
  if (bytes < 1024) return `${bytes} بایت`
  if (bytes < 1024 * 1024) return `${Math.round(bytes / 1024)} کیلوبایت`
  return `${(bytes / (1024 * 1024)).toFixed(1)} مگابایت`
}

export function FilesListPage() {
  const { data: attachments, isLoading } = useQuery({
    queryKey: ["org-attachments"],
    queryFn: listOrgAttachments,
  })

  return (
    <div className="flex flex-col gap-4">
      <div>
        <h1 className="text-2xl font-bold">فایل‌ها</h1>
        <p className="text-muted-foreground">همهٔ فایل‌های پیوست‌شده به وظایف پروژه‌هایی که به آن‌ها دسترسی دارید</p>
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
