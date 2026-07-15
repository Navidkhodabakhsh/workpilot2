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
import { login, fetchMe } from "@/features/auth/api"
import { useAuthStore } from "@/features/auth/auth-store"

const schema = z.object({
  identifier: z.string().min(3, "ایمیل یا شماره موبایل را وارد کنید"),
  password: z.string().min(8, "رمز عبور باید حداقل ۸ کاراکتر باشد"),
})

type FormValues = z.infer<typeof schema>

export function LoginPage() {
  const navigate = useNavigate()
  const setSession = useAuthStore((s) => s.setSession)
  const [serverError, setServerError] = useState<string | null>(null)

  const form = useForm<FormValues>({
    resolver: zodResolver(schema),
    defaultValues: { identifier: "", password: "" },
  })

  async function onSubmit(values: FormValues) {
    setServerError(null)
    try {
      const { access_token } = await login(values)
      useAuthStore.setState({ accessToken: access_token })
      const user = await fetchMe()
      setSession(access_token, user)
      navigate("/", { replace: true })
    } catch {
      setServerError("ایمیل/شماره موبایل یا رمز عبور اشتباه است")
    }
  }

  return (
    <AuthLayout>
      <Card className="w-full shadow-lg">
        <CardHeader>
          <CardTitle className="text-2xl">ورود به Tadvin</CardTitle>
          <CardDescription>برای ادامه، ایمیل یا شماره موبایل و رمز عبور خود را وارد کنید</CardDescription>
        </CardHeader>
        <CardContent>
          <form onSubmit={form.handleSubmit(onSubmit)} className="flex flex-col gap-4">
            <div className="flex flex-col gap-2">
              <Label htmlFor="identifier">ایمیل یا شماره موبایل</Label>
              <Input
                id="identifier"
                autoComplete="username"
                aria-invalid={!!form.formState.errors.identifier}
                {...form.register("identifier")}
              />
              {form.formState.errors.identifier && (
                <p className="text-sm text-danger">{form.formState.errors.identifier.message}</p>
              )}
            </div>
            <div className="flex flex-col gap-2">
              <Label htmlFor="password">رمز عبور</Label>
              <Input
                id="password"
                type="password"
                autoComplete="current-password"
                aria-invalid={!!form.formState.errors.password}
                {...form.register("password")}
              />
              {form.formState.errors.password && (
                <p className="text-sm text-danger">{form.formState.errors.password.message}</p>
              )}
            </div>
            {serverError && <p className="text-sm text-danger">{serverError}</p>}
            <Button type="submit" variant="accent" className="mt-2 w-full" disabled={form.formState.isSubmitting}>
              {form.formState.isSubmitting ? "در حال ورود..." : "ورود"}
            </Button>
            <p className="text-center text-sm text-muted-foreground">
              سازمان جدید دارید؟{" "}
              <Link to="/signup" className="font-medium text-primary underline-offset-4 hover:underline">
                ثبت‌نام
              </Link>
            </p>
          </form>
        </CardContent>
      </Card>
    </AuthLayout>
  )
}
