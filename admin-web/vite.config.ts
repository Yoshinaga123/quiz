import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import tailwindcss from '@tailwindcss/vite'
import fs from 'node:fs'
import path from 'node:path'

const certDir = path.resolve(__dirname, '../certs')

// https://vite.dev/config/
export default defineConfig({
  plugins: [react(), tailwindcss()],
  server: {
    https: {
      key: fs.readFileSync(path.join(certDir, 'localhost-key.pem')),
      cert: fs.readFileSync(path.join(certDir, 'localhost-cert.pem')),
    },
    proxy: {
      '/api': {
        target: 'http://localhost:8082',
        changeOrigin: true,
      },
      '/counter': {
        target: 'http://localhost:8082',
        changeOrigin: true,
      },
    },
  },
})
