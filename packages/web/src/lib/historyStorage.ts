import { historyRecordsSchema } from '../schemas/history'
import type { HistoryRecord } from '../types/quiz'

const STORAGE_KEY = 'quzzes:history:v1'

function getStorage(): Storage | null {
  if (typeof window === 'undefined') return null
  try {
    return window.localStorage
  } catch {
    return null
  }
}

export function loadHistory(): HistoryRecord[] {
  const storage = getStorage()
  if (!storage) return []

  const raw = storage.getItem(STORAGE_KEY)
  if (raw === null) return []

  try {
    const json: unknown = JSON.parse(raw)
    const parsed = historyRecordsSchema.safeParse(json)
    if (!parsed.success) {
      reportCorruption(parsed.error.message)
      return []
    }
    return parsed.data
  } catch (error) {
    reportCorruption(error instanceof Error ? error.message : String(error))
    return []
  }
}

export function saveHistory(records: readonly HistoryRecord[]): void {
  const storage = getStorage()
  if (!storage) return
  try {
    storage.setItem(STORAGE_KEY, JSON.stringify(records))
  } catch (error) {
    reportPersistenceFailure(error instanceof Error ? error.message : String(error))
  }
}

export function clearHistory(): void {
  const storage = getStorage()
  if (!storage) return
  try {
    storage.removeItem(STORAGE_KEY)
  } catch (error) {
    reportPersistenceFailure(error instanceof Error ? error.message : String(error))
  }
}

function reportCorruption(message: string): void {
  if (typeof window === 'undefined') return
  window.dispatchEvent(
    new CustomEvent('quzzes:history:corrupted', {
      detail: {
        message:
          'history storage is malformed and was reset (履歴データが壊れていたため空履歴で再開しました): ' +
          message,
      },
    }),
  )
}

function reportPersistenceFailure(message: string): void {
  if (typeof window === 'undefined') return
  window.dispatchEvent(
    new CustomEvent('quzzes:history:persist-failed', {
      detail: {
        message:
          'failed to persist history (履歴の保存に失敗しました。ブラウザのストレージ制限を確認してください): ' +
          message,
      },
    }),
  )
}
