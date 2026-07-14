import csv
import os
import uuid
from datetime import date, datetime, timezone
from enum import Enum

from openpyxl import Workbook
from reportlab.lib import colors
from reportlab.lib.pagesizes import A4
from reportlab.platypus import SimpleDocTemplate, Table, TableStyle

from app.core.config import settings
from app.db.session import SessionLocal
from app.models.enums import ExportFileType, ExportJobStatus, WorkLogStatus
from app.models.export_job import ExportJob
from app.models.user import User
from app.services.reports import query_worklog_report
from app.workers.celery_app import celery_app

REPORT_HEADERS = [
    "project_name",
    "task_title",
    "user_full_name",
    "log_date",
    "time_spent_minutes",
    "progress_percent",
    "status",
    "activity_description",
]
REPORT_HEADERS_FA = [
    "پروژه",
    "وظیفه",
    "کاربر",
    "تاریخ",
    "زمان (دقیقه)",
    "پیشرفت (٪)",
    "وضعیت",
    "توضیحات",
]


def _cell_str(value: object) -> str:
    # WorkLogStatus etc. -- str(enum_member) gives "ClassName.member", not
    # the value ("approved"); unwrap it so exported files show plain text.
    if isinstance(value, Enum):
        return str(value.value)
    return str(value)


def _row_values(item: dict) -> list[str]:
    return [_cell_str(item[key]) for key in REPORT_HEADERS]


def _write_csv(items: list[dict], path: str) -> None:
    with open(path, "w", newline="", encoding="utf-8-sig") as f:
        writer = csv.writer(f)
        writer.writerow(REPORT_HEADERS_FA)
        for item in items:
            writer.writerow(_row_values(item))


def _write_excel(items: list[dict], path: str) -> None:
    wb = Workbook()
    ws = wb.active
    ws.title = "WorkLog Report"
    ws.append(REPORT_HEADERS_FA)
    for item in items:
        ws.append(_row_values(item))
    for column_cells in ws.columns:
        length = max(len(str(cell.value)) for cell in column_cells)
        ws.column_dimensions[column_cells[0].column_letter].width = min(max(length + 2, 10), 50)
    wb.save(path)


def _write_pdf(items: list[dict], path: str) -> None:
    doc = SimpleDocTemplate(path, pagesize=A4)
    data = [REPORT_HEADERS_FA] + [_row_values(item) for item in items]
    table = Table(data, repeatRows=1)
    table.setStyle(
        TableStyle(
            [
                ("BACKGROUND", (0, 0), (-1, 0), colors.HexColor("#4f46e5")),
                ("TEXTCOLOR", (0, 0), (-1, 0), colors.white),
                ("FONTSIZE", (0, 0), (-1, -1), 7),
                ("GRID", (0, 0), (-1, -1), 0.5, colors.grey),
                ("VALIGN", (0, 0), (-1, -1), "MIDDLE"),
            ]
        )
    )
    doc.build([table])


_WRITERS = {
    ExportFileType.csv: (_write_csv, "csv"),
    ExportFileType.excel: (_write_excel, "xlsx"),
    ExportFileType.pdf: (_write_pdf, "pdf"),
}


@celery_app.task(name="generate_export")
def generate_export(job_id: str) -> None:
    db = SessionLocal()
    try:
        job = db.get(ExportJob, uuid.UUID(job_id))
        if job is None:
            return

        job.status = ExportJobStatus.processing
        db.commit()

        try:
            requester = db.get(User, job.requested_by_id)
            filters = job.filters or {}
            report = query_worklog_report(
                db,
                job.organization_id,
                requester,
                project_id=uuid.UUID(filters["project_id"]) if filters.get("project_id") else None,
                user_id=uuid.UUID(filters["user_id"]) if filters.get("user_id") else None,
                status_filter=WorkLogStatus(filters["status_filter"]) if filters.get("status_filter") else None,
                date_from=date.fromisoformat(filters["date_from"]) if filters.get("date_from") else None,
                date_to=date.fromisoformat(filters["date_to"]) if filters.get("date_to") else None,
            )

            os.makedirs(settings.exports_dir, exist_ok=True)
            writer, extension = _WRITERS[job.export_type]
            file_path = os.path.join(settings.exports_dir, f"{job.id}.{extension}")
            writer(report["items"], file_path)

            job.status = ExportJobStatus.done
            job.file_path = file_path
            job.completed_at = datetime.now(timezone.utc)
        except Exception as exc:  # noqa: BLE001 -- report the failure on the job, don't crash the worker
            job.status = ExportJobStatus.failed
            job.error_message = str(exc)[:2000]
        db.commit()
    finally:
        db.close()
