import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import tailwindcss from '@tailwindcss/vite'
import fs from 'node:fs'
import path from 'node:path'

const certDir = path.resolve(__dirname, '../certs')
const certKey = path.join(certDir, 'localhost-key.pem')
const certFile = path.join(certDir, 'localhost-cert.pem')
const https = fs.existsSync(certKey) && fs.existsSync(certFile)
  ? {
      key: fs.readFileSync(certKey),
      cert: fs.readFileSync(certFile),
    }
  : undefined

// https://vite.dev/config/
export default defineConfig({
  plugins: [react(), tailwindcss()],
  server: {
    https,
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
