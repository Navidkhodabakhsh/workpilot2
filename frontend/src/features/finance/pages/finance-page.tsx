import { useEffect, useRef, useState } from "react"
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query"
import { Controller, useForm } from "react-hook-form"
import { zodResolver } from "@hookform/resolvers/zod"
import { z } from "zod"
import { ArrowDown, ArrowDownLeft, ArrowUp, ArrowUpDown, ArrowUpRight, Landmark, Paperclip, Plus, Tags, Trash2, Upload, WalletCards } from "lucide-react"

import { PageHeader } from "@/components/layout/page-header"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { ConfirmDialog } from "@/components/ui/confirm-dialog"
import { CurrencyInput } from "@/components/ui/currency-input"
import { Dialog, DialogContent, DialogDescription, DialogHeader, DialogTitle, DialogTrigger } from "@/components/ui/dialog"
import { EmptyState } from "@/components/ui/empty-state"
import { Input } from "@/components/ui/input"
import { JalaliDateInput } from "@/components/ui/jalali-date-input"
import { Label } from "@/components/ui/label"
import { Select } from "@/components/ui/select"
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table"
import { Textarea } from "@/components/ui/textarea"
import { downloadAttachment, deleteAttachment, formatFileSize, listFinanceEntryAttachments, uploadFinanceEntryAttachment } from "@/features/attachments/api"
import { createFinanceCategory, createFinanceEntry, deleteFinanceEntry, getFinanceSummary, listFinanceCategories, listFinanceEntries } from "@/features/finance/api"
import type { FinanceEntrySort, FinanceEntryType, SortOrder } from "@/features/finance/api"
import { listProjects } from "@/features/projects/api"

const entrySchema = z.object({ entry_type: z.enum(["income", "expense"]), category_id: z.string().min(1, "گروه را انتخاب کنید"), project_id: z.string().optional(), document_date: z.string().min(1, "تاریخ را وارد کنید"), amount: z.string().refine((value) => Number(value) > 0, "مبلغ باید بیشتر از صفر باشد"), title: z.string().min(2, "عنوان سند را وارد کنید"), description: z.string().optional(), document_number: z.string().optional(), counterparty: z.string().optional() })
type EntryForm = z.infer<typeof entrySchema>
const money = (value: string | number) => `${Number(value).toLocaleString("fa-IR")} تومان`

