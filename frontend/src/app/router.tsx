import { createBrowserRouter } from "react-router-dom"

import { AppShell } from "@/components/layout/app-shell"
import { ProtectedRoute } from "@/app/protected-route"
import { RoleProtectedRoute } from "@/app/role-protected-route"
import { LoginPage } from "@/features/auth/pages/login-page"
import { SignupPage } from "@/features/auth/pages/signup-page"
import { ForgotPasswordPage } from "@/features/auth/pages/forgot-password-page"
import { DashboardPage } from "@/features/dashboard/pages/dashboard-page"
import { ProjectsListPage } from "@/features/projects/pages/projects-list-page"
import { ProjectDetailPage } from "@/features/projects/pages/project-detail-page"
import { TasksListPage } from "@/features/tasks/pages/tasks-list-page"
import { UsersListPage } from "@/features/users/pages/users-list-page"
import { MessagesPage } from "@/features/messages/pages/messages-page"
import { FilesListPage } from "@/features/attachments/pages/files-list-page"
import { SettingsPage } from "@/features/settings/pages/settings-page"
import { CalendarPage } from "@/features/calendar/pages/calendar-page"
import { ArchivePage } from "@/features/archive/pages/archive-page"
import { LeavePage } from "@/features/leave/pages/leave-page"

export const router = createBrowserRouter([
  { path: "/login", element: <LoginPage /> },
  { path: "/signup", element: <SignupPage /> },
  { path: "/forgot-password", element: <ForgotPasswordPage /> },
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
          { path: "/calendar", element: <CalendarPage /> },
          {
            element: <RoleProtectedRoute allowedRoles={["org_admin"]} />,
            children: [{ path: "/users", element: <UsersListPage /> }],
          },
          { path: "/messages", element: <MessagesPage /> },
          { path: "/files", element: <FilesListPage /> },
          { path: "/archive", element: <ArchivePage /> },
          { path: "/leave", element: <LeavePage /> },
          { path: "/settings", element: <SettingsPage /> },
        ],
      },
    ],
  },
])
