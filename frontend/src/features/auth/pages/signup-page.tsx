import { useState, type FormEvent } from "react"
import { Link, useNavigate } from "react-router-dom"

import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { AuthLayout } from "@/features/auth/components/auth-layout"
import { fetchMe, login, requestSignupOtp, signup } from "@/features/auth/api"
import { useAuthStore } from "@/features/auth/auth-store"
import { PASSWORD_HINT, PHONE_HINT, passwordSchema, phoneSchema, otpCodeSchema } from "@/features/auth/validation"

type Step = "phone" | "details"

export function SignupPage() {
  const navigate = useNavigate()
  const setSession = useAuthStore((s) => s.setSession)

  const [step, setStep] = useState<Step>("phone")
  const [phone, setPhone] = useState("")
  const [code, setCode] = useState("")
  const [organizationName, setOrganizationName] = useState("")
  const [departmentName, setDepartmentName] = useState("")
  const [fullName, setFullName] = useState("")
  const [password, setPassword] = useState("")
  const [debugCode, setDebugCode] = useState<string | null>(null)
  const [fieldError, setFieldError] = useState<string | null>(null)
  const [serverError, setServerError] = useState<string | null>(null)
  const [submitting, setSubmitting] = useState(false)

  async function onRequestCode(e: FormEvent) {
    e.preventDefault()
    setServerError(null)
    const phoneResult = phoneSchema.safeParse(phone)
    if (!phoneResult.success) {
      setFieldError(phoneResult.error.issues[0].message)
      return
    }
    setFieldError(null)
    setSubmitting(true)
    try {
      const { debug_code } = await requestSignupOtp({ phone_number: phone })
      setDebugCode(debug_code)
      setStep("details")
    } catch (err: any) {
      if (err?.response?.status === 409) {
        setServerError("این شماره موبایل قبلاً ثبت شده است")
      } else if (err?.response?.status === 429) {
        setServerError("تعداد درخواست‌های کد بیش از حد مجاز است؛ کمی بعد دوباره تلاش کنید.")
      } else {
        setServerError("خطایی رخ داد؛ دوباره تلاش کنید")
      }
    } finally {
      setSubmitting(false)
    }
  }

  async function onCreateOrganization(e: FormEvent) {
    e.preventDefault()
    setServerError(null)
    const codeResult = otpCodeSchema.safeParse(code)
    if (!codeResult.success) {
      setFieldError(codeResult.error.issues[0].message)
      return
    }
    if (organizationName.trim().length < 2) {
      setFieldError("نام سازمان را وارد کنید")
      return
    }
    if (fullName.trim().length < 2) {
      setFieldError("نام و نام خانوادگی را وارد کنید")
      return
    }
    const passwordResult = passwordSchema.safeParse(password)
    if (!passwordResult.success) {
      setFieldError(passwordResult.error.issues[0].message)
      return
    }
    setFieldError(null)
    setSubmitting(true)
    try {
      await signup({
        organization_name: organizationName,
        department_name: departmentName || undefined,
        full_name: fullName,
        phone_number: phone,
        code,
        password,
      })
      const { access_token } = await login({ phone_number: phone, password })
      useAuthStore.setState({ accessToken: access_token })
      const user = await fetchMe()
      setSession(access_token, user)
      navigate("/", { replace: true })
    } catch (err: any) {
      if (err?.response?.status === 401) {
        setServerError("کد وارد شده اشتباه یا منقضی شده است")
      } else if (err?.response?.status === 409) {
        setServerError("این شماره موبایل قبلاً ثبت شده است")
      } else {
        setServerError("خطایی رخ داد؛ دوباره تلاش کنید")
      }
    } finally {
      setSubmitting(false)
    }
  }

  return (
    <AuthLayout>
      <Card className="w-full rounded-2xl border-border/60 py-7 shadow-xl">
        <CardHeader>
          <CardTitle className="text-2xl">ساخت سازمان جدید در Tadvin</CardTitle>
          <CardDescription>
            {step === "phone"
              ? "شماره موبایل خود را وارد کنید تا کد تایید برایتان ارسال شود"
              : "کد ارسال‌شده را تایید و اطلاعات سازمان را تکمیل کنید"}
          </CardDescription>
        </CardHeader>
        <CardContent>
          {step === "phone" ? (
            <form onSubmit={onRequestCode} className="flex flex-col gap-4">
              <div className="flex flex-col gap-2">
                <Label htmlFor="phone_number" required>شماره موبایل</Label>
                <Input
                  id="phone_number"
                  type="tel"
                  inputMode="numeric"
                  dir="ltr"
                  autoComplete="tel"
                  value={phone}
                  onChange={(e) => setPhone(e.target.value)}
                />
                <p className="text-xs text-muted-foreground">{PHONE_HINT}</p>
              </div>
              {fieldError && <p className="text-sm text-danger">{fieldError}</p>}
              {serverError && <p className="text-sm text-danger">{serverError}</p>}
              <Button type="submit" variant="accent" className="mt-2 w-full" disabled={submitting}>
                {submitting ? "در حال ارسال..." : "دریافت کد تایید"}
              </Button>
              <p className="text-center text-sm text-muted-foreground">
                حساب دارید؟{" "}
                <Link to="/login" className="font-medium text-primary underline-offset-4 hover:underline">
                  ورود
                </Link>
              </p>
            </form>
          ) : (
            <form onSubmit={onCreateOrganization} className="flex flex-col gap-4">
              <div className="flex items-center justify-between">
                <p className="text-sm text-muted-foreground" dir="ltr">{phone}</p>
                <button
                  type="button"
                  onClick={() => {
                    setStep("phone")
                    setCode("")
                    setServerError(null)
                  }}
                  className="text-sm font-medium text-primary underline-offset-4 hover:underline"
                >
                  ویرایش شماره
                </button>
              </div>
              {debugCode && (
                <p className="rounded-md bg-muted p-2 text-xs text-muted-foreground">
                  سرویس پیامک هنوز متصل نشده — کد آزمایشی شما:{" "}
                  <span className="font-mono font-semibold" dir="ltr">{debugCode}</span>
                </p>
              )}
              <div className="flex flex-col gap-2">
                <Label htmlFor="signup-code" required>کد ۶ رقمی</Label>
                <Input
                  id="signup-code"
                  inputMode="numeric"
                  dir="ltr"
                  maxLength={6}
                  value={code}
                  onChange={(e) => setCode(e.target.value)}
                />
              </div>
              <div className="flex flex-col gap-2">
                <Label htmlFor="organization_name" required>نام سازمان</Label>
                <Input id="organization_name" value={organizationName} onChange={(e) => setOrganizationName(e.target.value)} />
              </div>
              <div className="flex flex-col gap-2">
                <Label htmlFor="department_name">نام دپارتمان</Label>
                <Input
                  id="department_name"
                  placeholder="مثلاً: عمومی (اختیاری)"
                  value={departmentName}
                  onChange={(e) => setDepartmentName(e.target.value)}
                />
                <p className="text-xs text-muted-foreground">
                  اختیاری — می‌توانید سازمان را بدون دپارتمان شروع کنید و بعداً از تنظیمات دپارتمان‌بندی کنید.
                </p>
              </div>
              <div className="flex flex-col gap-2">
                <Label htmlFor="full_name" required>نام و نام خانوادگی</Label>
                <Input id="full_name" value={fullName} onChange={(e) => setFullName(e.target.value)} />
              </div>
              <div className="flex flex-col gap-2">
                <Label htmlFor="password" required>رمز عبور</Label>
                <Input
                  id="password"
                  type="password"
                  autoComplete="new-password"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                />
                <p className="text-xs text-muted-foreground">{PASSWORD_HINT}</p>
              </div>
              {fieldError && <p className="text-sm text-danger">{fieldError}</p>}
              {serverError && <p className="text-sm text-danger">{serverError}</p>}
              <Button type="submit" variant="accent" className="mt-2 w-full" disabled={submitting}>
                {submitting ? "در حال ساخت..." : "ساخت سازمان و ورود"}
              </Button>
            </form>
          )}
        </CardContent>
      </Card>
    </AuthLayout>
  )
}
