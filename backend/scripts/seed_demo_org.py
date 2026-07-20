"""One-off script to seed a full demo organization for manual QA:
3 departments x 7 members x 5 projects x 100+ tasks, plus ~2 months of
calendar events per department. Writes directly to the DB (bypasses the API
and its RBAC, e.g. the "only the assignee can change a task's status" rule)
since this is pure test-data generation, not a real user flow.

Run once:  python3 scripts/seed_demo_org.py
"""

import random
import uuid
from datetime import date, datetime, timedelta, timezone

from app.core.security import hash_password
from app.db.session import SessionLocal
from app.models.calendar_event import CalendarEvent
from app.models.department import Department
from app.models.enums import (
    ApprovalStatus,
    CalendarEventType,
    ProjectStatus,
    TaskPriority,
    TaskStatus,
    UserRole,
)
from app.models.organization import Organization
from app.models.project import Project, ProjectMember
from app.models.task import Task
from app.models.user import User

random.seed(42)

PASSWORD = "Test@1234"
TODAY = date(2026, 7, 16)
WINDOW_START = TODAY - timedelta(days=30)
WINDOW_END = TODAY + timedelta(days=30)

DEPARTMENTS = [
    {
        "name": "مهندسی و فنی",
        "phone_prefix": "0911",
        "email_prefix": "eng",
        "project_names": [
            "بازطراحی وب‌سایت شرکتی",
            "توسعهٔ اپلیکیشن موبایل فروش",
            "مهاجرت زیرساخت به ابر",
            "پیاده‌سازی سامانهٔ مانیتورینگ",
            "بهبود عملکرد پایگاه‌داده",
        ],
        "task_titles": [
            "رفع باگ در ماژول پرداخت",
            "پیاده‌سازی صفحهٔ ورود جدید",
            "بهینه‌سازی کوئری‌های گزارش‌گیری",
            "افزودن تست واحد برای سرویس کاربران",
            "طراحی API نسخهٔ دوم",
            "رفع مشکل کندی بارگذاری صفحه",
            "پیاده‌سازی احراز هویت دومرحله‌ای",
            "بررسی و رفع آسیب‌پذیری امنیتی",
            "به‌روزرسانی کتابخانه‌های وابسته",
            "پیاده‌سازی صفحهٔ داشبورد مدیریتی",
            "تنظیم پایپ‌لاین CI/CD",
            "نوشتن مستندات فنی API",
            "رفع مشکل ناسازگاری مرورگر",
            "بازنویسی ماژول اعلان‌ها",
            "افزودن قابلیت جست‌وجوی پیشرفته",
        ],
    },
    {
        "name": "حسابداری و مالی",
        "phone_prefix": "0912",
        "email_prefix": "fin",
        "project_names": [
            "بستن حساب‌های مالی سال",
            "پیاده‌سازی سامانهٔ فاکتور الکترونیک",
            "ممیزی مالی سه‌ماههٔ دوم",
            "تدوین بودجهٔ سال آینده",
            "مدیریت مطالبات و بدهی‌ها",
        ],
        "task_titles": [
            "بررسی و تأیید صورت‌حساب‌های خرید",
            "تهیهٔ گزارش سود و زیان ماهانه",
            "مغایرت‌گیری حساب‌های بانکی",
            "ثبت اسناد حسابداری هفتگی",
            "پیگیری مطالبات معوق مشتریان",
            "تهیهٔ گزارش مالیاتی فصلی",
            "بررسی فاکتورهای فروش صادرشده",
            "به‌روزرسانی جدول حقوق و دستمزد",
            "تهیهٔ پیش‌نویس بودجهٔ واحد",
            "بررسی صورت وضعیت پیمانکاران",
            "تطبیق موجودی انبار با حساب‌ها",
            "تهیهٔ گزارش جریان نقدی",
            "بررسی و تسویهٔ کارت اعتباری شرکت",
            "پیگیری بیمهٔ کارکنان",
            "بررسی قراردادهای مالی جدید",
        ],
    },
    {
        "name": "منابع انسانی",
        "phone_prefix": "0913",
        "email_prefix": "hr",
        "project_names": [
            "برگزاری دورهٔ آموزشی کارکنان",
            "بازطراحی فرایند جذب و استخدام",
            "ارزیابی عملکرد سالانهٔ کارکنان",
            "طراحی برنامهٔ رفاهی کارکنان",
            "پیاده‌سازی سامانهٔ حضور و غیاب",
        ],
        "task_titles": [
            "بررسی رزومه‌های متقاضیان شغلی",
            "برنامه‌ریزی مصاحبهٔ استخدامی",
            "تهیهٔ گزارش ارزیابی عملکرد",
            "برگزاری جلسهٔ آموزش کارکنان جدید",
            "به‌روزرسانی آیین‌نامهٔ داخلی شرکت",
            "پیگیری درخواست‌های رفاهی کارکنان",
            "تهیهٔ فرم ارزیابی سه‌ماهه",
            "برنامه‌ریزی رویداد تیم‌سازی",
            "بررسی و تمدید قراردادهای پرسنلی",
            "تدوین برنامهٔ آموزشی سال آینده",
            "پیگیری مرخصی و مأموریت کارکنان",
            "به‌روزرسانی پروندهٔ پرسنلی",
            "برگزاری نظرسنجی رضایت شغلی",
            "تهیهٔ گزارش غیبت و تأخیر",
            "بررسی درخواست ترفیع کارکنان",
        ],
    },
]

