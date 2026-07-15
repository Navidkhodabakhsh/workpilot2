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

const schema = z.object({
  organization_name: z.string().min(2, "نام سازمان را وارد کنید"),
  full_name: z.string().min(2, "نام و نام خانوادگی را وارد کنید"),
  email: z.string().email("ایمیل معتبر وارد کنید"),
  password: z.string().min(8, "رمز عبور باید حداقل ۸ کاراکتر باشد"),
})

type FormValues = z.infer<typeof schema>

export function SignupPage() {
  const navigate = useNavigate()
  const setSession = useAuthStore((s) => s.setSession)
  const [serverError, setServerError] = useState<string | null>(null)

  const form = useForm<FormValues>({
    resolver: zodResolver(schema),
    defaultValues: { organization_name: "", full_name: "", email: "", password: "" },
  })

  async function onSubmit(values: FormValues) {
    setServerError(null)
    try {
      await signup(values)
      const { access_token } = await login({ email: values.email, password: values.password })
      useAuthStore.setState({ accessToken: access_token })
      const user = await fetchMe()
      setSession(access_token, user)
      navigate("/", { replace: true })
    } catch (err: any) {
      if (err?.response?.status === 409) {
        setServerError("این ایمیل قبلاً ثبت شده است")
      } else {
        setServerError("خطایی رخ داد؛ دوباره تلاش کنید")
      }
    }
  }

  return (
    <AuthLayout>
      <Card className="w-full shadow-lg">
        <CardHeader>
          <CardTitle className="text-2xl">ساخت سازمان جدید در Tadvin</CardTitle>
          <CardDescription>یک فضای کاری جدید برای سازمان خود بسازید</CardDescription>
        </CardHeader>
        <CardContent>
          <form onSubmit={form.handleSubmit(onSubmit)} className="flex flex-col gap-4">
            <div className="flex flex-col gap-2">
              <Label htmlFor="organization_name">نام سازمان</Label>
              <Input id="organization_name" {...form.register("organization_name")} />
              {form.formState.errors.organization_name && (
                <p className="text-sm text-danger">{form.formState.errors.organization_name.message}</p>
              )}
            </div>
            <div className="flex flex-col gap-2">
              <Label htmlFor="full_name">نام و نام خانوادگی</Label>
              <Input id="full_name" {...form.register("full_name")} />
              {form.formState.errors.full_name && (
                <p className="text-sm text-danger">{form.formState.errors.full_name.message}</p>
              )}
            </div>
            <div className="flex flex-col gap-2">
              <Label htmlFor="email">ایمیل</Label>
              <Input id="email" type="email" autoComplete="email" {...form.register("email")} />
              {form.formState.errors.email && (
                <p className="text-sm text-danger">{form.formState.errors.email.message}</p>
              )}
            </div>
            <div className="flex flex-col gap-2">
              <Label htmlFor="password">رمز عبور</Label>
              <Input id="password" type="password" autoComplete="new-password" {...form.register("password")} />
              {form.formState.errors.password && (
                <p className="text-sm text-danger">{form.formState.errors.password.message}</p>
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
