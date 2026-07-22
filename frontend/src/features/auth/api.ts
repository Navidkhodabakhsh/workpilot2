import { apiClient } from "@/lib/api-client"
import type { CurrentUser } from "@/features/auth/auth-store"

export type LoginPayload = { phone_number: string; password: string }
export type SignupOtpRequestPayload = { phone_number: string }
export type SignupPayload = {
  organization_name: string
  department_name?: string
  full_name: string
  phone_number: string
  code: string
  password: string
}
export type CreateOrganizationPayload = { organization_name: string; department_name?: string }
export type OrganizationMembership = { organization_id: string; organization_name: string; role: string }

export type OtpPurpose = "login" | "password_reset"
export type OtpRequestPayload = { phone_number: string; purpose: OtpPurpose }
export type OtpRequestResponse = { message: string; debug_code: string | null }
export type OtpLoginPayload = { phone_number: string; code: string; new_password?: string }
export type OtpResetPasswordPayload = { phone_number: string; code: string; new_password: string }

type TokenResponse = { access_token: string; token_type: string }

export async function login(payload: LoginPayload) {
  const { data } = await apiClient.post<TokenResponse>("/api/v1/auth/login", payload)
  return data
}

export async function requestSignupOtp(payload: SignupOtpRequestPayload) {
  const { data } = await apiClient.post<OtpRequestResponse>("/api/v1/auth/signup/request-otp", payload)
  return data
}

export async function signup(payload: SignupPayload) {
  const { data } = await apiClient.post<CurrentUser>("/api/v1/auth/signup", payload)
  return data
}

export async function requestOtp(payload: OtpRequestPayload) {
  const { data } = await apiClient.post<OtpRequestResponse>("/api/v1/auth/otp/request", payload)
  return data
}

export async function otpLogin(payload: OtpLoginPayload) {
  const { data } = await apiClient.post<TokenResponse>("/api/v1/auth/otp/login", payload)
  return data
}

export async function otpResetPassword(payload: OtpResetPasswordPayload) {
  const { data } = await apiClient.post<TokenResponse>("/api/v1/auth/otp/reset-password", payload)
  return data
}

export async function fetchMe() {
  const { data } = await apiClient.get<CurrentUser>("/api/v1/auth/me")
  return data
}

export async function logoutRequest() {
  await apiClient.post("/api/v1/auth/logout")
}

export async function listMyOrganizations() {
  const { data } = await apiClient.get<OrganizationMembership[]>("/api/v1/auth/organizations")
  return data
}

export async function createOrganization(payload: CreateOrganizationPayload) {
  const { data } = await apiClient.post<CurrentUser>("/api/v1/auth/organizations", payload)
  return data
}

export async function switchOrganization(organizationId: string) {
  const { data } = await apiClient.post<TokenResponse>("/api/v1/auth/switch-organization", {
    organization_id: organizationId,
  })
  return data
}
