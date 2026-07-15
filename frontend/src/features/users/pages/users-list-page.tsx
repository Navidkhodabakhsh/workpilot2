import { useState } from "react"
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query"
import { useForm } from "react-hook-form"
import { zodResolver } from "@hookform/resolvers/zod"
import { z } from "zod"
import { Pencil, Plus } from "lucide-react"

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
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table"
import { createOrgUser, listOrgUsers, updateOrgUser } from "@/features/users/api"
import { useAuthStore } from "@/features/auth/auth-store"
import type { OrgUser, UserRole } from "@/lib/types"

const ROLE_LABEL: Record<string, string> = {
  org_admin: "مدیر سازمان",
  project_manager: "مدیر پروژه",
  employee: "کارمند",
}
const ROLE_VARIANT: Record<string, "primary" | "info" | "default"> = {
  org_admin: "primary",
  project_manager: "info",
  employee: "default",
}

const schema = z.object({
  full_name: z.string().min(2, "نام و نام خانوادگی را وارد کنید"),
  email: z.string().email("ایمیل معتبر وارد کنید"),
  password: z.string().min(8, "رمز عبور باید حداقل ۸ کاراکتر باشد"),
  role: z.enum(["project_manager", "employee"]),
})
type FormValues = z.infer<typeof schema>

const editSchema = z.object({
  role: z.enum(["org_admin", "project_manager", "employee"]),
  is_active: z.enum(["true", "false"]),
})
type EditFormValues = z.infer<typeof editSchema>

export function UsersListPage() {
  const role = useAuthStore((s) => s.user?.role)
  const isOrgAdmin = role === "org_admin"
  const [open, setOpen] = useState(false)
  const [serverError, setServerError] = useState<string | null>(null)
  const queryClient = useQueryClient()

  const { data: users, isLoading } = useQuery({ queryKey: ["org-users"], queryFn: listOrgUsers })

  const form = useForm<FormValues>({
    resolver: zodResolver(schema),
    defaultValues: { full_name: "", email: "", password: "", role: "employee" },
  })

  const createMutation = useMutation({
    mutationFn: (values: FormValues) => createOrgUser(values as FormValues & { role: UserRole }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["org-users"] })
      setOpen(false)
      form.reset()
    },
    onError: (err: any) => {
      setServerError(err?.response?.status === 409 ? "این ایمیل قبلاً ثبت شده است" : "خطایی رخ داد؛ دوباره تلاش کنید")
    },
  })

  const [editingUser, setEditingUser] = useState<OrgUser | null>(null)
  const [editError, setEditError] = useState<string | null>(null)
  const editForm = useForm<EditFormValues>({ resolver: zodResolver(editSchema) })

  const updateMutation = useMutation({
    mutationFn: (values: EditFormValues) =>
      updateOrgUser(editingUser!.id, { role: values.role, is_active: values.is_active === "true" }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["org-users"] })
      setEditingUser(null)
    },
    onError: (err: any) => {
      setEditError(err?.response?.data?.detail ?? "خطایی رخ داد؛ دوباره تلاش کنید")
    },
  })

  function openEdit(u: OrgUser) {
    setEditError(null)
    setEditingUser(u)
    // Org-scoped users are never platform_admin (that role has no organization),
    // so this narrowing always holds in practice.
    editForm.reset({
      role: u.role as "org_admin" | "project_manager" | "employee",
      is_active: u.is_active ? "true" : "false",
    })
  }

  return (
    <div className="flex flex-col gap-4">
      <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <h1 className="text-2xl font-bold">کاربران</h1>
          <p className="text-muted-foreground">اعضای سازمان شما</p>
        </div>
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
                  <Label htmlFor="password">رمز عبور</Label>
                  <Input id="password" type="password" {...form.register("password")} />
                  {form.formState.errors.password && (
                    <p className="text-sm text-danger">{form.formState.errors.password.message}</p>
                  )}
                </div>
                <div className="flex flex-col gap-2">
                  <Label htmlFor="role">نقش</Label>
                  <Select id="role" {...form.register("role")}>
                    <option value="employee">کارمند</option>
                    <option value="project_manager">مدیر پروژه</option>
                  </Select>
                </div>
                {serverError && <p className="text-sm text-danger">{serverError}</p>}
                <Button type="submit" disabled={createMutation.isPending}>
                  {createMutation.isPending ? "در حال ایجاد..." : "افزودن کاربر"}
                </Button>
              </form>
            </DialogContent>
          </Dialog>
        )}
      </div>

      {isLoading && <p className="text-muted-foreground">در حال بارگذاری...</p>}

      {!isLoading && users && (
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>نام</TableHead>
              <TableHead>ایمیل</TableHead>
              <TableHead>نقش</TableHead>
              <TableHead>وضعیت</TableHead>
              {isOrgAdmin && <TableHead className="w-0" />}
            </TableRow>
          </TableHeader>
          <TableBody>
            {users.map((u) => (
              <TableRow key={u.id}>
                <TableCell className="font-medium">{u.full_name}</TableCell>
                <TableCell>{u.email}</TableCell>
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
