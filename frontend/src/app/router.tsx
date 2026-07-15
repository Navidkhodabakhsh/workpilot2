import { createBrowserRouter } from "react-router-dom"

import { AppShell } from "@/components/layout/app-shell"
import { ProtectedRoute } from "@/app/protected-route"
import { LoginPage } from "@/features/auth/pages/login-page"
import { SignupPage } from "@/features/auth/pages/signup-page"
import { DashboardPage } from "@/features/dashboard/pages/dashboard-page"
import { ProjectsListPage } from "@/features/projects/pages/projects-list-page"
import { ProjectDetailPage } from "@/features/projects/pages/project-detail-page"
import { TasksListPage } from "@/features/tasks/pages/tasks-list-page"
import { ReportsPage } from "@/features/reports/pages/reports-page"
import { UsersListPage } from "@/features/users/pages/users-list-page"

function ComingSoon({ title }: { title: string }) {
  return (
    <div>
      <h1 className="text-2xl font-bold">{title}</h1>
      <p className="text-muted-foreground">این بخش در فازهای بعدی ساخته می‌شود.</p>
    </div>
  )
}

export const router = createBrowserRouter([
  { path: "/login", element: <LoginPage /> },
  { path: "/signup", element: <SignupPage /> },
  {
    element: <ProtectedRoute />,
    children: [
      {
        element: <AppShell />,
        children: [
          { path: "/", element: <DashboardPage /> },
          { path: "/projects", element: <ProjectsListPage /> },
          { path: "/projects/:projectId", element: <ProjectDetailPage /> },
          { path: "/tasks", element: <TasksListPage /> },
          { path: "/reports", element: <ReportsPage /> },
          { path: "/calendar", element: <ComingSoon title="تقویم" /> },
          { path: "/users", element: <UsersListPage /> },
          { path: "/workflow", element: <ComingSoon title="گردش کار" /> },
          { path: "/analytics", element: <ComingSoon title="تحلیل‌ها" /> },
          { path: "/messages", element: <ComingSoon title="پیام‌ها" /> },
          { path: "/files", element: <ComingSoon title="فایل‌ها" /> },
          { path: "/settings", element: <ComingSoon title="تنظیمات" /> },
        ],
      },
    ],
  },
])
