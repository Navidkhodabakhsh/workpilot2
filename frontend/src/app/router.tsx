import { createBrowserRouter } from "react-router-dom"

import { AppShell } from "@/components/layout/app-shell"
import { ProtectedRoute } from "@/app/protected-route"
import { RoleProtectedRoute } from "@/app/role-protected-route"

export const router = createBrowserRouter([
  {
    path: "/login",
    lazy: async () => {
      const { LoginPage } = await import("@/features/auth/pages/login-page")
      return { Component: LoginPage }
    },
  },
  {
    path: "/signup",
    lazy: async () => {
      const { SignupPage } = await import("@/features/auth/pages/signup-page")
      return { Component: SignupPage }
    },
  },
  {
    path: "/forgot-password",
    lazy: async () => {
      const { ForgotPasswordPage } = await import("@/features/auth/pages/forgot-password-page")
      return { Component: ForgotPasswordPage }
    },
  },
  {
    element: <ProtectedRoute />,
    children: [
      {
        element: <AppShell />,
        children: [
          {
            path: "/",
            lazy: async () => {
              const { DashboardInsightsPage } = await import("@/features/dashboard/pages/dashboard-insights-page")
              return { Component: DashboardInsightsPage }
            },
          },
          {
            path: "/projects",
            lazy: async () => {
              const { ProjectsListPage } = await import("@/features/projects/pages/projects-list-page")
              return { Component: ProjectsListPage }
            },
          },
          {
            path: "/projects/:projectId",
            lazy: async () => {
              const { ProjectDetailPage } = await import("@/features/projects/pages/project-detail-page")
              return { Component: ProjectDetailPage }
            },
          },
          {
            path: "/tasks",
            lazy: async () => {
              const { TasksWorkflowPage } = await import("@/features/tasks/pages/tasks-workflow-page")
              return { Component: TasksWorkflowPage }
            },
          },
          {
            path: "/calendar",
            lazy: async () => {
              const { CalendarPage } = await import("@/features/calendar/pages/calendar-page")
              return { Component: CalendarPage }
            },
          },
          {
            element: <RoleProtectedRoute allowedRoles={["org_admin"]} />,
            children: [
              {
                path: "/users",
                lazy: async () => {
                  const { UsersListPage } = await import("@/features/users/pages/users-list-page")
                  return { Component: UsersListPage }
                },
              },
            ],
          },
          {
            element: <RoleProtectedRoute allowedRoles={["org_admin", "project_manager"]} />,
            children: [
              {
                path: "/finance",
                lazy: async () => {
                  const { FinancePage } = await import("@/features/finance/pages/finance-page")
                  return { Component: FinancePage }
                },
              },
            ],
          },
          {
            path: "/messages",
            lazy: async () => {
              const { MessagesPage } = await import("@/features/messages/pages/messages-page")
              return { Component: MessagesPage }
            },
          },
          {
            path: "/files",
            lazy: async () => {
              const { FilesListPage } = await import("@/features/attachments/pages/files-list-page")
              return { Component: FilesListPage }
            },
          },
          {
            path: "/archive",
            lazy: async () => {
              const { ArchivePage } = await import("@/features/archive/pages/archive-page")
              return { Component: ArchivePage }
            },
          },
          {
            path: "/leave",
            lazy: async () => {
              const { LeavePage } = await import("@/features/leave/pages/leave-page")
              return { Component: LeavePage }
            },
          },
          {
            path: "/settings",
            lazy: async () => {
              const { SettingsPage } = await import("@/features/settings/pages/settings-page")
              return { Component: SettingsPage }
            },
          },
        ],
      },
    ],
  },
])
