import { useState } from "react"
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query"
import { useForm } from "react-hook-form"
import { zodResolver } from "@hookform/resolvers/zod"
import { z } from "zod"
import { Plus, Trash2, Wallet } from "lucide-react"

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
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { createPayment, deletePayment, listPayments } from "@/features/payments/api"

const schema = z.object({
  payment_date: z.string().min(1, "تاریخ پرداخت را وارد کنید"),
  description: z.string().min(1, "شرح پرداخت را وارد کنید"),
  amount: z
    .string()
    .min(1, "مبلغ را وارد کنید")
    .refine((v) => Number(v) > 0, "مبلغ باید بزرگ‌تر از صفر باشد"),
})
type FormValues = z.infer<typeof schema>

function formatAmount(amount: string) {
  return `${Number(amount).toLocaleString("fa-IR")} تومان`
}

export function PaymentsSection({ projectId }: { projectId: string }) {
  const [open, setOpen] = useState(false)
  const queryClient = useQueryClient()

  const { data: payments, isLoading } = useQuery({
    queryKey: ["payments", projectId],
    queryFn: () => listPayments(projectId),
  })

  const form = useForm<FormValues>({
    resolver: zodResolver(schema),
    defaultValues: { payment_date: "", description: "", amount: "" },
  })

  const createMutation = useMutation({
    mutationFn: (values: FormValues) => createPayment(projectId, values),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["payments", projectId] })
      setOpen(false)
      form.reset()
    },
  })

  const deleteMutation = useMutation({
    mutationFn: (paymentId: string) => deletePayment(projectId, paymentId),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ["payments", projectId] }),
  })

  const total = (payments ?? []).reduce((sum, p) => sum + Number(p.amount), 0)

  return (
    <Card className="overflow-hidden border-primary/15 bg-gradient-to-br from-primary/[0.04] to-transparent">
      <CardHeader className="flex flex-row items-center justify-between gap-3 space-y-0">
        <div className="flex items-center gap-3">
          <div className="flex size-10 shrink-0 items-center justify-center rounded-xl bg-primary/10 text-primary">
            <Wallet className="size-5" />
          </div>
          <div>
            <CardTitle className="text-base">لیست پرداخت‌ها</CardTitle>
            <p className="text-sm text-muted-foreground">
              مجموع: <span className="font-semibold text-foreground">{total.toLocaleString("fa-IR")} تومان</span>
            </p>
          </div>
        </div>
        <Dialog open={open} onOpenChange={setOpen}>
          <DialogTrigger asChild>
            <Button size="sm">
              <Plus className="size-4" />
              افزودن پرداخت
            </Button>
          </DialogTrigger>
          <DialogContent>
            <DialogHeader>
              <DialogTitle>ثبت پرداخت جدید</DialogTitle>
              <DialogDescription>تاریخ، شرح و مبلغ پرداخت را وارد کنید</DialogDescription>
            </DialogHeader>
            <form
              onSubmit={form.handleSubmit((values) => createMutation.mutate(values))}
              className="flex flex-col gap-4"
            >
              <div className="flex flex-col gap-2">
                <Label htmlFor="payment_date">تاریخ</Label>
                <Input id="payment_date" type="date" {...form.register("payment_date")} />
                {form.formState.errors.payment_date && (
                  <p className="text-sm text-danger">{form.formState.errors.payment_date.message}</p>
                )}
              </div>
              <div className="flex flex-col gap-2">
                <Label htmlFor="description">شرح</Label>
                <Input id="description" {...form.register("description")} />
                {form.formState.errors.description && (
                  <p className="text-sm text-danger">{form.formState.errors.description.message}</p>
                )}
              </div>
              <div className="flex flex-col gap-2">
                <Label htmlFor="amount">مبلغ (تومان)</Label>
                <Input id="amount" type="number" step="0.01" {...form.register("amount")} />
                {form.formState.errors.amount && (
                  <p className="text-sm text-danger">{form.formState.errors.amount.message}</p>
                )}
              </div>
              <Button type="submit" disabled={createMutation.isPending}>
                {createMutation.isPending ? "در حال ثبت..." : "ثبت پرداخت"}
              </Button>
            </form>
          </DialogContent>
        </Dialog>
      </CardHeader>
      <CardContent>
        {isLoading && <p className="text-sm text-muted-foreground">در حال بارگذاری...</p>}
        {!isLoading && (!payments || payments.length === 0) && (
          <EmptyState icon={Wallet} message="هنوز پرداختی برای این پروژه ثبت نشده است." />
        )}
        {!isLoading && payments && payments.length > 0 && (
          <div className="flex flex-col divide-y divide-border/70 overflow-hidden rounded-lg border border-border/70">
            {payments.map((p) => (
              <div key={p.id} className="flex items-center justify-between gap-3 bg-card px-4 py-3">
                <div className="flex flex-col gap-0.5">
                  <span className="font-medium">{p.description}</span>
                  <span className="text-xs text-muted-foreground">
                    {new Date(p.payment_date).toLocaleDateString("fa-IR")}
                  </span>
                </div>
                <div className="flex items-center gap-3">
                  <span className="font-semibold text-success">{formatAmount(p.amount)}</span>
                  <button
                    type="button"
                    aria-label="حذف پرداخت"
                    onClick={() => deleteMutation.mutate(p.id)}
                    className="rounded-full p-1.5 text-muted-foreground hover:bg-danger/10 hover:text-danger"
                  >
                    <Trash2 className="size-4" />
                  </button>
                </div>
              </div>
            ))}
          </div>
        )}
      </CardContent>
    </Card>
  )
}