function DocumentDialog() {
  const [open, setOpen] = useState(false)
  const queryClient = useQueryClient()
  const { data: categories } = useQuery({ queryKey: ["finance-categories"], queryFn: listFinanceCategories })
  const { data: projects } = useQuery({ queryKey: ["projects"], queryFn: listProjects })
  const form = useForm<EntryForm>({ resolver: zodResolver(entrySchema), defaultValues: { entry_type: "expense", category_id: "", project_id: "", document_date: new Date().toISOString().slice(0, 10), amount: "", title: "", description: "", document_number: "", counterparty: "" } })
  const entryType = form.watch("entry_type")
  useEffect(() => { form.setValue("category_id", "") }, [entryType, form])
  const mutation = useMutation({ mutationFn: (values: EntryForm) => createFinanceEntry({ ...values, project_id: values.project_id || undefined, description: values.description || undefined, document_number: values.document_number || undefined, counterparty: values.counterparty || undefined }), onSuccess: () => { queryClient.invalidateQueries({ queryKey: ["finance"] }); queryClient.invalidateQueries({ queryKey: ["finance-summary"] }); setOpen(false); form.reset() } })
  return <Dialog open={open} onOpenChange={setOpen}><DialogTrigger asChild><Button><Plus className="size-4" />ثبت سند</Button></DialogTrigger><DialogContent className="max-h-[90vh] overflow-y-auto"><DialogHeader><DialogTitle>سند درآمد یا هزینه</DialogTitle><DialogDescription>هر رکورد مانند یک سند مالی با گروه، تاریخ، مبلغ و طرف حساب ثبت می‌شود.</DialogDescription></DialogHeader><form className="grid grid-cols-1 gap-4 sm:grid-cols-2" onSubmit={form.handleSubmit((values) => mutation.mutate(values))}><div className="flex flex-col gap-2"><Label required>نوع سند</Label><Select {...form.register("entry_type")}><option value="income">درآمد</option><option value="expense">هزینه</option></Select></div><div className="flex flex-col gap-2"><Label required>گروه</Label><Select {...form.register("category_id")}><option value="">انتخاب گروه</option>{categories?.filter((item) => item.entry_type === entryType).map((item) => <option key={item.id} value={item.id}>{item.name}</option>)}</Select>{form.formState.errors.category_id && <p className="text-xs text-danger">{form.formState.errors.category_id.message}</p>}</div><div className="flex flex-col gap-2 sm:col-span-2"><Label required>عنوان سند</Label><Input {...form.register("title")} />{form.formState.errors.title && <p className="text-xs text-danger">{form.formState.errors.title.message}</p>}</div><div className="flex flex-col gap-2"><Label required>مبلغ (تومان)</Label><Controller control={form.control} name="amount" render={({ field }) => <CurrencyInput value={field.value} onChange={field.onChange} />} />{form.formState.errors.amount && <p className="text-xs text-danger">{form.formState.errors.amount.message}</p>}</div><div className="flex flex-col gap-2"><Label required>تاریخ سند</Label><Controller control={form.control} name="document_date" render={({ field }) => <JalaliDateInput value={field.value} onChange={field.onChange} />} /></div><div className="flex flex-col gap-2"><Label>پروژه</Label><Select {...form.register("project_id")}><option value="">بدون پروژه</option>{projects?.map((project) => <option key={project.id} value={project.id}>{project.name}</option>)}</Select></div><div className="flex flex-col gap-2"><Label>طرف حساب</Label><Input {...form.register("counterparty")} /></div><div className="flex flex-col gap-2"><Label>شماره سند</Label><Input {...form.register("document_number")} /></div><div className="flex flex-col gap-2 sm:col-span-2"><Label>شرح</Label><Textarea {...form.register("description")} /></div>{mutation.isError && <p className="text-sm text-danger sm:col-span-2">ثبت سند انجام نشد.</p>}<Button type="submit" className="sm:col-span-2" disabled={mutation.isPending}>{mutation.isPending ? "در حال ثبت..." : "ثبت سند مالی"}</Button></form></DialogContent></Dialog>
}

function CategoryDialog() {
  const [open, setOpen] = useState(false)
  const [type, setType] = useState<FinanceEntryType>("expense")
  const [name, setName] = useState("")
  const [color, setColor] = useState("#64748b")
  const queryClient = useQueryClient()
  const mutation = useMutation({ mutationFn: () => createFinanceCategory({ entry_type: type, name, color }), onSuccess: () => { queryClient.invalidateQueries({ queryKey: ["finance-categories"] }); setOpen(false); setName("") } })
  return <Dialog open={open} onOpenChange={setOpen}><DialogTrigger asChild><Button variant="outline"><Tags className="size-4" />گروه جدید</Button></DialogTrigger><DialogContent><DialogHeader><DialogTitle>ساخت گروه مالی</DialogTitle><DialogDescription>گروه‌های دلخواه برای دسته‌بندی اسناد بسازید.</DialogDescription></DialogHeader><div className="flex flex-col gap-4"><div className="flex flex-col gap-2"><Label required>نوع</Label><Select value={type} onChange={(event) => setType(event.target.value as FinanceEntryType)}><option value="expense">هزینه</option><option value="income">درآمد</option></Select></div><div className="flex flex-col gap-2"><Label required>نام گروه</Label><Input value={name} onChange={(event) => setName(event.target.value)} /></div><div className="flex flex-col gap-2"><Label required>رنگ گروه</Label><Input type="color" value={color} onChange={(event) => setColor(event.target.value)} className="h-11" /></div><Button disabled={name.trim().length < 2 || mutation.isPending} onClick={() => mutation.mutate()}>ذخیره گروه</Button></div></DialogContent></Dialog>
}

