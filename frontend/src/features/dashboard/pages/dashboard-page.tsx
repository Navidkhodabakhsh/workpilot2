import { useQuery } from "@tanstack/react-query"

import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { apiClient } from "@/lib/api-client"
import { useAuthStore } from "@/features/auth/auth-store"

async function fetchHealth() {
  const { data } = await apiClient.get<{ status: string }>("/health")
  return data
}

export function DashboardPage() {
  const user = useAuthStore((s) => s.user)
  const { data, isLoading, isError } = useQuery({ queryKey: ["health"], queryFn: fetchHealth })

  return (
    <div className="flex flex-col gap-4">
      <div>
        <h1 className="text-2xl font-bold">داشبورد</h1>
        <p className="text-muted-foreground">نمای کلی از فعالیت‌ها و پروژه‌ها</p>
      </div>

      <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4">
        <Card>
          <CardHeader>
            <CardTitle className="text-base">وضعیت سرور</CardTitle>
          </CardHeader>
          <CardContent>
            {isLoading && <p className="text-muted-foreground">در حال بررسی...</p>}
            {isError && <p className="text-danger">اتصال به سرور برقرار نشد</p>}
            {data && <p className="text-success">سرور در دسترس است ({data.status})</p>}
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle className="text-base">کاربر جاری</CardTitle>
          </CardHeader>
          <CardContent>
            <p>{user?.full_name}</p>
            <p className="text-sm text-muted-foreground">{user?.role}</p>
          </CardContent>
        </Card>
      </div>

      <Card>
        <CardContent className="pt-6">
          <p className="text-muted-foreground">
            محتوای کامل داشبورد (نمودارها، فهرست تسک‌های در انتظار تأیید، پروژه‌های فعال) در فاز E
            پیاده‌سازی می‌شود — به `docs/UI-DESIGN.md` مراجعه کنید.
          </p>
        </CardContent>
      </Card>
    </div>
  )
}
