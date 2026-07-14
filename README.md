# WorkPilot

سیستم مدیریت پروژه، وظایف و گزارش‌دهی سازمانی — پلتفرم تحت وب چندمستأجری (Multi-tenant SaaS) برای مدیریت پروژه‌ها، تخصیص وظایف، ثبت فعالیت کاری، تأیید گزارش و تحلیل عملکرد تیم.

## وضعیت فعلی توسعه

پروژه در حال ساخت است. برای وضعیت دقیق و آخرین Handoff به [`docs/PROJECT_STATE.md`](docs/PROJECT_STATE.md) مراجعه کنید.

**فاز فعلی:** اسکلت پروژه (Phase A) — کد اپلیکیشن هنوز در حال ایجاد است.

## مستندات

| سند | محتوا |
|---|---|
| [`docs/RFB-WorkPilot-Project-Proposal.md`](docs/RFB-WorkPilot-Project-Proposal.md) | سند نیازمندی و پیشنهاد پروژه (RFB) |
| [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) | تصمیم‌های معماری فنی |
| [`docs/UI-DESIGN.md`](docs/UI-DESIGN.md) | جهت‌گیری طراحی رابط کاربری |
| [`docs/PROJECT_STATE.md`](docs/PROJECT_STATE.md) | وضعیت فعلی و تاریخچهٔ Handoff |

## تکنولوژی‌ها

- **Frontend:** React + TypeScript + Vite + Tailwind CSS + shadcn/ui
- **Backend:** FastAPI (Python) + SQLAlchemy + Alembic
- **پایگاه داده:** PostgreSQL
- **صف کار / کش:** Redis + Celery
- **استقرار:** Docker / docker-compose

## ساختار پروژه

```
backend/      → اپلیکیشن FastAPI
frontend/     → اپلیکیشن React + Vite
docker-compose.yml
docs/         → مستندات پروژه
skill/        → Skill های Claude نصب‌شده در این مخزن
```

## نحوهٔ اجرا (Local Development)

> این بخش به‌محض تکمیل اسکلت backend/frontend در فاز A تکمیل می‌شود.

```bash
docker compose up
```

## مشارکت

تغییرات معماری باید در `docs/ARCHITECTURE.md` و وضعیت پیشرفت در `docs/PROJECT_STATE.md` ثبت شود.
