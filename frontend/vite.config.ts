/// <reference types="vitest/config" />
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import tailwindcss from '@tailwindcss/vite'
import path from 'path'

// https://vite.dev/config/
export default defineConfig({
  plugins: [react(), tailwindcss()],
  resolve: {
    alias: [
      {
        find: '@/features/tasks/components/task-card',
        replacement: path.resolve(__dirname, './src/features/tasks/components/task-card-compat.tsx'),
      },
      { find: '@', replacement: path.resolve(__dirname, './src') },
    ],
  },
  server: {
    host: true,
    port: 5173,
  },
  test: {
    environment: 'jsdom',
    setupFiles: ['./src/test/setup-timezone.ts'],
    globals: true,
  },
})
