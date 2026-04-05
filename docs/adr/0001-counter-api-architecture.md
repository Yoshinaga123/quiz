# ADR 0001: Counter API Architecture

- Status: Accepted
- Date: 2026-04-04
- Deciders: Quiz App Team

## Context

The project needs a simple counter API that:
- Returns the current count value
- Increments count safely under concurrent requests
- Persists count across server restarts
- Allows browser access from local frontend origins in development

The endpoint contract is:
- GET /counter: get current count
- POST /counter: increment and return new count

## Decision

We adopt the following design:

1. Persistence uses PostgreSQL.
- Store counter in table `counters` with fixed record `id = 1`.
- Initialize schema and seed row at startup if missing.

2. Concurrency control is delegated to database atomic update.
- Use `UPDATE counters SET count = count + 1 WHERE id = 1 RETURNING count`.
- Do not use in-process `sync.Mutex` for this API path.

3. CORS uses explicit origin whitelist.
- Allow only known development origins.
- Do not reflect arbitrary `Origin` values in production behavior.

4. Response format is unified as JSON.
- Success: `{ "count": number }`
- Error: `{ "message": string }`

## Consequences

### Positive

- Count survives process restarts.
- Concurrent updates remain consistent using DB atomic semantics.
- Clear security posture for cross-origin browser access.
- Stable response shape for frontend error handling.

### Negative

- Requires PostgreSQL setup in local/dev environments.
- API availability depends on DB health.
- Single-row design can become a hotspot under very high write load.

## Alternatives Considered

1. In-memory counter with `sync.Mutex`
- Rejected because value is lost on restart and cannot scale across multiple instances.

2. File-based persistence
- Rejected due to complexity around file locking and corruption handling under concurrency.

3. Wildcard or origin-reflection CORS policy
- Rejected for production due to broader attack surface.

## Notes

This ADR documents architecture and operation policy. Detailed implementation examples are described in [Counter API implementation notes](../counter-api.md).
