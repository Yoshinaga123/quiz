import { useEffect, useState } from 'react'
import { incrementCounter } from '../api/counter'

export default function ViewCounter() {
  const [count, setCount] = useState<number | null>(null)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    const fetchViews = async () => {
      try {
        const data = await incrementCounter()
        setCount(data.count)
      } catch (err) {
        setError(err instanceof Error ? err.message : 'Unknown error')
      }
    }

    void fetchViews()
  }, [])

  if (error) return <span className="text-sm text-[#b42318]">PV取得失敗</span>
  if (count === null) return <span className="text-sm text-[#4f5d75]">PV: ...</span>
  return <span className="text-sm font-medium text-[#4f5d75]">{count.toLocaleString()} PV</span>
}
