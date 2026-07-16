# راهنمای جامع پایگاه‌داده و API — WorkPilot (Tadvin Hesab)

> این سند برای کسی نوشته شده که لازم نیست برنامه‌نویس باشد، ولی می‌خواهد بفهمد داده‌های سیستم کجا و چگونه ذخیره می‌شوند، چطور می‌تواند کارهای مدیریتی رایج (ریست رمز عبور، حذف کاربر، انتقال مالکیت سازمان، بک‌آپ/ریستور) را انجام دهد، و هر endpoint واقعیِ API چه کاری می‌کند. تمام مطالب این سند مستقیماً از خواندن کد واقعی پروژه (مدل‌ها، schemaها، روترها و سرویس‌ها) استخراج شده — چیزی حدس زده یا اضافه نشده است. هرجا قابلیتی در کد وجود نداشته (مثلاً حذف واقعی کاربر، یا مفهوم «مالک سازمان»)، همین موضوع صریحاً و بدون رودربایستی نوشته شده.
>
> برای تصمیم‌های معماری و تاریخچهٔ توسعه به `docs/ARCHITECTURE.md` و `docs/PROJECT_STATE.md` مراجعه کنید؛ این سند برخلاف آن‌ها، **عملیاتی و کاربردی** است — یعنی «چطور این کار را انجام دهم»، نه «چرا این‌طور طراحی شد».

---

# فهرست مطالب

