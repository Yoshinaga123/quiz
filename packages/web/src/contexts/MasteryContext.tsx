import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useMemo,
  useState,
  type ReactNode,
} from 'react'
import { fetchMastery } from '../api/member'
import {
  clearMasteryState,
  loadMasteryState,
  saveMasteryState,
  toNumericStreaks,
} from '../lib/masteryStorage'
import { nextStreak } from '../lib/rank'
import { useMemberSession } from './MemberSessionContext'

interface MasteryContextValue {
  streaks: Readonly<Record<number, number>>
  recordAnswer: (quizId: number, isCorrect: boolean) => void
  resetAll: () => void
  /**
   * true のとき、`streaks` はサーバー (`GET /api/me/mastery`) 由来。
   * 未ログインまたはフェッチ失敗中は false で、localStorage 由来を返す。
   */
  isRemoteSource: boolean
  isRemoteLoading: boolean
}

const MasteryContext = createContext<MasteryContextValue | null>(null)

export function MasteryProvider({ children }: { children: ReactNode }) {
  const [localStreaks, setLocalStreaks] = useState<Record<number, number>>(() =>
    toNumericStreaks(loadMasteryState()),
  )
  const [remoteBundle, setRemoteBundle] = useState<{
    memberId: string
    streaks: Record<number, number>
  } | null>(null)
  const { session } = useMemberSession()

  useEffect(() => {
    const stringified: Record<string, number> = {}
    for (const [id, value] of Object.entries(localStreaks)) {
      stringified[id] = value
    }
    saveMasteryState({
      streaks: stringified,
      updatedAt: new Date().toISOString(),
    })
  }, [localStreaks])

  const sessionMemberId = session?.memberId ?? null
  const sessionToken = session?.token ?? null
  useEffect(() => {
    if (sessionMemberId === null || sessionToken === null) return undefined
    const controller = new AbortController()
    void fetchMastery({ token: sessionToken, signal: controller.signal })
      .then((response) => {
        if (controller.signal.aborted) return
        const next: Record<number, number> = {}
        for (const entry of response.items) {
          next[entry.quizId] = entry.streak
        }
        setRemoteBundle({ memberId: sessionMemberId, streaks: next })
      })
      .catch(() => {
        if (!controller.signal.aborted) {
          setRemoteBundle((prev) =>
            prev !== null && prev.memberId === sessionMemberId ? null : prev,
          )
        }
      })
    return () => controller.abort()
  }, [sessionMemberId, sessionToken])

  const recordAnswer = useCallback((quizId: number, isCorrect: boolean) => {
    if (!Number.isFinite(quizId) || quizId <= 0) return
    setLocalStreaks((prev) => {
      const current = prev[quizId] ?? 0
      const updated = nextStreak(current, isCorrect)
      if (updated === current) return prev
      return { ...prev, [quizId]: updated }
    })
    setRemoteBundle((prev) => {
      if (prev === null) return prev
      const current = prev.streaks[quizId] ?? 0
      const updated = nextStreak(current, isCorrect)
      if (updated === current) return prev
      return {
        memberId: prev.memberId,
        streaks: { ...prev.streaks, [quizId]: updated },
      }
    })
  }, [])

  const resetAll = useCallback(() => {
    setLocalStreaks({})
    clearMasteryState()
  }, [])

  const isRemoteSource =
    sessionMemberId !== null &&
    remoteBundle !== null &&
    remoteBundle.memberId === sessionMemberId
  const streaks: Readonly<Record<number, number>> = isRemoteSource
    ? remoteBundle.streaks
    : localStreaks
  const isRemoteLoading = sessionMemberId !== null && !isRemoteSource

  const value = useMemo<MasteryContextValue>(
    () => ({ streaks, recordAnswer, resetAll, isRemoteSource, isRemoteLoading }),
    [streaks, recordAnswer, resetAll, isRemoteSource, isRemoteLoading],
  )

  return <MasteryContext.Provider value={value}>{children}</MasteryContext.Provider>
}

export function useMastery(): MasteryContextValue {
  const value = useContext(MasteryContext)
  if (value === null) {
    throw new Error('useMastery must be used within <MasteryProvider>')
  }
  return value
}
