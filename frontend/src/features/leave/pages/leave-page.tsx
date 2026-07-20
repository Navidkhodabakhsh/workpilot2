import { useState } from "react"
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query"
import { Controller, useForm } from "react-hook-form"
import { zodResolver } from "@hookform/resolvers/zod"
import { z } from "zod"
import { Plane } from "lucide-react"

import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog"
import { EmptyState } from "@/components/ui/empty-state"
import { JalaliDateInput } from "@/components/ui/jalali-date-input"
import { Label } from "@/components/ui/label"
import { Skeleton } from "@/components/ui/skeleton"
import { Textarea } from "@/components/ui/textarea"
import { approveLeaveRequest, createLeaveRequest, listLeaveRequests, rejectLeaveRequest, type LeaveRequest } from "@/features/leave/api"
import { useAuthStore } from "@/features/auth/auth-store"

const schema = z
  .object({
    start_date: z.string().min(1, "تاریخ شروع را انتخاب کنید"),
    end_date: z.string().min(1, "تاریخ پایان را انتخاب کنید"),
    reason: z.string().optional(),
  })
  .refine((v) => v.end_date >= v.start_date, {
    message: "تاریخ پایان نمی‌تواند قبل از تاریخ شروع باشد",
    path: ["end_date"],
  })
type FormValues = z.infer<typeof schema>

const STATUS_LABEL: Record<string, string> = { pending: "در انتظار بررسی", approved: "تأییدشده", rejected: "ردشده" }
const STATUS_VARIANT: Record<string, "warning" | "success" | "danger"> = {
  pending: "warning",
  approved: "success",
  rejected: "danger",
}

function NewLeaveRequestDialog() {
  const [open, setOpen] = useState(false)
  const queryClient = useQueryClient()
  const form = useForm<FormValues>({
    resolver: zodResolver(schema),
    defaultValues: { start_date: "", end_date: "", reason: "" },
  })

  const mutation = useMutation({
    mutationFn: (values: FormValues) =>
      createLeaveRequest({ start_date: values.start_date, end_date: values.end_date, reason: values.reason || undefined }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["leave-requests"] })
      setOpen(false)
      form.reset()
    },
  })

  return (
    <Dialog open={open} onOpenChange={setOpen}>
      <DialogTrigger asChild>
        <Button>درخواست مرخصی جدید</Button>
      </DialogTrigger>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>درخواست مرخصی جدید</DialogTitle>
          <DialogDescription>بازهٔ مرخصی و دلیل آن را وارد کنید تا برای بررسی ارسال شود</DialogDescription>
        </DialogHeader>
        <form onSubmit={form.handleSubmit((v) => mutation.mutate(v))} className="flex flex-col gap-4">
          <div className="grid grid-cols-2 gap-4">
            <div className="flex flex-col gap-2">
              <Label htmlFor="start_date">از تاریخ</Label>
              <Controller
                control={form.control}
                name="start_date"
                render={({ field }) => <JalaliDateInput id="start_date" value={field.value} onChange={field.onChange} />}
              />
              {form.formState.errors.start_date && (
                <p className="text-sm text-danger">{form.formState.errors.start_date.message}</p>
              )}
            </div>
            <div className="flex flex-col gap-2">
              <Label htmlFor="end_date">تا تاریخ</Label>
              <Controller
                control={form.control}
                name="end_date"
                render={({ field }) => <JalaliDateInput id="end_date" value={field.value} onChange={field.onChange} />}
              />
              {form.formState.errors.end_date && (
                <p className="text-sm text-danger">{form.formState.errors.end_date.message}</p>
              )}
            </div>
          </div>
          <div className="flex flex-col gap-2">
            <Label htmlFor="reason">دلیل (اختیاری)</Label>
            <Textarea id="reason" {...form.register("reason")} />
          </div>
          <Button type="submit" disabled={mutation.isPending}>
            {mutation.isPending ? "در حال ارسال..." : "ارسال درخواست"}
          </Button>
        </form>
      </DialogContent>
    </Dialog>
  )
}

