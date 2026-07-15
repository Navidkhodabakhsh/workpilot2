import { useState, type FormEvent } from "react"
import { Link, useNavigate } from "react-router-dom"

import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { AuthLayout } from "@/features/auth/components/auth-layout"
import { fetchMe, requestOtp, otpResetPassword } from "@/features/auth/api"
import { useAuthStore } from "@/features/auth/auth-store"
import { PASSWORD_HINT, PHONE_HINT, passwordSchema, phoneSchema, otpCodeSchema } from "@/features/auth/validation"

type Step = "phone" | "reset"

export function ForgotPasswordPage() {
  const navigate = useNavigate()
  const setSession = useAuthStore((s) => s.setSession)

  const [step, setStep] = useState<Step>("phone")
  const [phone, setPhone] = useState("")
  const [code, setCode] = useState("")
  const [newPassword, setNewPassword] = useState("")
  const [confirmPassword, setConfirmPassword] = useState("")
  const [debugCode, setDebugCode] = useState<string | null>(null)
  const [fieldError, setFieldError] = useState<string | null>(null)
  const [serverError, setServerError] = useState<string | null>(null)
  const [successMessage, setSuccessMessage] = useState<string | null>(null)
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
      const { debug_code } = await requestOtp({ phone_number: phone, purpose: "password_reset" })
      setDebugCode(debug_code)
      setStep("reset")
      setSuccessMessage("کد بازیابی رمز عبور برای شما ارسال شد")
    } catch (err: any) {
      if (err?.response?.status === 404) {
        setServerError("حسابی با این شماره موبایل ثبت نشده است")
      } else if (err?.response?.status === 429) {
        setServerError("تعداد درخواست‌های کد بیش از حد مجاز است؛ کمی بعد دوباره تلاش کنید.")
      } else {
        setServerError("خطایی رخ داد؛ دوباره تلاش کنید")
      }
    } finally {
      setSubmitting(false)
    }
  }

  async function onResetPassword(e: FormEvent) {
    e.preventDefault()
    setServerError(null)
    const codeResult = otpCodeSchema.safeParse(code)
    if (!codeResult.success) {
      setFieldError(codeResult.error.issues[0].message)
      return
    }
    const passwordResult = passwordSchema.safeParse(newPassword)
    if (!passwordResult.success) {
      setFieldError(passwordResult.error.issues[0].message)
      return
    }
    if (newPassword !== confirmPassword) {
      setFieldError("رمز عبور و تکرار آن یکسان نیستند")
      return
    }
    setFieldError(null)
    setSubmitting(true)
    try {
      const { access_token } = await otpResetPassword({ phone_number: phone, code, new_password: newPassword })
      useAuthStore.setState({ accessToken: access_token })
      const user = await fetchMe()
      setSession(access_token, user)
      navigate("/", { replace: true })
    } catch (err: any) {
      if (err?.response?.status === 401) {
        setServerError("کد وارد شده اشتباه یا منقضی شده است")
      } else if (err?.response?.status === 429) {
        setServerError("تعداد تلاش‌ها بیش از حد مجاز است؛ چند دقیقه دیگر دوباره امتحان کنید.")
      } else {
        setServerError("خطایی رخ داد؛ دوباره تلاش کنید")
      }
    } finally {
      setSubmitting(false)
    }
  }

  return (
    <AuthLayout>
      <Card className="w-full shadow-lg">
        <CardHeader>
          <CardTitle className="text-2xl">فراموشی رمز عبور</CardTitle>
          <CardDescription>
            {step === "phone"
              ? "شماره موبایل حساب خود را وارد کنید تا کد بازیابی برایتان ارسال شود"
              : "کد ارسال‌شده و رمز عبور جدید خود را وارد کنید"}
          </CardDescription>
        </CardHeader>
        <CardContent className="flex flex-col gap-4">
          {step === "phone" ? (
            <form onSubmit={onRequestCode} className="flex flex-col gap-4">
              <div className="flex flex-col gap-2">
                <Label htmlFor="fp-phone">شماره موبایل</Label>
                <Input
                  id="fp-phone"
                  type="tel"
                  inputMode="numeric"
                  dir="ltr"
                  autoComplete="username"
                  value={phone}
                  onChange={(e) => setPhone(e.target.value)}
                />
                <p className="text-xs text-muted-foreground">{PHONE_HINT}</p>
              </div>
              {fieldError && <p className="text-sm text-danger">{fieldError}</p>}
              {serverError && <p className="text-sm text-danger">{serverError}</p>}
              <Button type="submit" variant="accent" className="mt-1 w-full" disabled={submitting}>
                {submitting ? "در حال ارسال..." : "دریافت کد بازیابی"}
              </Button>
            </form>
          ) : (
            <form onSubmit={onResetPassword} className="flex flex-col gap-4">
              <div className="flex items-center justify-between">
                <p className="text-sm text-muted-foreground" dir="ltr">
                  {phone}
                </p>
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
              {successMessage && <p className="text-sm text-success">{successMessage}</p>}
              {debugCode && (
                <p className="rounded-md bg-muted p-2 text-xs text-muted-foreground">
                  سرویس پیامک هنوز متصل نشده — کد آزمایشی شما:{" "}
                  <span className="font-mono font-semibold" dir="ltr">
                    {debugCode}
                  </span>
                </p>
              )}
              <div className="flex flex-col gap-2">
                <Label htmlFor="fp-code">کد ۶ رقمی</Label>
                <Input
                  id="fp-code"
                  inputMode="numeric"
                  dir="ltr"
                  maxLength={6}
                  value={code}
                  onChange={(e) => setCode(e.target.value)}
                />
              </div>
              <div className="flex flex-col gap-2">
                <Label htmlFor="fp-new-password">رمز عبور جدید</Label>
                <Input
                  id="fp-new-password"
                  type="password"
                  autoComplete="new-password"
                  value={newPassword}
                  onChange={(e) => setNewPassword(e.target.value)}
                />
                <p className="text-xs text-muted-foreground">{PASSWORD_HINT}</p>
              </div>
              <div className="flex flex-col gap-2">
                <Label htmlFor="fp-confirm-password">تکرار رمز عبور جدید</Label>
                <Input
                  id="fp-confirm-password"
                  type="password"
                  autoComplete="new-password"
                  value={confirmPassword}
                  onChange={(e) => setConfirmPassword(e.target.value)}
                />
              </div>
              {fieldError && <p className="text-sm text-danger">{fieldError}</p>}
              {serverError && <p className="text-sm text-danger">{serverError}</p>}
              <Button type="submit" variant="accent" className="mt-1 w-full" disabled={submitting}>
                {submitting ? "در حال ثبت..." : "تغییر رمز عبور و ورود"}
              </Button>
            </form>
          )}

          <p className="text-center text-sm text-muted-foreground">
            <Link to="/login" className="font-medium text-primary underline-offset-4 hover:underline">
              بازگشت به صفحهٔ ورود
            </Link>
          </p>
        </CardContent>
      </Card>
    </AuthLayout>
  )
}
