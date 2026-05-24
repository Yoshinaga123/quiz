import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import tailwindcss from '@tailwindcss/vite'
import fs from 'node:fs'
import path from 'node:path'

const certDir = path.resolve(__dirname, '../certs')

export default defineConfig({
  plugins: [react(), tailwindcss()],
  server: {
    port: 5174,
    https: {
      key: fs.readFileSync(path.join(certDir, 'localhost-key.pem')),
      cert: fs.readFileSync(path.join(certDir, 'localhost-cert.pem')),
    },
  },
})
