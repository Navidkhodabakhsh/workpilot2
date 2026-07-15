# WorkPilot

سیستم مدیریت پروژه، وظایف و گزارش‌دهی سازمانی — پلتفرم تحت وب چندمستأجری (Multi-tenant SaaS) برای مدیریت پروژه‌ها، تخصیص وظایف، ثبت فعالیت کاری، تأیید گزارش و تحلیل عملکرد تیم. طراحی RTL و کاملاً واکنش‌گرا (Mobile-First) بر پایهٔ محتوای فارسی.

## وضعیت فعلی توسعه

**فازهای A تا Z تکمیل شده‌اند + یک دور بازخورد سوم دربارهٔ احراز هویت.** فازهای A تا J دامنهٔ اصلی RFB را ساختند؛ فازهای K تا R (بازطراحی بصری کامل + تکمیل هر ۱۱ آیتم منو) و فازهای S تا Z (ریبرندینگ Tadvin Hesab + بازسازی کامل تسک‌ها و تقویم) پس از دو دور بازخورد واقعی کاربر اضافه شدند؛ دور سوم بازخورد صفحهٔ ورود را کاملاً موبایل‌محور کرد. تمام ۸ خروجی نهایی پروژه طبق بخش ۱۵ RFB ساخته و تست شده‌اند:

- [x] پنل مدیریت سازمان (ساخت/مدیریت کاربران با نقش و ویرایش، Audit Log)
- [x] پنل کاربران (پروفایل، نقش‌ها: platform_admin / org_admin / project_manager / employee؛ ورود فقط با شماره موبایل — رمز عبور یا کد یکبار مصرف پیامکی، فراموشی رمز، دعوت کاربر فقط با موبایل بدون رمز)
- [x] مدیریت پروژه‌ها (CRUD + عضویت)
- [x] مدیریت وظایف (تسک‌ها) — وضعیت و تأیید مستقل از هم، تسک شخصی بدون پروژه، تاریخچهٔ کامل فعالیت، درخت زیروظیفه، ۶ تب فیلتر، وابستگی با تشخیص چرخه، تختهٔ Kanban + فهرست سراسری
- [x] گزارش‌دهی کاری (ثبت → تأیید/رد توسط مدیر پروژه)
- [x] داشبورد تحلیلی (آمار پروژه/وظیفه/ساعت کاری + نمودار پیشرفت پروژه‌ها + گزارش‌گیری با فیلتر + روند زمانی)
- [x] سیستم خروجی فایل (CSV / Excel / PDF، ۹ بازهٔ زمانی آماده، تولید ناهمزمان با Celery)
- [x] سیستم امنیتی (JWT + Refresh Token httpOnly، RBAC، Rate Limiting، سیاست رمز عبور، Audit Log)

به‌علاوه، هر ۱۱ آیتم منوی برنامه به یک صفحهٔ واقعی و کاربردی وصل است — از جمله تقویم کامل (FullCalendar: نمای ماه/هفته/روز/برنامه، جلسه/مرخصی/تعطیلی/یادآوری، Drag & Drop) و دو ماژول بدون تعریف قبلی در RFB (گردش کار، پیام‌ها) که با تفسیر مشخص و مستند ساخته شدند (جزئیات در `docs/PROJECT_STATE.md`).

برای وضعیت دقیق، تصمیم‌های معماری، و تاریخچهٔ کامل هر مرحلهٔ توسعه به [`docs/PROJECT_STATE.md`](docs/PROJECT_STATE.md) مراجعه کنید.

## مستندات

| سند | محتوا |
|---|---|
| [`docs/RFB-WorkPilot-Project-Proposal.md`](docs/RFB-WorkPilot-Project-Proposal.md) | سند نیازمندی و پیشنهاد پروژه (RFB) |
| [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) | تصمیم‌های معماری فنی |
| [`docs/UI-DESIGN.md`](docs/UI-DESIGN.md) | جهت‌گیری طراحی رابط کاربری (غیرنهایی) |
| [`docs/PROJECT_STATE.md`](docs/PROJECT_STATE.md) | وضعیت فعلی و تاریخچهٔ Handoff هر فاز |

