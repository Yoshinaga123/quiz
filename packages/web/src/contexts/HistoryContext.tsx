import { createContext, useCallback, useContext, useEffect, useMemo, useState, type ReactNode } from 'react'
import { clearHistory as clearStoredHistory, loadHistory, saveHistory } from '../lib/historyStorage'
import type { HistoryRecord } from '../types/quiz'

interface HistoryContextValue {
  records: readonly HistoryRecord[]
  appendRecord: (record: HistoryRecord) => void
  clearAll: () => void
}

const HistoryContext = createContext<HistoryContextValue | null>(null)

export function HistoryProvider({ children }: { children: ReactNode }) {
  const [records, setRecords] = useState<HistoryRecord[]>(() => loadHistory())

  useEffect(() => {
    saveHistory(records)
  }, [records])

  const appendRecord = useCallback((record: HistoryRecord) => {
    setRecords((prev) => [record, ...prev])
  }, [])

  const clearAll = useCallback(() => {
    setRecords([])
    clearStoredHistory()
  }, [])

  const value = useMemo<HistoryContextValue>(
    () => ({ records, appendRecord, clearAll }),
    [records, appendRecord, clearAll],
  )

  return <HistoryContext.Provider value={value}>{children}</HistoryContext.Provider>
}

export function useHistory(): HistoryContextValue {
  const value = useContext(HistoryContext)
  if (value === null) {
    throw new Error('useHistory must be used within <HistoryProvider>')
  }
  return value
}