MEETING_TITLES = ["جلسهٔ هماهنگی هفتگی", "جلسهٔ بررسی پیشرفت پروژه", "جلسهٔ برنامه‌ریزی اسپرینت", "جلسهٔ مرور با مدیریت"]
REMINDER_TITLES = ["یادآوری ارسال گزارش", "یادآوری تمدید قرارداد", "یادآوری پیگیری مشتری"]
HOLIDAY_TITLES = ["تعطیلی رسمی"]


def make_users_for_department(db, org, dept, dept_data, index_offset):
    manager_email = f"{dept_data['email_prefix']}.manager@test.local"
    manager = User(
        organization_id=org.id,
        email=manager_email,
        phone_number=f"{dept_data['phone_prefix']}{1000000 + index_offset}",
        hashed_password=hash_password(PASSWORD),
        full_name=f"مدیر پروژه {dept.name}",
        role=UserRole.project_manager,
        department_id=dept.id,
    )
    db.add(manager)
    db.flush()

    employees = []
    for i in range(1, 7):
        email = f"{dept_data['email_prefix']}.emp{i}@test.local"
        emp = User(
            organization_id=org.id,
            email=email,
            phone_number=f"{dept_data['phone_prefix']}{1000010 + index_offset + i}",
            hashed_password=hash_password(PASSWORD),
            full_name=f"کارمند {i} {dept.name}",
            role=UserRole.employee,
            department_id=dept.id,
        )
        db.add(emp)
        employees.append(emp)
    db.flush()
    return manager, employees


def random_date_in_window():
    span = (WINDOW_END - WINDOW_START).days
    return WINDOW_START + timedelta(days=random.randint(0, span))