## تکنولوژی‌ها

- **Frontend:** React 19 + TypeScript + Vite + Tailwind CSS v4 + shadcn/ui (دستی، بدون CLI) + React Query + Zustand + react-router + recharts
- **Backend:** FastAPI (Python) + SQLAlchemy 2.0 + Alembic + Pydantic
- **پایگاه داده:** PostgreSQL
- **صف کار / کش:** Redis + Celery (worker + beat)
- **تست:** pytest (بک‌اند)، vitest + React Testing Library (فرانت)
- **CI:** GitHub Actions (`.github/workflows/ci.yml`)
- **استقرار:** Docker / docker-compose

## ساختار پروژه

```
backend/      → اپلیکیشن FastAPI (app/{models,schemas,services,api,workers,db,core}, alembic/, tests/)
frontend/     → اپلیکیشن React + Vite (src/{features,components,app,lib})
docker-compose.yml
docs/         → مستندات پروژه
skill/        → Skill های Claude نصب‌شده در این مخزن
```

## نحوهٔ اجرا (Local Development)

### با Docker (روش پیشنهادی)

```bash
cp backend/.env.example backend/.env    # اختیاری برای اجرای محلی؛ برای production حتماً SECRET_KEY را عوض کنید
docker compose up
```

Migration دیتابیس به‌صورت خودکار توسط سرویس `backend` هنگام بالا آمدن اجرا می‌شود (نیازی به دستور دستی نیست).

- Backend: `http://localhost:8000` (مستندات API خودکار: `/docs`)
- Frontend: `http://localhost:5173`
- سرویس‌های `worker` و `beat` به‌صورت خودکار برای پردازش خروجی فایل و یادآوری مهلت اجرا می‌شوند.

> **محدودیت شناخته‌شده:** پیکربندی `docker-compose.yml` در این مخزن با `docker compose config` اعتبارسنجی شده، ولی به‌دلیل محدودیت دسترسی دیمان Docker در محیط توسعهٔ این جلسه (sandbox)، اجرای واقعی `docker compose up` امکان‌پذیر نبود. تمام فازهای توسعه با Postgres/Redis نصب‌شدهٔ سیستم‌عامل به‌صورت native تأیید شدند (جزئیات در `docs/PROJECT_STATE.md`، بخش «محدودیت محیط»). در یک محیط با دسترسی کامل به Docker باید یک بار `docker compose up` تأیید نهایی شود.

### بدون Docker (اجرای مستقیم)

```bash
# پیش‌نیاز: PostgreSQL و Redis در حال اجرا (به‌صورت native یا هر روش دیگر)

# Backend
cd backend
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env   # و DATABASE_URL/SECRET_KEY را متناسب با محیط خودتان تنظیم کنید
alembic upgrade head
uvicorn app.main:app --reload

# Celery worker (ترمینال جدا، برای خروجی فایل)
celery -A app.workers.celery_app worker --loglevel=info

# Celery beat (ترمینال جدا، برای یادآوری مهلت روزانه — اختیاری برای توسعهٔ محلی)
celery -A app.workers.celery_app beat --loglevel=info

# Frontend (ترمینال جدا)
cd frontend
npm install
npm run dev
```

> نکته: در محیط‌های sandboxed که دیمان Docker بالا نمی‌آید، از سرویس‌های سیستم‌عامل استفاده کنید: `service postgresql start` و `service redis-server start`.

## اجرای تست‌ها

```bash
# Backend (نیاز به یک Postgres در دسترس؛ پایگاه‌دادهٔ تست به‌صورت خودکار ساخته می‌شود)
cd backend
pytest

# Frontend
cd frontend
npm run test          # یک‌بار اجرا
npm run test:watch    # حالت watch
npm run build          # typecheck + build production
```

هر دو سوییت روی هر `push`/`pull request` توسط GitHub Actions (`.github/workflows/ci.yml`) نیز اجرا می‌شوند.

## مشارکت

تغییرات معماری باید در `docs/ARCHITECTURE.md` و وضعیت پیشرفت در `docs/PROJECT_STATE.md` ثبت شود.
