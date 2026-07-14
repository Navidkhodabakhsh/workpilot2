import { useRef, useState } from "react"
import { Download } from "lucide-react"

import { Button } from "@/components/ui/button"
import { Label } from "@/components/ui/label"
import { Select } from "@/components/ui/select"
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog"
import { createExportJob, downloadExportJob, getExportJob } from "@/features/exports/api"
import type { ExportFileType, ExportJobStatus } from "@/features/exports/api"

const FORMAT_LABEL: Record<ExportFileType, string> = { excel: "Excel", pdf: "PDF", csv: "CSV" }

export function ExportDialog({ projectId }: { projectId: string }) {
  const [open, setOpen] = useState(false)
  const [format, setFormat] = useState<ExportFileType>("excel")
  const [status, setStatus] = useState<ExportJobStatus | "idle">("idle")
  const [error, setError] = useState<string | null>(null)
  const pollRef = useRef<number | null>(null)

  function stopPolling() {
    if (pollRef.current !== null) {
      window.clearInterval(pollRef.current)
      pollRef.current = null
    }
  }

  async function handleExport() {
    setError(null)
    setStatus("pending")
    const job = await createExportJob(projectId, format)

    pollRef.current = window.setInterval(async () => {
      const updated = await getExportJob(job.id)
      setStatus(updated.status)
      if (updated.status === "done") {
        stopPolling()
        await downloadExportJob(job.id, format)
      } else if (updated.status === "failed") {
        stopPolling()
        setError(updated.error_message ?? "خروجی گرفتن با خطا مواجه شد")
      }
    }, 1000)
  }

  return (
    <Dialog
      open={open}
      onOpenChange={(next) => {
        setOpen(next)
        if (!next) {
          stopPolling()
          setStatus("idle")
          setError(null)
        }
      }}
    >
      <DialogTrigger asChild>
        <Button variant="outline">
          <Download className="size-4" />
          خروجی گزارش
        </Button>
      </DialogTrigger>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>خروجی گرفتن از گزارش‌های کاری</DialogTitle>
          <DialogDescription>فرمت موردنظر را انتخاب کنید</DialogDescription>
        </DialogHeader>
        <div className="flex flex-col gap-4">
          <div className="flex flex-col gap-2">
            <Label htmlFor="export-format">فرمت خروجی</Label>
            <Select
              id="export-format"
              value={format}
              onChange={(e) => setFormat(e.target.value as ExportFileType)}
              disabled={status === "pending" || status === "processing"}
            >
              {(["excel", "pdf", "csv"] as const).map((f) => (
                <option key={f} value={f}>
                  {FORMAT_LABEL[f]}
                </option>
              ))}
            </Select>
          </div>

          {(status === "pending" || status === "processing") && (
            <p className="text-sm text-muted-foreground">در حال آماده‌سازی فایل...</p>
          )}
          {status === "done" && <p className="text-sm text-success">فایل آماده شد و دانلود شروع شد.</p>}
          {error && <p className="text-sm text-danger">{error}</p>}

          <Button onClick={handleExport} disabled={status === "pending" || status === "processing"}>
            {status === "pending" || status === "processing" ? "در حال پردازش..." : "دریافت خروجی"}
          </Button>
        </div>
      </DialogContent>
    </Dialog>
  )
}