function LeaveRequestRow({ request, canReview }: { request: LeaveRequest; canReview: boolean }) {
  const queryClient = useQueryClient()
  const [rejecting, setRejecting] = useState(false)
  const [comment, setComment] = useState("")

  const invalidate = () => queryClient.invalidateQueries({ queryKey: ["leave-requests"] })
  const approveMutation = useMutation({ mutationFn: () => approveLeaveRequest(request.id), onSuccess: invalidate })
  const rejectMutation = useMutation({
    mutationFn: () => rejectLeaveRequest(request.id, comment || undefined),
    onSuccess: () => {
      invalidate()
      setRejecting(false)
      setComment("")
    },
  })

  return (
    <Card>
      <CardContent className="flex flex-col gap-3 pt-6">
        <div className="flex flex-col justify-between gap-1 sm:flex-row sm:items-start">
          <div>
            {request.user_full_name && <p className="font-medium">{request.user_full_name}</p>}
            <p className="text-sm text-muted-foreground">
              {request.start_date} تا {request.end_date}
            </p>
          </div>
          <Badge variant={STATUS_VARIANT[request.status]}>{STATUS_LABEL[request.status]}</Badge>
        </div>
        {request.reason && <p className="text-sm">{request.reason}</p>}
        {request.review_comment && (
          <p className="text-sm text-muted-foreground">توضیح بررسی‌کننده: {request.review_comment}</p>
        )}

        {canReview && request.status === "pending" && (
          <div className="flex flex-col gap-2">
            {rejecting ? (
              <>
                <Textarea
                  placeholder="دلیل رد درخواست (اختیاری)..."
                  value={comment}
                  onChange={(e) => setComment(e.target.value)}
                />
                <div className="flex gap-2">
                  <Button size="sm" variant="destructive" disabled={rejectMutation.isPending} onClick={() => rejectMutation.mutate()}>
                    ثبت رد درخواست
                  </Button>
                  <Button size="sm" variant="outline" onClick={() => setRejecting(false)}>
                    انصراف
                  </Button>
                </div>
              </>
            ) : (
              <div className="flex gap-2">
                <Button size="sm" disabled={approveMutation.isPending} onClick={() => approveMutation.mutate()}>
                  تأیید
                </Button>
                <Button size="sm" variant="destructive" onClick={() => setRejecting(true)}>
                  رد درخواست
                </Button>
              </div>
            )}
          </div>
        )}
      </CardContent>
    </Card>
  )
}

export function LeavePage() {
  const role = useAuthStore((s) => s.user?.role)
  const canReview = role === "org_admin" || role === "project_manager"

  const { data: requests, isLoading } = useQuery({ queryKey: ["leave-requests"], queryFn: listLeaveRequests })

  return (
    <div className="flex flex-col gap-4">
      <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <h1 className="text-2xl font-bold">مرخصی</h1>
          <p className="text-muted-foreground">
            {canReview ? "درخواست‌های مرخصی اعضای سازمان را بررسی کنید" : "درخواست مرخصی خود را ثبت و پیگیری کنید"}
          </p>
        </div>
        <NewLeaveRequestDialog />
      </div>

      {isLoading && (
        <div className="flex flex-col gap-3">
          {Array.from({ length: 3 }, (_, i) => (
            <Card key={i}>
              <CardContent className="flex items-center justify-between gap-3 pt-6">
                <div className="flex flex-1 flex-col gap-2">
                  <Skeleton className="h-4 w-40" />
                  <Skeleton className="h-3.5 w-56" />
                </div>
                <Skeleton className="h-5 w-16 rounded-full" />
              </CardContent>
            </Card>
          ))}
        </div>
      )}

      {!isLoading && (!requests || requests.length === 0) && (
        <Card>
          <CardHeader>
            <CardTitle className="text-base">درخواستی ثبت نشده است</CardTitle>
          </CardHeader>
          <CardContent>
            <EmptyState icon={Plane} message="هنوز هیچ درخواست مرخصی‌ای ثبت نشده است." />
          </CardContent>
        </Card>
      )}

      {requests && requests.length > 0 && (
        <div className="flex flex-col gap-3">
          {requests.map((r) => (
            <LeaveRequestRow key={r.id} request={r} canReview={canReview} />
          ))}
        </div>
      )}
    </div>
  )
}
