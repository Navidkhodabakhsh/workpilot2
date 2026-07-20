declare const process: { env: Record<string, string | undefined> }

process.env.TZ = "Asia/Tehran"

await import("@testing-library/jest-dom/vitest")
