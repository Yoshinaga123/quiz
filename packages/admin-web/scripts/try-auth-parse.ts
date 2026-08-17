/**
 * Zod play.ts equivalent for admin-web.
 * Not included in vite build (tsconfig include is src only).
 *
 * Run: npx --yes tsx scripts/try-auth-parse.ts
 */
import { loginRequestSchema, loginVerificationSchema } from '../src/schemas/auth.ts'

const login = loginRequestSchema.safeParse({
  username: 'admin',
  password: 'secret',
})
console.log('loginRequest:', login.success)

const verification = loginVerificationSchema.safeParse({
  username: 'admin',
  password: 'secret',
  challengeId: 'challenge-1',
  verificationCode: '123456',
})
console.log('loginVerification:', verification.success)
console.log(verification.success ? verification.data : verification.error)
