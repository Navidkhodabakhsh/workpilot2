import { useState } from "react"
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query"
import { useForm } from "react-hook-form"
import { zodResolver } from "@hookform/resolvers/zod"
import { z } from "zod"
import { Pencil, Plus, Users } from "lucide-react"

import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Select } from "@/components/ui/select"
import { PageHeader } from "@/components/layout/page-header"
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table"
import { TableRowsSkeleton } from "@/components/ui/table-rows-skeleton"
import {
  createOrgUser,
  listOrgUsers,
  setUserDepartments,
  updateOrgUser,
  type DepartmentMembershipInput,
} from "@/features/users/api"
import { listDepartments } from "@/features/departments/api"
import { useDepartmentStore } from "@/features/departments/department-store"
import { useAuthStore } from "@/features/auth/auth-store"
import { PASSWORD_HINT, PHONE_HINT, passwordSchema, phoneSchema } from "@/features/auth/validation"
import { ROLE_LABEL } from "@/lib/role-labels"
import type { OrgUser, UserRole } from "@/lib/types"

const ROLE_VARIANT: Record<string, "primary" | "info" | "default"> = {
  org_admin: "primary",
  project_manager: "info",
  employee: "default",
}

const schema = z.object({
  full_name: z.string().min(2, "نام و نام خانوادگی را وارد کنید"),
  email: z.string().email("ایمیل معتبر وارد کنید"),
  phone_number: phoneSchema,
  password: z.union([z.literal(""), passwordSchema]),
  role: z.enum(["project_manager", "employee"]),
  department_id: z.string().optional(),
})
type FormValues = z.infer<typeof schema>

const editSchema = z.object({
  role: z.enum(["org_admin", "project_manager", "employee"]),
  is_active: z.enum(["true", "false"]),
  phone_number: z.union([z.literal(""), phoneSchema]),
  department_id: z.string().optional(),
})
type EditFormValues = z.infer<typeof editSchema>

