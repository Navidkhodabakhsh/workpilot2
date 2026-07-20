import { useState } from "react"
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query"
import { Controller, useForm } from "react-hook-form"
import { zodResolver } from "@hookform/resolvers/zod"
import { z } from "zod"
import { Link } from "react-router-dom"
import { FolderKanban, Plus } from "lucide-react"

import { PageHeader } from "@/components/layout/page-header"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { Skeleton } from "@/components/ui/skeleton"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Input } from "@/components/ui/input"
import { JalaliDateInput } from "@/components/ui/jalali-date-input"
import { Label } from "@/components/ui/label"
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog"
import { Select } from "@/components/ui/select"
import { createProject, listProjects } from "@/features/projects/api"
import { listDepartments } from "@/features/departments/api"
import { useDepartmentStore } from "@/features/departments/department-store"
import { listOrgUsers } from "@/features/users/api"
import { useAuthStore } from "@/features/auth/auth-store"

const schema = z.object({
  name: z.string().min(2, "نام پروژه را وارد کنید"),
  description: z.string().optional(),
  cooperation_start_date: z.string().optional(),
  start_date: z.string().optional(),
  end_date: z.string().optional(),
  manager_id: z.string().optional(),
  department_id: z.string().optional(),
})
type FormValues = z.infer<typeof schema>

const STATUS_LABEL: Record<string, string> = {
  active: "فعال",
  completed: "تکمیل‌شده",
  archived: "بایگانی‌شده",
}
const STATUS_VARIANT: Record<string, "success" | "info" | "default"> = {
  active: "info",
  completed: "success",
  archived: "default",
}

