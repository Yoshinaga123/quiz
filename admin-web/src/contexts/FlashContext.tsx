import { createContext, useCallback, useContext, useEffect, useMemo, useState, type ReactNode } from 'react'

type FlashContextValue = {
  message: string | null
  showFlash: (message: string) => void
  clearFlash: () => void
}

const FLASH_DURATION_MS = 4000

const FlashContext = createContext<FlashContextValue | undefined>(undefined)

export function FlashProvider({ children }: { children: ReactNode }) {
  const [message, setMessage] = useState<string | null>(null)

  const showFlash = useCallback((nextMessage: string) => {
    setMessage(nextMessage)
  }, [])

  const clearFlash = useCallback(() => {
    setMessage(null)
  }, [])

  useEffect(() => {
    if (message == null) {
      return
    }

    const timeoutId = window.setTimeout(() => {
      setMessage(null)
    }, FLASH_DURATION_MS)

    return () => {
      window.clearTimeout(timeoutId)
    }
  }, [message])

  const value = useMemo(
    () => ({ message, showFlash, clearFlash }),
    [message, showFlash, clearFlash],
  )

  return <FlashContext.Provider value={value}>{children}</FlashContext.Provider>
}

export function useFlash(): FlashContextValue {
  const context = useContext(FlashContext)
  if (context === undefined) {
    throw new Error('useFlash must be used within a FlashProvider')
  }
  return context
}
