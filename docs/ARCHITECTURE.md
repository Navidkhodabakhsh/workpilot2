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

## تصمیم‌های ریز اما پرتبعات (طراحی دیتابیس، امنیت، API)

> این تصمیم‌ها با سطح بالای استدلال گرفته شدن چون تغییرشان بعداً پرهزینه است.

### مدل داده و چندمستأجری
- **یکتایی ایمیل کاربر: سراسری (Global)، نه در حد سازمان.** ساده‌تر برای فرآیند ورود (نیازی به انتخاب/تشخیص سازمان در لاگین نیست). محدودیت شناخته‌شده: یک ایمیل نمی‌تواند در دو سازمان مختلف حساب داشته باشد؛ در صورت نیاز آینده به ورود یک نفر به چند سازمان، باید جدول Membership جداگانه اضافه شود (مسیر ارتقا، نه نیاز فعلی).
- **`organization_id` روی جداول فرزند (Task، WorkLog، Comment، Attachment، Notification، AuditLog) دنرمالایز می‌شود**، حتی وقتی از طریق `project_id` قابل استخراج است. دلیل: دفاع در عمق در برابر نشت داده بین سازمان‌ها — فیلتر مستقیم بدون JOIN، و جلوگیری از باگ «فراموش‌کردن اسکوپ» در سرویس‌ها.
- **ایزوله‌سازی چندمستأجری در سطح کد، نه دیتابیس:** یک کلاس پایه `TenantScopedRepository` تمام کوئری‌ها را با `organization_id` فیلتر می‌کند؛ هیچ سرویسی مستقیم به session خام دسترسی نمی‌گیرد. مسیر ارتقای آینده در صورت نیاز به سخت‌گیری بیشتر: Row-Level Security پستگرس.
- **وابستگی بین وظایف (TaskDependency):** تشخیص چرخه (cycle) در سطح سرویس انجام می‌شود، نه constraint دیتابیس (چون DB این محدودیت را به‌سادگی پشتیبانی نمی‌کند).

### احراز هویت و امنیت
- **JWT دوتکه:** access token کوتاه‌عمر (۳۰ دقیقه) حاوی `user_id`، `organization_id`، `role`؛ refresh token بلندمدت (۷ روز) در کوکی httpOnly+Secure (نه localStorage) تا ریسک سرقت توکن با XSS کم شود.
- **هش رمز عبور:** bcrypt از طریق passlib.
- **RBAC:** بررسی نقش به‌صورت dependency factory (`require_role(*roles)`) در سطح روتر، نه شرط پراکنده داخل توابع.
- **Rate limiting روی ورود** برای مقابله با brute-force در فاز H اضافه می‌شود؛ از همین فاز A ساختار dependency injection طوری طراحی می‌شود که افزودنش بعداً نیازی به بازنویسی نداشته باشد.

### ساختار API
- REST با پیشوند نسخه: `/api/v1/...`.
- بدون envelope اضافه دور پاسخ‌ها — مستقیماً مدل‌های Pydantic (سادگی به‌جای انتزاع زودهنگام).
- Pagination: offset/limit ساده (نه cursor) — مقیاس فعلی این پروژه نیازی به cursor pagination ندارد.
- خطاها: `HTTPException` استاندارد FastAPI با فیلد `detail`.

### الگوی نرم‌افزاری
لایه‌بندی: **Router (HTTP) → Service (منطق کسب‌وکار + مجوز) → Repository/Model (دسترسی داده)**. این لایه‌بندی برای پیچیدگی RBAC چندمستأجری این پروژه توجیه دارد و انتزاع زائد نیست.

## ماتریس دسترسی پروژه/وظیفه (فاز C)

| عملیات | org_admin | project_manager | employee |
|---|---|---|---|
| ساخت پروژه | همه‌جا | بله (خودش عضو می‌شود) | ✗ |
| دیدن/ویرایش پروژه | همهٔ پروژه‌های سازمان | فقط پروژه‌هایی که عضوشان است | فقط پروژه‌هایی که عضوشان است (فقط دیدن) |
| مدیریت اعضای پروژه | همه‌جا | فقط پروژه‌های خودش | ✗ |
| ساخت/ویرایش/حذف وظیفه | همه‌جا | فقط پروژه‌های خودش | ✗ |
| تغییر وضعیت وظیفهٔ خودش | — | — | بله (فقط فیلد status) |
| وابستگی بین وظایف | همه‌جا | فقط پروژه‌های خودش | ✗ |

نکتهٔ پیاده‌سازی: سازندهٔ یک پروژه به‌طور خودکار عضو آن می‌شود تا `project_manager` بلافاصله بتواند آن را مدیریت کند. تشخیص چرخه در وابستگی وظایف با DFS روی گراف `depends_on` در لایهٔ سرویس انجام می‌شود (نه constraint دیتابیس).

`POST/GET /api/v1/users` (مدیریت کاربران سازمان توسط org_admin) در فاز C اضافه شد؛ در RFB بخش ۴.۱ پیش‌بینی شده بود ولی در فاز B از قلم افتاده بود.

## مرجع طراحی بصری

جهت‌گیری کلی UI (چیدمان سایدبار، رنگ‌ها، اجزای داشبورد) در `docs/UI-DESIGN.md` مستند شده — بر اساس تصویر مرجعی که کاربر فرستاد و **هنوز تأیید نهایی نشده**.
