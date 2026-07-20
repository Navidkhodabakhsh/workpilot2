import { apiClient } from "@/lib/api-client"

export type FinanceEntryType = "income" | "expense"
export type FinanceCategory = { id: string; entry_type: FinanceEntryType; name: string; color: string; is_system: boolean }
export type FinanceEntry = {
  id: string
  category_id: string
  category_name: string
  category_color: string
  project_id: string | null
  project_name: string | null
  recorded_by_id: string
  entry_type: FinanceEntryType
  document_date: string
  amount: string
  title: string
  description: string | null
  document_number: string | null
  counterparty: string | null
  created_at: string
}
export type FinanceSummary = {
  total_income: string
  total_expense: string
  balance: string
  income_breakdown: { category_id: string; category_name: string; color: string; amount: string; percent: number }[]
  expense_breakdown: { category_id: string; category_name: string; color: string; amount: string; percent: number }[]
}

export const listFinanceCategories = async () => (await apiClient.get<FinanceCategory[]>("/api/v1/finance/categories")).data
export const createFinanceCategory = async (payload: { entry_type: FinanceEntryType; name: string; color: string }) => (await apiClient.post<FinanceCategory>("/api/v1/finance/categories", payload)).data
export const listFinanceEntries = async (filters: { type?: FinanceEntryType; category_id?: string; project_id?: string; date_from?: string; date_to?: string }) => (await apiClient.get<FinanceEntry[]>("/api/v1/finance/entries", { params: filters })).data
export const createFinanceEntry = async (payload: { category_id: string; project_id?: string; entry_type: FinanceEntryType; document_date: string; amount: string; title: string; description?: string; document_number?: string; counterparty?: string }) => (await apiClient.post<FinanceEntry>("/api/v1/finance/entries", payload)).data
export const deleteFinanceEntry = async (id: string) => apiClient.delete(`/api/v1/finance/entries/${id}`)
export const getFinanceSummary = async (dateFrom?: string, dateTo?: string) => (await apiClient.get<FinanceSummary>("/api/v1/finance/summary", { params: { ...(dateFrom ? { date_from: dateFrom } : {}), ...(dateTo ? { date_to: dateTo } : {}) } })).data
