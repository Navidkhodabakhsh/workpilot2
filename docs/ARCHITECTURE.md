# معماری فنی WorkPilot

> این سند تصمیم‌های معماری پروژه را ثبت می‌کند و در طول توسعه به‌روز نگه داشته می‌شود. برای نیازمندی‌های محصول به `docs/RFB-WorkPilot-Project-Proposal.md` و برای جهت‌گیری بصری به `docs/UI-DESIGN.md` مراجعه کنید.

## تصمیم‌های کلیدی

| تاریخ | تصمیم | دلیل |
|---|---|---|
| 1404/04/23 | استک: React+TS+Vite+Tailwind (فرانت) / FastAPI+SQLAlchemy (بک‌اند) / PostgreSQL / Redis / Docker | انتخاب صریح کارفرما |
| 1404/04/23 | چندمستأجری (Multi-tenant SaaS) از ابتدا، مدل Shared-Schema | انتخاب صریح کارفرما؛ ساده‌تر از schema-per-tenant برای مقیاس اولیه، با مسیر ارتقا در آینده |
| 1404/04/23 | ساخت کل محدودهٔ RFB (نه فقط MVP) در یک برنامهٔ فازبندی‌شده | درخواست صریح کارفرما |
| 1404/04/23 | ریسپانسیو/موبایل‌فرندلی به‌عنوان نیازمندی الزامی (نه اختیاری) | درخواست صریح کارفرما؛ در RFB بخش‌های ۲، ۶ و ۱۲ ثبت شد |

## ساختار مخزن

```
backend/      → اپلیکیشن FastAPI
frontend/     → اپلیکیشن React + Vite
docker-compose.yml
.env.example
docs/         → مستندات (RFB، معماری، وضعیت پروژه، طراحی UI)
skill/        → Skill های نصب‌شده (ui-ux-pro-max, anthropic-skills)
```

## چندمستأجری (Multi-tenant)

- مدل: **Shared-Schema** — یک دیتابیس مشترک، هر جدول تننت‌محور دارای ستون `organization_id`.
- ایزوله‌سازی در لایهٔ سرویس اعمال می‌شود: یک dependency مشترک (`get_current_org_scope`) که `organization_id` کاربر جاری را استخراج و در تمام کوئری‌های سرویس اعمال می‌کند.
- نقش `platform_admin` از این محدودیت مستثناست (دسترسی سراسری برای مدیریت پلتفرم).
- در آینده در صورت نیاز به ایزوله‌سازی سخت‌تر، می‌توان به Row-Level Security پستگرس یا schema-per-tenant مهاجرت کرد؛ این تصمیم فعلاً باز گذاشته نشده و به عنوان مسیر ارتقا مستند است.

## Backend (FastAPI)

```
backend/app/
  core/        → config (pydantic-settings), security (JWT, hashing), dependencies (current_user, RBAC, org scope)
  db/          → SQLAlchemy engine/session, Alembic migrations
  models/      → Organization, User, Project, Task, TaskDependency, WorkLog, Comment, Attachment, Notification, AuditLog
  schemas/     → Pydantic request/response
  api/routers/ → auth, organizations, users, projects, tasks, worklogs, reports, dashboard, notifications, exports
  services/    → business logic + RBAC rules per-endpoint
  workers/     → Celery tasks (Redis broker) برای تولید ناهمزمان خروجی فایل
backend/tests/ → pytest
```

نقش‌ها (enum روی `User.role`): `platform_admin`, `org_admin`, `project_manager`, `employee`.

## Frontend (React + TS + Vite + Tailwind)

```
frontend/src/
  app/           → routing (react-router v6)، route guard بر اساس نقش
  components/ui/ → کامپوننت‌های shadcn/ui
  features/      → auth, projects, tasks, worklogs, reports, dashboard, notifications
  lib/           → API client (react-query hooks)، توکن‌های طراحی
```

- فرم‌ها: `react-hook-form` + `zod`
- state سرور: React Query؛ state سبک UI: Zustand
- توکن طراحی سه‌لایه: Primitive → Semantic → Component (CSS variables، map شده در `tailwind.config`)
- RTL/فارسی: `dir="rtl"` پیش‌فرض، فونت Vazirmatn
- **استراتژی موبایل (الزامی):** Mobile-first؛ کلاس پایه = موبایل، سپس `sm/md/lg/xl` رو به بالا. جزئیات در `docs/UI-DESIGN.md`.

## Async Jobs

Celery + Redis برای تولید خروجی Excel/PDF/CSV حجیم (طبق نکتهٔ فنی RFB بخش ۵.۸)؛ endpoint وضعیت job برای polling از فرانت.

## تست

- Backend: pytest (واحد + یکپارچگی روی دیتابیس تست)
- Frontend: vitest + React Testing Library
- E2E: Playwright — سناریوهای حیاتی در دو ویوپورت (دسکتاپ 1280px، موبایل 375px)

## استقرار

`docker-compose.yml` با سرویس‌های: `postgres`, `redis`, `backend` (uvicorn), `worker` (celery), `frontend` (vite dev / build production).

## مرجع طراحی بصری

جهت‌گیری کلی UI (چیدمان سایدبار، رنگ‌ها، اجزای داشبورد) در `docs/UI-DESIGN.md` مستند شده — بر اساس تصویر مرجعی که کاربر فرستاد و **هنوز تأیید نهایی نشده**.
