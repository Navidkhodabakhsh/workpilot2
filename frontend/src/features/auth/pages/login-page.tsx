import { useState, type FormEvent } from "react"
import { Link, useNavigate } from "react-router-dom"
import { KeyRound, MessageSquareText } from "lucide-react"

import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { AuthLayout } from "@/features/auth/components/auth-layout"
import { login, fetchMe, requestOtp, otpLogin } from "@/features/auth/api"
import { useAuthStore } from "@/features/auth/auth-store"
import { PASSWORD_HINT, PHONE_HINT, passwordSchema, phoneSchema, otpCodeSchema } from "@/features/auth/validation"

type Mode = "password" | "otp"
type OtpStep = "phone" | "code"

const RATE_LIMIT_MESSAGE = "تعداد تلاش‌های ورود بیش از حد مجاز است؛ چند دقیقه دیگر دوباره امتحان کنید."
const NETWORK_ERROR_MESSAGE = "اتصال به سرور برقرار نشد. مطمئن شوید سرور در حال اجراست و آدرسش درست تنظیم شده."
const POST_LOGIN_ERROR_MESSAGE = "ورود موفق بود ولی دریافت اطلاعات کاربر با خطا مواجه شد؛ دوباره تلاش کنید."

export function LoginPage() {
  const navigate = useNavigate()
  const setSession = useAuthStore((s) => s.setSession)
  const [mode, setMode] = useState<Mode>("password")

  return (
    <AuthLayout>
      <Card className="w-full rounded-2xl border-border/60 py-7 shadow-xl">
        <CardHeader>
          <CardTitle className="text-2xl">ورود به Tadvin</CardTitle>
          <CardDescription>
            {mode === "password"
              ? "شماره موبایل و رمز عبور خود را وارد کنید"
              : "شماره موبایل خود را وارد کنید تا کد ورود برایتان ارسال شود"}
          </CardDescription>
        </CardHeader>
        <CardContent className="flex flex-col gap-4">
          <div className="grid grid-cols-2 gap-1 rounded-lg bg-muted p-1">
            <button
              type="button"
              onClick={() => setMode("password")}
              className={`flex items-center justify-center gap-1.5 rounded-md py-1.5 text-sm font-medium transition-all duration-200 ${
                mode === "password" ? "bg-card text-foreground shadow-sm" : "text-muted-foreground hover:text-foreground"
              }`}
            >
              <KeyRound className="size-3.5" aria-hidden="true" />
              ورود با رمز عبور
            </button>
            <button
              type="button"
              onClick={() => setMode("otp")}
              className={`flex items-center justify-center gap-1.5 rounded-md py-1.5 text-sm font-medium transition-all duration-200 ${
                mode === "otp" ? "bg-card text-foreground shadow-sm" : "text-muted-foreground hover:text-foreground"
              }`}
            >
              <MessageSquareText className="size-3.5" aria-hidden="true" />
              ورود با کد یکبار مصرف
            </button>
          </div>

          {mode === "password" ? (
            <PasswordLoginForm
              onSuccess={async (accessToken) => {
                useAuthStore.setState({ accessToken })
                const user = await fetchMe()
                setSession(accessToken, user)
                navigate("/", { replace: true })
              }}
            />
          ) : (
            <OtpLoginForm
              onSuccess={async (accessToken) => {
                useAuthStore.setState({ accessToken })
                const user = await fetchMe()
                setSession(accessToken, user)
                navigate("/", { replace: true })
              }}
            />
          )}

          <p className="text-center text-sm text-muted-foreground">
            <Link to="/forgot-password" className="font-medium text-primary underline-offset-4 hover:underline">
              رمز عبور خود را فراموش کرده‌اید؟
            </Link>
          </p>
          <p className="text-center text-sm text-muted-foreground">
            سازمان جدید دارید؟{" "}
            <Link to="/signup" className="font-medium text-primary underline-offset-4 hover:underline">
              ثبت‌نام
            </Link>
          </p>
        </CardContent>
      </Card>
    </AuthLayout>
  )
}

