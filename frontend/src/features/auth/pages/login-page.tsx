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
  email: z.string().email("ایمیل معتبر وارد کنید"),
  password: z.string().min(8, "رمز عبور باید حداقل ۸ کاراکتر باشد"),
})

type FormValues = z.infer<typeof schema>

export function LoginPage() {
  const navigate = useNavigate()
  const setSession = useAuthStore((s) => s.setSession)
  const [serverError, setServerError] = useState<string | null>(null)

  const form = useForm<FormValues>({
    resolver: zodResolver(schema),
    defaultValues: { email: "", password: "" },
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
      setServerError("ایمیل یا رمز عبور اشتباه است")
    }
  }

  return (
    <AuthLayout>
      <Card className="w-full border-white/20 bg-white/15 shadow-2xl backdrop-blur-xl">
        <CardHeader>
          <CardTitle className="text-2xl text-white">ورود به WorkPilot</CardTitle>
          <CardDescription className="text-white/70">
            برای ادامه، ایمیل و رمز عبور خود را وارد کنید
          </CardDescription>
        </CardHeader>
        <CardContent>
          <form onSubmit={form.handleSubmit(onSubmit)} className="flex flex-col gap-4">
            <div className="flex flex-col gap-2">
              <Label htmlFor="email" className="text-white">
                ایمیل
              </Label>
              <Input
                id="email"
                type="email"
                autoComplete="email"
                aria-invalid={!!form.formState.errors.email}
                className="border-white/30 bg-white/10 text-white placeholder:text-white/50"
                {...form.register("email")}
              />
              {form.formState.errors.email && (
                <p className="text-sm text-amber-200">{form.formState.errors.email.message}</p>
              )}
            </div>
            <div className="flex flex-col gap-2">
              <Label htmlFor="password" className="text-white">
                رمز عبور
              </Label>
              <Input
                id="password"
                type="password"
                autoComplete="current-password"
                aria-invalid={!!form.formState.errors.password}
                className="border-white/30 bg-white/10 text-white placeholder:text-white/50"
                {...form.register("password")}
              />
              {form.formState.errors.password && (
                <p className="text-sm text-amber-200">{form.formState.errors.password.message}</p>
              )}
            </div>
            {serverError && <p className="text-sm text-amber-200">{serverError}</p>}
            <Button type="submit" variant="accent" className="mt-2 w-full" disabled={form.formState.isSubmitting}>
              {form.formState.isSubmitting ? "در حال ورود..." : "ورود"}
            </Button>
            <p className="text-center text-sm text-white/70">
              سازمان جدید دارید؟{" "}
              <Link to="/signup" className="text-white underline hover:text-white/80">
                ثبت‌نام
              </Link>
            </p>
          </form>
        </CardContent>
      </Card>
    </AuthLayout>
  )
}
