import { apiClient } from "@/lib/api-client"

export type ExportFileType = "excel" | "pdf" | "csv"
export type ExportJobStatus = "pending" | "processing" | "done" | "failed"

export type ExportJob = {
  id: string
  export_type: ExportFileType
  status: ExportJobStatus
  error_message: string | null
  created_at: string
  completed_at: string | null
  download_available: boolean
}

export async function createExportJob(
  projectId: string,
  exportType: ExportFileType,
  dateRange?: { from: string; to: string }
) {
  const { data } = await apiClient.post<ExportJob>("/api/v1/exports", {
    export_type: exportType,
    project_id: projectId,
    date_from: dateRange?.from,
    date_to: dateRange?.to,
  })
  return data
}

export async function getExportJob(jobId: string) {
  const { data } = await apiClient.get<ExportJob>(`/api/v1/exports/${jobId}`)
  return data
}

const EXTENSION: Record<ExportFileType, string> = { excel: "xlsx", pdf: "pdf", csv: "csv" }

export async function downloadExportJob(jobId: string, exportType: ExportFileType) {
  const response = await apiClient.get(`/api/v1/exports/${jobId}/download`, { responseType: "blob" })
  const blob = new Blob([response.data])
  const url = window.URL.createObjectURL(blob)
  const link = document.createElement("a")
  link.href = url
  link.download = `workpilot-report-${jobId}.${EXTENSION[exportType]}`
  link.click()
  window.URL.revokeObjectURL(url)
}
