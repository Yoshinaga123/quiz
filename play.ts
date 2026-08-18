/**
 * Scratch pad (Zod play.ts equivalent).
 * Do not import this file from packages/web/src or packages/admin-web/src.
 *
 * Run: npm run play
 * Local-only experiments: copy to play.local.ts (gitignored).
 */
function padLeft(padding: number | string, input: string): string {
  if (typeof padding === 'number') {
    return ' '.repeat(padding) + input
  }
  return padding + input
}

console.log(JSON.stringify(padLeft(4, 'hello')))
console.log(JSON.stringify(padLeft('>>> ', 'hello')))