function PasswordLoginForm({ onSuccess }: { onSuccess: (accessToken: string) => Promise<void> }) {
  const [phone, setPhone] = useState("")
  const [password, setPassword] = useState("")
  const [fieldError, setFieldError] = useState<string | null>(null)
  const [serverError, setServerError] = useState<string | null>(null)
  const [submitting, setSubmitting] = useState(false)

  async function onSubmit(e: FormEvent) {
    e.preventDefault()
    setServerError(null)
    const phoneResult = phoneSchema.safeParse(phone)
    if (!phoneResult.success) {
      setFieldError(phoneResult.error.issues[0].message)
      return
    }
    if (password.length < 8) {
      setFieldError("رمز عبور باید حداقل ۸ کاراکتر باشد")
      return
    }
    setFieldError(null)
    setSubmitting(true)
    let accessToken: string
    try {
      accessToken = (await login({ identifier: phone, password })).access_token
    } catch (err: any) {
      if (err?.response?.status === 429) {
        setServerError(RATE_LIMIT_MESSAGE)
      } else if (!err?.response) {
        setServerError(NETWORK_ERROR_MESSAGE)
      } else {
        setServerError("شماره موبایل یا رمز عبور اشتباه است")
      }
      setSubmitting(false)
      return
    }
    // Credentials were accepted -- a failure past this point (e.g.
    // fetching the profile) is not a wrong-password case, so it gets its
    // own distinct message instead of falling into the block above.
    try {
      await onSuccess(accessToken)
    } catch {
      setServerError(POST_LOGIN_ERROR_MESSAGE)
      setSubmitting(false)
    }
  }

  return (
    <form onSubmit={onSubmit} className="flex flex-col gap-4">
      <div className="flex flex-col gap-2">
        <Label htmlFor="phone">شماره موبایل</Label>
        <Input
          id="phone"
          type="tel"
          inputMode="numeric"
          autoComplete="username"
          dir="ltr"
          value={phone}
          onChange={(e) => setPhone(e.target.value)}
        />
      </div>
      <div className="flex flex-col gap-2">
        <Label htmlFor="password">رمز عبور</Label>
        <Input
          id="password"
          type="password"
          autoComplete="current-password"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
        />
      </div>
      {fieldError && <p className="text-sm text-danger">{fieldError}</p>}
      {serverError && <p className="text-sm text-danger">{serverError}</p>}
      <Button type="submit" variant="accent" className="mt-1 w-full" disabled={submitting}>
        {submitting ? "در حال ورود..." : "ورود"}
      </Button>
    </form>
  )
}