export function UsersListPage() {
  const role = useAuthStore((s) => s.user?.role)
  const isOrgAdmin = role === "org_admin"
  const [open, setOpen] = useState(false)
  const [serverError, setServerError] = useState<string | null>(null)
  const queryClient = useQueryClient()

  const { data: users, isLoading } = useQuery({ queryKey: ["org-users"], queryFn: listOrgUsers })
  const { data: departments } = useQuery({ queryKey: ["departments"], queryFn: listDepartments })
  const selectedDepartmentId = useDepartmentStore((s) => s.selectedDepartmentId)

  const form = useForm<FormValues>({
    resolver: zodResolver(schema),
    defaultValues: { full_name: "", email: "", phone_number: "", password: "", role: "employee" },
  })

  const createMutation = useMutation({
    mutationFn: (values: FormValues) =>
      createOrgUser({
        full_name: values.full_name,
        email: values.email,
        phone_number: values.phone_number,
        password: values.password || undefined,
        role: values.role as UserRole,
        department_id: values.department_id || undefined,
      }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["org-users"] })
      setOpen(false)
      form.reset()
    },
    onError: (err: any) => {
      const detail = err?.response?.data?.detail
      if (err?.response?.status === 409) {
        setServerError(detail?.includes("Phone") ? "این شماره موبایل قبلاً ثبت شده است" : "این ایمیل قبلاً ثبت شده است")
      } else {
        setServerError("خطایی رخ داد؛ دوباره تلاش کنید")
      }
    },
  })

  const [editingUser, setEditingUser] = useState<OrgUser | null>(null)
  const [editError, setEditError] = useState<string | null>(null)
  const [editMemberships, setEditMemberships] = useState<DepartmentMembershipInput[]>([])
  const editForm = useForm<EditFormValues>({ resolver: zodResolver(editSchema) })

  const updateMutation = useMutation({
    mutationFn: async (values: EditFormValues) => {
      await updateOrgUser(editingUser!.id, {
        role: values.role,
        is_active: values.is_active === "true",
        ...(values.phone_number ? { phone_number: values.phone_number } : {}),
        ...(values.department_id ? { department_id: values.department_id } : {}),
      })
      // Only project_manager/employee have department memberships -- an
      // org_admin edit skips this call (the backend would reject it anyway).
      if (values.role !== "org_admin") {
        await setUserDepartments(editingUser!.id, editMemberships)
      }
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["org-users"] })
      setEditingUser(null)
    },
    onError: (err: any) => {
      const detail = err?.response?.data?.detail
      setEditError(
        err?.response?.status === 409 && typeof detail === "string" && detail.includes("Phone")
          ? "این شماره موبایل قبلاً ثبت شده است"
          : (detail ?? "خطایی رخ داد؛ دوباره تلاش کنید")
      )
    },
  })

  function openEdit(u: OrgUser) {
    setEditError(null)
    setEditingUser(u)
    setEditMemberships(u.department_memberships.map((m) => ({ department_id: m.department_id, role: m.role as "project_manager" | "employee" })))
    // Org-scoped users are never platform_admin (that role has no organization),
    // so this narrowing always holds in practice.
    editForm.reset({
      role: u.role as "org_admin" | "project_manager" | "employee",
      is_active: u.is_active ? "true" : "false",
      phone_number: u.phone_number ?? "",
      department_id: u.department_id ?? "",
    })
  }

  return (
    <div className="flex flex-col gap-4">
      <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
        <PageHeader icon={Users} tone="success" title="کاربران" description="اعضای سازمان شما" />
        {isOrgAdmin && (
          <Dialog
            open={open}
            onOpenChange={(v) => {
              setOpen(v)
              setServerError(null)
            }}
          >
            <DialogTrigger asChild>
              <Button>
                <Plus className="size-4" />
                کاربر جدید
              </Button>
            </DialogTrigger>
            <DialogContent>
              <DialogHeader>
                <DialogTitle>افزودن کاربر جدید</DialogTitle>
                <DialogDescription>یک عضو تازه با نقش دلخواه به سازمان اضافه کنید</DialogDescription>
              </DialogHeader>
              <form
                onSubmit={form.handleSubmit((values) => createMutation.mutate(values))}
                className="flex flex-col gap-4"
              >
                <div className="flex flex-col gap-2">
                  <Label htmlFor="full_name">نام و نام خانوادگی</Label>
                  <Input id="full_name" {...form.register("full_name")} />
                  {form.formState.errors.full_name && (
                    <p className="text-sm text-danger">{form.formState.errors.full_name.message}</p>
                  )}
                </div>
                <div className="flex flex-col gap-2">
                  <Label htmlFor="email">ایمیل</Label>
                  <Input id="email" type="email" {...form.register("email")} />
                  {form.formState.errors.email && (
                    <p className="text-sm text-danger">{form.formState.errors.email.message}</p>
                  )}
                </div>
                <div className="flex flex-col gap-2">
                  <Label htmlFor="phone_number">شماره موبایل</Label>
                  <Input id="phone_number" type="tel" dir="ltr" {...form.register("phone_number")} />
                  {form.formState.errors.phone_number ? (
                    <p className="text-sm text-danger">{form.formState.errors.phone_number.message}</p>
                  ) : (
                    <p className="text-xs text-muted-foreground">{PHONE_HINT}</p>
                  )}
                </div>
                <div className="flex flex-col gap-2">
                  <Label htmlFor="password">رمز عبور (اختیاری)</Label>
                  <Input id="password" type="password" {...form.register("password")} />
                  {form.formState.errors.password ? (
                    <p className="text-sm text-danger">{form.formState.errors.password.message}</p>
                  ) : (
                    <p className="text-xs text-muted-foreground">
                      اگر خالی بگذارید، کاربر با کد یکبار مصرف پیامکی وارد شده و در اولین ورود رمز خود را تعیین می‌کند. {PASSWORD_HINT}
                    </p>
                  )}
                </div>
                <div className="flex flex-col gap-2">
                  <Label htmlFor="role">نقش</Label>
                  <Select id="role" {...form.register("role")}>
                    <option value="employee">کارمند</option>
                    <option value="project_manager">مدیر پروژه</option>
                  </Select>
                </div>
                {departments && departments.length > 0 && (
                  <div className="flex flex-col gap-2">
                    <Label htmlFor="department_id">دپارتمان (اختیاری)</Label>
                    <Select id="department_id" {...form.register("department_id")}>
                      <option value="">بدون دپارتمان مشخص</option>
                      {departments.map((d) => (
                        <option key={d.id} value={d.id}>
                          {d.name}
                        </option>
                      ))}
                    </Select>
                  </div>
                )}
                {serverError && <p className="text-sm text-danger">{serverError}</p>}
                <Button type="submit" disabled={createMutation.isPending}>
                  {createMutation.isPending ? "در حال ایجاد..." : "افزودن کاربر"}
                </Button>
              </form>
            </DialogContent>
          </Dialog>
        )}
      </div>

      {(isLoading || users) && (
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>نام</TableHead>
              <TableHead>ایمیل</TableHead>
              <TableHead>شماره موبایل</TableHead>
              <TableHead>نقش</TableHead>
              <TableHead>وضعیت</TableHead>
              {isOrgAdmin && <TableHead className="w-0" />}
            </TableRow>
          </TableHeader>
          <TableBody>
            {isLoading && <TableRowsSkeleton columns={isOrgAdmin ? 6 : 5} />}
            {!isLoading && users
              ?.filter((u) => !selectedDepartmentId || u.department_id === selectedDepartmentId)
              .map((u) => (
              <TableRow key={u.id}>
                <TableCell className="font-medium">{u.full_name}</TableCell>
                <TableCell>{u.email}</TableCell>
                <TableCell dir="ltr" className="text-start">
                  {u.phone_number ?? "—"}
                </TableCell>
                <TableCell>
                  <Badge variant={ROLE_VARIANT[u.role] ?? "default"}>{ROLE_LABEL[u.role] ?? u.role}</Badge>
                </TableCell>
                <TableCell>
                  <Badge variant={u.is_active ? "success" : "default"}>
                    {u.is_active ? "فعال" : "غیرفعال"}
                  </Badge>
                </TableCell>
                {isOrgAdmin && (
                  <TableCell>
                    <Button variant="ghost" size="icon" aria-label="ویرایش کاربر" onClick={() => openEdit(u)}>
                      <Pencil className="size-4" />
                    </Button>
                  </TableCell>
                )}
              </TableRow>
            ))}
          </TableBody>
        </Table>
      )}

      <Dialog open={editingUser !== null} onOpenChange={(v) => !v && setEditingUser(null)}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>ویرایش کاربر</DialogTitle>
            <DialogDescription>{editingUser?.full_name}</DialogDescription>
          </DialogHeader>
          <form
            onSubmit={editForm.handleSubmit((values) => updateMutation.mutate(values))}
            className="flex flex-col gap-4"
          >
            <div className="flex flex-col gap-2">
              <Label htmlFor="edit-role">نقش</Label>
              <Select id="edit-role" {...editForm.register("role")}>
                <option value="employee">کارمند</option>
                <option value="project_manager">مدیر پروژه</option>
                <option value="org_admin">مدیر سازمان</option>
              </Select>
            </div>
            <div className="flex flex-col gap-2">
              <Label htmlFor="edit-active">وضعیت</Label>
              <Select id="edit-active" {...editForm.register("is_active")}>
                <option value="true">فعال</option>
                <option value="false">غیرفعال</option>
              </Select>
            </div>
            <div className="flex flex-col gap-2">
              <Label htmlFor="edit-phone">شماره موبایل</Label>
              <Input id="edit-phone" type="tel" dir="ltr" {...editForm.register("phone_number")} />
              {editForm.formState.errors.phone_number ? (
                <p className="text-sm text-danger">{editForm.formState.errors.phone_number.message}</p>
              ) : (
                <p className="text-xs text-muted-foreground">
                  {editingUser?.has_password ? "این کاربر رمز عبور تعیین کرده است" : "این کاربر هنوز رمز عبوری تعیین نکرده و با کد یکبار مصرف وارد می‌شود"}
                </p>
              )}
            </div>
            {departments && departments.length > 0 && (
              <div className="flex flex-col gap-2">
                <Label htmlFor="edit-department">دپارتمان</Label>
                <Select id="edit-department" {...editForm.register("department_id")}>
                  <option value="">بدون دپارتمان مشخص</option>
                  {departments.map((d) => (
                    <option key={d.id} value={d.id}>
                      {d.name}
                    </option>
                  ))}
                </Select>
              </div>
            )}
            {departments && departments.length > 0 && editForm.watch("role") !== "org_admin" && (
              <div className="flex flex-col gap-2">
                <Label>عضویت در دپارتمان‌های دیگر (اختیاری)</Label>
                <p className="text-xs text-muted-foreground">
                  علاوه بر دپارتمان اصلی بالا، این کاربر می‌تواند در دپارتمان‌های دیگر هم عضو باشد -- با نقشی
                  مستقل در هرکدام. اگر بیش از یکی انتخاب شود، خودِ کاربر می‌تواند بین آن‌ها جابه‌جا شود.
                </p>
                <div className="flex max-h-48 flex-col gap-2 overflow-y-auto rounded-md border p-2">
                  {departments.map((d) => {
                    const current = editMemberships.find((m) => m.department_id === d.id)
                    return (
                      <div key={d.id} className="flex items-center gap-2">
                        <label className="flex flex-1 items-center gap-2 text-sm">
                          <input
                            type="checkbox"
                            checked={!!current}
                            onChange={(e) => {
                              if (e.target.checked) {
                                setEditMemberships((prev) => [...prev, { department_id: d.id, role: "employee" }])
                              } else {
                                setEditMemberships((prev) => prev.filter((m) => m.department_id !== d.id))
                              }
                            }}
                          />
                          {d.name}
                        </label>
                        {current && (
                          <Select
                            aria-label={`نقش در ${d.name}`}
                            className="h-8 w-32"
                            value={current.role}
                            onChange={(e) =>
                              setEditMemberships((prev) =>
                                prev.map((m) =>
                                  m.department_id === d.id
                                    ? { ...m, role: e.target.value as "project_manager" | "employee" }
                                    : m
                                )
                              )
                            }
                          >
                            <option value="employee">کارمند</option>
                            <option value="project_manager">مدیر پروژه</option>
                          </Select>
                        )}
                      </div>
                    )
                  })}
                </div>
              </div>
            )}
            {editError && <p className="text-sm text-danger">{editError}</p>}
            <Button type="submit" disabled={updateMutation.isPending}>
              {updateMutation.isPending ? "در حال ذخیره..." : "ذخیرهٔ تغییرات"}
            </Button>
          </form>
        </DialogContent>
      </Dialog>
    </div>
  )
}
