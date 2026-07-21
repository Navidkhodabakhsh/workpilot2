import { useEffect, useState } from "react"
import { useQuery } from "@tanstack/react-query"
import { useNavigate } from "react-router-dom"
import { Building2 } from "lucide-react"

import { Button } from "@/components/ui/button"
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog"
import { listDepartments } from "@/features/departments/api"
import { useAuthStore } from "@/features/auth/auth-store"

function dismissedKey(organizationId: string) {
  return `department-onboarding-dismissed-${organizationId}`
}

/** A one-time explainer shown to a fresh org_admin whose organization has no
 * departments yet -- departments are optional (not required at signup
 * anymore), so most people need telling that the option exists at all and
 * that skipping it is fine. Dismissing (either action) persists per-org in
 * localStorage so it never nags again, even once departments are added. */
export function DepartmentOnboardingHint() {
  const user = useAuthStore((s) => s.user)
  const navigate = useNavigate()
  const isOrgAdmin = user?.role === "org_admin"
  const organizationId = user?.organization_id ?? null

  const { data: departments } = useQuery({
    queryKey: ["departments"],
    queryFn: listDepartments,
    enabled: isOrgAdmin,
  })

  const [open, setOpen] = useState(false)

  useEffect(() => {
    if (!isOrgAdmin || !organizationId || !departments) return
    if (departments.length > 0) return
    if (localStorage.getItem(dismissedKey(organizationId)) === "1") return
    setOpen(true)
  }, [isOrgAdmin, organizationId, departments])

  function dismiss() {
    if (organizationId) localStorage.setItem(dismissedKey(organizationId), "1")
    setOpen(false)
  }

  if (!isOrgAdmin) return null

  return (
    <Dialog open={open} onOpenChange={(next) => !next && dismiss()}>
      <DialogContent>
        <DialogHeader>
          <div className="mb-2 flex size-11 items-center justify-center rounded-full bg-primary/10 text-primary">
            <Building2 className="size-5" aria-hidden="true" />
          </div>
          <DialogTitle>می‌خواهید سازمان را دپارتمان‌بندی کنید؟</DialogTitle>
          <DialogDescription>
            شما می‌توانید سازمان خود را به بخش‌های جداگانه (مثل حسابداری، برنامه‌نویسی، منابع انسانی) تقسیم کنید تا
            مدیریت کاربران، پروژه‌ها و گزارش‌ها راحت‌تر شود. این کار کاملاً اختیاری است — همین حالا هم بدون هیچ
            دپارتمانی می‌توانید از سازمان استفاده کنید و هر وقت خواستید از تنظیمات دپارتمان اضافه کنید.
          </DialogDescription>
        </DialogHeader>
        <div className="flex flex-col gap-2 sm:flex-row-reverse">
          <Button
            className="sm:flex-1"
            onClick={() => {
              dismiss()
              navigate("/settings")
            }}
          >
            برو دپارتمان بساز
          </Button>
          <Button variant="outline" className="sm:flex-1" onClick={dismiss}>
            فعلاً نه
          </Button>
        </div>
      </DialogContent>
    </Dialog>
  )
}
