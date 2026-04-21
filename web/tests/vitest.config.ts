import { defineConfig } from 'vitest/config';
import react from '@vitejs/plugin-react';

/**
 * tests/ 配下に独立した Vitest 設定を置く。
 * `web/package.json` に `vitest` を追加した後に
 * `npx vitest --config tests/vitest.config.ts` で実行できる。
 */
export default defineConfig({
  plugins: [react()],
  test: {
    environment: 'jsdom',
    globals: true,
    include: ['tests/**/*.test.{ts,tsx}'],
    setupFiles: ['tests/setup.ts'],
    coverage: {
      provider: 'v8',
      reporter: ['text', 'html'],
      include: ['src/**/*.{ts,tsx}'],
      exclude: ['src/main.tsx', 'src/**/*.d.ts'],
    },
  },
});
