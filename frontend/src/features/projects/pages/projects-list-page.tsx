import { useState } from "react"
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query"
import { useForm } from "react-hook-form"
import { zodResolver } from "@hookform/resolvers/zod"
import { z } from "zod"
import { Link } from "react-router-dom"
import { Plus } from "lucide-react"

import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Input } from "@/components/ui/input"
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
import { listOrgUsers } from "@/features/users/api"
import { useAuthStore } from "@/features/auth/auth-store"

const schema = z.object({
  name: z.string().min(2, "نام پروژه را وارد کنید"),
  description: z.string().optional(),
  cooperation_start_date: z.string().optional(),
  start_date: z.string().optional(),
  end_date: z.string().optional(),
  manager_id: z.string().optional(),
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

  const form = useForm<FormValues>({ resolver: zodResolver(schema), defaultValues: { name: "", description: "" } })

  const createMutation = useMutation({
    mutationFn: (values: FormValues) =>
      createProject({
        ...values,
        cooperation_start_date: values.cooperation_start_date || undefined,
        start_date: values.start_date || undefined,
        end_date: values.end_date || undefined,
        manager_id: values.manager_id || undefined,
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
        <div>
          <h1 className="text-2xl font-bold">پروژه‌ها</h1>
          <p className="text-muted-foreground">فهرست پروژه‌های سازمان</p>
        </div>
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
                    <Input id="cooperation_start_date" type="date" {...form.register("cooperation_start_date")} />
                  </div>
                  <div className="flex flex-col gap-2">
                    <Label htmlFor="start_date">تاریخ شروع پروژه</Label>
                    <Input id="start_date" type="date" {...form.register("start_date")} />
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

      {isLoading && <p className="text-muted-foreground">در حال بارگذاری...</p>}

      <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
        {projects?.map((project) => (
          <Link key={project.id} to={`/projects/${project.id}`}>
            <Card className="h-full transition-shadow hover:shadow-md">
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