function EntryAttachmentsDialog({ entryId }: { entryId: string }) {
  const [open, setOpen] = useState(false)
  const fileInputRef = useRef<HTMLInputElement>(null)
  const queryClient = useQueryClient()
  const { data: attachments } = useQuery({
    queryKey: ["finance-attachments", entryId],
    queryFn: () => listFinanceEntryAttachments(entryId),
    enabled: open,
  })
  const uploadMutation = useMutation({
    mutationFn: (file: File) => uploadFinanceEntryAttachment(entryId, file),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ["finance-attachments", entryId] }),
  })
  const deleteMutation = useMutation({
    mutationFn: (attachmentId: string) => deleteAttachment(attachmentId),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ["finance-attachments", entryId] }),
  })
  return (
    <Dialog open={open} onOpenChange={setOpen}>
      <DialogTrigger asChild>
        <button type="button" className="rounded-lg p-2 text-muted-foreground hover:bg-muted hover:text-foreground" aria-label="فایل‌های پیوست سند">
          <Paperclip className="size-4" />
        </button>
      </DialogTrigger>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>فایل‌های پیوست سند</DialogTitle>
          <DialogDescription>رسید یا فاکتور مربوط به این سند مالی را پیوست کنید.</DialogDescription>
        </DialogHeader>
        <div className="flex flex-col gap-2 rounded-md border border-border p-2">
          {attachments?.length === 0 && <p className="text-sm text-muted-foreground">فایلی پیوست نشده است.</p>}
          {attachments?.map((attachment) => (
            <div key={attachment.id} className="flex items-center justify-between gap-2 text-sm">
              <button
                onClick={() => downloadAttachment(attachment.id, attachment.original_filename)}
                className="truncate text-primary hover:underline"
              >
                {attachment.original_filename}
              </button>
              <div className="flex shrink-0 items-center gap-2 text-xs text-muted-foreground">
                <span>{formatFileSize(attachment.size_bytes)}</span>
                <button
                  onClick={() => deleteMutation.mutate(attachment.id)}
                  aria-label="حذف فایل"
                  className="text-danger hover:text-danger/80"
                >
                  <Trash2 className="size-4" />
                </button>
              </div>
            </div>
          ))}
        </div>
        <input
          ref={fileInputRef}
          type="file"
          className="hidden"
          onChange={(event) => {
            const file = event.target.files?.[0]
            if (file) uploadMutation.mutate(file)
            event.target.value = ""
          }}
        />
        <Button size="sm" variant="outline" className="self-end" disabled={uploadMutation.isPending} onClick={() => fileInputRef.current?.click()}>
          <Upload className="size-4" />
          {uploadMutation.isPending ? "در حال آپلود..." : "افزودن فایل"}
        </Button>
      </DialogContent>
    </Dialog>
  )
}

function SortHeader({
  label,
  field,
  sort,
  order,
  onSort,
}: {
  label: string
  field: FinanceEntrySort
  sort: FinanceEntrySort
  order: SortOrder
  onSort: (field: FinanceEntrySort) => void
}) {
  const active = sort === field
  return (
    <button type="button" className="flex items-center gap-1 hover:text-foreground" onClick={() => onSort(field)}>
      {label}
      {active ? (
        order === "asc" ? <ArrowUp className="size-3.5" /> : <ArrowDown className="size-3.5" />
      ) : (
        <ArrowUpDown className="size-3.5 opacity-40" />
      )}
    </button>
  )
}

