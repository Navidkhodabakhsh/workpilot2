# WorkPilot

سیستم مدیریت پروژه، وظایف و گزارش‌دهی سازمانی — پلتفرم تحت وب چندمستأجری (Multi-tenant SaaS) برای مدیریت پروژه‌ها، تخصیص وظایف، ثبت فعالیت کاری، تأیید گزارش و تحلیل عملکرد تیم.

## وضعیت فعلی توسعه

پروژه در حال ساخت است. برای وضعیت دقیق و آخرین Handoff به [`docs/PROJECT_STATE.md`](docs/PROJECT_STATE.md) مراجعه کنید.

**فاز فعلی:** فاز A (اسکلت پروژه) تکمیل شد؛ احراز هویت (signup/login/me) کار می‌کند و با مرورگر واقعی در دسکتاپ و موبایل تست شده. فازهای C تا J (مدیریت پروژه/وظایف، گزارش کاری، داشبورد، خروجی فایل، اعلان‌ها، امنیت، تست، Docker نهایی) باقی مانده‌اند.

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

### با Docker (روش پیشنهادی)

```bash
cp backend/.env.example backend/.env
docker compose up
```

- Backend روی `http://localhost:8000` (مستندات API: `/docs`)
- Frontend روی `http://localhost:5173`

### بدون Docker (اجرای مستقیم)

```bash
# Backend
cd backend
python -m venv .venv && source .venv/bin/activate   # یا: uv venv .venv
pip install -r requirements.txt                       # یا: uv pip install -r requirements.txt
cp .env.example .env   # و DATABASE_URL/SECRET_KEY را متناسب با محیط خودتان تنظیم کنید
alembic upgrade head
uvicorn app.main:app --reload

# Frontend (در ترمینال دیگر)
cd frontend
npm install
npm run dev
```

> نکته: در محیط‌های sandboxed که دیمان Docker بالا نمی‌آید، از Postgres/Redis نصب‌شدهٔ سیستم‌عامل (`service postgresql start` و `service redis-server start`) استفاده کنید — همین روش برای تست فاز A استفاده شد (جزئیات در `docs/PROJECT_STATE.md`).

## مشارکت

تغییرات معماری باید در `docs/ARCHITECTURE.md` و وضعیت پیشرفت در `docs/PROJECT_STATE.md` ثبت شود.