def main():
    db = SessionLocal()
    try:
        # Idempotent: safe to run on every startup (e.g. from install.sh),
        # including against a Postgres volume from a previous run that
        # already has this same demo org in it.
        if db.query(User).filter(User.email == "admin@test.local").first() is not None:
            print("Demo org already seeded (admin@test.local exists) -- skipping.")
            return

        org = Organization(name="شرکت نمونهٔ آزمایشی", slug=f"demo-org-{uuid.uuid4().hex[:8]}")
        db.add(org)
        db.flush()

        admin = User(
            organization_id=org.id,
            email="admin@test.local",
            phone_number="09100000001",
            hashed_password=hash_password(PASSWORD),
            full_name="مدیر سازمان",
            role=UserRole.org_admin,
        )
        db.add(admin)
        db.flush()

        credentials = [("مدیر سازمان (org_admin)", admin.email, admin.phone_number, PASSWORD)]

        for dept_idx, dept_data in enumerate(DEPARTMENTS):
            dept = Department(organization_id=org.id, name=dept_data["name"])
            db.add(dept)
            db.flush()
            if dept_idx == 0:
                admin.department_id = dept.id

            manager, employees = make_users_for_department(db, org, dept, dept_data, dept_idx * 100)
            credentials.append((f"مدیر پروژهٔ {dept.name}", manager.email, manager.phone_number, PASSWORD))
            for i, emp in enumerate(employees, start=1):
                credentials.append((f"کارمند {i} - {dept.name}", emp.email, emp.phone_number, PASSWORD))

            members_pool = [manager] + employees

            projects = []
            for p_idx, project_name in enumerate(dept_data["project_names"]):
                project_members_subset = random.sample(employees, k=3)
                project = Project(
                    organization_id=org.id,
                    name=project_name,
                    description=f"پروژهٔ {dept.name} شماره {p_idx + 1}",
                    cooperation_start_date=WINDOW_START,
                    start_date=WINDOW_START,
                    end_date=WINDOW_END + timedelta(days=60),
                    status=ProjectStatus.active,
                    created_by_id=admin.id,
                    manager_id=manager.id,
                    department_id=dept.id,
                )
                db.add(project)
                db.flush()
                db.add(ProjectMember(project_id=project.id, user_id=manager.id))
                for member in project_members_subset:
                    db.add(ProjectMember(project_id=project.id, user_id=member.id))
                projects.append(project)
            db.flush()

            # --- Tasks: 90 project tasks (18/project) + 15 personal = 105 ---
            task_titles = dept_data["task_titles"]
            statuses_weighted = (
                [TaskStatus.todo] * 25 + [TaskStatus.in_progress] * 30 + [TaskStatus.completed] * 35 + [TaskStatus.archived] * 10
            )
            priorities = [TaskPriority.low, TaskPriority.medium, TaskPriority.high]

            def make_task(project, assignee, creator, seq):
                status = random.choice(statuses_weighted)
                approval = None
                if status == TaskStatus.completed:
                    approval = random.choices(
                        [ApprovalStatus.approved, ApprovalStatus.pending, ApprovalStatus.rejected],
                        weights=[60, 30, 10],
                    )[0]
                start_d = random_date_in_window()
                deadline_d = start_d + timedelta(days=random.randint(2, 21))
                return Task(
                    organization_id=org.id,
                    project_id=project.id if project else None,
                    assignee_id=assignee.id,
                    created_by_id=creator.id,
                    title=f"{random.choice(task_titles)} #{seq}",
                    description=None,
                    priority=random.choice(priorities),
                    status=status,
                    approval_status=approval,
                    progress_percent=100 if status == TaskStatus.completed else random.randint(0, 80),
                    estimated_hours=round(random.uniform(2, 40), 1),
                    start_date=start_d,
                    deadline=deadline_d,
                )

            seq = 1
            for project in projects:
                for _ in range(18):
                    assignee = random.choice(members_pool)
                    db.add(make_task(project, assignee, manager, seq))
                    seq += 1
            for _ in range(15):
                person = random.choice(members_pool)
                db.add(make_task(None, person, person, seq))
                seq += 1
            db.flush()

            # --- Calendar events: ~24 across the 2-month window ---
            for w in range(9):
                week_start = WINDOW_START + timedelta(days=w * 7)
                event_project = random.choice(projects)
                meeting_dt = datetime.combine(week_start + timedelta(days=random.randint(0, 4)), datetime.min.time(), tzinfo=timezone.utc) + timedelta(hours=10)
                db.add(
                    CalendarEvent(
                        organization_id=org.id,
                        created_by_id=manager.id,
                        project_id=event_project.id,
                        title=random.choice(MEETING_TITLES),
                        event_type=CalendarEventType.meeting,
                        start_at=meeting_dt,
                        end_at=meeting_dt + timedelta(hours=1),
                        all_day=False,
                    )
                )
                reminder_dt = datetime.combine(week_start + timedelta(days=random.randint(0, 6)), datetime.min.time(), tzinfo=timezone.utc)
                db.add(
                    CalendarEvent(
                        organization_id=org.id,
                        created_by_id=random.choice(employees).id,
                        project_id=random.choice(projects).id,
                        title=random.choice(REMINDER_TITLES),
                        event_type=CalendarEventType.reminder,
                        start_at=reminder_dt,
                        end_at=reminder_dt + timedelta(hours=1),
                        all_day=True,
                    )
                )
                if w % 4 == 0:
                    holiday_dt = datetime.combine(week_start + timedelta(days=2), datetime.min.time(), tzinfo=timezone.utc)
                    db.add(
                        CalendarEvent(
                            organization_id=org.id,
                            created_by_id=admin.id,
                            project_id=None,
                            title=random.choice(HOLIDAY_TITLES),
                            event_type=CalendarEventType.holiday,
                            start_at=holiday_dt,
                            end_at=holiday_dt + timedelta(hours=1),
                            all_day=True,
                        )
                    )
            db.flush()

        db.commit()

        print("=== Seed complete ===")
        print(f"Organization: {org.name} (id={org.id})")
        print()
        print("=== Credentials (email | phone | password) ===")
        for label, email, phone, pwd in credentials:
            print(f"{label}: {email} | {phone} | {pwd}")
    finally:
        db.close()


if __name__ == "__main__":
    main()