**بخش ۱ — راهنمای پایگاه‌داده**
1. [ساختار کلی دیتابیس](#۱-ساختار-کلی-دیتابیس)
2. [توضیح تمام جداول](#۲-توضیح-تمام-جداول)
3. [ارتباط بین جداول](#۳-ارتباط-بین-جداول)
4. [نحوهٔ اضافه/ویرایش/حذف داده به‌صورت دستی](#۴-نحوهٔ-اضافهویرایشحذف-داده-به‌صورت-دستی)
5. [نحوهٔ تغییر رمز عبور یک کاربر](#۵-نحوهٔ-تغییر-رمز-عبور-یک-کاربر)
6. [نحوهٔ ایجاد یک مدیر (org_admin) جدید](#۶-نحوهٔ-ایجاد-یک-مدیر-org_admin-جدید)
7. [نحوهٔ حذف یک کاربر](#۷-نحوهٔ-حذف-یک-کاربر)
8. [نحوهٔ انتقال مالکیت سازمان](#۸-نحوهٔ-انتقال-مالکیت-سازمان)
9. [نکات امنیتی دیتابیس](#۹-نکات-امنیتی-دیتابیس)
10. [Backup و Restore](#۱۰-backup-و-restore)
11. [نحوهٔ ریست کردن دیتابیس](#۱۱-نحوهٔ-ریست-کردن-دیتابیس)

**بخش ۲ — راهنمای API**
1. [نحوهٔ احراز هویت](#۱-نحوهٔ-احراز-هویت)
2. [جدول کامل Endpointها](#۲-جدول-کامل-endpointها)
3. [نحوهٔ استفاده از API در فرانت‌اند](#۳-نحوهٔ-استفاده-از-api-در-فرانت‌اند)

[منابع و فایل‌های مرتبط](#منابع-و-فایل‌های-مرتبط)

---

# بخش ۱: راهنمای پایگاه‌داده

## ۱. ساختار کلی دیتابیس

WorkPilot یک اپلیکیشن **چندمستأجری (Multi-tenant)** است — یعنی چند سازمان (شرکت/تیم) مستقل از یک نصب مشترک از برنامه و از یک دیتابیس مشترک استفاده می‌کنند، ولی داده‌های هر سازمان کاملاً از سازمان‌های دیگر جدا و پنهان است.

نکات کلیدی معماری داده:

- **مدل چندمستأجری: Shared-Schema.** یک دیتابیس واحد، یک مجموعه جدول واحد؛ تقریباً همهٔ جدول‌ها یک ستون `organization_id` دارند که مشخص می‌کند هر ردیف متعلق به کدام سازمان است.
- **ایزوله‌سازی در سطح کد اجرا می‌شود، نه با قابلیتی داخل خود پستگرس** (مثل Row-Level Security). یک کلاس پایه به نام `TenantScopedRepository` (`backend/app/db/tenant_repository.py`) هر کوئری را به‌طور خودکار با `organization_id` فیلتر می‌کند، و `organization_id` هرگز از ورودی کاربر خوانده نمی‌شود — همیشه از توکن JWT کاربر جاری استخراج می‌شود (`get_current_org_id` در `backend/app/api/deps.py`). یعنی هیچ کاربری حتی تئوریک نمی‌تواند با دستکاری درخواست، داده سازمان دیگری را ببیند.
- **استثنا: `platform_admin`.** این نقش به هیچ سازمانی متعلق نیست (`organization_id` آن در جدول `users` مقدار `NULL` دارد) و برای مدیریت کل پلتفرم در نظر گرفته شده، نه کار روزمرهٔ یک سازمان خاص.
- **دنرمالایز عمدی `organization_id`:** جدول‌هایی مثل `tasks`، `worklogs`، `comments` و... با این‌که از طریق `project_id` یا `task_id` هم می‌شد سازمان را پیدا کرد، مستقیماً ستون `organization_id` خودشان را دارند. این یک تصمیم امنیتی آگاهانه است: فیلتر مستقیم بدون نیاز به JOIN، به‌عنوان یک لایهٔ دفاعی اضافه در برابر بروز باگ «فراموش‌کردن اسکوپ سازمان» در کد.

### موتور و نسخهٔ پایگاه‌داده

- **PostgreSQL نسخهٔ ۱۶** (ایمیج `postgres:16-alpine` در `docker-compose.yml`).
- در محیط Docker، نام دیتابیس، کاربر و رمز پیش‌فرض همگی `workpilot` هستند (`docker-compose.yml`، سرویس `postgres`).
- در محیط توسعهٔ بدون Docker (native)، رشتهٔ اتصال پیش‌فرض در `backend/app/core/config.py` همین مقدار را دارد:

```
postgresql+psycopg2://workpilot:workpilot@localhost:5432/workpilot
```

- **دیتابیس تست** با نام جدا `workpilot_test` استفاده می‌شود (طبق `backend/tests/conftest.py` و مستندات `docs/ARCHITECTURE.md`)، تا اجرای تست‌های خودکار هیچ‌وقت داده‌های دیتابیس توسعه (`workpilot`) را پاک یا آلوده نکند.
- ORM: SQLAlchemy 2.0 + Alembic برای migration. مهاجرت‌های شِمای دیتابیس در `backend/alembic/versions/*.py` نگه‌داری می‌شوند (تاریخچهٔ آن‌ها در بخش «سیر تحول شِما» پایین همین بخش آمده).
- کلید اصلی (Primary Key) همهٔ جدول‌ها از نوع **UUID** است (نه عدد صحیح افزایشی)، تولیدشده در سمت اپلیکیشن با `uuid.uuid4()` (`backend/app/db/base_class.py`).
- تقریباً همهٔ جدول‌ها دو ستون زمانی خودکار دارند: `created_at` و `updated_at` (هر دو `timestamptz`، با `server_default=now()`؛ `updated_at` هم با `onupdate=now()` در هر UPDATE به‌روز می‌شود). دو جدول استثنا هستند: `audit_logs` و `task_activity_logs` که چون **غیرقابل‌تغییر (Immutable)** طراحی شده‌اند، فقط `created_at` دارند و اصلاً ستون `updated_at` روی آن‌ها تعریف نشده.

### سیر تحول شِما (خلاصهٔ Migrationها)

فایل‌های زیر در `backend/alembic/versions/` به‌ترتیب اعمال‌شده وجود دارند (فقط برای آشنایی کلی؛ برای اجرای واقعی migration همیشه از `alembic upgrade head` استفاده کنید، نه بازتولید دستی این فایل‌ها):

| Migration | تغییر |
|---|---|
| `65d476c7b4af_initial_schema` | ساخت شِمای اولیهٔ همهٔ جدول‌های پایه |
| `5b4dbfab694a_add_user_phone_number` | افزودن ستون `phone_number` به `users` |
| `24ef455fdc1d_add_export_jobs_table` | افزودن جدول `export_jobs` |
| `67a93e70f708_add_comment_added_notification_type` | افزودن مقدار `comment_added` به enum پستگرسی `NotificationType` |
| `5caf58e16e40_add_calendar_events` | افزودن جدول `calendar_events` و مقدار `event_reminder` به `NotificationType` |
| `04da1673aa0f_rebuild_tasks_status_approval` | بازسازی `tasks`: کاهش enum وضعیت به ۴ مقدار، افزودن `approval_status`، `progress_percent`، `estimated_hours`، پشتیبانی از تسک شخصی، افزودن جدول `task_activity_logs` |
| `a943e0a49f2e_add_otp_codes_nullable_password` | افزودن جدول `otp_codes`، nullable کردن `hashed_password` |
| `275fdf9f608c_add_project_manager_and_cooperation_` | افزودن `manager_id` (مدیر تعیین‌شدهٔ پروژه) و `cooperation_start_date` به `projects` |
| `ee822a986fe7_add_payments_table` | افزودن جدول `payments` (دفترچهٔ ساده و دستی پرداخت‌های هر پروژه) |
| `032a3a3047df_add_task_start_date` | افزودن ستون `start_date` به `tasks` |
| `734190b6fd34_add_departments` | افزودن جدول `departments`، و ستون `department_id` (nullable) به `users` و `projects` |
| `60291deba722_add_leave_requests` | افزودن جدول `leave_requests` و مقدار `leave_reviewed` به `NotificationType`؛ با استفاده مجدد از enum پستگرسی `approvalstatus` که پیش‌تر برای `tasks.approval_status` ساخته شده بود (`create_type=False` تا این ستون دوباره تلاش نکند همان نوع را از نو بسازد) |

---

## ۲. توضیح تمام جداول

> در تمام جداول زیر، `id` از نوع UUID و کلید اصلی است و `created_at`/`updated_at` (مگر خلاف آن گفته شود) به‌صورت خودکار توسط دیتابیس مقداردهی می‌شوند — نیازی به ست‌کردن دستی آن‌ها نیست.

### `organizations` — سازمان‌ها

هر ردیف این جدول یک «مستأجر» (Tenant) مستقل از سیستم است — یعنی یک شرکت/تیم که از WorkPilot استفاده می‌کند.

| ستون | نوع | توضیح |
|---|---|---|
| `id` | UUID (PK) | شناسهٔ یکتای سازمان |
| `name` | `varchar(200)`, اجباری | نام نمایشی سازمان |
| `slug` | `varchar(100)`, یکتا، اجباری | شناسهٔ متنی یکتا (خودکار از نام سازمان ساخته می‌شود، در هیچ endpoint ای مستقیماً قابل تغییر نیست) |
| `is_active` | `boolean`, پیش‌فرض `true` | آیا سازمان فعال است (فعلاً هیچ endpoint ای این فیلد را از طریق API تغییر نمی‌دهد) |
| `created_at` / `updated_at` | `timestamptz` | زمان ساخت/آخرین ویرایش |

### `departments` — دپارتمان‌ها

یک دپارتمان صرفاً یک **گروه‌بندی منطقی** درون یک سازمان است (مثلاً «مالی»، «فنی»، «منابع انسانی») — **هیچ جداسازی فیزیکی دادهٔ واقعی** در پی ندارد؛ فقط یک ستون `department_id` روی `users` و `projects` است که در فرانت‌اند برای فیلتر/گروه‌بندی نمایش استفاده می‌شود. فقط `org_admin` می‌تواند دپارتمان بسازد.

**نکتهٔ مهم:** از این نسخه به بعد، **هر سازمان تازه باید حداقل یک دپارتمان در همان لحظهٔ ثبت‌نام تعریف کند** — `POST /api/v1/auth/signup` حالا یک فیلد اجباری `department_name` دارد و سرویس `signup` (`backend/app/services/auth.py`) هم‌زمان با ساخت `Organization`، اولین `Department` را هم می‌سازد و اولین کاربر (org_admin) را عضو همان دپارتمان می‌کند.

| ستون | نوع | توضیح |
|---|---|---|
| `id` | UUID (PK) | |
| `organization_id` | UUID (FK → `organizations.id`), اجباری | سازمان صاحب دپارتمان |
| `name` | `varchar(200)`, اجباری | نام دپارتمان |
| `created_at` / `updated_at` | `timestamptz` | |

### `users` — کاربران

هر ردیف یک حساب کاربری است. کاربران یا به یک سازمان تعلق دارند، یا (در حالت خاص `platform_admin`) به هیچ سازمانی.

| ستون | نوع | توضیح |
|---|---|---|
| `id` | UUID (PK) | شناسهٔ کاربر |
| `organization_id` | UUID (FK → `organizations.id`), **nullable** | سازمان کاربر؛ فقط برای `platform_admin` مقدار `NULL` است |
| `email` | `varchar(255)`, **یکتا در کل دیتابیس** (نه فقط در سازمان)، اجباری | ایمیل کاربر؛ برای ورود و شناسایی استفاده می‌شود |
| `phone_number` | `varchar(32)`, یکتا، nullable | شمارهٔ موبایل؛ محور اصلی ورود در نسخهٔ فعلی است (OTP و لاگین) |
| `hashed_password` | `varchar(255)`, **nullable** | رمز عبور هش‌شده با bcrypt؛ `NULL` یعنی کاربری که فقط با موبایل دعوت شده و هنوز رمز خودش را تعیین نکرده |
| `full_name` | `varchar(200)`, اجباری | نام کامل |
| `role` | enum `UserRole`, اجباری، پیش‌فرض `employee` | نقش کاربر (جدول مقادیر پایین) |
| `is_active` | `boolean`, پیش‌فرض `true` | غیرفعال‌سازی حساب (معادل نزدیک‌ترین چیز به «حذف» که از طریق API در دسترس است) |
| `department_id` | UUID (FK → `departments.id`, `ondelete SET NULL`), nullable | دپارتمان اختیاریِ کاربر — صرفاً گروه‌بندی منطقی (بخش «دپارتمان‌ها» بالا)؛ اولین کاربر هر سازمان (org_admin ثبت‌نام‌کننده) همیشه به‌طور خودکار همان دپارتمان اولیهٔ سازمان را می‌گیرد |
| `created_at` / `updated_at` | `timestamptz` | |

مقادیر enum `role`:

| مقدار | معنی |
|---|---|
| `platform_admin` | مدیر کل پلتفرم؛ خارج از هر سازمانی؛ فقط با اسکریپت `seed_platform_admin.py` ساخته می‌شود |
| `org_admin` | مدیر سازمان؛ دسترسی کامل به همهٔ پروژه‌ها/کاربران/تنظیمات همان سازمان |
| `project_manager` | مدیر پروژه؛ فقط روی پروژه‌هایی که عضوشان است دسترسی مدیریتی دارد |
| `employee` | کارمند عادی؛ فقط می‌تواند وظایف تخصیص‌داده‌شده به خودش را ببیند/به‌روزرسانی محدود کند و برایشان گزارش کار ثبت کند |

### `projects` — پروژه‌ها

| ستون | نوع | توضیح |
|---|---|---|
| `id` | UUID (PK) | |
| `organization_id` | UUID (FK → `organizations.id`), اجباری | سازمان صاحب پروژه |
| `name` | `varchar(200)`, اجباری | نام پروژه |
| `description` | `text`, nullable | توضیحات |
| `cooperation_start_date` | `date`, nullable | تاریخ شروع همکاری با مشتری/کارفرما (متفاوت از `start_date` که تاریخ شروع خودِ کار روی پروژه است) |
| `start_date` / `end_date` | `date`, nullable | بازهٔ زمانی پروژه |
| `status` | enum `ProjectStatus`, پیش‌فرض `active` | وضعیت پروژه: `active` (فعال)، `completed` (تکمیل‌شده)، `archived` (بایگانی‌شده) |
| `created_by_id` | UUID (FK → `users.id`), اجباری | کاربری که پروژه را ساخته |
| `manager_id` | UUID (FK → `users.id`), nullable | مدیر پروژهٔ تعیین‌شده توسط org_admin — **فقط توصیفی است**، جایگزین بررسی RBAC واقعی (نقش + عضویت در `project_members`) نمی‌شود؛ هنگام تعیین، همان کاربر به‌صورت خودکار عضو پروژه هم می‌شود |
| `department_id` | UUID (FK → `departments.id`, `ondelete SET NULL`), nullable | دپارتمان اختیاریِ پروژه — مثل `manager_id`، این هم صرفاً یک برچسب توصیفی/گروه‌بندی است (بخش «دپارتمان‌ها» بالا)، نه یک محدودیت دسترسی؛ پروژه‌های قدیمی‌تر از این ستون مقدار `NULL` دارند |
| `created_at` / `updated_at` | `timestamptz` | |

### `project_members` — عضویت در پروژه

جدول واسط چندبه‌چند بین کاربران و پروژه‌ها؛ تعیین می‌کند چه کسی «عضو» یک پروژه است (و در نتیجه اجازهٔ دیدن/کار‌کردن روی آن را دارد).

| ستون | نوع | توضیح |
|---|---|---|
| `id` | UUID (PK) | |
| `project_id` | UUID (FK → `projects.id`), اجباری | |
| `user_id` | UUID (FK → `users.id`), اجباری | |
| `created_at` / `updated_at` | `timestamptz` | تاریخ عضویت |

### `payments` — پرداخت‌ها

یک دفترچهٔ ساده و **دستی‌ثبت‌شونده** از پرداخت‌های هر پروژه — **نه یک سامانهٔ واقعی صورتحساب/حسابداری**؛ فقط یک رکورد متنی از این‌که «فلان مبلغ در فلان تاریخ برای فلان پروژه ثبت شد»، بدون هیچ منطق مالیاتی/تسویه/فاکتور رسمی.

> **نکتهٔ مهم دسترسی:** برخلاف بیشتر منابع پروژه‌محور (که معمولاً هم `org_admin` و هم `project_manager` عضو پروژه به آن‌ها دسترسی دارند)، دسترسی به `payments` **منحصراً به `org_admin` محدود است** — حتی `project_manager` عضو همان پروژه هم نمی‌تواند پرداخت‌ها را ببیند یا ثبت کند. این یک تصمیم عمدی و سخت‌گیرانه‌تر از الگوی معمول است (`backend/app/services/payments.py`, تابع `_assert_owner`).

| ستون | نوع | توضیح |
|---|---|---|
| `id` | UUID (PK) | |
| `organization_id` | UUID (FK → `organizations.id`), اجباری | |
| `project_id` | UUID (FK → `projects.id`), اجباری | پروژه‌ای که این پرداخت برای آن ثبت شده |
| `recorded_by_id` | UUID (FK → `users.id`), اجباری | چه کسی این پرداخت را ثبت کرده (همیشه خودِ org_admin) |
| `payment_date` | `date`, اجباری | تاریخ پرداخت |
| `description` | `text`, اجباری | توضیح پرداخت |
| `amount` | `numeric(12,2)`, اجباری | مبلغ (باید بزرگ‌تر از صفر باشد) |
| `created_at` / `updated_at` | `timestamptz` | |

### `tasks` — وظایف

هستهٔ اصلی سیستم مدیریت کار. یک وظیفه می‌تواند به یک پروژه تعلق داشته باشد، یا «تسک شخصی» بدون پروژه باشد.

| ستون | نوع | توضیح |
|---|---|---|
| `id` | UUID (PK) | |
| `organization_id` | UUID (FK → `organizations.id`), اجباری | دنرمالایز شده از `project.organization_id` |
| `project_id` | UUID (FK → `projects.id`), **nullable** | `NULL` یعنی «تسک شخصی» — تسکی بدون پروژه که فقط برای خودِ سازنده است (باید `assignee_id == created_by_id` باشد) |
| `parent_task_id` | UUID (FK → `tasks.id`, self)، nullable | اگر پر باشد، این ردیف یک **زیروظیفه (subtask)** است |
| `assignee_id` | UUID (FK → `users.id`), nullable | مسئول انجام وظیفه |
| `created_by_id` | UUID (FK → `users.id`), اجباری | سازندهٔ وظیفه |
| `title` | `varchar(300)`, اجباری | عنوان |
| `description` | `text`, nullable | توضیحات |
| `priority` | enum `TaskPriority`, پیش‌فرض `medium` | `low` / `medium` / `high` |
| `status` | enum `TaskStatus`, پیش‌فرض `todo` | `todo` (انجام‌نشده) / `in_progress` (در حال انجام) / `completed` (تکمیل‌شده) / `archived` (بایگانی‌شده) |
| `approval_status` | enum `ApprovalStatus`, **nullable** | `NULL` تا وقتی وظیفه هرگز submit نشده؛ سپس `pending` (در انتظار تأیید) / `approved` (تأییدشده) / `rejected` (ردشده) |
| `progress_percent` | `integer`, پیش‌فرض `0` | درصد پیشرفت (۰ تا ۱۰۰) |
| `estimated_hours` | `numeric(6,2)`, nullable | ساعت برآوردی |
| `start_date` | `date`, nullable | تاریخ شروع کار روی وظیفه (متفاوت از `deadline` که تاریخ پایان/مهلت آن است) |
| `deadline` | `date`, nullable | مهلت انجام |
| `created_at` / `updated_at` | `timestamptz` | |

> نکتهٔ مهم: `status` و `approval_status` **کاملاً مستقل از هم هستند** — یک وظیفه می‌تواند هم‌زمان `completed` (از نظر پیشرفت کار) و `pending` (از نظر تأیید مدیر) باشد. رسیدن وضعیت به `completed` به‌طور خودکار `approval_status` را `pending` می‌کند؛ خارج‌شدن از `completed` مقدار تأیید را پاک (`NULL`) می‌کند.
>
> نکتهٔ دیگر: ستونی برای «ساعت واقعی صرف‌شده» (`actual_hours`) در جدول وجود **ندارد** — این عدد هیچ‌وقت ذخیره نمی‌شود؛ همیشه در لحظه از مجموع دقایق `worklogs` با وضعیت `approved` مربوط به همان تسک محاسبه می‌شود.
>
> به همین ترتیب، ستونی برای «نام کامل سازنده» هم در جدول وجود **ندارد** — فیلد `created_by_full_name` که در schema خروجی `TaskOut` دیده می‌شود، دقیقاً مثل `actual_hours` یک فیلد محاسبه‌شده و ذخیره‌نشده است: در لایهٔ سرویس (`backend/app/services/tasks.py`, تابع `_attach_computed_fields`) با یک کوئری دسته‌ای (batch) روی `users` پر می‌شود تا فرانت‌اند بدون درخواست جداگانه بداند هر وظیفه را چه کسی ساخته.

### `task_dependencies` — وابستگی بین وظایف

| ستون | نوع | توضیح |
|---|---|---|
| `id` | UUID (PK) | |
| `task_id` | UUID (FK → `tasks.id`), اجباری | این وظیفه |
| `depends_on_task_id` | UUID (FK → `tasks.id`), اجباری | ... به این وظیفهٔ دیگر وابسته است (باید قبل از آن تمام/شروع شود) |
| `created_at` / `updated_at` | `timestamptz` | |

جلوگیری از **چرخهٔ وابستگی (cycle)** — مثلاً A به B و B دوباره (مستقیم یا غیرمستقیم) به A وابسته شود — در سطح **کد سرویس** (`backend/app/services/tasks.py`, تابع `_depends_on_chain_reaches`) با یک پیمایش DFS انجام می‌شود، نه با یک محدودیت (constraint) در خودِ دیتابیس؛ چون پستگرس به‌سادگی نمی‌تواند «نبود چرخه در یک گراف» را به‌عنوان یک CHECK constraint بیان کند.

### `task_activity_logs` — تاریخچهٔ فعالیت هر وظیفه

یک ردپای غیرقابل‌تغییر (Immutable) از هر اتفاقی که برای یک وظیفهٔ خاص افتاده (ساخت، تغییر وضعیت/مسئول/اولویت، کامنت، آپلود فایل، تأیید/رد).

| ستون | نوع | توضیح |
|---|---|---|
| `id` | UUID (PK) | |
| `created_at` | `timestamptz` | (این جدول `updated_at` **ندارد** — چون هیچ‌وقت ویرایش نمی‌شود) |
| `organization_id` | UUID (FK → `organizations.id`), اجباری | |
| `task_id` | UUID (FK → `tasks.id`), اجباری | |
| `actor_user_id` | UUID (FK → `users.id`), nullable | چه کسی این رویداد را ایجاد کرده |
| `action` | `varchar(100)`, اجباری | نوع رویداد، مثل `task.create`, `task.status_change`, `task.comment`, `task.attachment`, `task.approve`, `task.reject` |
| `extra_metadata` | `jsonb`, پیش‌فرض `{}` | جزئیات اضافه (مثلاً مقدار قبل/بعد تغییر) |

> هیچ endpoint یا تابع سرویسی برای ویرایش/حذف این جدول تعریف نشده — همین «نبودن راه ویرایش» خودش تضمین‌کنندهٔ غیرقابل‌تغییر بودن آن است.

### `worklogs` — گزارش‌های کاری

هر ردیف یعنی «فلان کاربر روی فلان تاریخ، فلان مدت زمان روی فلان وظیفه کار کرده».

| ستون | نوع | توضیح |
|---|---|---|
| `id` | UUID (PK) | |
| `organization_id` | UUID (FK), اجباری | |
| `task_id` | UUID (FK → `tasks.id`), اجباری | |
| `user_id` | UUID (FK → `users.id`), اجباری | چه کسی گزارش را ثبت کرده |
| `activity_description` | `text`, اجباری | توضیح کاری که انجام شده |
| `time_spent_minutes` | `integer`, اجباری | مدت زمان (به دقیقه) |
| `progress_percent` | `integer`, پیش‌فرض `0` | درصد پیشرفتی که این گزارش نشان می‌دهد |
| `log_date` | `date`, اجباری | تاریخ انجام کار |
| `status` | enum `WorkLogStatus`, پیش‌فرض `submitted` | `draft` (پیش‌نویس) / `submitted` (ارسال‌شده، در انتظار بررسی) / `approved` (تأییدشده) / `rejected` (ردشده) |
| `reviewed_by_id` | UUID (FK → `users.id`), nullable | چه کسی تأیید/رد کرده |
| `review_comment` | `text`, nullable | توضیح رد (یا هر توضیح دیگر مدیر) |
| `created_at` / `updated_at` | `timestamptz` | |

### `notifications` — اعلان‌ها

| ستون | نوع | توضیح |
|---|---|---|
| `id` | UUID (PK) | |
| `organization_id` | UUID (FK), اجباری | |
| `user_id` | UUID (FK → `users.id`), اجباری | گیرندهٔ اعلان |
| `type` | enum `NotificationType`, اجباری | نوع اعلان (جدول پایین) |
| `payload` | `jsonb`, پیش‌فرض `{}` | داده‌های اضافی مخصوص همان نوع اعلان (مثلاً `task_id`, `task_title`) |
| `is_read` | `boolean`, پیش‌فرض `false` | آیا کاربر خوانده |
| `created_at` / `updated_at` | `timestamptz` | |

مقادیر enum `type`:

| مقدار | معنی |
|---|---|
| `task_created` | وظیفهٔ جدیدی به کاربر تخصیص داده شد |
| `deadline_approaching` | مهلت یک وظیفهٔ کاربر نزدیک می‌شود (۲ روز مانده، Job روزانه) |
| `report_submitted` | یک گزارش کاری روی وظیفه‌ای که کاربر ساخته، ثبت شد |
| `report_reviewed` | گزارش کاری کاربر تأیید یا رد شد |
| `comment_added` | کامنت جدیدی روی وظیفهٔ کاربر اضافه شد |
| `event_reminder` | یادآوری رویداد تقویم (فعلاً enum تعریف شده ولی هیچ Job زمان‌بندی‌شده‌ای این نوع را واقعاً نمی‌سازد) |
| `leave_reviewed` | درخواست مرخصی کاربر تأیید یا رد شد (بخش «دپارتمان‌ها و مرخصی» — جدول `leave_requests`) |

### `calendar_events` — رویدادهای تقویم

| ستون | نوع | توضیح |
|---|---|---|
| `id` | UUID (PK) | |
| `organization_id` | UUID (FK), اجباری | |
| `created_by_id` | UUID (FK → `users.id`), اجباری | سازندهٔ رویداد |
| `project_id` | UUID (FK → `projects.id`), nullable | اگر پر باشد، رویداد به یک پروژهٔ خاص مربوط است (مثل جلسهٔ پروژه) |
| `user_id` | UUID (FK → `users.id`), nullable | اگر پر باشد، رویداد مختص یک کاربر خاص است (مثل مرخصی/یادآوری شخصی) |
| `title` | `varchar(300)`, اجباری | |
| `description` | `text`, nullable | |
| `event_type` | enum `CalendarEventType`, اجباری | `meeting` (جلسه) / `leave` (مرخصی) / `holiday` (تعطیلی) / `reminder` (یادآوری) |
| `start_at` / `end_at` | `timestamptz`, اجباری | بازهٔ زمانی رویداد (`end_at` باید ≥ `start_at` باشد) |
| `all_day` | `boolean`, پیش‌فرض `false` | آیا رویداد تمام‌روز است |
| `created_at` / `updated_at` | `timestamptz` | |

> توجه: مقدار `leave` در enum `event_type` همچنان در دیتابیس تعریف شده (به‌خاطر سازگاری با گذشته)، ولی در فرانت‌اند دیگر **قابل‌انتخاب یا نمایش نیست** — فرم ساخت رویداد آن را عمداً از فهرست گزینه‌ها حذف کرده (`frontend/src/features/calendar/components/event-form-dialog.tsx`) و صفحهٔ تقویم هم آن را رندر نمی‌کند (`frontend/src/features/calendar/pages/calendar-page.tsx`). دلیلش این است که مدیریت مرخصی حالا یک گردش‌کار اختصاصی و جدا دارد — جدول `leave_requests` زیر — که جایگزین این روش قدیمی‌تر شده است.

### `leave_requests` — درخواست‌های مرخصی

گردش‌کار اختصاصی درخواست/تأیید مرخصی — جایگزین روش قدیمی‌تر «رویداد تقویم از نوع `leave`» شده (نکتهٔ بالا را ببینید). هر عضو سازمان می‌تواند برای خودش درخواست مرخصی ثبت کند؛ بررسی (تأیید/رد) آن **در سطح کل سازمان** است، نه محدود به یک پروژهٔ خاص — چون مرخصی اصلاً به هیچ پروژه‌ای وابسته نیست.

| ستون | نوع | توضیح |
|---|---|---|
| `id` | UUID (PK) | |
| `organization_id` | UUID (FK → `organizations.id`), اجباری | |
| `user_id` | UUID (FK → `users.id`), اجباری | کاربری که درخواست داده |
| `start_date` / `end_date` | `date`, اجباری | بازهٔ زمانی مرخصی (`end_date` نباید قبل از `start_date` باشد) |
| `reason` | `text`, nullable | دلیل مرخصی (اختیاری) |
| `status` | enum `ApprovalStatus`, اجباری، پیش‌فرض `pending` | `pending` (در انتظار بررسی) / `approved` (تأییدشده) / `rejected` (ردشده) |
| `reviewed_by_id` | UUID (FK → `users.id`, `ondelete SET NULL`), nullable | چه کسی تأیید/رد کرده |
| `review_comment` | `text`, nullable | توضیح رد (یا هر توضیح دیگر بررسی‌کننده) |
| `created_at` / `updated_at` | `timestamptz` | |

> نکتهٔ فنی دربارهٔ enum: ستون `status` این جدول از **همان نوع پستگرسی `approvalstatus`** استفاده می‌کند که پیش‌تر برای `tasks.approval_status` ساخته شده بود — یک enum مشترک، نه یک enum جداگانهٔ هم‌نام. Migration مربوطه (`60291deba722_add_leave_requests`) با `create_type=False` این ستون را می‌سازد تا پستگرس تلاش نکند دوباره همان نوع را از نو `CREATE TYPE` کند (که با خطای «نوع از قبل وجود دارد» شکست می‌خورد).
>
> چه کسی مجاز به بررسی است: **`org_admin` یا `project_manager`** (هر project_manager سازمان، نه فقط مدیر یک پروژهٔ خاص — چون همان‌طور که گفته شد، این بررسی سازمانی است، نه پروژه‌ای). فهرست درخواست‌ها هم بر همین اساس فیلتر می‌شود: کارمند عادی فقط درخواست‌های خودش را می‌بیند؛ org_admin/project_manager همهٔ درخواست‌های سازمان را می‌بینند.
>
> **اعلان `leave_reviewed`:** تأیید یا رد یک درخواست، یک اعلان از نوع `leave_reviewed` برای درخواست‌دهنده می‌سازد (`backend/app/services/leave_requests.py`) — **مگر این‌که بررسی‌کننده همان درخواست‌دهنده باشد** (یعنی کسی درخواست خودش را بررسی کند، که در عمل فقط وقتی رخ می‌دهد که یک org_admin/project_manager مدیریت مرخصی خودش را هم داشته باشد)؛ در آن حالت هیچ اعلانی به خودش ساخته نمی‌شود. این دقیقاً همان الگویی است که برای اعلان `report_reviewed` روی تأیید/رد گزارش‌های کاری (`worklogs`) هم استفاده شده است.

### `otp_codes` — کدهای یک‌بارمصرف

برای ورود مبتنی بر موبایل و بازیابی رمز عبور. **بر اساس شمارهٔ موبایل کلید می‌خورد، نه FK به `users`** — چون ممکن است کدی برای شماره‌ای درخواست شود که هنوز مشخص نیست دقیقاً کدام رکورد کاربر را resolve می‌کند.

| ستون | نوع | توضیح |
|---|---|---|
| `id` | UUID (PK) | |
| `phone_number` | `varchar(32)`, اجباری، ایندکس‌شده (نه FK) | شمارهٔ مقصد کد |
| `code_hash` | `varchar(255)`, اجباری | کد ۶رقمی، **هش‌شده با bcrypt** (نه متن ساده) |
| `purpose` | enum `OtpPurpose`, اجباری | `login` (ورود) / `password_reset` (بازیابی رمز) |
| `expires_at` | `timestamptz`, اجباری | انقضای کد (پیش‌فرض ۵ دقیقه بعد از صدور) |
| `consumed_at` | `timestamptz`, nullable | زمان مصرف‌شدن کد (اگر `NULL` یعنی هنوز مصرف نشده) |
| `attempt_count` | `integer`, پیش‌فرض `0` | تعداد تلاش‌های اشتباه روی همین کد |
| `created_at` / `updated_at` | `timestamptz` | |

### `export_jobs` — درخواست‌های تولید فایل خروجی

| ستون | نوع | توضیح |
|---|---|---|
| `id` | UUID (PK) | |
| `organization_id` | UUID (FK), اجباری | |
| `requested_by_id` | UUID (FK → `users.id`), اجباری | چه کسی درخواست داده |
| `export_type` | enum `ExportFileType`, اجباری | `excel` / `pdf` / `csv` |
| `filters` | `jsonb`, پیش‌فرض `{}` | فیلترهای انتخاب‌شده (پروژه، کاربر، بازهٔ تاریخ و...) |
| `status` | enum `ExportJobStatus`, پیش‌فرض `pending` | `pending` (در صف) / `processing` (در حال تولید) / `done` (آماده) / `failed` (شکست‌خورده) |
| `file_path` | `varchar(500)`, nullable | مسیر فایل تولیدشده روی دیسک، بعد از اتمام |
| `error_message` | `text`, nullable | پیام خطا در صورت شکست |
| `completed_at` | `timestamptz`, nullable | زمان اتمام |
| `created_at` / `updated_at` | `timestamptz` | |

### `audit_logs` — ثبت‌وقایع امنیتی سراسری

مثل `task_activity_logs` ولی در سطح کل سازمان (نه فقط یک وظیفه) و فقط برای رویدادهای امنیتی/حساسِ منتخب (نه هر تغییر).

| ستون | نوع | توضیح |
|---|---|---|
| `id` | UUID (PK) | |
| `created_at` | `timestamptz` | (بدون `updated_at` — غیرقابل‌تغییر) |
| `organization_id` | UUID (FK), **nullable** | `NULL` برای رویدادهای سطح‌پلتفرم که به یک سازمان خاص محدود نیستند |
| `actor_user_id` | UUID (FK → `users.id`), nullable | |
| `action` | `varchar(100)`, اجباری | مثل `user.signup`, `user.login`, `worklog.approve`, `task.delete` |
| `entity_type` | `varchar(100)`, اجباری | نوع موجودیت مرتبط (`organization`, `user`, `task`, `worklog`) |
| `entity_id` | `varchar(100)`, اجباری | شناسهٔ همان موجودیت |
| `extra_metadata` | `jsonb`, پیش‌فرض `{}` | جزئیات اضافه |

> فقط رویدادهای زیر واقعاً ثبت می‌شوند: ثبت‌نام (`user.signup`)، ورود (`user.login`, `user.otp_login`)، بازیابی رمز (`user.password_reset`)، تأیید/رد گزارش کار (`worklog.approve`/`worklog.reject`)، و حذف وظیفه (`task.delete`). این یک انتخاب آگاهانه است، نه نقص — پوشش کامل هر mutation باعث شلوغی بی‌فایدهٔ این جدول می‌شد.

### `comments` — نظرات روی وظیفه

| ستون | نوع | توضیح |
|---|---|---|
| `id` | UUID (PK) | |
| `organization_id` | UUID (FK), اجباری | |
| `task_id` | UUID (FK → `tasks.id`), اجباری | |
| `author_id` | UUID (FK → `users.id`), اجباری | نویسندهٔ کامنت |
| `body` | `text`, اجباری | متن کامنت |
| `created_at` / `updated_at` | `timestamptz` | |

> توجه: ماژول «پیام‌ها» در منوی برنامه در واقع همین کامنت‌های سطح وظیفه است، نه یک سیستم چت/پیام‌رسانی مستقیم بین افراد؛ هیچ مدل مکالمهٔ جداگانه‌ای در سیستم وجود ندارد.

### `attachments` — فایل‌های پیوست به وظیفه

| ستون | نوع | توضیح |
|---|---|---|
| `id` | UUID (PK) | |
| `organization_id` | UUID (FK), اجباری | |
| `task_id` | UUID (FK → `tasks.id`), اجباری | |
| `uploaded_by_id` | UUID (FK → `users.id`), اجباری | آپلودکننده |
| `file_path` | `varchar(500)`, اجباری | مسیر فایل روی دیسک (زیرپوشهٔ مخصوص هر سازمان: `attachments/<organization_id>/...`) |
| `original_filename` | `varchar(300)`, اجباری | نام اصلی فایل |
| `content_type` | `varchar(150)`, اجباری | نوع MIME |
| `size_bytes` | `integer`, اجباری | حجم فایل به بایت (حداکثر مجاز پیش‌فرض ۱۰ مگابایت، `settings.max_attachment_size_bytes`) |
| `created_at` / `updated_at` | `timestamptz` | |

---

## ۳. ارتباط بین جداول

### نمودار متنی روابط کلیدی FK

```
organizations
  └─(organization_id)── departments
  └─(organization_id)── users            (nullable فقط برای platform_admin)
  └─(organization_id)── projects
  └─(organization_id)── tasks             [دنرمالایز از project.organization_id]
  └─(organization_id)── worklogs
  └─(organization_id)── notifications
  └─(organization_id)── calendar_events
  └─(organization_id)── leave_requests
  └─(organization_id)── payments
  └─(organization_id)── export_jobs
  └─(organization_id)── comments
  └─(organization_id)── attachments
  └─(organization_id)── task_activity_logs
  └─(organization_id, nullable)── audit_logs

departments
  └─(department_id, nullable)── users     [فقط گروه‌بندی منطقی، نه ایزوله‌سازی فیزیکی]
  └─(department_id, nullable)── projects  [همان‌طور]

users
  └─(created_by_id)── projects
  └─(user_id)──────── project_members ──(project_id)── projects
  └─(assignee_id, nullable)── tasks
  └─(created_by_id)── tasks
  └─(user_id)──────── worklogs
  └─(reviewed_by_id, nullable)── worklogs
  └─(actor_user_id, nullable)── task_activity_logs
  └─(actor_user_id, nullable)── audit_logs
  └─(user_id)──────── notifications
  └─(created_by_id)── calendar_events
  └─(user_id, nullable)── calendar_events
  └─(user_id)──────── leave_requests
  └─(reviewed_by_id, nullable)── leave_requests
  └─(recorded_by_id)── payments
  └─(requested_by_id)── export_jobs
  └─(author_id)──────── comments
  └─(uploaded_by_id)──── attachments

projects
  └─(project_id)── project_members
  └─(project_id, nullable)── tasks        [NULL روی task یعنی «تسک شخصی»]
  └─(project_id, nullable)── calendar_events
  └─(project_id)── payments

tasks
  └─(parent_task_id, self-FK, nullable)── tasks           [درخت زیروظیفه]
  └─(task_id, self-FK via task_dependencies)── tasks       [وابستگی]
  └─(task_id)── worklogs
  └─(task_id)── task_activity_logs
  └─(task_id)── comments
  └─(task_id)── attachments

otp_codes   ← مستقل، فقط با phone_number (نه FK) به کاربر مرتبط می‌شود
```

### توضیح روابط کلیدی به زبان ساده

- **یک سازمان، چند کاربر و چند پروژه دارد.** هر کاربر و هر پروژه دقیقاً به یک سازمان تعلق دارند (به‌جز `platform_admin` که به هیچ سازمانی تعلق ندارد).
- **یک پروژه چند «عضو» دارد** (از طریق جدول واسط `project_members`) و چند وظیفه دارد. عضویت در پروژه، شرط لازم برای دیدن/کارکردن با آن پروژه است (مگر برای `org_admin` که همه‌چیز سازمان را می‌بیند).
- **یک وظیفه می‌تواند زیروظیفه (subtask) داشته باشد** — یعنی خودش `parent_task_id` بگیرد یا وظایف دیگری `parent_task_id` آن را بگیرند (یک درخت والد/فرزند، نه فقط یک سطح).
- **یک وظیفه می‌تواند به وظایف دیگر وابسته باشد** (از طریق `task_dependencies`) — این جدا از رابطهٔ والد/فرزند است؛ وابستگی یعنی «تا وظیفهٔ دیگر تمام نشود، این وظیفه منطقاً نباید جلو برود» (اجرای این قانون دستی‌ست، دیتابیس آن را قفل نمی‌کند).
- **یک وظیفه چند گزارش کاری (worklog)، چند کامنت و چند پیوست (attachment) دارد.** همهٔ این‌ها با `task_id` به همان وظیفه وصل می‌شوند.
- **یک تسک «شخصی»** (بدون `project_id`) استثنای مهم این مدل است: چون هیچ پروژه‌ای ندارد، عملاً فقط برای سازندهٔ خودش قابل دیدن است و هیچ گردش‌کار تأیید/رد یا وابستگی روی آن اجرا نمی‌شود.
- **گزارش کاری (`worklogs`) به‌طور مستقیم هم به `tasks` و هم به `users` وصل است** — و علاوه‌بر آن یک فیلد اختیاری `reviewed_by_id` دارد که وقتی مدیر پروژه آن را تأیید/رد می‌کند پر می‌شود.
- **`departments` فقط یک برچسب گروه‌بندی است، نه یک مرز ایزوله‌سازی.** برخلاف `organization_id` که واقعاً دید داده را محدود می‌کند، `department_id` روی `users` و `projects` هیچ محدودیت دسترسی‌ای اعمال نمی‌کند — صرفاً برای نمایش/فیلتر در فرانت‌اند استفاده می‌شود.
- **`payments` یک دفترچهٔ ساده و دستی است، محدود به `org_admin`.** برخلاف اکثر جدول‌های پروژه‌محور (که project_manager عضو هم به آن‌ها دسترسی دارد)، فقط org_admin می‌تواند پرداخت‌های یک پروژه را ثبت/دیدن/حذف کند.
- **`leave_requests` جایگزین رویدادهای تقویم از نوع `leave` شده** و بررسی آن (برخلاف اکثر گردش‌کارهای تأیید که پروژه‌محورند) در سطح کل سازمان انجام می‌شود، نه محدود به یک پروژهٔ خاص.

---

## ۴. نحوهٔ اضافه/ویرایش/حذف داده به‌صورت دستی

> **قانون طلایی:** روش توصیه‌شده و درست برای هرگونه تغییر داده، همیشه **از طریق API** است، نه دستکاری مستقیم دیتابیس. دلیل ساده است: منطق کنترل دسترسی (RBAC)، ایزوله‌سازی چندمستأجری، و ثبت رویداد در `audit_logs`/`task_activity_logs` **همگی فقط در لایهٔ سرویس (Python)** اجرا می‌شوند — نه در خودِ دیتابیس. اگر مستقیم روی جدول‌ها SQL بزنید، هیچ‌کدام از این کنترل‌ها اعمال نمی‌شود.
>
> دستکاری مستقیم دیتابیس فقط باید در موارد **اضطراری یا دیباگ** (مثلاً وقتی endpoint مناسب اصلاً وجود ندارد، یا سرویس API از دسترس خارج شده) و توسط افراد مورد اعتماد انجام شود.

### اتصال به دیتابیس با psql

روی محیط توسعهٔ native (بدون Docker):

```bash
psql "$DATABASE_URL"
# یا صریح:
psql "postgresql://workpilot:workpilot@localhost:5432/workpilot"
```

روی محیط Docker Compose:

```bash
docker compose exec postgres psql -U workpilot -d workpilot
```

### مثال بی‌خطر: افزودن/ویرایش/حذف روی جدول `comments`

جدول `comments` نسبتاً کم‌خطر است چون هیچ جدول دیگری وابسته به آن نیست (رابطهٔ فرزندی از آن خارج نمی‌شود). مثال:

```sql
-- افزودن یک کامنت دستی (فقط برای دیباگ اضطراری — معمولاً از API انجام شود)
INSERT INTO comments (id, organization_id, task_id, author_id, body, created_at, updated_at)
VALUES (
    gen_random_uuid(),
    '11111111-1111-1111-1111-111111111111', -- organization_id واقعی
    '22222222-2222-2222-2222-222222222222', -- task_id واقعی
    '33333333-3333-3333-3333-333333333333', -- author_id واقعی (باید یک کاربر همان سازمان باشد)
    'این یک کامنت آزمایشی است که مستقیماً در دیتابیس درج شد.',
    now(),
    now()
);

-- ویرایش متن یک کامنت
UPDATE comments
SET body = 'متن ویرایش‌شده', updated_at = now()
WHERE id = '44444444-4444-4444-4444-444444444444';

-- حذف یک کامنت
DELETE FROM comments WHERE id = '44444444-4444-4444-4444-444444444444';
```

اگر پستگرس شما `gen_random_uuid()` را نمی‌شناسد، اکستنشن `pgcrypto` را فعال کنید:

```sql
CREATE EXTENSION IF NOT EXISTS pgcrypto;
```

### هشدار صریح دربارهٔ ستون‌های `organization_id`

> **هرگز مقدار `organization_id` یک ردیف موجود را با UPDATE مستقیم تغییر ندهید**، مگر این‌که دقیقاً بدانید چه‌کاری انجام می‌دهید و پیامدهایش را می‌پذیرید. تغییر دستی `organization_id` روی هر جدول (`users`, `projects`, `tasks`, `worklogs`, ...) عملاً یعنی «این ردیف را از یک مستأجر به مستأجر دیگر منتقل کن» — که می‌تواند:
>
> - **ایزولاسیون داده بین سازمان‌ها را کاملاً بشکند** (مثلاً یک کاربر یا وظیفه از سازمان A ناگهان در سازمان B قابل مشاهده شود).
> - داده‌های مرتبط (FK) را در وضعیت ناسازگار قرار دهد — مثلاً یک `task` که `organization_id` آن عوض شده ولی `project_id` آن هنوز به پروژه‌ای در سازمان قبلی اشاره می‌کند.
> - باعث بروز رفتار غیرمنتظره در `TenantScopedRepository` شود چون این کلاس همیشه فرض می‌کند `organization_id` هر ردیف با `project`/`task` والدش سازگار است.
>
> اگر واقعاً نیاز به انتقال داده بین سازمان‌ها دارید، باید همهٔ جدول‌های وابسته (به‌ترتیب صحیح FK) به‌طور هماهنگ به‌روزرسانی شوند و بعد از آن با کوئری دستی صحت داده بررسی شود — این یک عملیات نادر و پرریسک است، نه یک کار روزمره.

---

## ۵. نحوهٔ تغییر رمز عبور یک کاربر

### روش الف — توصیه‌شده (از طریق UI/API)

سه راه در سطح API برای این کار وجود دارد:

1. **خودِ کاربر رمزش را عوض می‌کند (وقتی رمز فعلی را می‌داند):**
   ```http
   POST /api/v1/auth/me/change-password
   Authorization: Bearer <access_token>
   Content-Type: application/json

   {
     "current_password": "RamzeQabli123",
     "new_password": "RamzeJadid456"
   }
   ```

2. **کاربر رمزش را فراموش کرده — بازیابی با کد پیامکی:**
   ```http
   POST /api/v1/auth/otp/request
   Content-Type: application/json

   { "phone_number": "09121234567", "purpose": "password_reset" }
   ```
   سپس با کد دریافتی:
   ```http
   POST /api/v1/auth/otp/reset-password
   Content-Type: application/json

   {
     "phone_number": "09121234567",
     "code": "482913",
     "new_password": "RamzeTazeAmn789"
   }
   ```

3. **کاربر اصلاً هنوز رمز ندارد (با موبایل دعوت شده)** — از طریق `POST /api/v1/auth/otp/login` با فیلد `new_password` (جزئیات کامل در بخش ۲).

### روش ب — اضطراری، مستقیم روی دیتابیس

رمزهای عبور در ستون `hashed_password` جدول `users` با الگوریتم **bcrypt** هش شده‌اند (نه رمزنگاری قابل‌برگشت، و قطعاً نه متن ساده). **هرگز نباید** مستقیماً متن ساده (plaintext) در این ستون قرار داده شود — چون:

- کد برنامه (`verify_password` در `backend/app/core/security.py`) انتظار دارد مقدار این ستون یک هش معتبر bcrypt باشد؛ اگر متن ساده در آن باشد، تلاش برای مقایسه‌اش با `bcrypt.checkpw` با خطا (Exception) مواجه می‌شود یا رفتار نامشخص می‌دهد — کاربر عملاً هرگز نمی‌تواند وارد شود.
- اگر پشتیبان (backup) دیتابیس درز کند، رمزهای متن‌ساده مستقیماً افشا می‌شوند؛ هش bcrypt برخلاف آن، حتی در صورت درز، به‌سادگی قابل بازگردانی به رمز اصلی نیست.

بنابراین همیشه باید مقدار را **قبل از درج در دیتابیس** با bcrypt هش کرد. دو راه:

**۱) اسکریپت پایتون کامل (روش توصیه‌شده برای اضطراری):**

```python
#!/usr/bin/env python
"""ریست اضطراری رمز عبور یک کاربر — فقط برای دیباگ/اضطرار.
اجرا از داخل پوشهٔ backend، با virtualenv فعال:
    python reset_password.py --email admin@example.com --password "RamzeJadid123"
"""
import argparse

from app.core.security import hash_password
from app.db.session import SessionLocal
from app.models.user import User


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--email", required=True)
    parser.add_argument("--password", required=True)
    args = parser.parse_args()

    db = SessionLocal()
    try:
        user = db.query(User).filter(User.email == args.email).first()
        if user is None:
            print(f"کاربری با ایمیل {args.email} پیدا نشد.")
            return
        user.hashed_password = hash_password(args.password)
        db.commit()
        print(f"رمز عبور کاربر {args.email} با موفقیت تغییر کرد.")
    finally:
        db.close()


if __name__ == "__main__":
    main()
```

این اسکریپت دقیقاً از همان تابع `hash_password` که خودِ اپلیکیشن برای ثبت‌نام/تغییر رمز استفاده می‌کند بهره می‌برد — پس هش تولیدشده ۱۰۰٪ با چیزی که کد بعداً برای اعتبارسنجی می‌خواند سازگار است.

**۲) ساده‌تر: تولید هش با یک خط پایتون و درج مستقیم با SQL:**

```bash
# داخل پوشهٔ backend با virtualenv فعال
python -c "import bcrypt; print(bcrypt.hashpw(b'RamzeJadid123', bcrypt.gensalt()).decode())"
```

خروجی چیزی شبیه این خواهد بود (هر بار متفاوت است چون salt تصادفی است):

```
$2b$12$KIXQ3n6y6E1r0S8QpX8mFOeYq6zj9F0m7pXWQwqzQvJXk3l0m1a2S
```

سپس همین رشته را مستقیم در دیتابیس بگذارید:

```sql
UPDATE users
SET hashed_password = '$2b$12$KIXQ3n6y6E1r0S8QpX8mFOeYq6zj9F0m7pXWQwqzQvJXk3l0m1a2S',
    updated_at = now()
WHERE email = 'admin@example.com';
```

> توجه: bcrypt رمزهای طولانی‌تر از ۷۲ بایت را نادیده می‌گیرد (فقط ۷۲ بایت اول را واقعاً هش می‌کند)؛ کد برنامه (`hash_password` در `core/security.py`) به همین دلیل رمزهای طولانی‌تر از ۷۲ بایت را رد می‌کند (خطا می‌دهد)، نه این‌که خاموش فقط بخشی از آن را هش کند.

---

## ۶. نحوهٔ ایجاد یک مدیر (org_admin) جدید

### حالت معمول — سازمان از قبل حداقل یک org_admin دارد

سریع‌ترین و درست‌ترین راه، از طریق API توسط یک `org_admin` موجود است:

```http
POST /api/v1/users
Authorization: Bearer <access_token_org_admin>
Content-Type: application/json

{
  "full_name": "سارا احمدی",
  "email": "sara.ahmadi@example.com",
  "phone_number": "09123334455",
  "password": "RamzeAvvaliyeh123",
  "role": "org_admin"
}
```

اگر بخواهید یک کاربر **موجود** را به org_admin ارتقا دهید (نه ساخت کاربر تازه):

```http
PATCH /api/v1/users/{user_id}
Authorization: Bearer <access_token_org_admin>
Content-Type: application/json

{ "role": "org_admin" }
```

### حالت اضطراری — هیچ org_admin فعالی در سازمان نمانده

اگر به هر دلیل (مثلاً غیرفعال‌شدن حساب تنها org_admin) سازمانی بدون هیچ org_admin فعالی باقی بماند، هیچ‌کس دیگر نمی‌تواند از طریق UI/API نقش کسی را org_admin کند (چون این endpoint فقط برای خودِ org_admin باز است). در این حالت، تنها راه مستقیم SQL است:

```sql
UPDATE users
SET role = 'org_admin', updated_at = now()
WHERE id = '<user_id>' AND organization_id = '<organization_id>';
```

قبل از اجرا، حتماً مطمئن شوید کاربر مقصد واقعاً متعلق به همان سازمان است (شرط `organization_id` در همین کوئری دقیقاً برای همین است).

### `platform_admin` چیست و چطور ساخته می‌شود؟

`platform_admin` یک نقش کاملاً جدا و بالاتر از `org_admin` است — به **هیچ سازمانی تعلق ندارد** (`organization_id = NULL`) و برای مدیریت کل پلتفرم (نه یک سازمان خاص) در نظر گرفته شده. این نقش:

- **از طریق endpoint عمومی ثبت‌نام (`POST /auth/signup`) هرگز ساخته نمی‌شود** — آن مسیر همیشه یک سازمان تازه + یک `org_admin` می‌سازد.
- **از طریق `POST /api/v1/users` هم قابل تخصیص نیست** — schema (`OrgUserCreate`) به‌طور صریح تلاش برای ست‌کردن `role=platform_admin` را رد می‌کند (خطای ۴۲۲).
- تنها راه ساختش، اجرای اسکریپت یک‌باره `backend/scripts/seed_platform_admin.py` است:

```bash
cd backend
python -m scripts.seed_platform_admin --email admin@workpilot.example --password 'RamzeQaviPlatform123'
```

این اسکریپت باید **یک‌بار در هر استقرار (deployment)** اجرا شود، معمولاً بلافاصله بعد از راه‌اندازی اولیهٔ دیتابیس.

---

## ۷. نحوهٔ حذف یک کاربر

**هیچ endpoint ای برای حذف واقعی (فیزیکی) کاربر در سیستم وجود ندارد.** تنها چیزی که از طریق API موجود است **غیرفعال‌سازی** حساب است:

```http
PATCH /api/v1/users/{user_id}
Authorization: Bearer <access_token_org_admin>
Content-Type: application/json

{ "is_active": false }
```

با این کار، `is_active` کاربر `false` می‌شود؛ کاربر دیگر نمی‌تواند وارد شود (`authenticate`/`otp_login`/`request_otp` همه صریحاً چک `is_active` را انجام می‌دهند)، ولی همهٔ ردیف‌های تاریخی مربوط به او (وظایف، گزارش‌های کاری، کامنت‌ها، ...) دست‌نخورده باقی می‌مانند.

> **توصیهٔ صریح این سند:** تقریباً همیشه به‌جای حذف فیزیکی، از همین غیرفعال‌سازی استفاده کنید. حذف واقعی یک کاربر، تاریخچهٔ کاری (چه کسی چه وظیفه‌ای را انجام داد، چه کامنتی گذاشت) را از دست می‌دهد یا شکسته می‌کند.

اگر با این‌همه واقعاً نیاز به حذف فیزیکی دارید (مثلاً درخواست قانونی حذف داده)، چون بسیاری از جدول‌ها به `users.id` با FK ارجاع می‌دهند، **باید قبل از حذف کاربر، ردیف‌های وابسته را یا حذف یا مقدار FK آن‌ها را `NULL`/بازتخصیص کنید** — در غیر این صورت دیتابیس با خطای Foreign Key Constraint جلوی حذف را می‌گیرد. ترتیب پیشنهادی (از فرزندترین به ریشه‌ای‌ترین):

```sql
BEGIN;

-- ۱) وظایفی که این کاربر مسئولشان بوده: یا تخصیص را بردار، یا به کاربر دیگری بده
UPDATE tasks SET assignee_id = NULL WHERE assignee_id = '<user_id>';

-- وظایفی که این کاربر ساخته: created_by_id اجباری است (NOT NULL) — این‌ها را
-- نمی‌توان صرفاً NULL کرد. یا باید به کاربر دیگری منتقل شوند، یا خودِ وظیفه حذف شود.
-- مثال انتقال به یک کاربر جایگزین (مثلاً خودِ org_admin):
UPDATE tasks SET created_by_id = '<replacement_user_id>' WHERE created_by_id = '<user_id>';

-- ۲) گزارش‌های کاری ثبت‌شده توسط این کاربر
DELETE FROM worklogs WHERE user_id = '<user_id>';
UPDATE worklogs SET reviewed_by_id = NULL WHERE reviewed_by_id = '<user_id>';

-- ۳) کامنت‌ها و پیوست‌های این کاربر
DELETE FROM comments WHERE author_id = '<user_id>';
DELETE FROM attachments WHERE uploaded_by_id = '<user_id>';

-- ۴) عضویت در پروژه‌ها
DELETE FROM project_members WHERE user_id = '<user_id>';

-- ۵) اعلان‌های این کاربر
DELETE FROM notifications WHERE user_id = '<user_id>';

-- ۶) رویدادهای تقویم مرتبط
UPDATE calendar_events SET user_id = NULL WHERE user_id = '<user_id>';
UPDATE calendar_events SET created_by_id = '<replacement_user_id>' WHERE created_by_id = '<user_id>';

-- ۷) ثبت‌وقایع (این‌ها را می‌توان NULL کرد چون actor_user_id در این جدول‌ها nullable است)
UPDATE audit_logs SET actor_user_id = NULL WHERE actor_user_id = '<user_id>';
UPDATE task_activity_logs SET actor_user_id = NULL WHERE actor_user_id = '<user_id>';

-- ۸) پروژه‌هایی که این کاربر ساخته (created_by_id اجباری روی projects هم هست)
UPDATE projects SET created_by_id = '<replacement_user_id>' WHERE created_by_id = '<user_id>';

-- ۹) export_jobs که این کاربر درخواست داده
DELETE FROM export_jobs WHERE requested_by_id = '<user_id>';

-- ۱۰) در نهایت خودِ کاربر
DELETE FROM users WHERE id = '<user_id>';

COMMIT;
```

> این یک عملیات پرریسک و برگشت‌ناپذیر است — همیشه قبل از اجرا یک بک‌آپ تازه بگیرید (بخش ۱۰) و در محیط تست اول امتحان کنید.

---

## ۸. نحوهٔ انتقال مالکیت سازمان

**نکتهٔ مهم و صریح:** مدل دادهٔ فعلی WorkPilot اصلاً مفهوم «یک مالک منحصربه‌فرد برای هر سازمان» را ندارد. جدول `organizations` هیچ ستونی مثل `owner_id` ندارد؛ هر تعداد کاربر می‌توانند هم‌زمان نقش `org_admin` داشته باشند و همگی از نظر سیستم کاملاً هم‌سطح‌اند — هیچ‌کدام «مالک اصلی‌تر» از دیگری نیست. این یک **محدودیت شناخته‌شدهٔ مدل فعلی** است، نه یک قابلیت آماده که بشود «فعال»اش کرد.

بنابراین «انتقال مالکیت» در عمل، یعنی ترکیب دو کار سادهٔ زیر که هردو از طریق endpointهای موجود انجام‌پذیرند:

**۱) نقش کاربر جدید را به `org_admin` ارتقا دهید:**

```http
PATCH /api/v1/users/{new_owner_user_id}
Authorization: Bearer <access_token_current_org_admin>
Content-Type: application/json

{ "role": "org_admin" }
```

یا معادل SQL (اضطراری، وقتی هیچ org_admin فعالی نمانده — همان روش بخش ۶):

```sql
UPDATE users SET role = 'org_admin', updated_at = now()
WHERE id = '<new_owner_user_id>' AND organization_id = '<organization_id>';
```

**۲) در صورت نیاز، نقش «مالک قبلی» را تنزل دهید یا غیرفعالش کنید:**

```http
PATCH /api/v1/users/{old_owner_user_id}
Authorization: Bearer <access_token_new_org_admin>
Content-Type: application/json

{ "role": "project_manager" }
```

یا برای خروج کامل او از سازمان (غیرفعال‌سازی، نه حذف — طبق توصیهٔ بخش ۷):

```json
{ "is_active": false }
```

> نکته: طبق منطق سرویس `users_service.update_org_user` (`backend/app/services/users.py`)، **یک کاربر نمی‌تواند حساب خودش را غیرفعال کند** (خطای ۴۰۰) — پس اگر «مالک قبلی» می‌خواهد خودش را کنار بگذارد، باید این کار را «مالک جدید» (که تازه org_admin شده) برایش انجام دهد، نه خودش.

اگر در آینده نیاز واقعی به مفهوم «یک مالک واحد و منحصربه‌فرد سازمان» پیش بیاید (مثلاً برای صورتحساب/فاکتور)، باید یک ستون جدید مثل `organizations.owner_user_id` به مدل اضافه شود — این یک تغییر معماری است، نه چیزی که با تنظیمات فعلی قابل انجام باشد.

---

## ۹. نکات امنیتی دیتابیس

- **رمزهای عبور هرگز متن ساده نیستند** — با bcrypt هش می‌شوند (`backend/app/core/security.py`). حتی وقتی مستقیم SQL می‌زنید، همیشه از یک هش معتبر استفاده کنید (بخش ۵).
- **کدهای OTP هم plaintext ذخیره نمی‌شوند** — دقیقاً با همان تابع `hash_password`/`verify_password` (bcrypt) هش می‌شوند، حتی با این‌که فقط ۶ رقم و کوتاه‌عمرند؛ چون درز دیتابیس نباید کد فعال یک کاربر را افشا کند.
- **هرگز رشتهٔ اتصال دیتابیس (Connection String) حاوی رمز عبور را commit نکنید.** فایل `backend/.env` (که `DATABASE_URL` واقعی و `SECRET_KEY` را نگه می‌دارد) در `.gitignore` است؛ فقط `backend/.env.example` (بدون مقدار واقعی حساس) در مخزن قرار دارد.
- **دسترسی مستقیم psql فقط برای افراد مورد اعتماد و فقط برای دیباگ اضطراری** باشد — نه یک ابزار روزمرهٔ کاری. هر تغییر معمول باید از API عبور کند.
- **پشتیبان (Backup) دیتابیس باید محدود‌دسترسی و ترجیحاً رمزگذاری‌شده نگه‌داری شود** — چون شامل داده‌های شخصی واقعی (ایمیل، شمارهٔ موبایل، رمز هش‌شده، متن گزارش‌های کاری) است. فایل بک‌آپ را هرگز در یک مخزن گیت عمومی یا فضای اشتراکی بدون کنترل دسترسی قرار ندهید.
- **`SECRET_KEY`** (در `backend/app/core/config.py`، مورد استفاده برای امضای JWT) باید در production یک مقدار تصادفی و طولانی و مخفی باشد؛ مقدار پیش‌فرض توسعه (`change-me-in-.env`) هرگز نباید در production استفاده شود.
- **`cookie_secure`** باید در production حتماً `True` باشد (کوکی refresh token فقط روی HTTPS ارسال شود)؛ پیش‌فرض توسعه `False` است چون توسعهٔ محلی روی HTTP ساده اجرا می‌شود.

---

## ۱۰. Backup و Restore

### اجرای Native (بدون Docker)

**گرفتن بک‌آپ:**

```bash
pg_dump -U workpilot -h localhost -d workpilot -F c -f workpilot_backup_$(date +%Y%m%d_%H%M%S).dump
```

(`-F c` یعنی فرمت فشرده و سفارشی pg_dump — سریع‌تر و کوچک‌تر از خروجی متنی ساده، و با `pg_restore` قابل بازگردانی است.)

اگر فرمت ساده و متنی (SQL خام) می‌خواهید:

```bash
pg_dump -U workpilot -h localhost -d workpilot -F p -f workpilot_backup_$(date +%Y%m%d_%H%M%S).sql
```

**بازگردانی (Restore) از فرمت custom:**

```bash
# روی یک دیتابیس خالی و از‌قبل ساخته‌شده
pg_restore -U workpilot -h localhost -d workpilot --clean --if-exists workpilot_backup_20260716_120000.dump
```

**بازگردانی از فرمت متنی ساده:**

```bash
psql -U workpilot -h localhost -d workpilot < workpilot_backup_20260716_120000.sql
```

### اجرای Docker Compose

**گرفتن بک‌آپ از داخل کانتینر `postgres`:**

```bash
docker compose exec postgres pg_dump -U workpilot -d workpilot -F c -f /tmp/workpilot_backup.dump
docker compose cp postgres:/tmp/workpilot_backup.dump ./workpilot_backup_$(date +%Y%m%d_%H%M%S).dump
```

**بازگردانی:**

```bash
docker compose cp ./workpilot_backup_20260716_120000.dump postgres:/tmp/restore.dump
docker compose exec postgres pg_restore -U workpilot -d workpilot --clean --if-exists /tmp/restore.dump
```

### پیشنهاد زمان‌بندی بک‌آپ خودکار (cron)

مثال یک اسکریپت ساده (`/opt/workpilot/backup.sh`) که هر شب ساعت ۳ بامداد اجرا می‌شود و ۷ بک‌آپ آخر را نگه می‌دارد:

```bash
#!/bin/bash
set -euo pipefail
BACKUP_DIR="/var/backups/workpilot"
mkdir -p "$BACKUP_DIR"
STAMP=$(date +%Y%m%d_%H%M%S)

pg_dump -U workpilot -h localhost -d workpilot -F c -f "$BACKUP_DIR/workpilot_$STAMP.dump"

# نگه‌داشتن فقط ۷ بک‌آپ آخر
ls -1t "$BACKUP_DIR"/workpilot_*.dump | tail -n +8 | xargs -r rm --
```

و ثبت آن در crontab (اجرای هر شب ساعت ۳):

```cron
0 3 * * * /opt/workpilot/backup.sh >> /var/log/workpilot-backup.log 2>&1
```

> یادآوری: طبق بخش ۹، فایل‌های بک‌آپ حاوی داده‌های شخصی هستند — پوشهٔ `/var/backups/workpilot` باید دسترسی محدود (مثلاً `chmod 700`) داشته باشد و ایده‌آل است که در یک storage رمزگذاری‌شده نگه‌داری شود.

---

## ۱۱. نحوهٔ ریست کردن دیتابیس

> **هشدار بسیار مهم:** دستورهای این بخش **همهٔ داده‌های دیتابیس را برای همیشه پاک می‌کنند** و هیچ راه بازگشتی ندارند مگر این‌که از قبل بک‌آپ گرفته باشید. این دستورها فقط باید در محیط **توسعه (dev)** یا **staging** استفاده شوند — **هرگز روی دیتابیس production بدون یک بک‌آپ تازه و تأییدشده اجرا نشوند.**

### روش کامل: Drop + Create + Migrate

```bash
# ۱) اتصال به دیتابیس postgres (نه خودِ workpilot، چون نمی‌شود دیتابیسی که به آن وصلید را drop کرد)
psql -U workpilot -h localhost -d postgres

# ۲) داخل psql:
DROP DATABASE IF EXISTS workpilot;
CREATE DATABASE workpilot OWNER workpilot;
\q
```

سپس اجرای مهاجرت‌ها از صفر تا آخرین نسخه:

```bash
cd backend
alembic upgrade head
```

### معادل روی Docker Compose

```bash
docker compose exec postgres psql -U workpilot -d postgres -c "DROP DATABASE IF EXISTS workpilot;"
docker compose exec postgres psql -U workpilot -d postgres -c "CREATE DATABASE workpilot OWNER workpilot;"

# مهاجرت از داخل کانتینر backend (که کد و alembic.ini را دارد)
docker compose exec backend alembic upgrade head
```

> نکته: طبق `docker-compose.yml`، سرویس `backend` خودش هنگام بالا آمدن (وقتی `RUN_MIGRATIONS=true` باشد) به‌طور خودکار `alembic upgrade head` را اجرا می‌کند — پس اگر فقط کانتینر `backend` را ری‌استارت کنید (`docker compose restart backend`)، migration خودش دوباره اجرا می‌شود؛ نیازی به دستور دستی `alembic upgrade head` در محیط Docker نیست، مگر بخواهید صریحاً و بلافاصله همان لحظه اجرا شود.

بعد از ریست، دیتابیس کاملاً خالی است — هیچ سازمان/کاربری وجود ندارد. برای شروع کار باید یا:
- از `POST /api/v1/auth/signup` یک سازمان + اولین `org_admin` بسازید، یا
- اسکریپت `python -m scripts.seed_platform_admin ...` را برای اولین `platform_admin` اجرا کنید (بخش ۶).

---

# بخش ۲: راهنمای API

## ۱. نحوهٔ احراز هویت

WorkPilot از یک جریان **JWT دوتکه (Two-Token)** استفاده می‌کند:

- **Access Token:** کوتاه‌مدت (پیش‌فرض **۳۰ دقیقه**، `settings.access_token_expire_minutes`)، شامل `user_id`، `organization_id`، `role`. باید در هر درخواست به API در هدر زیر فرستاده شود:
  ```
  Authorization: Bearer <access_token>
  ```
  این توکن **فقط در حافظهٔ مرورگر (state جاوااسکریپت، نه localStorage)** نگه‌داری می‌شود تا ریسک سرقت با XSS کم شود.

- **Refresh Token:** بلندمدت (پیش‌فرض **۷ روز**، `settings.refresh_token_expire_days`)، در یک **کوکی httpOnly** با تنظیمات زیر ست می‌شود:
  - `httponly=true` (جاوااسکریپت اصلاً نمی‌تواند آن را بخواند)
  - `secure=<settings.cookie_secure>` (باید در production حتماً `true` باشد)
  - `samesite=lax`
  - `path=/api/v1/auth` (**فقط** به مسیرهای زیر `/api/v1/auth` فرستاده می‌شود، نه کل سایت)
  - در **هر بار استفاده rotate می‌شود** (یعنی هر فراخوانی `POST /auth/refresh` یک کوکی refresh تازه صادر می‌کند و قبلی را عملاً بی‌اثر می‌کند).

### جریان کامل کلاسیک (ایمیل/موبایل + رمز عبور)

**۱) ثبت‌نام (اولین بار — ساخت سازمان تازه + اولین کاربر آن به‌عنوان org_admin):**

```http
POST /api/v1/auth/signup
Content-Type: application/json

{
  "organization_name": "شرکت نمونهٔ تدوین حساب",
  "full_name": "علی رضایی",
  "email": "ali.rezaei@example.com",
  "phone_number": "09121112233",
  "password": "RamzeAvvaliyeh123"
}
```

پاسخ موفق (`201`):

```json
{
  "id": "9c1f2e3a-...",
  "organization_id": "b7d4a1c0-...",
  "email": "ali.rezaei@example.com",
  "phone_number": "09121112233",
  "full_name": "علی رضایی",
  "role": "org_admin",
  "is_active": true,
  "has_password": true
}
```

**۲) ورود:**

```http
POST /api/v1/auth/login
Content-Type: application/json

{ "identifier": "09121112233", "password": "RamzeAvvaliyeh123" }
```

`identifier` می‌تواند ایمیل یا شمارهٔ موبایل باشد (اگر `@` داشته باشد ایمیل در نظر گرفته می‌شود). پاسخ (`200`)، به‌همراه ست‌شدن کوکی `refresh_token`:

```json
{ "access_token": "eyJhbGciOi...", "token_type": "bearer" }
```

**۳) گرفتن اطلاعات کاربر جاری:**

```http
GET /api/v1/auth/me
Authorization: Bearer eyJhbGciOi...
```

**۴) تمدید access token (وقتی منقضی شده یا نزدیک انقضاست):**

```http
POST /api/v1/auth/refresh
Cookie: refresh_token=eyJhbGciOi...
```

پاسخ: یک `access_token` تازه (و کوکی refresh هم rotate می‌شود).

**۵) خروج:**

```http
POST /api/v1/auth/logout
```

کوکی `refresh_token` پاک می‌شود (سمت فرانت هم باید `accessToken` را از حافظه پاک کند).

### جریان جدیدتر: ورود/بازیابی با کد یکبارمصرف پیامکی (OTP)

> توجه مهم: در محیط توسعهٔ فعلی هیچ ارائه‌دهندهٔ واقعی پیامک وصل نشده (`settings.sms_provider_configured = False`). تا وقتی این پرچم `False` است، endpoint درخواست کد، کد تولیدشده را مستقیماً در پاسخ API (فیلد `debug_code`) برمی‌گرداند — این فقط برای تست/توسعه است و **هرگز نباید در production با شماره‌های واقعی کاربران به همین شکل باقی بماند.**

**درخواست کد ورود:**

```http
POST /api/v1/auth/otp/request
Content-Type: application/json

{ "phone_number": "09121112233", "purpose": "login" }
```

پاسخ (در محیط توسعه):

```json
{ "message": "کد ارسال شد", "debug_code": "482913" }
```

**ورود با کد (کاربری که از قبل رمز دارد، `new_password` اختیاری):**

```http
POST /api/v1/auth/otp/login
Content-Type: application/json

{ "phone_number": "09121112233", "code": "482913" }
```

**ورود با کد + تعیین رمز تازه (کاربری که با موبایل دعوت شده و هنوز رمز ندارد — این‌جا `new_password` اجباری است، وگرنه خطای `400 password_setup_required` می‌گیرید):**

```http
POST /api/v1/auth/otp/login
Content-Type: application/json

{ "phone_number": "09123334455", "code": "119284", "new_password": "RamzeTaze123" }
```

**درخواست کد بازیابی رمز، و بازیابی:**

```http
POST /api/v1/auth/otp/request
Content-Type: application/json

{ "phone_number": "09121112233", "purpose": "password_reset" }
```

```http
POST /api/v1/auth/otp/reset-password
Content-Type: application/json

{
  "phone_number": "09121112233",
  "code": "731045",
  "new_password": "RamzeBazyabiShode456"
}
```

هر دو مسیر `otp/login` و `otp/reset-password` مثل `login` معمولی، هم `access_token` برمی‌گردانند و هم کوکی `refresh_token` را ست می‌کنند — یعنی کاربر بلافاصله وارد می‌شود.

### قانون قدرت رمز عبور

هرجا رمز عبور تعیین/تغییر می‌شود (`signup`, `POST /users`, `change-password`, `otp/login`, `otp/reset-password`)، این قوانین (`backend/app/schemas/validators.py`) اعمال می‌شود:

- حداقل ۸ و حداکثر ۱۲۸ کاراکتر (محدودیت طول از خودِ schema)
- حداکثر ۷۲ بایت (محدودیت واقعی bcrypt)
- حداقل یک حرف انگلیسی (`[A-Za-z]`)
- حداقل یک رقم (`[0-9]`)

---

## ۲. جدول کامل Endpointها

> در تمام مثال‌ها، پیشوند نسخهٔ API `/api/v1` است (به‌جز `/health`). هر endpoint (به‌جز `auth/signup`، `auth/login`، `auth/otp/*`، `auth/refresh`، `auth/logout`، `health`) نیازمند هدر `Authorization: Bearer <access_token>` است.

### گروه Auth (`/api/v1/auth`)

| # | کاربرد | Method + مسیر |
|---|---|---|
| ۱ | ثبت‌نام سازمان تازه + اولین کاربر (org_admin) | `POST /api/v1/auth/signup` |
| ۲ | ورود با ایمیل/موبایل + رمز عبور | `POST /api/v1/auth/login` |
| ۳ | درخواست کد یکبارمصرف پیامکی | `POST /api/v1/auth/otp/request` |
| ۴ | ورود با کد یکبارمصرف | `POST /api/v1/auth/otp/login` |
| ۵ | بازیابی رمز عبور با کد یکبارمصرف | `POST /api/v1/auth/otp/reset-password` |
| ۶ | تمدید access token با استفاده از کوکی refresh | `POST /api/v1/auth/refresh` |
| ۷ | خروج (پاک‌کردن کوکی refresh) | `POST /api/v1/auth/logout` |
| ۸ | گرفتن اطلاعات کاربر جاری | `GET /api/v1/auth/me` |
| ۹ | ویرایش نام کاربر جاری | `PATCH /api/v1/auth/me` |
| ۱۰ | تغییر رمز عبور کاربر جاری | `POST /api/v1/auth/me/change-password` |

جزئیات کامل ۶ مورد اول در بخش «نحوهٔ احراز هویت» بالا آمد. سه مورد باقی‌مانده:

**`GET /api/v1/auth/me`** — نقش مجاز: هر کاربر واردشده (اعم از platform_admin). بدون بدنه. پاسخ (`200`):
```json
{
  "id": "9c1f2e3a-...",
  "organization_id": "b7d4a1c0-...",
  "email": "ali.rezaei@example.com",
  "phone_number": "09121112233",
  "full_name": "علی رضایی",
  "role": "org_admin",
  "is_active": true,
  "has_password": true
}
```
خطاها: `401` (توکن نامعتبر/منقضی/نبود توکن).

**`PATCH /api/v1/auth/me`** — بدنه: `{"full_name": "string(2..200), اجباری"}`. نمونه:
```json
{ "full_name": "علی رضاییِ ویرایش‌شده" }
```
پاسخ: همان شکل `UserOut` بالا با `full_name` جدید. خطاها: `401`, `422` (طول نام نامعتبر).

**`POST /api/v1/auth/me/change-password`** — بدنه: `{"current_password": "string", "new_password": "string(8..128)"}`. نمونه:
```json
{ "current_password": "RamzeQabli123", "new_password": "RamzeJadid456" }
```
پاسخ (`200`): `{"detail": "password changed"}`. خطاها: `400` (رمز فعلی اشتباه است، یا کاربر اصلاً رمزی ندارد)، `401`, `422` (رمز جدید ضعیف/کوتاه).

---

### گروه Users (`/api/v1/users`)

| # | کاربرد | Method + مسیر | نقش مجاز |
|---|---|---|---|
| ۱ | ساخت کاربر جدید در سازمان | `POST /api/v1/users` | فقط `org_admin` |
| ۲ | فهرست همهٔ کاربران سازمان | `GET /api/v1/users` | هر کاربر واردشدهٔ همان سازمان |
| ۳ | ویرایش نقش/وضعیت/موبایل یک کاربر | `PATCH /api/v1/users/{user_id}` | فقط `org_admin` |

**`POST /api/v1/users`** — بدنه (`OrgUserCreate`):

| فیلد | نوع | اجباری؟ |
|---|---|---|
| `full_name` | رشته، ۲ تا ۲۰۰ کاراکتر | بله |
| `email` | ایمیل معتبر | بله |
| `phone_number` | رشته، ۸ تا ۳۲ کاراکتر | بله |
| `password` | رشته، ۸ تا ۱۲۸ کاراکتر (اگر حذف شود، کاربر با موبایل دعوت می‌شود و رمزش را بعداً با OTP تعیین می‌کند) | خیر |
| `role` | یکی از `org_admin`/`project_manager`/`employee` (نمی‌تواند `platform_admin` باشد؛ پیش‌فرض `employee`) | خیر |

نمونهٔ درخواست:
```json
{
  "full_name": "مریم کریمی",
  "email": "maryam.karimi@example.com",
  "phone_number": "09354445566",
  "password": "RamzeMaryam123",
  "role": "project_manager"
}
```
پاسخ (`201`) — شکل `UserOut` (همان ساختار بخش auth/me). خطاها: `403` (کاربر جاری org_admin نیست)، `409` (ایمیل یا موبایل تکراری)، `422` (نقش نامعتبر مثل `platform_admin`، یا رمز ضعیف).

**`GET /api/v1/users`** — بدون پارامتر. پاسخ: آرایه‌ای از `UserOut`. این endpoint عمداً به همهٔ نقش‌ها باز است (نه فقط org_admin) چون فهرست کاربران سازمان در چند جای دیگر فرانت‌اند هم لازم است — مثلاً منوی انتخاب مسئولِ وظیفه یا مدیر/اعضای پروژه. آنچه محدود به org_admin است **صفحهٔ مدیریت کاربران** (`/users` در فرانت‌اند، شامل ساخت/ویرایش کاربر) است، نه خودِ این API — این تفکیک عمداً در سطح UI (نه API) اعمال شده (`frontend/src/app/role-protected-route.tsx` + `frontend/src/components/layout/sidebar-nav.tsx`).

**`PATCH /api/v1/users/{user_id}`** — بدنه (`UserUpdate`، همه اختیاری):

| فیلد | نوع |
|---|---|
| `role` | یکی از `org_admin`/`project_manager`/`employee` |
| `is_active` | بولین |
| `phone_number` | رشته، ۸ تا ۳۲ کاراکتر |

نمونه:
```json
{ "role": "employee", "is_active": true }
```
پاسخ: `UserOut` به‌روزشده. خطاها: `403` (کاربر جاری org_admin نیست)، `404` (کاربر در این سازمان پیدا نشد)، `400` (تلاش برای غیرفعال‌کردن حساب خودِ فرد)، `409` (شمارهٔ موبایل تکراری)، `422`.

---

### گروه Organizations (`/api/v1/organizations`)

| # | کاربرد | Method + مسیر | نقش مجاز |
|---|---|---|---|
| ۱ | گرفتن اطلاعات سازمان جاری | `GET /api/v1/organizations/me` | هر کاربر واردشدهٔ همان سازمان |
| ۲ | ویرایش نام سازمان | `PATCH /api/v1/organizations/me` | فقط `org_admin` |

**`GET /api/v1/organizations/me`** — پاسخ:
```json
{ "id": "b7d4a1c0-...", "name": "شرکت نمونهٔ تدوین حساب" }
```
خطاها: `403` (کاربر platform_admin است و به هیچ سازمانی تعلق ندارد).

**`PATCH /api/v1/organizations/me`** — بدنه: `{"name": "string(2..200)"}`. نمونه:
```json
{ "name": "شرکت نمونهٔ تدوین حساب (ویرایش‌شده)" }
```
پاسخ: همان شکل بالا. خطاها: `403` (نقش org_admin نیست)، `422`.

---

### گروه Departments (`/api/v1/departments`)

| # | کاربرد | Method + مسیر | نقش مجاز |
|---|---|---|---|
| ۱ | ساخت دپارتمان جدید | `POST /api/v1/departments` | فقط `org_admin` |
| ۲ | فهرست دپارتمان‌های سازمان (به ترتیب نام) | `GET /api/v1/departments` | هر کاربر واردشدهٔ همان سازمان |

**`POST /api/v1/departments`** — بدنه (`DepartmentCreate`): `{"name": "string(2..200)"}`. نمونه:
```json
{ "name": "مالی" }
```
پاسخ (`201`, `DepartmentOut`):
```json
{
  "id": "dd11ee22-...",
  "organization_id": "b7d4a1c0-...",
  "name": "مالی",
  "created_at": "2026-07-16T09:00:00Z"
}
```
خطاها: `403` (کاربر جاری org_admin نیست)، `422` (طول نام نامعتبر).

**`GET /api/v1/departments`** — بدون پارامتر. پاسخ: آرایه‌ای از `DepartmentOut`، مرتب‌شده بر اساس `name`. این endpoint عمداً به همهٔ نقش‌ها باز است (نه فقط org_admin) — دقیقاً مثل `GET /api/v1/users` — چون فهرست دپارتمان‌ها برای منوهای انتخاب (مثلاً هنگام ساخت/ویرایش پروژه یا کاربر) در چند جای فرانت‌اند لازم است.

---

### گروه Projects (`/api/v1/projects`)

| # | کاربرد | Method + مسیر | نقش مجاز |
|---|---|---|---|
| ۱ | ساخت پروژهٔ جدید | `POST /api/v1/projects` | `org_admin`, `project_manager` |
| ۲ | فهرست پروژه‌های قابل‌دیدن | `GET /api/v1/projects` | همه |
| ۳ | جزئیات یک پروژه | `GET /api/v1/projects/{project_id}` | عضو پروژه یا `org_admin` |
| ۴ | ویرایش پروژه | `PATCH /api/v1/projects/{project_id}` | `org_admin` یا `project_manager` عضو |
| ۵ | فهرست اعضای پروژه | `GET /api/v1/projects/{project_id}/members` | عضو پروژه یا `org_admin` |
| ۶ | افزودن عضو به پروژه | `POST /api/v1/projects/{project_id}/members` | `org_admin` یا `project_manager` عضو |
| ۷ | حذف عضو از پروژه | `DELETE /api/v1/projects/{project_id}/members/{member_user_id}` | `org_admin` یا `project_manager` عضو |

**`POST /api/v1/projects`** — بدنه (`ProjectCreate`): `name` (رشته، ۲..۲۰۰، اجباری)، `description` (رشته، اختیاری)، `cooperation_start_date`/`start_date`/`end_date` (تاریخ `YYYY-MM-DD`، اختیاری)، `manager_id` (UUID، اختیاری — باید کاربری با نقش `org_admin` یا `project_manager` در همین سازمان باشد)، `member_ids` (آرایه‌ای از UUID، اختیاری). سازنده و `manager_id` و همهٔ `member_ids` به‌صورت خودکار عضو پروژه می‌شوند. نمونه:
```json
{
  "name": "پیاده‌سازی سامانهٔ حسابداری داخلی",
  "description": "پروژهٔ داخلی تیم مالی برای دیجیتالی‌کردن گردش حساب‌ها",
  "cooperation_start_date": "2026-07-01",
  "start_date": "2026-08-01",
  "end_date": "2026-12-01",
  "manager_id": "5f6e7d8c-...",
  "member_ids": ["9c1f2e3a-...", "aa11bb22-..."]
}
```
پاسخ (`201`, `ProjectOut`):
```json
{
  "id": "1a2b3c4d-...",
  "organization_id": "b7d4a1c0-...",
  "name": "پیاده‌سازی سامانهٔ حسابداری داخلی",
  "description": "پروژهٔ داخلی تیم مالی برای دیجیتالی‌کردن گردش حساب‌ها",
  "cooperation_start_date": "2026-07-01",
  "start_date": "2026-08-01",
  "end_date": "2026-12-01",
  "status": "active",
  "created_by_id": "9c1f2e3a-...",
  "manager_id": "5f6e7d8c-...",
  "created_at": "2026-07-16T10:15:00Z"
}
```
خطاها: `403` (نقش employee است)، `400` (`manager_id` کاربری با نقش نامعتبر است)، `404` (`manager_id`/یکی از `member_ids` در سازمان پیدا نشد)، `422`.

**`GET /api/v1/projects`** — بدون پارامتر. پاسخ: آرایه‌ای از `ProjectOut`. `org_admin` همهٔ پروژه‌های سازمان را می‌بیند؛ بقیه فقط پروژه‌هایی که عضوشان هستند.

**`GET /api/v1/projects/{project_id}`** — پاسخ: `ProjectOut`. خطاها: `404` (پروژه نیست یا در سازمان دیگری است)، `403` (عضو نیست).

**`PATCH /api/v1/projects/{project_id}`** — بدنه (`ProjectUpdate`، همه اختیاری): `name`, `description`, `cooperation_start_date`, `start_date`, `end_date`, `status` (یکی از `active`/`completed`/`archived`), `manager_id` (همان قوانین بالا؛ در صورت تغییر، مدیر جدید هم به‌صورت خودکار عضو می‌شود). نمونه:
```json
{ "status": "completed" }
```
پاسخ: `ProjectOut` به‌روزشده. خطاها: `403`, `404`, `400` (`manager_id` نامعتبر)، `422`.

**`GET /api/v1/projects/{project_id}/members`** — پاسخ:
```json
[
  { "id": "aa11...", "project_id": "1a2b3c4d-...", "user_id": "9c1f2e3a-..." }
]
```

**`POST /api/v1/projects/{project_id}/members`** — بدنه: `{"user_id": "uuid"}`. نمونه:
```json
{ "user_id": "5f6e7d8c-..." }
```
پاسخ (`201`): همان شکل `ProjectMemberOut` بالا. خطاها: `404` (پروژه یا کاربر پیدا نشد/در سازمان دیگری است)، `403`, `409` (از قبل عضو است).

**`DELETE /api/v1/projects/{project_id}/members/{member_user_id}`** — بدون بدنه. پاسخ: `204 No Content`. خطاها: `404` (عضویت پیدا نشد)، `403`.

---

### گروه Payments (`/api/v1/projects/{project_id}/payments`)

| # | کاربرد | Method + مسیر | نقش مجاز |
|---|---|---|---|
| ۱ | ثبت پرداخت جدید برای پروژه | `POST /api/v1/projects/{project_id}/payments` | فقط `org_admin` |
| ۲ | فهرست پرداخت‌های یک پروژه | `GET /api/v1/projects/{project_id}/payments` | فقط `org_admin` |
| ۳ | حذف یک پرداخت | `DELETE /api/v1/projects/{project_id}/payments/{payment_id}` | فقط `org_admin` |

> نکتهٔ مهم: هر سه endpoint این گروه **فقط برای org_admin باز هستند** — حتی `project_manager` عضو همان پروژه هم به آن‌ها دسترسی ندارد (`backend/app/services/payments.py`, تابع `_assert_owner`). این سخت‌گیرانه‌تر از الگوی معمول سایر منابع پروژه‌محور (مثل تسک‌ها یا گزارش‌های کاری) است که معمولاً project_manager عضو هم به آن‌ها دسترسی مدیریتی دارد.

**`POST /api/v1/projects/{project_id}/payments`** — بدنه (`PaymentCreate`): `payment_date` (تاریخ، اجباری)، `description` (رشته، ۱..۱۰۰۰ کاراکتر، اجباری)، `amount` (عدد اعشاری، باید بزرگ‌تر از صفر باشد، اجباری). نمونه:
```json
{
  "payment_date": "2026-07-16",
  "description": "پیش‌پرداخت اول قرارداد",
  "amount": 50000000
}
```
پاسخ (`201`, `PaymentOut`):
```json
{
  "id": "pp33qq44-...",
  "project_id": "1a2b3c4d-...",
  "recorded_by_id": "9c1f2e3a-...",
  "payment_date": "2026-07-16",
  "description": "پیش‌پرداخت اول قرارداد",
  "amount": 50000000,
  "created_at": "2026-07-16T17:00:00Z"
}
```
خطاها: `403` (کاربر جاری org_admin نیست)، `404` (پروژه در این سازمان پیدا نشد)، `422` (مبلغ صفر یا منفی، یا توضیح خالی).

**`GET /api/v1/projects/{project_id}/payments`** — بدون پارامتر. پاسخ: آرایه‌ای از `PaymentOut`، مرتب‌شده از جدیدترین به قدیمی‌ترین (`payment_date` سپس `created_at`، هردو نزولی). خطاها: `403`, `404`.

**`DELETE /api/v1/projects/{project_id}/payments/{payment_id}`** — بدون بدنه. پاسخ: `204 No Content`. خطاها: `403`, `404` (پروژه یا پرداخت پیدا نشد).

---

### گروه Leave Requests (`/api/v1/leave-requests`)

| # | کاربرد | Method + مسیر | نقش مجاز |
|---|---|---|---|
| ۱ | ثبت درخواست مرخصی جدید (برای خودِ کاربر) | `POST /api/v1/leave-requests` | هر عضو سازمان |
| ۲ | فهرست درخواست‌های مرخصی | `GET /api/v1/leave-requests` | همه (اما محدودهٔ دیده‌شده بر اساس نقش فرق می‌کند) |
| ۳ | دریافت یک درخواست خاص | `GET /api/v1/leave-requests/{leave_request_id}` | صاحب درخواست، یا `org_admin`/`project_manager` |
| ۴ | تأیید درخواست | `POST /api/v1/leave-requests/{leave_request_id}/approve` | فقط `org_admin`/`project_manager` |
| ۵ | رد درخواست | `POST /api/v1/leave-requests/{leave_request_id}/reject` | فقط `org_admin`/`project_manager` |

> نکتهٔ مهم دربارهٔ فهرست (#۲): کارمند عادی فقط درخواست‌های خودش را می‌بیند؛ `org_admin`/`project_manager` همهٔ درخواست‌های سازمان را می‌بینند — چون بررسی مرخصی، برخلاف اکثر گردش‌کارهای تأیید این سیستم، **در سطح کل سازمان است، نه محدود به یک پروژهٔ خاص**.

**`POST /api/v1/leave-requests`** — بدنه (`LeaveRequestCreate`): `start_date` (تاریخ، اجباری)، `end_date` (تاریخ، اجباری، نباید قبل از `start_date` باشد)، `reason` (رشته، اختیاری، حداکثر ۲۰۰۰ کاراکتر). نمونه:
```json
{
  "start_date": "2026-08-01",
  "end_date": "2026-08-03",
  "reason": "سفر خانوادگی"
}
```
پاسخ (`201`, `LeaveRequestOut`):
```json
{
  "id": "ll55mm66-...",
  "organization_id": "b7d4a1c0-...",
  "user_id": "9c1f2e3a-...",
  "user_full_name": "کارمند نمونه",
  "start_date": "2026-08-01",
  "end_date": "2026-08-03",
  "reason": "سفر خانوادگی",
  "status": "pending",
  "reviewed_by_id": null,
  "review_comment": null,
  "created_at": "2026-07-16T17:00:00Z"
}
```
خطاها: `422` (تاریخ پایان قبل از تاریخ شروع، یا فیلد ناقص).

**`GET /api/v1/leave-requests`** — بدون پارامتر. پاسخ: آرایه‌ای از `LeaveRequestOut` (جدیدترین اول)، با فیلد اضافهٔ `user_full_name` که مثل `Task.created_by_full_name` یک فیلد محاسبه‌شده (نه ستون واقعی جدول) است — با یک کوئری دسته‌ای روی `users` پر می‌شود.

**`GET /api/v1/leave-requests/{leave_request_id}`** — خطاها: `403` (نه صاحب درخواست است، نه مدیر)، `404` (پیدا نشد یا متعلق به سازمان دیگری است).

**`POST /api/v1/leave-requests/{leave_request_id}/approve`** — بدون بدنه. وضعیت را به `approved` تغییر می‌دهد و یک اعلان `leave_reviewed` برای درخواست‌دهنده می‌سازد (مگر این‌که بررسی‌کننده همان درخواست‌دهنده باشد). خطاها: `403` (کاربر جاری نه org_admin است نه project_manager)، `404`، `400` (درخواست از قبل بررسی شده — فقط درخواست‌های `pending` قابل بررسی‌اند).

**`POST /api/v1/leave-requests/{leave_request_id}/reject`** — بدنه (`LeaveRequestReview`، اختیاری): `{"review_comment": "string(اختیاری)"}`. مثل approve عمل می‌کند اما وضعیت را `rejected` می‌کند. خطاها: مشابه approve.

---

### گروه Tasks (`/api/v1/tasks`)

| # | کاربرد | Method + مسیر | نقش مجاز |
|---|---|---|---|
| ۱ | ساخت وظیفهٔ جدید (پروژه‌ای یا شخصی) | `POST /api/v1/tasks` | همه (شخصی)؛ `org_admin`/`project_manager` عضو (پروژه‌ای) |
| ۲ | فهرست وظایف با فیلتر | `GET /api/v1/tasks` | همه (بر اساس دسترسی) |
| ۳ | جزئیات یک وظیفه | `GET /api/v1/tasks/{task_id}` | مسئول/سازنده/عضو پروژه/`org_admin` |
| ۴ | ویرایش وظیفه | `PATCH /api/v1/tasks/{task_id}` | مدیر پروژه؛ یا خودِ کارمند فقط برای `status`/`progress_percent` |
| ۵ | حذف وظیفه | `DELETE /api/v1/tasks/{task_id}` | مدیر پروژه یا سازندهٔ تسک شخصی |
| ۶ | تأیید وظیفهٔ تکمیل‌شده | `POST /api/v1/tasks/{task_id}/approve` | `org_admin`/`project_manager` عضو |
| ۷ | رد وظیفهٔ تکمیل‌شده | `POST /api/v1/tasks/{task_id}/reject` | `org_admin`/`project_manager` عضو |
| ۸ | تاریخچهٔ فعالیت وظیفه | `GET /api/v1/tasks/{task_id}/activity` | هرکه به وظیفه دسترسی دیدن دارد |
| ۹ | افزودن وابستگی بین وظایف | `POST /api/v1/tasks/{task_id}/dependencies` | مدیر پروژه |
| ۱۰ | فهرست وابستگی‌های یک وظیفه | `GET /api/v1/tasks/{task_id}/dependencies` | هرکه به وظیفه دسترسی دیدن دارد |

**`POST /api/v1/tasks`** — بدنه (`TaskCreate`):

| فیلد | نوع | اجباری؟ |
|---|---|---|
| `project_id` | UUID | خیر (خالی = تسک شخصی) |
| `parent_task_id` | UUID | خیر |
| `title` | رشته، ۲..۳۰۰ | بله |
| `description` | رشته | خیر |
| `assignee_id` | UUID | خیر |
| `priority` | یکی از `low`/`medium`/`high` (پیش‌فرض `medium`) | خیر |
| `start_date` | تاریخ | خیر |
| `deadline` | تاریخ | خیر |
| `estimated_hours` | عدد اعشاری، ۰ تا ۹۹۹۹ | خیر |

نمونهٔ وظیفهٔ پروژه‌ای:
```json
{
  "project_id": "1a2b3c4d-...",
  "title": "طراحی فرم ثبت فاکتور فروش",
  "description": "فرم باید شامل نام مشتری، اقلام، و مبلغ کل باشد",
  "assignee_id": "5f6e7d8c-...",
  "priority": "high",
  "start_date": "2026-08-01",
  "deadline": "2026-08-10",
  "estimated_hours": 6
}
```
نمونهٔ تسک شخصی (بدون پروژه):
```json
{ "title": "پیگیری قرارداد با تأمین‌کننده", "priority": "medium" }
```
پاسخ (`201`, `TaskOut`):
```json
{
  "id": "7788aabb-...",
  "organization_id": "b7d4a1c0-...",
  "project_id": "1a2b3c4d-...",
  "parent_task_id": null,
  "assignee_id": "5f6e7d8c-...",
  "created_by_id": "9c1f2e3a-...",
  "created_by_full_name": "علی رضایی",
  "title": "طراحی فرم ثبت فاکتور فروش",
  "description": "فرم باید شامل نام مشتری، اقلام، و مبلغ کل باشد",
  "priority": "high",
  "status": "todo",
  "approval_status": null,
  "progress_percent": 0,
  "estimated_hours": 6,
  "actual_hours": 0,
  "start_date": "2026-08-01",
  "deadline": "2026-08-10",
  "created_at": "2026-07-16T11:00:00Z"
}
```
خطاها: `400` (تسک شخصی باید به خودِ سازنده تخصیص یابد؛ یا `parent_task_id` در پروژهٔ دیگری است)، `403` (مجوز مدیریت پروژه ندارد)، `404` (پروژه پیدا نشد)، `422`.

> `created_by_full_name` و `actual_hours` هیچ‌کدام ستون واقعی جدول `tasks` نیستند — هردو در لایهٔ سرویس محاسبه/پیوست می‌شوند (بخش «توضیح تمام جداول» بالا، جدول `tasks`).

**`GET /api/v1/tasks`** — پارامترهای Query (همه اختیاری): `project_id`, `assignee_id`, `status` (`todo`/`in_progress`/`completed`/`archived`), `approval_status` (`pending`/`approved`/`rejected`), `overdue` (بولین)، `personal_only` (بولین). پاسخ: آرایه‌ای از `TaskOut`. خطاها: `403`/`404` اگر `project_id` داده شود و دسترسی نباشد.

**`GET /api/v1/tasks/{task_id}`** — پاسخ: `TaskOut`. خطاها: `404`, `403` (تسک شخصیِ فرد دیگر، یا عدم عضویت در پروژه).

**`PATCH /api/v1/tasks/{task_id}`** — بدنه (`TaskUpdate`، همه اختیاری): `title`, `description`, `assignee_id`, `priority`, `status`, `progress_percent` (۰..۱۰۰), `estimated_hours`, `start_date`, `deadline`. نمونهٔ کارمندی که فقط وضعیت خودش را عوض می‌کند:
```json
{ "status": "completed", "progress_percent": 100 }
```
پاسخ: `TaskOut` به‌روزشده. خطاها: `403` (کارمند فیلدی غیر از `status`/`progress_percent` فرستاده، یا وظیفهٔ خودش نیست؛ یا مدیریت پروژه ندارد)، `404`, `422`.

**`DELETE /api/v1/tasks/{task_id}`** — پاسخ: `204`. خطاها: `403`, `404`.

**`POST /api/v1/tasks/{task_id}/approve`** — بدون بدنه. پاسخ: `TaskOut` با `approval_status: "approved"`. خطاها: `400` (تسک شخصی گردش تأیید ندارد، یا وضعیت تأیید در حال حاضر `pending` نیست)، `403`, `404`.

**`POST /api/v1/tasks/{task_id}/reject`** — بدنه: `{"review_comment": "string(2..2000)"}`. نمونه:
```json
{ "review_comment": "لطفاً بخش محاسبهٔ مالیات را کامل کنید و دوباره ارسال کنید." }
```
پاسخ: `TaskOut` با `approval_status: "rejected"` و `status` که به‌طور خودکار به `in_progress` برمی‌گردد. خطاها: مشابه approve + `422`.

**`GET /api/v1/tasks/{task_id}/activity`** — پاسخ:
```json
[
  {
    "id": "cc22...",
    "task_id": "7788aabb-...",
    "actor_user_id": "9c1f2e3a-...",
    "actor_full_name": "علی رضایی",
    "action": "task.create",
    "extra_metadata": { "title": "طراحی فرم ثبت فاکتور فروش" },
    "created_at": "2026-07-16T11:00:00Z"
  }
]
```

**`POST /api/v1/tasks/{task_id}/dependencies`** — بدنه: `{"depends_on_task_id": "uuid"}`. نمونه:
```json
{ "depends_on_task_id": "99887766-..." }
```
پاسخ (`201`):
```json
{ "id": "dd33...", "task_id": "7788aabb-...", "depends_on_task_id": "99887766-..." }
```
خطاها: `400` (تسک شخصی وابستگی ندارد؛ خودوابستگی؛ پروژهٔ متفاوت؛ ایجاد چرخه)، `403`, `404`, `409` (وابستگی از قبل وجود دارد).

**`GET /api/v1/tasks/{task_id}/dependencies`** — پاسخ: آرایه‌ای مثل بالا.

---

### گروه Worklogs (`/api/v1/worklogs`)

| # | کاربرد | Method + مسیر | نقش مجاز |
|---|---|---|---|
| ۱ | ثبت گزارش کاری | `POST /api/v1/worklogs` | فقط مسئول (assignee) همان وظیفه |
| ۲ | فهرست گزارش‌های یک پروژه | `GET /api/v1/worklogs` | عضو پروژه یا `org_admin` |
| ۳ | جزئیات یک گزارش | `GET /api/v1/worklogs/{worklog_id}` | عضو پروژه یا `org_admin` |
| ۴ | تأیید گزارش | `POST /api/v1/worklogs/{worklog_id}/approve` | `org_admin`/`project_manager` عضو |
| ۵ | رد گزارش | `POST /api/v1/worklogs/{worklog_id}/reject` | `org_admin`/`project_manager` عضو |

**`POST /api/v1/worklogs`** — بدنه (`WorkLogCreate`): `task_id` (اجباری)، `activity_description` (رشته، ۲..۲۰۰۰، اجباری)، `time_spent_minutes` (عدد صحیح، ۱ تا ۱۴۴۰ یعنی حداکثر ۲۴ ساعت، اجباری)، `progress_percent` (۰..۱۰۰، اجباری)، `log_date` (تاریخ، اجباری). نمونه:
```json
{
  "task_id": "7788aabb-...",
  "activity_description": "پیاده‌سازی بخش اعتبارسنجی فرم و اتصال آن به API",
  "time_spent_minutes": 180,
  "progress_percent": 60,
  "log_date": "2026-07-16"
}
```
پاسخ (`201`, `WorkLogOut`):
```json
{
  "id": "ee44...",
  "organization_id": "b7d4a1c0-...",
  "task_id": "7788aabb-...",
  "user_id": "5f6e7d8c-...",
  "activity_description": "پیاده‌سازی بخش اعتبارسنجی فرم و اتصال آن به API",
  "time_spent_minutes": 180,
  "progress_percent": 60,
  "log_date": "2026-07-16",
  "status": "submitted",
  "reviewed_by_id": null,
  "review_comment": null,
  "created_at": "2026-07-16T15:00:00Z"
}
```
خطاها: `403` (کاربر مسئول این وظیفه نیست)، `404` (وظیفه پیدا نشد)، `422` (مقادیر خارج از محدوده).

**`GET /api/v1/worklogs`** — پارامتر Query: `project_id` (**اجباری**)، `task_id` (اختیاری)، `status` (اختیاری، یکی از `draft`/`submitted`/`approved`/`rejected`). پاسخ: آرایه‌ای از `WorkLogOut`. خطاها: `403`/`404` روی دسترسی پروژه.

**`GET /api/v1/worklogs/{worklog_id}`** — پاسخ: `WorkLogOut`. خطاها: `404`, `403`.

**`POST /api/v1/worklogs/{worklog_id}/approve`** — بدون بدنه. پاسخ: `WorkLogOut` با `status: "approved"`. خطاها: `400` (فقط گزارش با وضعیت `submitted` قابل بررسی است)، `403`, `404`.

**`POST /api/v1/worklogs/{worklog_id}/reject`** — بدنه: `{"review_comment": "string(2..2000)"}`. نمونه:
```json
{ "review_comment": "لطفاً زمان صرف‌شده را دقیق‌تر و با جزئیات بیشتر بنویسید." }
```
پاسخ: `WorkLogOut` با `status: "rejected"`. خطاها: مشابه approve + `422`.

---

### گروه Dashboard (`/api/v1/dashboard`)

| # | کاربرد | Method + مسیر |
|---|---|---|
| ۱ | خلاصهٔ آماری داشبورد | `GET /api/v1/dashboard/summary` |

**`GET /api/v1/dashboard/summary`** — بدون پارامتر. محدودهٔ داده بر اساس نقش کاربر خودکار تعیین می‌شود (org_admin کل سازمان، بقیه فقط پروژه‌های عضوشان). پاسخ (`DashboardSummary`):
```json
{
  "project_count": 3,
  "projects_by_status": [
    { "status": "active", "count": 2 },
    { "status": "completed", "count": 1 }
  ],
  "task_count": 12,
  "tasks_by_status": [
    { "status": "todo", "count": 4 },
    { "status": "in_progress", "count": 5 },
    { "status": "completed", "count": 3 }
  ],
  "total_approved_hours": 47.5,
  "team_hours": [
    { "user_id": "5f6e7d8c-...", "full_name": "مریم کریمی", "approved_hours": 22.0 }
  ],
  "recent_activity": [
    {
      "worklog_id": "ee44...",
      "task_id": "7788aabb-...",
      "task_title": "طراحی فرم ثبت فاکتور فروش",
      "user_id": "5f6e7d8c-...",
      "user_full_name": "مریم کریمی",
      "status": "submitted",
      "created_at": "2026-07-16T15:00:00"
    }
  ]
}
```

---

### گروه Reports (`/api/v1/reports`)

| # | کاربرد | Method + مسیر |
|---|---|---|
| ۱ | گزارش تفصیلی گزارش‌های کاری | `GET /api/v1/reports/worklogs` |
| ۲ | روند زمانی ساعات تأییدشده | `GET /api/v1/reports/worklog-trend` |

**`GET /api/v1/reports/worklogs`** — پارامترهای Query (همه اختیاری): `project_id`, `user_id`, `status`, `date_from`, `date_to`. پاسخ (`WorkLogReport`):
```json
{
  "items": [
    {
      "worklog_id": "ee44...",
      "task_id": "7788aabb-...",
      "task_title": "طراحی فرم ثبت فاکتور فروش",
      "project_id": "1a2b3c4d-...",
      "project_name": "پیاده‌سازی سامانهٔ حسابداری داخلی",
      "user_id": "5f6e7d8c-...",
      "user_full_name": "مریم کریمی",
      "activity_description": "پیاده‌سازی بخش اعتبارسنجی فرم و اتصال آن به API",
      "time_spent_minutes": 180,
      "progress_percent": 60,
      "log_date": "2026-07-16",
      "status": "submitted",
      "created_at": "2026-07-16T15:00:00"
    }
  ],
  "total_minutes": 180,
  "total_hours": 3.0
}
```

**`GET /api/v1/reports/worklog-trend`** — پارامترها: `project_id` (اختیاری)، `group_by` (`week` یا `month`، پیش‌فرض `week`)، `date_from`, `date_to` (اختیاری). پاسخ:
```json
{ "items": [ { "period": "2026-07-13", "approved_hours": 18.5 } ] }
```

---

### گروه Exports (`/api/v1/exports`)

| # | کاربرد | Method + مسیر | نقش مجاز |
|---|---|---|---|
| ۱ | درخواست تولید فایل خروجی | `POST /api/v1/exports` | همه (بر اساس دسترسی پروژه) |
| ۲ | بررسی وضعیت یک درخواست خروجی | `GET /api/v1/exports/{job_id}` | فقط سازندهٔ درخواست یا `org_admin` |
| ۳ | دانلود فایل خروجی آماده‌شده | `GET /api/v1/exports/{job_id}/download` | فقط سازندهٔ درخواست یا `org_admin` |

**`POST /api/v1/exports`** — بدنه (`ExportJobCreate`): `export_type` (اجباری، یکی از `excel`/`pdf`/`csv`)، `project_id`, `user_id`, `status_filter`, `date_from`, `date_to` (همه اختیاری، برای فیلتر کردن دادهٔ گزارش). نمونه:
```json
{ "export_type": "excel", "project_id": "1a2b3c4d-...", "date_from": "2026-07-01", "date_to": "2026-07-31" }
```
پاسخ (`201`, `ExportJobOut`):
```json
{
  "id": "ff55...",
  "export_type": "excel",
  "status": "pending",
  "error_message": null,
  "created_at": "2026-07-16T16:00:00Z",
  "completed_at": null,
  "download_available": false
}
```
تولید فایل به‌صورت **ناهمزمان (Celery)** انجام می‌شود؛ کلاینت باید دوره‌ای (polling) وضعیت را با `GET /exports/{job_id}` چک کند تا `status` به `done` برسد. خطاها: `403`/`404` (پروژهٔ داده‌شده در دسترس نیست)، `422`.

**`GET /api/v1/exports/{job_id}`** — پاسخ: همان `ExportJobOut`، با `status: "done"` و `download_available: true` وقتی آماده شود. خطاها: `404`, `403` (نه سازندهٔ Job است نه org_admin).

**`GET /api/v1/exports/{job_id}/download`** — پاسخ: خودِ فایل (Excel/PDF/CSV) به‌عنوان دانلود باینری. خطاها: `404`, `403`, `409` (هنوز آماده نشده).

---

### گروه Notifications (`/api/v1/notifications`)

| # | کاربرد | Method + مسیر |
|---|---|---|
| ۱ | فهرست اعلان‌های کاربر جاری | `GET /api/v1/notifications` |
| ۲ | تعداد اعلان‌های نخوانده | `GET /api/v1/notifications/unread-count` |
| ۳ | علامت‌گذاری یک اعلان به‌عنوان خوانده‌شده | `POST /api/v1/notifications/{notification_id}/read` |
| ۴ | علامت‌گذاری همهٔ اعلان‌ها به‌عنوان خوانده‌شده | `POST /api/v1/notifications/read-all` |

**`GET /api/v1/notifications?unread_only=false`** — پاسخ:
```json
[
  {
    "id": "gg66...",
    "type": "task_created",
    "payload": { "task_id": "7788aabb-...", "task_title": "طراحی فرم ثبت فاکتور فروش", "project_id": "1a2b3c4d-..." },
    "is_read": false,
    "created_at": "2026-07-16T11:00:00Z"
  }
]
```

**`GET /api/v1/notifications/unread-count`** — پاسخ: `{"unread_count": 3}`.

**`POST /api/v1/notifications/{notification_id}/read`** — بدون بدنه. پاسخ: همان شکل اعلان با `is_read: true`. خطاها: `404` (اعلان یافت نشد یا مال کاربر دیگری است).

**`POST /api/v1/notifications/read-all`** — بدون بدنه. پاسخ: `{"updated": 5}` (تعداد اعلان‌هایی که علامت خوردند).

---

### گروه Calendar Events (`/api/v1/calendar-events`)

| # | کاربرد | Method + مسیر | نقش مجاز |
|---|---|---|---|
| ۱ | ساخت رویداد تقویم | `POST /api/v1/calendar-events` | همه (کارمند فقط `leave`/`reminder` برای خودش) |
| ۲ | فهرست رویدادها در یک بازهٔ زمانی | `GET /api/v1/calendar-events` | همه (بر اساس دسترسی) |
| ۳ | ویرایش رویداد | `PATCH /api/v1/calendar-events/{event_id}` | سازنده/کاربر مرتبط/`org_admin`/`project_manager` عضو |
| ۴ | حذف رویداد | `DELETE /api/v1/calendar-events/{event_id}` | همان بالا |

**`POST /api/v1/calendar-events`** — بدنه (`CalendarEventCreate`): `title` (۲..۳۰۰، اجباری)، `description` (اختیاری)، `event_type` (اجباری، یکی از `meeting`/`leave`/`holiday`/`reminder`)، `start_at`/`end_at` (تاریخ‌زمان ISO، اجباری، `end_at` باید ≥ `start_at`)، `all_day` (پیش‌فرض `false`)، `project_id` (اختیاری)، `user_id` (اختیاری). نمونه:
```json
{
  "title": "جلسهٔ هماهنگی هفتگی تیم مالی",
  "event_type": "meeting",
  "start_at": "2026-07-20T09:00:00+03:30",
  "end_at": "2026-07-20T10:00:00+03:30",
  "project_id": "1a2b3c4d-..."
}
```
پاسخ (`201`, `CalendarEventOut`):
```json
{
  "id": "hh77...",
  "organization_id": "b7d4a1c0-...",
  "created_by_id": "9c1f2e3a-...",
  "project_id": "1a2b3c4d-...",
  "user_id": null,
  "title": "جلسهٔ هماهنگی هفتگی تیم مالی",
  "description": null,
  "event_type": "meeting",
  "start_at": "2026-07-20T09:00:00+03:30",
  "end_at": "2026-07-20T10:00:00+03:30",
  "all_day": false,
  "created_at": "2026-07-16T12:00:00Z"
}
```
خطاها: `403` (کارمند تلاش می‌کند نوعی غیر از `leave`/`reminder` بسازد، یا برای فرد دیگری بسازد)، `404` (پروژهٔ داده‌شده در دسترس نیست)، `422` (`end_at` قبل از `start_at`).

**`GET /api/v1/calendar-events?start=...&end=...`** — هر دو پارامتر **اجباری** (تاریخ‌زمان ISO). پاسخ: آرایه‌ای از `CalendarEventOut` که با بازه هم‌پوشانی دارند.

**`PATCH /api/v1/calendar-events/{event_id}`** — بدنه (`CalendarEventUpdate`، همه اختیاری): `title`, `description`, `start_at`, `end_at`, `all_day`. خطاها: `400` (`end_at` قبل از `start_at`)، `403`, `404`.

**`DELETE /api/v1/calendar-events/{event_id}`** — پاسخ: `204`. خطاها: `403`, `404`.

---

### گروه Leave Requests (`/api/v1/leave-requests`)

> این گروه جایگزین رویدادهای تقویم از نوع `leave` شده (بخش «توضیح تمام جداول» بالا، جدول `leave_requests` را ببینید) — یک گردش‌کار اختصاصیِ درخواست/تأیید مرخصی، با بررسی در سطح کل سازمان (نه محدود به یک پروژه).

| # | کاربرد | Method + مسیر | نقش مجاز |
|---|---|---|---|
| ۱ | ثبت درخواست مرخصی | `POST /api/v1/leave-requests` | هر عضو سازمان (برای خودش) |
| ۲ | فهرست درخواست‌ها | `GET /api/v1/leave-requests` | هر عضو (فقط درخواست‌های خودش)؛ `org_admin`/`project_manager` همهٔ درخواست‌های سازمان |
| ۳ | جزئیات یک درخواست | `GET /api/v1/leave-requests/{leave_request_id}` | درخواست‌دهنده یا `org_admin`/`project_manager` |
| ۴ | تأیید درخواست | `POST /api/v1/leave-requests/{leave_request_id}/approve` | فقط `org_admin`/`project_manager` |
| ۵ | رد درخواست | `POST /api/v1/leave-requests/{leave_request_id}/reject` | فقط `org_admin`/`project_manager` |

**`POST /api/v1/leave-requests`** — بدنه (`LeaveRequestCreate`): `start_date` (تاریخ، اجباری)، `end_date` (تاریخ، اجباری، نباید قبل از `start_date` باشد)، `reason` (رشته، حداکثر ۲۰۰۰ کاراکتر، اختیاری). نمونه:
```json
{
  "start_date": "2026-08-05",
  "end_date": "2026-08-09",
  "reason": "مرخصی استحقاقی سالانه"
}
```
پاسخ (`201`, `LeaveRequestOut`):
```json
{
  "id": "rr55ss66-...",
  "organization_id": "b7d4a1c0-...",
  "user_id": "9c1f2e3a-...",
  "user_full_name": "علی رضایی",
  "start_date": "2026-08-05",
  "end_date": "2026-08-09",
  "reason": "مرخصی استحقاقی سالانه",
  "status": "pending",
  "reviewed_by_id": null,
  "review_comment": null,
  "created_at": "2026-07-16T18:00:00Z"
}
```
خطاها: `422` (`end_date` قبل از `start_date`، یا طول `reason` نامعتبر).

**`GET /api/v1/leave-requests`** — بدون پارامتر. پاسخ: آرایه‌ای از `LeaveRequestOut`. کارمند عادی فقط درخواست‌های خودش را می‌بیند؛ `org_admin`/`project_manager` همهٔ درخواست‌های سازمان را می‌بینند (مرتب‌شده از جدیدترین به قدیمی‌ترین).

**`GET /api/v1/leave-requests/{leave_request_id}`** — پاسخ: `LeaveRequestOut`. خطاها: `404` (پیدا نشد)، `403` (نه درخواست‌دهنده است، نه org_admin/project_manager).

**`POST /api/v1/leave-requests/{leave_request_id}/approve`** — بدون بدنه. پاسخ: `LeaveRequestOut` با `status: "approved"` و `reviewed_by_id` پرشده. خطاها: `403` (نقش مجاز به بررسی نیست)، `404`، `400` (درخواست از قبل `pending` نیست).

**`POST /api/v1/leave-requests/{leave_request_id}/reject`** — بدنه (`LeaveRequestReview`): `{"review_comment": "string(حداکثر ۲۰۰۰ کاراکتر), اختیاری"}`. نمونه:
```json
{ "review_comment": "در این بازه تیم نیاز به حضور شما دارد؛ لطفاً تاریخ دیگری پیشنهاد دهید." }
```
پاسخ: `LeaveRequestOut` با `status: "rejected"`. خطاها: مشابه approve + `422`.

> **اعلان:** تأیید/رد یک درخواست، یک اعلان `leave_reviewed` برای درخواست‌دهنده می‌سازد — مگر این‌که بررسی‌کننده همان درخواست‌دهنده باشد (که در این حالت هیچ اعلانی به خودش ساخته نمی‌شود؛ همان الگوی اعلان‌های تأیید/رد گزارش کاری).

---

### گروه Comments (`/api/v1/tasks/{task_id}/comments`)

| # | کاربرد | Method + مسیر |
|---|---|---|
| ۱ | افزودن کامنت روی وظیفه | `POST /api/v1/tasks/{task_id}/comments` |
| ۲ | فهرست کامنت‌های یک وظیفه | `GET /api/v1/tasks/{task_id}/comments` |

**`POST /api/v1/tasks/{task_id}/comments`** — بدنه: `{"body": "string(1..4000)"}`. نمونه:
```json
{ "body": "لطفاً قبل از تحویل نهایی، اعتبارسنجی شمارهٔ ملی مشتری را هم اضافه کن." }
```
پاسخ (`201`, `CommentOut`):
```json
{
  "id": "ii88...",
  "task_id": "7788aabb-...",
  "author_id": "9c1f2e3a-...",
  "author_full_name": "علی رضایی",
  "body": "لطفاً قبل از تحویل نهایی، اعتبارسنجی شمارهٔ ملی مشتری را هم اضافه کن.",
  "created_at": "2026-07-16T13:00:00Z"
}
```
خطاها: `403`/`404` (دسترسی دیدن وظیفه نیست)، `422`.

**`GET /api/v1/tasks/{task_id}/comments`** — پاسخ: آرایه‌ای از `CommentOut` (به‌ترتیب زمان ایجاد).

---

### گروه Attachments

| # | کاربرد | Method + مسیر | نقش مجاز |
|---|---|---|---|
| ۱ | آپلود فایل پیوست به یک وظیفه | `POST /api/v1/tasks/{task_id}/attachments` | هرکه به وظیفه دسترسی دیدن دارد |
| ۲ | فهرست پیوست‌های یک وظیفه | `GET /api/v1/tasks/{task_id}/attachments` | هرکه به وظیفه دسترسی دیدن دارد |
| ۳ | فهرست همهٔ پیوست‌های سازمان | `GET /api/v1/attachments` | هرکه پروژه‌ای می‌بیند |
| ۴ | دانلود یک پیوست | `GET /api/v1/attachments/{attachment_id}/download` | هرکه به وظیفهٔ آن پیوست دسترسی دارد |
| ۵ | حذف یک پیوست | `DELETE /api/v1/attachments/{attachment_id}` | آپلودکننده، `org_admin`، یا مدیر پروژه |

**`POST /api/v1/tasks/{task_id}/attachments`** — بدنه: `multipart/form-data` با فیلد `file`. نمونه (curl):
```bash
curl -X POST "http://localhost:8000/api/v1/tasks/7788aabb-.../attachments" \
  -H "Authorization: Bearer eyJhbGciOi..." \
  -F "file=@fatura-namune.pdf"
```
پاسخ (`201`, `AttachmentOut`):
```json
{
  "id": "jj99...",
  "task_id": "7788aabb-...",
  "uploaded_by_id": "9c1f2e3a-...",
  "uploaded_by_full_name": "علی رضایی",
  "original_filename": "fatura-namune.pdf",
  "content_type": "application/pdf",
  "size_bytes": 245678,
  "created_at": "2026-07-16T14:00:00Z",
  "task_title": null,
  "project_id": null
}
```
خطاها: `413` (حجم فایل بیشتر از سقف مجاز، پیش‌فرض ۱۰ مگابایت)، `403`/`404` (دسترسی وظیفه نیست).

**`GET /api/v1/tasks/{task_id}/attachments`** — پاسخ: آرایهٔ `AttachmentOut` (فیلدهای `task_title`/`project_id` این‌جا همیشه `null` هستند چون کاربر از قبل می‌داند روی کدام وظیفه است).

**`GET /api/v1/attachments`** — پاسخ: مثل بالا ولی با `task_title` و `project_id` پرشده (چون فهرست سراسری است).

**`GET /api/v1/attachments/{attachment_id}/download`** — پاسخ: خودِ فایل. خطاها: `404`.

**`DELETE /api/v1/attachments/{attachment_id}`** — پاسخ: `204`. خطاها: `403` (نه آپلودکننده، نه org_admin، نه مدیر پروژه)، `404`.

---

### گروه Audit Logs (`/api/v1/audit-logs`)

| # | کاربرد | Method + مسیر | نقش مجاز |
|---|---|---|---|
| ۱ | فهرست رویدادهای ثبت‌شدهٔ سازمان | `GET /api/v1/audit-logs?limit=50` | فقط `org_admin` |

پاسخ:
```json
[
  {
    "id": "kk10...",
    "actor_user_id": "9c1f2e3a-...",
    "action": "user.login",
    "entity_type": "user",
    "entity_id": "9c1f2e3a-...",
    "extra_metadata": {},
    "created_at": "2026-07-16T08:00:00Z"
  }
]
```
خطاها: `403` (کاربر جاری org_admin نیست).

---

### گروه Search (`/api/v1/search`)

| # | کاربرد | Method + مسیر |
|---|---|---|
| ۱ | جستجوی سراسری در پروژه/وظیفه/کاربر | `GET /api/v1/search?q=...` |

پارامتر `q` حداقل ۲ کاراکتر. پاسخ:
```json
{
  "projects": [ { "id": "1a2b3c4d-...", "name": "پیاده‌سازی سامانهٔ حسابداری داخلی" } ],
  "tasks": [ { "id": "7788aabb-...", "title": "طراحی فرم ثبت فاکتور فروش", "project_id": "1a2b3c4d-..." } ],
  "users": [ { "id": "5f6e7d8c-...", "full_name": "مریم کریمی", "email": "maryam.karimi@example.com" } ]
}
```
خطاها: `422` (`q` کوتاه‌تر از ۲ کاراکتر).

---

### گروه Health (`/health`)

| # | کاربرد | Method + مسیر |
|---|---|---|
| ۱ | بررسی سلامت سرویس (بدون نیاز به احراز هویت) | `GET /health` |

> توجه: برخلاف همهٔ گروه‌های دیگر، این مسیر **زیر پیشوند `/api/v1` نیست** — مستقیماً `GET /health` است (طبق `backend/app/main.py`، این تنها روتری‌ست که بدون `prefix=settings.api_v1_prefix` mount شده).

پاسخ: `{"status": "ok"}`. بدون نیاز به توکن، بدون خطای خاص.

---

## ۳. نحوهٔ استفاده از API در فرانت‌اند

فرانت‌اند (`frontend/src/`) با **axios** و یک نمونهٔ مشترک `apiClient` (`frontend/src/lib/api-client.ts`) با API صحبت می‌کند. دو رفتار خودکار مهم در همین فایل پیاده شده:

1. **افزودن خودکار هدر Authorization:** یک request interceptor، قبل از هر درخواست، `accessToken` را از store مدیریت حالت (`useAuthStore`, حافظهٔ Zustand) می‌خواند و اگر موجود بود، هدر `Authorization: Bearer <token>` را خودش اضافه می‌کند — یعنی توابع API جدا نیازی نیست این هدر را دستی بگذارند.

2. **تمدید خودکار توکن روی خطای ۴۰۱:** یک response interceptor، اگر پاسخ سرور `401` بود و این اولین بار تلاش برای همین درخواست بود، یک‌بار `POST /api/v1/auth/refresh` را (با یک axios instance جدا به نام `refreshClient` تا خودش دوباره وارد همین چرخهٔ ۴۰۱ نشود) صدا می‌زند؛ اگر موفق شد، توکن تازه را در store می‌گذارد و **همان درخواست اصلی را یک‌بار دیگر با توکن جدید تکرار می‌کند** — کاربر اصلاً متوجه این اتفاق پشت‌صحنه نمی‌شود. اگر تمدید هم شکست خورد، `logout()` صدا زده می‌شود (کاربر عملاً خارج می‌شود).

کد کلیدی این فایل:

```typescript
export const apiClient = axios.create({ baseURL, withCredentials: true })

apiClient.interceptors.request.use((config) => {
  const token = useAuthStore.getState().accessToken
  if (token) {
    config.headers.Authorization = `Bearer ${token}`
  }
  return config
})

apiClient.interceptors.response.use(
  (response) => response,
  async (error) => {
    const originalRequest = error.config
    if (error.response?.status === 401 && !originalRequest._retried) {
      originalRequest._retried = true
      const newToken = await refreshAccessToken()
      if (newToken) {
        useAuthStore.setState({ accessToken: newToken })
        originalRequest.headers.Authorization = `Bearer ${newToken}`
        return apiClient(originalRequest)
      }
      useAuthStore.getState().logout()
    }
    return Promise.reject(error)
  }
)
```

### الگوی استاندارد یک فایل `features/*/api.ts`

هر بخش فرانت‌اند (auth، tasks، projects، ...) یک فایل `api.ts` مخصوص خودش دارد که فقط تابع‌های ساده‌ای است که `apiClient` را صدا می‌زنند و مقدار `data` پاسخ را برمی‌گردانند — بدون منطق اضافه. مثال کامل `frontend/src/features/auth/api.ts`:

```typescript
import { apiClient } from "@/lib/api-client"
import type { CurrentUser } from "@/features/auth/auth-store"

export type LoginPayload = { identifier: string; password: string }
type TokenResponse = { access_token: string; token_type: string }

export async function login(payload: LoginPayload) {
  const { data } = await apiClient.post<TokenResponse>("/api/v1/auth/login", payload)
  return data
}

export async function fetchMe() {
  const { data } = await apiClient.get<CurrentUser>("/api/v1/auth/me")
  return data
}
```

و مثال دوم از `frontend/src/features/tasks/api.ts` که نشان می‌دهد چطور پارامترهای Query و مسیرهای پویا (`{taskId}`) مدیریت می‌شوند:

```typescript
export async function listAllTasks(filters?: TaskFilters) {
  const { data } = await apiClient.get<Task[]>("/api/v1/tasks", { params: filters })
  return data
}

export async function approveTask(taskId: string) {
  const { data } = await apiClient.post<Task>(`/api/v1/tasks/${taskId}/approve`)
  return data
}
```

**اگر بخواهید یک endpoint جدید به فرانت‌اند اضافه کنید**، الگوی استاندارد پروژه این است:
1. یک تابع `async` کوچک در فایل `api.ts` مربوط به همان feature بنویسید که فقط `apiClient.get/post/patch/delete` را با مسیر و پارامترهای درست صدا بزند و `data` را برگرداند.
2. تایپ‌های TypeScript پاسخ/درخواست را (اگر جای مشترکی مثل `lib/types.ts` ندارند) همان‌جا تعریف کنید.
3. از این تابع در یک React Query hook یا مستقیم در یک کامپوننت استفاده کنید — نیازی به تنظیم دستی هدر Authorization یا مدیریت خطای ۴۰۱ نیست، چون هردو در سطح `apiClient` مرکزی حل شده‌اند.

---

## منابع و فایل‌های مرتبط

برای هر بخش از این سند، فایل‌های زیر منبع اصلی و قابل‌اعتماد برای تغییرات آینده هستند:

**مدل‌های دیتابیس:**
`backend/app/models/user.py`, `organization.py`, `project.py`, `task.py`, `task_activity.py`, `worklog.py`, `notification.py`, `calendar_event.py`, `otp_code.py`, `export_job.py`, `audit_log.py`, `collaboration.py` (شامل `Comment` و `Attachment`), `enums.py` (همهٔ مقادیر enum)، `backend/app/db/base_class.py` (کلاس پایه/mixinهای مشترک)، `backend/app/db/tenant_repository.py` (مکانیزم ایزوله‌سازی چندمستأجری).

**مهاجرت‌های دیتابیس:**
`backend/alembic/versions/*.py`، تنظیمات در `backend/alembic.ini`.

**Schemaهای Pydantic (شکل دقیق درخواست/پاسخ):**
`backend/app/schemas/auth.py`, `user.py`, `project.py`, `task.py`, `worklog.py`, `dashboard.py`, `report.py`, `export.py`, `notification.py`, `calendar_event.py`, `audit.py`, `settings.py`, `comment.py`, `attachment.py`, `search.py`, `validators.py` (قوانین رمز عبور).

**روترهای FastAPI (مسیر/Method دقیق هر endpoint):**
`backend/app/api/routers/*.py` (auth, users, organizations, projects, tasks, worklogs, dashboard, reports, exports, notifications, calendar_events, comments, attachments, audit, search, health)، و نقطهٔ اتصال همه به اپ در `backend/app/main.py`.

**سرویس‌ها (منطق کسب‌وکار و قوانین دسترسی RBAC):**
`backend/app/services/*.py` (auth, users, organizations, projects, tasks, worklogs, dashboard, reports, exports, notifications, calendar_events, comments, attachments, search, task_activity, audit, otp).

**احراز هویت/امنیت:**
`backend/app/core/security.py` (JWT + bcrypt)، `backend/app/core/config.py` (تنظیمات از جمله `SECRET_KEY`, انقضای توکن‌ها)، `backend/app/core/rate_limit.py` (محدودسازی نرخ روی Redis)، `backend/app/api/deps.py` (`get_current_user`, `get_current_org_id`, `require_role`).

**اسکریپت‌ها و پیکربندی زیرساخت:**
`backend/scripts/seed_platform_admin.py` (ساخت اولین platform_admin)، `docker-compose.yml`، `backend/.env.example`، `backend/app/db/session.py`.

**فرانت‌اند (نحوهٔ فراخوانی API):**
`frontend/src/lib/api-client.ts` (کلاینت axios مرکزی + رفرش خودکار توکن)، `frontend/src/features/auth/api.ts`, `frontend/src/features/auth/auth-store.ts`، و فایل `api.ts` مشابه در هر پوشهٔ `frontend/src/features/*/`.

**مستندات مرتبط دیگر پروژه:**
`docs/ARCHITECTURE.md` (تصمیم‌های معماری و چرایی آن‌ها)، `docs/PROJECT_STATE.md` (وضعیت فعلی و تاریخچهٔ کامل توسعه)، `README.md` (راه‌اندازی سریع پروژه).
