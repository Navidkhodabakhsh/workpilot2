import { useState } from "react"
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query"
import { useForm } from "react-hook-form"
import { zodResolver } from "@hookform/resolvers/zod"
import { z } from "zod"
import { Settings } from "lucide-react"

import { PageHeader } from "@/components/layout/page-header"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { getMyOrganization, updateMyOrganization, updateProfile, changePassword } from "@/features/settings/api"
import { createDepartment, listDepartments } from "@/features/departments/api"
import { useAuthStore } from "@/features/auth/auth-store"

const profileSchema = z.object({
  full_name: z.string().min(2, "نام و نام خانوادگی را وارد کنید"),
})
type ProfileValues = z.infer<typeof profileSchema>

const passwordSchema = z
  .object({
    current_password: z.string().min(1, "رمز فعلی را وارد کنید"),
    new_password: z.string().min(8, "رمز عبور باید حداقل ۸ کاراکتر باشد"),
    confirm_password: z.string(),
  })
  .refine((v) => v.new_password === v.confirm_password, {
    message: "رمز جدید و تکرار آن یکسان نیستند",
    path: ["confirm_password"],
  })
type PasswordValues = z.infer<typeof passwordSchema>

const orgSchema = z.object({ name: z.string().min(2, "نام سازمان را وارد کنید") })
type OrgValues = z.infer<typeof orgSchema>

const departmentSchema = z.object({ name: z.string().min(2, "نام دپارتمان را وارد کنید") })
type DepartmentValues = z.infer<typeof departmentSchema>

function ProfileSection() {
  const user = useAuthStore((s) => s.user)
  const [success, setSuccess] = useState(false)
  const form = useForm<ProfileValues>({
    resolver: zodResolver(profileSchema),
    defaultValues: { full_name: user?.full_name ?? "" },
  })

  const mutation = useMutation({
    mutationFn: (values: ProfileValues) => updateProfile(values.full_name),
    onSuccess: (updated) => {
      useAuthStore.setState({ user: updated })
      setSuccess(true)
    },
  })

  return (
    <Card>
      <CardHeader>
        <CardTitle className="text-base">پروفایل</CardTitle>
        <CardDescription>نام نمایشی شما در سیستم</CardDescription>
      </CardHeader>
      <CardContent>
        <form
          onSubmit={form.handleSubmit((values) => {
            setSuccess(false)
            mutation.mutate(values)
          })}
          className="flex flex-col gap-3 sm:max-w-sm"
        >
          <div className="flex flex-col gap-2">
            <Label htmlFor="full_name">نام و نام خانوادگی</Label>
            <Input id="full_name" {...form.register("full_name")} />
            {form.formState.errors.full_name && (
              <p className="text-sm text-danger">{form.formState.errors.full_name.message}</p>
            )}
          </div>
          {success && <p className="text-sm text-success">پروفایل با موفقیت به‌روزرسانی شد.</p>}
          <Button type="submit" disabled={mutation.isPending} className="self-start">
            {mutation.isPending ? "در حال ذخیره..." : "ذخیره"}
          </Button>
        </form>
      </CardContent>
    </Card>
  )
}

function PasswordSection() {
  const [serverError, setServerError] = useState<string | null>(null)
  const [success, setSuccess] = useState(false)
  const form = useForm<PasswordValues>({
    resolver: zodResolver(passwordSchema),
    defaultValues: { current_password: "", new_password: "", confirm_password: "" },
  })

  const mutation = useMutation({
    mutationFn: (values: PasswordValues) => changePassword(values.current_password, values.new_password),
    onSuccess: () => {
      setSuccess(true)
      setServerError(null)
      form.reset()
    },
    onError: (err: any) => {
      setSuccess(false)
      setServerError(err?.response?.status === 400 ? "رمز فعلی اشتباه است" : "خطایی رخ داد؛ دوباره تلاش کنید")
    },
  })

  return (
    <Card>
      <CardHeader>
        <CardTitle className="text-base">تغییر رمز عبور</CardTitle>
        <CardDescription>برای امنیت بیشتر، رمز عبور خود را به‌صورت دوره‌ای تغییر دهید</CardDescription>
      </CardHeader>
      <CardContent>
        <form
          onSubmit={form.handleSubmit((values) => {
            setSuccess(false)
            mutation.mutate(values)
          })}
          className="flex flex-col gap-3 sm:max-w-sm"
        >
          <div className="flex flex-col gap-2">
            <Label htmlFor="current_password">رمز فعلی</Label>
            <Input id="current_password" type="password" {...form.register("current_password")} />
            {form.formState.errors.current_password && (
              <p className="text-sm text-danger">{form.formState.errors.current_password.message}</p>
            )}
          </div>
          <div className="flex flex-col gap-2">
            <Label htmlFor="new_password">رمز جدید</Label>
            <Input id="new_password" type="password" {...form.register("new_password")} />
            {form.formState.errors.new_password && (
              <p className="text-sm text-danger">{form.formState.errors.new_password.message}</p>
            )}
          </div>
          <div className="flex flex-col gap-2">
            <Label htmlFor="confirm_password">تکرار رمز جدید</Label>
            <Input id="confirm_password" type="password" {...form.register("confirm_password")} />
            {form.formState.errors.confirm_password && (
              <p className="text-sm text-danger">{form.formState.errors.confirm_password.message}</p>
            )}
          </div>
          {serverError && <p className="text-sm text-danger">{serverError}</p>}
          {success && <p className="text-sm text-success">رمز عبور با موفقیت تغییر کرد.</p>}
          <Button type="submit" disabled={mutation.isPending} className="self-start">
            {mutation.isPending ? "در حال ذخیره..." : "تغییر رمز"}
          </Button>
        </form>
      </CardContent>
    </Card>
  )
}

