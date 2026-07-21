import { useState } from "react"
import { useForm } from "react-hook-form"
import { zodResolver } from "@hookform/resolvers/zod"
import { z } from "zod"
import { Link, useNavigate } from "react-router-dom"

import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { AuthLayout } from "@/features/auth/components/auth-layout"
import { signup, login, fetchMe } from "@/features/auth/api"
import { useAuthStore } from "@/features/auth/auth-store"
import { PASSWORD_HINT, PHONE_HINT, passwordSchema, phoneSchema } from "@/features/auth/validation"

const schema = z.object({
  organization_name: z.string().min(2, "نام سازمان را وارد کنید"),
  department_name: z.string().optional(),
  full_name: z.string().min(2, "نام و نام خانوادگی را وارد کنید"),
  phone_number: phoneSchema,
  password: passwordSchema,
})

type FormValues = z.infer<typeof schema>

export function SignupPage() {
  const navigate = useNavigate()
  const setSession = useAuthStore((s) => s.setSession)
  const [serverError, setServerError] = useState<string | null>(null)

  const form = useForm<FormValues>({
    resolver: zodResolver(schema),
    defaultValues: {
      organization_name: "",
      department_name: "",
      full_name: "",
      phone_number: "",
      password: "",
    },
  })

  async function onSubmit(values: FormValues) {
    setServerError(null)
    try {
      await signup({ ...values, department_name: values.department_name || undefined })
      const { access_token } = await login({ phone_number: values.phone_number, password: values.password })
      useAuthStore.setState({ accessToken: access_token })
      const user = await fetchMe()
      setSession(access_token, user)
      navigate("/", { replace: true })
    } catch (err: any) {
      if (err?.response?.status === 409) {
        setServerError("این شماره موبایل قبلاً ثبت شده است")
      } else {
        setServerError("خطایی رخ داد؛ دوباره تلاش کنید")
      }
    }
  }

  return (
    <AuthLayout>
      <Card className="w-full rounded-2xl border-border/60 py-7 shadow-xl">
        <CardHeader>
          <CardTitle className="text-2xl">ساخت سازمان جدید در Tadvin</CardTitle>
          <CardDescription>یک فضای کاری جدید برای سازمان خود بسازید</CardDescription>
        </CardHeader>
        <CardContent>
          <form onSubmit={form.handleSubmit(onSubmit)} className="flex flex-col gap-4">
            <div className="flex flex-col gap-2">
              <Label htmlFor="organization_name" required>نام سازمان</Label>
              <Input id="organization_name" {...form.register("organization_name")} />
              {form.formState.errors.organization_name && (
                <p className="text-sm text-danger">{form.formState.errors.organization_name.message}</p>
              )}
            </div>
            <div className="flex flex-col gap-2">
              <Label htmlFor="department_name">نام دپارتمان</Label>
              <Input id="department_name" placeholder="مثلاً: عمومی (اختیاری)" {...form.register("department_name")} />
              <p className="text-xs text-muted-foreground">
                اختیاری — می‌توانید سازمان را بدون دپارتمان شروع کنید و بعداً از تنظیمات دپارتمان‌بندی کنید.
              </p>
            </div>
            <div className="flex flex-col gap-2">
              <Label htmlFor="full_name" required>نام و نام خانوادگی</Label>
              <Input id="full_name" {...form.register("full_name")} />
              {form.formState.errors.full_name && (
                <p className="text-sm text-danger">{form.formState.errors.full_name.message}</p>
              )}
            </div>
            <div className="flex flex-col gap-2">
              <Label htmlFor="phone_number" required>شماره موبایل</Label>
              <Input
                id="phone_number"
                type="tel"
                inputMode="numeric"
                dir="ltr"
                autoComplete="tel"
                {...form.register("phone_number")}
              />
              {form.formState.errors.phone_number ? (
                <p className="text-sm text-danger">{form.formState.errors.phone_number.message}</p>
              ) : (
                <p className="text-xs text-muted-foreground">{PHONE_HINT}</p>
              )}
            </div>
            <div className="flex flex-col gap-2">
              <Label htmlFor="password" required>رمز عبور</Label>
              <Input id="password" type="password" autoComplete="new-password" {...form.register("password")} />
              {form.formState.errors.password ? (
                <p className="text-sm text-danger">{form.formState.errors.password.message}</p>
              ) : (
                <p className="text-xs text-muted-foreground">{PASSWORD_HINT}</p>
              )}
            </div>
            {serverError && <p className="text-sm text-danger">{serverError}</p>}
            <Button type="submit" variant="accent" className="mt-2 w-full" disabled={form.formState.isSubmitting}>
              {form.formState.isSubmitting ? "در حال ساخت..." : "ساخت سازمان و ورود"}
            </Button>
            <p className="text-center text-sm text-muted-foreground">
              حساب دارید؟{" "}
              <Link to="/login" className="font-medium text-primary underline-offset-4 hover:underline">
                ورود
              </Link>
            </p>
          </form>
        </CardContent>
      </Card>
    </AuthLayout>
  )
}
