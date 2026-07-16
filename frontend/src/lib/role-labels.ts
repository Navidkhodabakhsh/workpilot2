import type { UserRole } from "@/lib/types"

export const ROLE_LABEL: Record<UserRole, string> = {
  platform_admin: "مدیر پلتفرم",
  org_admin: "مدیر سازمان",
  project_manager: "مدیر پروژه",
  employee: "کارمند",
}