function OrganizationSection() {
  const queryClient = useQueryClient()
  const [success, setSuccess] = useState(false)
  const { data: org } = useQuery({ queryKey: ["my-organization"], queryFn: getMyOrganization })

  const form = useForm<OrgValues>({
    resolver: zodResolver(orgSchema),
    values: org ? { name: org.name } : undefined,
  })

  const mutation = useMutation({
    mutationFn: (values: OrgValues) => updateMyOrganization(values.name),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["my-organization"] })
      setSuccess(true)
    },
  })

  return (
    <Card>
      <CardHeader>
        <CardTitle className="text-base">تنظیمات سازمان</CardTitle>
        <CardDescription>نام سازمان شما در سراسر سیستم</CardDescription>
      </CardHeader>
      <CardContent>
        <form
          onSubmit={form.handleSubmit((values) => {
            setSuccess(false)
            mutation.mutate(values)
          })}
          className="flex flex-col gap-3 sm:max-w-sm"
        >
          <div className="flex flex-col gap-2">
            <Label htmlFor="org_name">نام سازمان</Label>
            <Input id="org_name" {...form.register("name")} />
            {form.formState.errors.name && (
              <p className="text-sm text-danger">{form.formState.errors.name.message}</p>
            )}
          </div>
          {success && <p className="text-sm text-success">نام سازمان به‌روزرسانی شد.</p>}
          <Button type="submit" disabled={mutation.isPending} className="self-start">
            {mutation.isPending ? "در حال ذخیره..." : "ذخیره"}
          </Button>
        </form>
      </CardContent>
    </Card>
  )
}

function DepartmentsSection() {
  const queryClient = useQueryClient()
  const { data: departments } = useQuery({ queryKey: ["departments"], queryFn: listDepartments })

  const form = useForm<DepartmentValues>({ resolver: zodResolver(departmentSchema), defaultValues: { name: "" } })

  const mutation = useMutation({
    mutationFn: (values: DepartmentValues) => createDepartment(values.name),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["departments"] })
      form.reset()
    },
  })

  return (
    <Card>
      <CardHeader>
        <CardTitle className="text-base">دپارتمان‌ها</CardTitle>
        <CardDescription>
          سازمان شما را به بخش‌های جداگانه (مثل حسابداری، برنامه‌نویسی، منابع انسانی) تقسیم کنید
        </CardDescription>
      </CardHeader>
      <CardContent className="flex flex-col gap-4">
        <div className="flex flex-wrap gap-2">
          {departments?.map((d) => (
            <span key={d.id} className="rounded-full bg-muted px-3 py-1 text-sm">
              {d.name}
            </span>
          ))}
        </div>
        <form
          onSubmit={form.handleSubmit((values) => mutation.mutate(values))}
          className="flex flex-col gap-3 sm:max-w-sm"
        >
          <div className="flex flex-col gap-2">
            <Label htmlFor="department_name">افزودن دپارتمان جدید</Label>
            <Input id="department_name" placeholder="مثلاً: منابع انسانی" {...form.register("name")} />
            {form.formState.errors.name && (
              <p className="text-sm text-danger">{form.formState.errors.name.message}</p>
            )}
          </div>
          <Button type="submit" disabled={mutation.isPending} className="self-start">
            {mutation.isPending ? "در حال افزودن..." : "افزودن دپارتمان"}
          </Button>
        </form>
      </CardContent>
    </Card>
  )
}

export function SettingsPage() {
  const role = useAuthStore((s) => s.user?.role)

  return (
    <div className="flex flex-col gap-4">
      <PageHeader icon={Settings} tone="secondary" title="تنظیمات" description="مدیریت پروفایل و تنظیمات سازمان" />

      <ProfileSection />
      <PasswordSection />
      {role === "org_admin" && <OrganizationSection />}
      {role === "org_admin" && <DepartmentsSection />}
    </div>
  )
}
