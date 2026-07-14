# وضعیت فعلی پروژه WorkPilot

> این فایل همیشه باید نشان‌دهندهٔ آخرین وضعیت واقعی پروژه باشد تا در صورت قطع گفتگو یا تغییر محیط، کار بدون از دست دادن اطلاعات ادامه پیدا کند. برای جزئیات هر مرحله به گزارش Handoff همان مرحله در پایین همین فایل مراجعه کنید.

## برنچ فعال
`claude/push-main-github-c3qd9w`

## فاز فعلی
**فاز A تکمیل شد + بخش زیادی از فاز B (احراز هویت) هم پیاده‌سازی و تست شد.**

## خلاصهٔ کارهای تکمیل‌شده

- [x] سند RFB نهایی شد — چندمستأجری از ابتدا + الزام موبایل‌فرندلی.
- [x] Skill های طراحی/تست نصب شدند (`skill/.claude/skills`, `skill/anthropic-skills`).
- [x] جهت‌گیری UI داشبورد ثبت شد (`docs/UI-DESIGN.md`) — **هنوز تأیید نهایی نشده**.
- [x] مستندات پایه (`docs/ARCHITECTURE.md`, این فایل) ایجاد و به‌روز نگه داشته می‌شوند.
- [x] **Backend**: اسکلت FastAPI کامل با تمام ۱۱ مدل دیتابیس (Organization, User, Project, ProjectMember, Task, TaskDependency, WorkLog, Comment, Attachment, Notification, AuditLog)، لایهٔ چندمستأجری (`TenantScopedRepository`)، امنیت JWT+bcrypt، RBAC (`require_role`), اولین Alembic migration.
- [x] **Auth API کامل و تست‌شده**: signup (ساخت سازمان+کاربر اول به‌عنوان org_admin)، login، `/me` — با تست دستی موفق (ثبت‌نام، ورود، ایمیل تکراری→409، رمز اشتباه→401، بدون توکن→401، رمز خیلی بلند→422).
- [x] **Frontend**: اسکلت Vite+React+TS+Tailwind v4 با تنظیم دستی shadcn/ui (چون `npx shadcn init/add` به دلیل محدودیت شبکهٔ محیط به `ui.shadcn.com` مسدود بود — کامپوننت‌های پایه Button/Card/Input/Label دستی نوشته شدند)، توکن‌های طراحی سه‌لایه، صفحهٔ ورود/ثبت‌نام، AppShell ریسپانسیو (سایدبار تیره راست در دسکتاپ، Drawer در موبایل)، صفحهٔ داشبورد نمونه.
- [x] **تست سرتاسری واقعی با Playwright** (نه فقط curl): جریان signup→login→dashboard در دو ویوپورت (1280px دسکتاپ، 375px موبایل) با مرورگر واقعی تأیید شد؛ اسکرین‌شات‌ها ذخیره شدند.
- [x] `docker-compose.yml` نوشته شد (postgres, redis, backend, worker, frontend).

## در حال انجام / ناقص

- Celery worker فقط یک stub داره (`app/workers/celery_app.py`) — تسک واقعی export فایل در فاز F اضافه می‌شود.
- بقیهٔ روترهای API (projects, tasks, worklogs, reports, dashboard, notifications, exports) هنوز نوشته نشده‌اند — این‌ها فازهای C تا G هستند.
- Refresh-token/کوکی httpOnly که در ARCHITECTURE.md طراحی شده، هنوز پیاده نشده؛ فعلاً فقط access token کوتاه‌عمر (۳۰ دقیقه) در حافظهٔ فرانت — یعنی رفرش صفحه یعنی نیاز به ورود مجدد. این در فاز H (سخت‌سازی امنیتی) تکمیل می‌شود.
- تست‌های خودکار (pytest برای بک‌اند، vitest برای فرانت) هنوز نوشته نشده — فاز I.

## محدودیت محیط (برای ادامه‌دهنده مهم است)

- **Docker daemon در این سندباکس قابل اجراست ولی دیمانش بالا نمی‌آد** (`service docker start` با خطای دسترسی ulimit مواجه می‌شود) — بنابراین `docker compose up` مستقیماً تست نشد. به‌جایش Postgres و Redis به‌صورت native (سرویس سیستم‌عامل) استفاده و تست کامل انجام شد. `docker-compose.yml` از نظر syntax/ساختار درست نوشته شده ولی در یک محیط با دسترسی کامل داکر باید یک بار `docker compose up` تأیید بشه.
- `npx shadcn@latest init/add` به دلیل مسدود بودن دامنهٔ `ui.shadcn.com` توسط سیاست شبکهٔ این محیط کار نکرد (خطای 403 از پراکسی). راه‌حل: پیکربندی و کامپوننت‌های shadcn به‌صورت دستی نوشته شدند (`components.json`, `src/lib/utils.ts`, `src/components/ui/*`). اگر در محیط دیگری با دسترسی به آن دامنه کار می‌کنید، `npx shadcn@latest add <component>` باید کار کند و روش دستی صرفاً یک جایگزین است.

