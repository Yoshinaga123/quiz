import { masteryStateSchema, type MasteryState } from '../schemas/mastery'
import { STREAK_CAP } from './rank'

const STORAGE_KEY = 'quzzes:mastery:v1'

function getStorage(): Storage | null {
  if (typeof window === 'undefined') return null
  try {
    return window.localStorage
  } catch {
    return null
  }
}

export function loadMasteryState(): MasteryState {
  const empty = emptyState()
  const storage = getStorage()
  if (!storage) return empty

  const raw = storage.getItem(STORAGE_KEY)
  if (raw === null) return empty

  try {
    const json: unknown = JSON.parse(raw)
    const parsed = masteryStateSchema.safeParse(json)
    if (!parsed.success) {
      reportCorruption(parsed.error.message)
      return empty
    }
    return parsed.data
  } catch (error) {
    reportCorruption(error instanceof Error ? error.message : String(error))
    return empty
  }
}

export function saveMasteryState(state: MasteryState): void {
  const storage = getStorage()
  if (!storage) return
  try {
    storage.setItem(STORAGE_KEY, JSON.stringify(state))
  } catch (error) {
    reportPersistenceFailure(error instanceof Error ? error.message : String(error))
  }
}

export function clearMasteryState(): void {
  const storage = getStorage()
  if (!storage) return
  try {
    storage.removeItem(STORAGE_KEY)
  } catch (error) {
    reportPersistenceFailure(error instanceof Error ? error.message : String(error))
  }
}

function emptyState(): MasteryState {
  return { streaks: {}, updatedAt: new Date().toISOString() }
}

/**
 * quizId -> streak を通常の数値キーの map に射影する。
 * schema 上は string キーで保存しているため、UI 層で number キー Record として扱う。
 */
export function toNumericStreaks(
  state: MasteryState,
): Record<number, number> {
  const out: Record<number, number> = {}
  for (const [key, value] of Object.entries(state.streaks)) {
    const id = Number.parseInt(key, 10)
    if (!Number.isFinite(id)) continue
    const clamped = Math.max(0, Math.min(STREAK_CAP, Math.floor(value)))
    out[id] = clamped
  }
  return out
}

function reportCorruption(message: string): void {
  if (typeof window === 'undefined') return
  window.dispatchEvent(
    new CustomEvent('quzzes:mastery:corrupted', {
      detail: {
        message:
          '段位ストレージが壊れていたため初期状態から再開しました: ' + message,
      },
    }),
  )
}

function reportPersistenceFailure(message: string): void {
  if (typeof window === 'undefined') return
  window.dispatchEvent(
    new CustomEvent('quzzes:mastery:persist-failed', {
      detail: {
        message:
          '段位データの保存に失敗しました。ブラウザのストレージ制限を確認してください: ' + message,
      },
    }),
  )
}