export function ProjectsListPage() {
  const role = useAuthStore((s) => s.user?.role)
  const isOrgAdmin = role === "org_admin"
  const canCreate = role === "org_admin" || role === "project_manager"
  const [open, setOpen] = useState(false)
  const [selectedMemberIds, setSelectedMemberIds] = useState<string[]>([])
  const queryClient = useQueryClient()

  const { data: projects, isLoading } = useQuery({ queryKey: ["projects"], queryFn: listProjects })
  const { data: users } = useQuery({ queryKey: ["org-users"], queryFn: listOrgUsers, enabled: canCreate })
  const { data: departments } = useQuery({ queryKey: ["departments"], queryFn: listDepartments })
  const selectedDepartmentId = useDepartmentStore((s) => s.selectedDepartmentId)

  const form = useForm<FormValues>({ resolver: zodResolver(schema), defaultValues: { name: "", description: "" } })

  const createMutation = useMutation({
    mutationFn: (values: FormValues) =>
      createProject({
        ...values,
        cooperation_start_date: values.cooperation_start_date || undefined,
        start_date: values.start_date || undefined,
        end_date: values.end_date || undefined,
        manager_id: values.manager_id || undefined,
        department_id: values.department_id || undefined,
        member_ids: selectedMemberIds,
      }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["projects"] })
      setOpen(false)
      form.reset()
      setSelectedMemberIds([])
    },
  })

  function toggleMember(userId: string) {
    setSelectedMemberIds((prev) => (prev.includes(userId) ? prev.filter((id) => id !== userId) : [...prev, userId]))
  }

  return (
    <div className="flex flex-col gap-4">
      <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
        <PageHeader icon={FolderKanban} tone="primary" title="پروژه‌ها" description="فهرست پروژه‌های سازمان" />
        {canCreate && (
          <Dialog open={open} onOpenChange={setOpen}>
            <DialogTrigger asChild>
              <Button>
                <Plus className="size-4" />
                پروژه جدید
              </Button>
            </DialogTrigger>
            <DialogContent>
              <DialogHeader>
                <DialogTitle>ایجاد پروژهٔ جدید</DialogTitle>
                <DialogDescription>نام و توضیحات پروژه را وارد کنید</DialogDescription>
              </DialogHeader>
              <form
                onSubmit={form.handleSubmit((values) => createMutation.mutate(values))}
                className="flex flex-col gap-4"
              >
                <div className="flex flex-col gap-2">
                  <Label htmlFor="name">نام پروژه</Label>
                  <Input id="name" {...form.register("name")} />
                  {form.formState.errors.name && (
                    <p className="text-sm text-danger">{form.formState.errors.name.message}</p>
                  )}
                </div>
                <div className="flex flex-col gap-2">
                  <Label htmlFor="description">توضیحات (اختیاری)</Label>
                  <Input id="description" {...form.register("description")} />
                </div>
                <div className="grid grid-cols-2 gap-3">
                  <div className="flex flex-col gap-2">
                    <Label htmlFor="cooperation_start_date">تاریخ شروع همکاری</Label>
                    <Controller
                      control={form.control}
                      name="cooperation_start_date"
                      render={({ field }) => (
                        <JalaliDateInput id="cooperation_start_date" value={field.value ?? ""} onChange={field.onChange} />
                      )}
                    />
                  </div>
                  <div className="flex flex-col gap-2">
                    <Label htmlFor="start_date">تاریخ شروع پروژه</Label>
                    <Controller
                      control={form.control}
                      name="start_date"
                      render={({ field }) => <JalaliDateInput id="start_date" value={field.value ?? ""} onChange={field.onChange} />}
                    />
                  </div>
                </div>
                {isOrgAdmin && (
                  <div className="flex flex-col gap-2">
                    <Label htmlFor="manager_id">مدیر پروژه (اختیاری)</Label>
                    <Select id="manager_id" {...form.register("manager_id")}>
                      <option value="">بدون مدیر مشخص</option>
                      {users
                        ?.filter((u) => u.role === "org_admin" || u.role === "project_manager")
                        .map((u) => (
                          <option key={u.id} value={u.id}>
                            {u.full_name}
                          </option>
                        ))}
                    </Select>
                  </div>
                )}
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
                {users && users.length > 0 && (
                  <div className="flex flex-col gap-2">
                    <Label>اعضای پروژه (اختیاری)</Label>
                    <div className="flex max-h-40 flex-col gap-1.5 overflow-y-auto rounded-md border p-2">
                      {users.map((u) => (
                        <label key={u.id} className="flex items-center gap-2 text-sm">
                          <input
                            type="checkbox"
                            checked={selectedMemberIds.includes(u.id)}
                            onChange={() => toggleMember(u.id)}
                          />
                          {u.full_name}
                        </label>
                      ))}
                    </div>
                  </div>
                )}
                <Button type="submit" disabled={createMutation.isPending}>
                  {createMutation.isPending ? "در حال ایجاد..." : "ایجاد پروژه"}
                </Button>
              </form>
            </DialogContent>
          </Dialog>
        )}
      </div>

      {isLoading && (
        <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
          {Array.from({ length: 6 }, (_, i) => (
            <Card key={i}>
              <CardHeader>
                <Skeleton className="h-5 w-2/3" />
              </CardHeader>
              <CardContent className="flex flex-col gap-2">
                <Skeleton className="h-3.5 w-full" />
                <Skeleton className="h-3.5 w-4/5" />
                <Skeleton className="mt-1 h-5 w-16 rounded-full" />
              </CardContent>
            </Card>
          ))}
        </div>
      )}

      <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
        {!isLoading && projects
          ?.filter((p) => !selectedDepartmentId || p.department_id === selectedDepartmentId)
          .map((project) => (
          <Link key={project.id} to={`/projects/${project.id}`}>
            <Card className="h-full transition-all duration-200 hover:-translate-y-0.5 hover:shadow-md">
              <CardHeader>
                <CardTitle className="text-base">{project.name}</CardTitle>
              </CardHeader>
              <CardContent>
                <p className="line-clamp-2 text-sm text-muted-foreground">
                  {project.description || "بدون توضیحات"}
                </p>
                <Badge variant={STATUS_VARIANT[project.status] ?? "default"} className="mt-3">
                  {STATUS_LABEL[project.status] ?? project.status}
                </Badge>
              </CardContent>
            </Card>
          </Link>
        ))}
        {projects?.length === 0 && (
          <p className="text-muted-foreground">هنوز پروژه‌ای ایجاد نشده است.</p>
        )}
      </div>
    </div>
  )
}
