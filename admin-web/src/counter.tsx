import { useState } from 'react'

export function useCounterClipboard() {
	const [count, setCount] = useState(0)
	const [copyMessage, setCopyMessage] = useState('')

	const incrementCount = () => {
		setCount((prevCount) => prevCount + 1)
	}

	const copyCount = async () => {
		try {
			await navigator.clipboard.writeText(String(count))
			setCopyMessage(`Copied: ${count}`)
		} catch {
			setCopyMessage('Copy failed. Please allow clipboard access.')
		}
	}

	return {
		count,
		copyMessage,
		incrementCount,
		copyCount,
	}
}