## مشکلات/نکات باز

- طرح داشبورد نهایی نشده؛ قبل از پیاده‌سازی کامل فاز E باید با کاربر چک شود.
- مقادیر [TBD] در RFB (بودجه، تعداد کاربر همزمان، SLA دقیق) هنوز نیاز به تصمیم کارفرما دارند — مانع شروع توسعه نیستند.
- تصمیم «یکتایی ایمیل سراسری» در `docs/ARCHITECTURE.md` ثبت شده — یعنی هر ایمیل فقط می‌تواند عضو یک سازمان باشد.

---

## تاریخچهٔ Handoff

### Handoff — پس از نهایی‌سازی RFB (پیش از شروع فاز A)
- **خلاصه:** سند RFB نهایی شد؛ دو مجموعه skill نصب شد؛ جهت‌گیری UI ثبت شد؛ مستندات پایه ایجاد شد.
- **گام بعدی:** شروع فاز A.

### به‌روزرسانی — توقف عمدی قبل از فاز A
- **خلاصه:** کاربر گفت فقط مستندات push شود، صبر کن. هیچ کدی نوشته نشد.
- **گام بعدی:** منتظر تأیید صریح کاربر برای شروع.

### Handoff — تکمیل فاز A + بخشی از فاز B (احراز هویت)
- **خلاصه:** با تأیید کاربر و درخواست صریح «شروع کن» + دستور استفادهٔ حتمی از skill های نصب‌شده و استدلال عمیق برای تصمیم‌های معماری/امنیت/دیتابیس/API، اسکلت کامل backend (FastAPI) و frontend (React+Vite+Tailwind) ساخته شد. تصمیم‌های کلیدی (Shared-Schema چندمستأجری، `TenantScopedRepository`، JWT دوتکه، یکتایی ایمیل سراسری) در `docs/ARCHITECTURE.md` ثبت شدند. سیستم auth (signup/login/me) به‌صورت واقعی (نه فقط تئوری) با curl و سپس با مرورگر واقعی (Playwright) در دو ویوپورت دسکتاپ/موبایل تست و تأیید شد.
- **فایل‌های ساخته‌شده (خلاصه):**
  - `backend/app/**` (models, schemas, services/auth.py, api/deps.py, api/routers/{auth,health}.py, core/{config,security}.py, db/{session,base_class,tenant_repository}.py, workers/celery_app.py stub)
  - `backend/alembic/**` + اولین migration (`initial schema`)
  - `backend/requirements.txt`, `backend/Dockerfile`, `backend/.env.example`
  - `frontend/src/**` (components/ui/{button,card,input,label}.tsx دستی به‌جای shadcn CLI، components/layout/{app-shell,sidebar-nav}.tsx، features/auth/**، features/dashboard/**، app/{router,protected-route}.tsx، lib/{utils,api-client}.ts، index.css با توکن‌های سه‌لایه)
  - `docker-compose.yml`, `.gitignore` (ریشهٔ مخزن)
- **مشکلات کشف و رفع‌شده حین توسعه:**
  1. باگ سازگاری `passlib`+`bcrypt` جدید → حذف passlib، استفادهٔ مستقیم از کتابخانهٔ `bcrypt`.
  2. `npx shadcn init/add` به دلیل مسدودبودن `ui.shadcn.com` در این محیط کار نکرد → پیکربندی دستی.
  3. CORS بین `127.0.0.1:5173` و `localhost:5173` → هر دو origin به تنظیمات پیش‌فرض اضافه شد.
  4. یک باگ واقعی در CSS (`*/` داخل یک کامنت که کامنت رو زودتر می‌بست) پیدا و رفع شد.
- **کارهای باقی‌مانده:** فاز B (بقیه‌اش: refresh token)، فازهای C تا J کامل — جزئیات در بخش «در حال انجام / ناقص» بالا.
- **گام بعدی برای ادامه‌دهنده:** شروع فاز C (مدیریت پروژه و وظایف) طبق `docs/ARCHITECTURE.md`. قبل از شروع، `service postgresql start` و `service redis-server start` را در محیط سندباکس اجرا کنید (چون داکر دیمان بالا نمی‌آد) و از `backend/.venv` موجود استفاده کنید یا با `uv venv .venv && uv pip install -r requirements.txt` دوباره بسازید.
