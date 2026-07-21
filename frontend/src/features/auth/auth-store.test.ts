import { beforeEach, describe, expect, it } from "vitest"
import { useAuthStore, type CurrentUser } from "./auth-store"

const user: CurrentUser = {
  id: "u1",
  organization_id: "org1",
  phone_number: "09120000001",
  full_name: "Admin User",
  role: "org_admin",
  is_active: true,
  department_id: null,
  department_memberships: [],
}

describe("useAuthStore", () => {
  beforeEach(() => {
    useAuthStore.setState({ accessToken: null, user: null })
  })

  it("starts with no session", () => {
    const state = useAuthStore.getState()
    expect(state.accessToken).toBeNull()
    expect(state.user).toBeNull()
  })

  it("setSession stores the token and user together", () => {
    useAuthStore.getState().setSession("token-123", user)
    const state = useAuthStore.getState()
    expect(state.accessToken).toBe("token-123")
    expect(state.user).toEqual(user)
  })

  it("logout clears both the token and the user", () => {
    useAuthStore.getState().setSession("token-123", user)
    useAuthStore.getState().logout()
    const state = useAuthStore.getState()
    expect(state.accessToken).toBeNull()
    expect(state.user).toBeNull()
  })
})
