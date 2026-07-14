# وضعیت فعلی پروژه WorkPilot

> این فایل همیشه باید نشان‌دهندهٔ آخرین وضعیت واقعی پروژه باشد تا در صورت قطع گفتگو یا تغییر محیط، کار بدون از دست دادن اطلاعات ادامه پیدا کند. برای جزئیات هر مرحله به گزارش Handoff همان مرحله در پایین همین فایل مراجعه کنید.

## برنچ فعال
`claude/push-main-github-c3qd9w`

## فاز فعلی
**فاز A: اسکلت پروژه (Project Scaffolding)** — در حال انجام

## خلاصهٔ کارهای تکمیل‌شده

- [x] سند RFB بازنگری و نهایی شد (`docs/RFB-WorkPilot-Project-Proposal.md`) — چندمستأجری از ابتدا + نیازمندی الزامی موبایل‌فرندلی.
- [x] Skill های طراحی/تست نصب شدند: `skill/.claude/skills` (ui-ux-pro-max) و `skill/anthropic-skills` (مجموعهٔ رسمی Anthropic).
- [x] جهت‌گیری کلی UI داشبورد از تصویر مرجع کاربر ثبت شد (`docs/UI-DESIGN.md`) — **تأیید نهایی نشده، فقط جهت‌گیری**.
- [x] مستندات پایه (`docs/ARCHITECTURE.md`, `docs/PROJECT_STATE.md`) ایجاد شد.

## در حال انجام

- [ ] اسکلت backend (FastAPI) و frontend (React+Vite+Tailwind)
- [ ] docker-compose.yml
- [ ] health endpoint بک‌اند
- [ ] لایهٔ ظاهری (shell) واکنش‌گرا با RTL برای فرانت

## کارهای باقی‌مانده (فازهای بعدی)

فاز B تا J طبق برنامهٔ تأییدشده — جزئیات در `/root/.claude/plans/root-claude-uploads-b3275c80-e249-5fd8-synthetic-hippo.md` و خلاصهٔ فازها در `docs/ARCHITECTURE.md`.

## مشکلات/نکات باز

- طرح داشبورد نهایی نشده؛ قبل از پیاده‌سازی کامل فاز E باید با کاربر چک شود.
- مقادیر [TBD] در RFB (بودجه، تعداد کاربر همزمان، SLA دقیق) هنوز نیاز به تصمیم کارفرما دارند — مانع شروع توسعه نیستند.

---

## تاریخچهٔ Handoff

### Handoff — پس از نهایی‌سازی RFB (پیش از شروع فاز A)
- **خلاصه:** سند RFB نهایی شد؛ دو مجموعه skill نصب شد؛ جهت‌گیری UI ثبت شد؛ مستندات پایه ایجاد شد.
- **فایل‌های ساخته/تغییر یافته:** `docs/RFB-WorkPilot-Project-Proposal.md` (ویرایش)، `docs/UI-DESIGN.md` (جدید)، `docs/ARCHITECTURE.md` (جدید)، `docs/PROJECT_STATE.md` (جدید)، `skill/` (دو مجموعه skill).
- **مشکلات:** ندارد.
- **گام بعدی برای ادامه‌دهنده:** شروع فاز A طبق `docs/ARCHITECTURE.md` بخش «ساختار مخزن» — ساخت `backend/` و `frontend/` و `docker-compose.yml`.