function OtpLoginForm({ onSuccess }: { onSuccess: (accessToken: string) => Promise<void> }) {
  const [step, setStep] = useState<OtpStep>("phone")
  const [phone, setPhone] = useState("")
  const [code, setCode] = useState("")
  const [newPassword, setNewPassword] = useState("")
  const [debugCode, setDebugCode] = useState<string | null>(null)
  const [fieldError, setFieldError] = useState<string | null>(null)
  const [serverError, setServerError] = useState<string | null>(null)
  const [infoMessage, setInfoMessage] = useState<string | null>(null)
  const [submitting, setSubmitting] = useState(false)

  async function requestCode() {
    setServerError(null)
    const phoneResult = phoneSchema.safeParse(phone)
    if (!phoneResult.success) {
      setFieldError(phoneResult.error.issues[0].message)
      return
    }
    setFieldError(null)
    setSubmitting(true)
    try {
      const { debug_code } = await requestOtp({ phone_number: phone, purpose: "login" })
      setDebugCode(debug_code)
      setStep("code")
      setInfoMessage("کد ورود برای شما ارسال شد")
    } catch (err: any) {
      if (err?.response?.status === 404) {
        setServerError("حسابی با این شماره موبایل ثبت نشده است")
      } else if (err?.response?.status === 429) {
        setServerError("تعداد درخواست‌های کد بیش از حد مجاز است؛ کمی بعد دوباره تلاش کنید.")
      } else if (!err?.response) {
        setServerError(NETWORK_ERROR_MESSAGE)
      } else {
        setServerError("خطایی رخ داد؛ دوباره تلاش کنید")
      }
    } finally {
      setSubmitting(false)
    }
  }

  async function onSubmitCode(e: FormEvent) {
    e.preventDefault()
    setServerError(null)
    const codeResult = otpCodeSchema.safeParse(code)
    if (!codeResult.success) {
      setFieldError(codeResult.error.issues[0].message)
      return
    }
    if (newPassword && !passwordSchema.safeParse(newPassword).success) {
      setFieldError(passwordSchema.safeParse(newPassword).error!.issues[0].message)
      return
    }
    setFieldError(null)
    setSubmitting(true)
    let accessToken: string
    try {
      accessToken = (
        await otpLogin({
          phone_number: phone,
          code,
          new_password: newPassword || undefined,
        })
      ).access_token
    } catch (err: any) {
      const detail = err?.response?.data?.detail
      if (detail === "password_setup_required") {
        setServerError(
          "برای اولین ورود باید رمز عبور تعیین کنید. چون این کد مصرف شد، لطفاً کد جدیدی درخواست کنید و همراه رمز عبور جدید ارسال کنید."
        )
        setStep("phone")
        setCode("")
      } else if (err?.response?.status === 401) {
        setServerError("کد وارد شده اشتباه یا منقضی شده است")
      } else if (err?.response?.status === 429) {
        setServerError(RATE_LIMIT_MESSAGE)
      } else if (!err?.response) {
        setServerError(NETWORK_ERROR_MESSAGE)
      } else {
        setServerError("خطایی رخ داد؛ دوباره تلاش کنید")
      }
      setSubmitting(false)
      return
    }
    try {
      await onSuccess(accessToken)
    } catch {
      setServerError(POST_LOGIN_ERROR_MESSAGE)
      setSubmitting(false)
    }
  }

  if (step === "phone") {
    return (
      <div className="flex flex-col gap-4">
        <div className="flex flex-col gap-2">
          <Label htmlFor="otp-phone">شماره موبایل</Label>
          <Input
            id="otp-phone"
            type="tel"
            inputMode="numeric"
            autoComplete="username"
            dir="ltr"
            value={phone}
            onChange={(e) => setPhone(e.target.value)}
          />
          <p className="text-xs text-muted-foreground">{PHONE_HINT}</p>
        </div>
        {fieldError && <p className="text-sm text-danger">{fieldError}</p>}
        {serverError && <p className="text-sm text-danger">{serverError}</p>}
        <Button type="button" variant="accent" className="mt-1 w-full" disabled={submitting} onClick={requestCode}>
          {submitting ? "در حال ارسال..." : "دریافت کد ورود"}
        </Button>
      </div>
    )
  }

  return (
    <form onSubmit={onSubmitCode} className="flex flex-col gap-4">
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
      {infoMessage && <p className="text-sm text-success">{infoMessage}</p>}
      {debugCode && (
        <p className="rounded-md bg-muted p-2 text-xs text-muted-foreground">
          سرویس پیامک هنوز متصل نشده — کد آزمایشی شما: <span className="font-mono font-semibold" dir="ltr">{debugCode}</span>
        </p>
      )}
      <div className="flex flex-col gap-2">
        <Label htmlFor="otp-code">کد ۶ رقمی</Label>
        <Input
          id="otp-code"
          inputMode="numeric"
          dir="ltr"
          maxLength={6}
          value={code}
          onChange={(e) => setCode(e.target.value)}
        />
      </div>
      <div className="flex flex-col gap-2">
        <Label htmlFor="otp-new-password">رمز عبور جدید (در صورت اولین ورود)</Label>
        <Input
          id="otp-new-password"
          type="password"
          autoComplete="new-password"
          value={newPassword}
          onChange={(e) => setNewPassword(e.target.value)}
        />
        <p className="text-xs text-muted-foreground">
          اگر برای اولین‌بار وارد می‌شوید، رمز عبور دلخواه خود را اینجا وارد کنید. {PASSWORD_HINT}
        </p>
      </div>
      {fieldError && <p className="text-sm text-danger">{fieldError}</p>}
      {serverError && <p className="text-sm text-danger">{serverError}</p>}
      <Button type="submit" variant="accent" className="mt-1 w-full" disabled={submitting}>
        {submitting ? "در حال ورود..." : "ورود"}
      </Button>
    </form>
  )
}
