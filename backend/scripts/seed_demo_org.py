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
from app.models.account import Account
from app.models.calendar_event import CalendarEvent
from app.models.department import Department
from app.models.department_membership import DepartmentMembership
from app.models.enums import (
    ApprovalStatus,
    CalendarEventType,
    ProjectStatus,
    TaskPriority,
    TaskStatus,
    UserRole,
    WorkLogStatus,
)
from app.models.organization import Organization
from app.models.project import Project, ProjectMember
from app.models.task import Task
from app.models.user import User
from app.models.worklog import WorkLog

WORK_ACTIVITY_DESCRIPTIONS = [
    "پیشرفت اولیه و بررسی نیازمندی‌ها",
    "پیاده‌سازی بخش اصلی",
    "رفع اشکالات و بازبینی",
    "تست و اطمینان از عملکرد صحیح",
    "مستندسازی و نهایی‌سازی",
]

random.seed(42)

PASSWORD = "Test@1234"
TODAY = date(2026, 7, 16)
WINDOW_START = TODAY - timedelta(days=30)
WINDOW_END = TODAY + timedelta(days=30)

DEPARTMENTS = [
    {
        "name": "مهندسی و فنی",
        "phone_prefix": "0911",
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


def _make_account(db, phone_number):
    account = Account(phone_number=phone_number, hashed_password=hash_password(PASSWORD))
    db.add(account)
    db.flush()
    return account


def make_users_for_department(db, org, dept, dept_data, index_offset):
    manager_account = _make_account(db, f"{dept_data['phone_prefix']}{1000000 + index_offset}")
    manager = User(
        account_id=manager_account.id,
        organization_id=org.id,
        full_name=f"مدیر پروژه {dept.name}",
        role=UserRole.project_manager,
        department_id=dept.id,
    )
    db.add(manager)
    db.flush()
    db.add(DepartmentMembership(organization_id=org.id, user_id=manager.id, department_id=dept.id, role=manager.role))

    employees = []
    for i in range(1, 7):
        emp_account = _make_account(db, f"{dept_data['phone_prefix']}{1000010 + index_offset + i}")
        emp = User(
            account_id=emp_account.id,
            organization_id=org.id,
            full_name=f"کارمند {i} {dept.name}",
            role=UserRole.employee,
            department_id=dept.id,
        )
        db.add(emp)
        employees.append(emp)
        db.flush()
        db.add(DepartmentMembership(organization_id=org.id, user_id=emp.id, department_id=dept.id, role=emp.role))
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
        if db.query(Account).filter(Account.phone_number == "09100000001").first() is not None:
            print("Demo org already seeded (09100000001 exists) -- skipping.")
            return

        org = Organization(name="شرکت نمونهٔ آزمایشی", slug=f"demo-org-{uuid.uuid4().hex[:8]}")
        db.add(org)
        db.flush()

        admin_account = _make_account(db, "09100000001")
        admin = User(
            account_id=admin_account.id,
            organization_id=org.id,
            full_name="مدیر سازمان",
            role=UserRole.org_admin,
        )
        db.add(admin)
        db.flush()

        credentials = [("مدیر سازمان (org_admin)", admin_account.phone_number, PASSWORD)]
        all_dept_records = []  # [(dept, manager, employees), ...] -- used below for cross-department memberships

        for dept_idx, dept_data in enumerate(DEPARTMENTS):
            dept = Department(organization_id=org.id, name=dept_data["name"])
            db.add(dept)
            db.flush()
            if dept_idx == 0:
                admin.department_id = dept.id

            manager, employees = make_users_for_department(db, org, dept, dept_data, dept_idx * 100)
            all_dept_records.append((dept, manager, employees))
            credentials.append((f"مدیر پروژهٔ {dept.name}", manager.account.phone_number, PASSWORD))
            for i, emp in enumerate(employees, start=1):
                credentials.append((f"کارمند {i} - {dept.name}", emp.account.phone_number, PASSWORD))

            members_pool = [manager] + employees

            projects = []
            for p_idx, project_name in enumerate(dept_data["project_names"]):
                project_members_subset = random.sample(employees, k=3)
                # Staggered, varied-length windows (not all sharing WINDOW_START/END)
                # so a roadmap/Gantt view of projects actually shows a spread
                # instead of every bar being identical.
                project_start = TODAY - timedelta(days=random.randint(10, 90))
                project_end = project_start + timedelta(days=random.randint(45, 150))
                project = Project(
                    organization_id=org.id,
                    name=project_name,
                    description=f"پروژهٔ {dept.name} شماره {p_idx + 1}",
                    start_date=project_start,
                    end_date=project_end,
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
            dept_tasks = []
            for project in projects:
                for _ in range(18):
                    assignee = random.choice(members_pool)
                    task = make_task(project, assignee, manager, seq)
                    db.add(task)
                    dept_tasks.append(task)
                    seq += 1
            for _ in range(15):
                person = random.choice(members_pool)
                task = make_task(None, person, person, seq)
                db.add(task)
                dept_tasks.append(task)
                seq += 1
            db.flush()

            # --- Work logs: real logged hours for anything past "todo", so
            # Task.actual_hours (summed from approved logs) isn't zero
            # everywhere -- most are approved, some left pending to also
            # show the manager approval queue with real data in it.
            for task in dept_tasks:
                if task.status == TaskStatus.todo:
                    continue
                for i in range(random.randint(1, 4)):
                    log_dt = min(task.start_date + timedelta(days=i * random.randint(1, 4)), TODAY)
                    worklog_status = (
                        WorkLogStatus.approved
                        if task.status in (TaskStatus.completed, TaskStatus.archived)
                        else random.choices([WorkLogStatus.approved, WorkLogStatus.submitted], weights=[70, 30])[0]
                    )
                    db.add(
                        WorkLog(
                            organization_id=org.id,
                            task_id=task.id,
                            user_id=task.assignee_id,
                            activity_description=random.choice(WORK_ACTIVITY_DESCRIPTIONS),
                            time_spent_minutes=random.randint(30, 240),
                            progress_percent=min(100, (i + 1) * random.randint(20, 40)),
                            log_date=log_dt,
                            status=worklog_status,
                            reviewed_by_id=manager.id if worklog_status == WorkLogStatus.approved else None,
                        )
                    )
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
            db.flush()

        # --- Official holidays: org-wide, generated once (not per
        # department) -- these used to be created inside the department
        # loop above, so the same date got one duplicate "تعطیلی رسمی"
        # event per department instead of a single org-wide one.
        for w in range(9):
            if w % 4 != 0:
                continue
            week_start = WINDOW_START + timedelta(days=w * 7)
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

        # --- A few cross-department memberships, so the demo actually shows
        # a user who belongs to more than one department (the HR manager
        # also helps out in Engineering; one Engineering employee is also
        # in Accounting) -- exercises the department switcher in the UI.
        (eng_dept, eng_manager, eng_employees) = all_dept_records[0]
        (fin_dept, fin_manager, fin_employees) = all_dept_records[1]
        (hr_dept, hr_manager, hr_employees) = all_dept_records[2]

        db.add(
            DepartmentMembership(
                organization_id=org.id, user_id=hr_manager.id, department_id=eng_dept.id, role=UserRole.employee
            )
        )
        db.add(
            DepartmentMembership(
                organization_id=org.id,
                user_id=eng_employees[0].id,
                department_id=fin_dept.id,
                role=UserRole.employee,
            )
        )
        db.flush()

        db.commit()

        print("=== Seed complete ===")
        print(f"Organization: {org.name} (id={org.id})")
        print()
        print("=== Credentials (phone | password) ===")
        for label, phone, pwd in credentials:
            print(f"{label}: {phone} | {pwd}")
    finally:
        db.close()


if __name__ == "__main__":
    main()
