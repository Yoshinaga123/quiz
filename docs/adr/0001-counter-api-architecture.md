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
- Store the PV counter in table `views` with fixed record `id = 1`.
- Initialize schema and seed row via migration `001_create_tables.up.sql` at startup.

2. Concurrency control is delegated to database atomic update.
- Use `UPDATE views SET count = count + 1 WHERE id = 1 RETURNING count`.
- Do not use in-process `sync.Mutex` for this API path.

3. CORS allows browser access from local frontend origins in development.
- Current implementation reflects the request `Origin` header in `Access-Control-Allow-Origin` (see `withCORS` in `packages/backend/main.go`).
- Production deployments should revisit an explicit origin allowlist before public exposure.

4. Response format is unified as JSON.
- Success: `{ "count": number }`
- Error (admin/system handlers): `{ "error": string, "detail"?: string }`

## Consequences

### Positive

- Count survives process restarts.
- Concurrent updates remain consistent using DB atomic semantics.
- Local development works across varying Vite dev-server ports via Origin reflection.
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
- Rejected as the long-term production default due to broader attack surface.
- Accepted temporarily for local development because Vite may switch ports (for example 5173 to 5174).

## Notes

- The HTTP path remains `/counter`, but the persistence table is named `views` (PV counter semantics).
- This ADR documents architecture and operation policy. Detailed implementation notes are in [Counter API implementation notes](../counter-api.md).