export function FinancePage() {
  const queryClient = useQueryClient()
  const [type, setType] = useState<"all" | FinanceEntryType>("all")
  const [dateFrom, setDateFrom] = useState("")
  const [dateTo, setDateTo] = useState("")
  const [sort, setSort] = useState<FinanceEntrySort>("document_date")
  const [order, setOrder] = useState<SortOrder>("desc")
  const [deleteId, setDeleteId] = useState<string | null>(null)

  function handleSort(field: FinanceEntrySort) {
    if (field === sort) {
      setOrder((prev) => (prev === "asc" ? "desc" : "asc"))
    } else {
      setSort(field)
      setOrder("desc")
    }
  }

  const { data: entries, isLoading } = useQuery({
    queryKey: ["finance", type, dateFrom, dateTo, sort, order],
    queryFn: () =>
      listFinanceEntries({
        ...(type !== "all" ? { type } : {}),
        ...(dateFrom ? { date_from: dateFrom } : {}),
        ...(dateTo ? { date_to: dateTo } : {}),
        sort,
        order,
      }),
  })
  const { data: summary } = useQuery({ queryKey: ["finance-summary", dateFrom, dateTo], queryFn: () => getFinanceSummary(dateFrom, dateTo) })
  const deleteMutation = useMutation({ mutationFn: deleteFinanceEntry, onSuccess: () => { queryClient.invalidateQueries({ queryKey: ["finance"] }); queryClient.invalidateQueries({ queryKey: ["finance-summary"] }); setDeleteId(null) } })
  const breakdownItems = type === "income" ? summary?.income_breakdown ?? [] : type === "expense" ? summary?.expense_breakdown ?? [] : []

  return <div className="flex flex-col gap-6"><div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between"><PageHeader icon={Landmark} tone="success" title="درآمد و هزینه" description="دفتر اسناد مالی با گروه‌بندی درآمدها و هزینه‌ها" /><div className="flex gap-2"><CategoryDialog /><DocumentDialog /></div></div>
    <div className="grid grid-cols-1 gap-4 sm:grid-cols-3"><Card className="border-success/20 bg-success/[0.04]"><CardContent className="flex items-center gap-3 pt-6"><ArrowDownLeft className="size-8 text-success" /><div><p className="text-xl font-bold text-success">{money(summary?.total_income ?? 0)}</p><p className="text-sm text-muted-foreground">کل درآمد</p></div></CardContent></Card><Card className="border-danger/20 bg-danger/[0.04]"><CardContent className="flex items-center gap-3 pt-6"><ArrowUpRight className="size-8 text-danger" /><div><p className="text-xl font-bold text-danger">{money(summary?.total_expense ?? 0)}</p><p className="text-sm text-muted-foreground">کل هزینه</p></div></CardContent></Card><Card className="border-primary/20 bg-primary/[0.04]"><CardContent className="flex items-center gap-3 pt-6"><WalletCards className="size-8 text-primary" /><div><p className="text-xl font-bold">{money(summary?.balance ?? 0)}</p><p className="text-sm text-muted-foreground">مانده خالص</p></div></CardContent></Card></div>
    <Card><CardContent className="flex flex-col gap-3 pt-5 sm:flex-row sm:items-end"><div className="flex gap-1 rounded-lg bg-muted p-1"><button className={`rounded-md px-3 py-2 text-sm ${type === "all" ? "bg-card shadow-sm" : "text-muted-foreground"}`} onClick={() => setType("all")}>همه</button><button className={`rounded-md px-3 py-2 text-sm ${type === "income" ? "bg-success/10 text-success" : "text-muted-foreground"}`} onClick={() => setType("income")}>درآمد</button><button className={`rounded-md px-3 py-2 text-sm ${type === "expense" ? "bg-danger/10 text-danger" : "text-muted-foreground"}`} onClick={() => setType("expense")}>هزینه</button></div><div className="flex flex-1 flex-col gap-3 sm:flex-row sm:justify-end"><div className="flex flex-col gap-2"><Label>از تاریخ</Label><JalaliDateInput value={dateFrom} onChange={setDateFrom} /></div><div className="flex flex-col gap-2"><Label>تا تاریخ</Label><JalaliDateInput value={dateTo} onChange={setDateTo} /></div></div></CardContent></Card>
    <div className="grid grid-cols-1 gap-4 lg:grid-cols-[minmax(0,1fr)_19rem]">
      <Card>
        <CardHeader><CardTitle className="text-base">اسناد ثبت‌شده</CardTitle></CardHeader>
        <CardContent className="p-0">
          {isLoading && <p className="p-5 text-sm text-muted-foreground">در حال بارگذاری...</p>}
          {!isLoading && !entries?.length && <div className="p-5"><EmptyState icon={WalletCards} message="سندی با این فیلترها ثبت نشده است." /></div>}
          {!isLoading && !!entries?.length && (
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>عنوان و گروه</TableHead>
                  <TableHead><SortHeader label="تاریخ سند" field="document_date" sort={sort} order={order} onSort={handleSort} /></TableHead>
                  <TableHead><SortHeader label="شماره سند" field="document_number" sort={sort} order={order} onSort={handleSort} /></TableHead>
                  <TableHead><SortHeader label="مبلغ" field="amount" sort={sort} order={order} onSort={handleSort} /></TableHead>
                  <TableHead></TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {entries?.map((entry) => (
                  <TableRow key={entry.id}>
                    <TableCell className="max-w-56 whitespace-normal">
                      <div className="flex items-center gap-2">
                        <span className="size-2.5 shrink-0 rounded-full" style={{ backgroundColor: entry.category_color }} />
                        <div className="min-w-0">
                          <p className="truncate font-medium">{entry.title}</p>
                          <div className="mt-0.5 flex flex-wrap items-center gap-1">
                            <Badge variant={entry.entry_type === "income" ? "success" : "danger"}>{entry.category_name}</Badge>
                            {entry.project_name && <Badge variant="info">{entry.project_name}</Badge>}
                          </div>
                        </div>
                      </div>
                    </TableCell>
                    <TableCell>{new Date(entry.document_date).toLocaleDateString("fa-IR")}</TableCell>
                    <TableCell>{entry.document_number || "—"}</TableCell>
                    <TableCell className={`font-bold ${entry.entry_type === "income" ? "text-success" : "text-danger"}`}>
                      {entry.entry_type === "income" ? "+" : "−"}{money(entry.amount)}
                    </TableCell>
                    <TableCell>
                      <div className="flex items-center gap-1">
                        <EntryAttachmentsDialog entryId={entry.id} />
                        <button className="rounded-lg p-2 text-muted-foreground hover:bg-danger/10 hover:text-danger" onClick={() => setDeleteId(entry.id)} aria-label="حذف سند">
                          <Trash2 className="size-4" />
                        </button>
                      </div>
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          )}
        </CardContent>
      </Card>
      <Card><CardHeader><CardTitle className="text-base">سهم گروه‌ها</CardTitle></CardHeader><CardContent className="flex flex-col gap-4">{type === "all" && <p className="text-sm text-muted-foreground">برای مشاهده سهم گروه‌ها، درآمد یا هزینه را از بالا انتخاب کنید.</p>}{breakdownItems.slice(0, 8).map((item) => <div key={item.category_id}><div className="mb-1 flex items-center justify-between gap-2 text-xs"><span>{item.category_name}</span><span className="font-semibold">{item.percent.toLocaleString("fa-IR")}٪</span></div><div className="h-2 overflow-hidden rounded-full bg-muted"><div className="h-full rounded-full" style={{ width: `${item.percent}%`, backgroundColor: item.color }} /></div></div>)}</CardContent></Card>
    </div>
    <ConfirmDialog open={!!deleteId} onOpenChange={(open) => !open && setDeleteId(null)} title="حذف سند مالی؟" description="این سند برای همیشه از دفتر مالی حذف می‌شود." confirmLabel="حذف سند" cancelLabel="انصراف" onConfirm={() => deleteId && deleteMutation.mutate(deleteId)} isConfirming={deleteMutation.isPending} />
  </div>
}
