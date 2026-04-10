import { ApiError } from './errors'

const COUNTER_URL = 'http://localhost:8082/counter'

export interface CounterResponse {
    count: number
}

function isCounterResponse(value: unknown): value is CounterResponse {
    if (typeof value !== 'object' || value === null) {
        return false
    }

    const candidate = value as Record<string, unknown>
    return (
        typeof candidate.count === 'number' &&
        Number.isFinite(candidate.count) &&
        Number.isInteger(candidate.count) &&
        candidate.count >= 0
    )
}

async function parseCounterResponse(response: Response): Promise<CounterResponse> {
    const json: unknown = await response.json()

    if (!isCounterResponse(json)) {
        throw new Error('Invalid counter response format')
    }

    return json
}

export async function incrementCounter(): Promise<CounterResponse> {
    const response = await fetch(COUNTER_URL, {
        method: 'POST',
    })

    if (!response.ok) {
        throw new ApiError(response.status, `HTTP error: ${response.status}`)
    }

    return parseCounterResponse(response)
}
