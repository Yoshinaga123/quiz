# ADR 0002: Frontend Architecture Selection (SPA)

- Status: Accepted
- Date: 2026-04-04
- Deciders: Quiz App Team

## Context

The project is an interactive quiz application.

Primary requirements:
- Frequent UI updates during answering and feedback
- Local state transitions are central to user experience
- Quiz data is mostly static JSON
- Fast development iteration and low architectural complexity are preferred

Candidate options considered:
- Vite + React SPA
- Next.js App Router (RSC)
- Astro (Islands)

## Decision

Adopt Vite + React SPA as the frontend architecture.

## Rationale

1. Interaction-driven product fit
- The app behavior is dominated by stateful interactions, not static content delivery.
- SPA keeps interaction logic straightforward and predictable.

2. Limited incremental value from RSC for current scope
- RSC is strong when server-side data dependencies dominate rendering.
- Current quiz data is static/local, so DB-direct and server-component advantages are limited.

3. Limited incremental value from Astro Islands for current scope
- Islands architecture is strongest for mostly static pages with small interactive islands.
- This app has broad dynamic UI behavior, so island-style decomposition gives less benefit.

4. Cost-aware optimization path
- Keep architecture simple first, then optimize via measurement.
- Prioritize memoization and code splitting before framework migration.

## Consequences

### Positive

- Faster implementation and simpler mental model
- Excellent DX with Vite in local development
- Lower migration and maintenance overhead at current scale

### Negative

- Initial client bundle can grow if features expand without optimization
- Less built-in server rendering capability compared with Next.js

## Optimization Policy

Apply optimizations in this order:
1. Measure first (LCP, INP, bundle size)
2. Optimize within SPA (`React.memo`, `useMemo`, `React.lazy`)
3. Re-evaluate RSC/Astro only if measured goals are not met

## Search Requirements

- If a page is public and search discovery is a requirement, implementation must follow Google Search Central guidance.
- In SPA routes, use crawlable links and History API based URLs instead of fragment-based routing.
- If a public page cannot expose correct status codes, metadata, or index control reliably in SPA form, re-evaluate SSR/SSG/prerender instead of forcing the current architecture.

## Alternatives Considered

1. Next.js App Router (RSC)
- Not selected now due to mismatch with current interaction-heavy and static-data scope.
- May be revisited if content/SEO/server-data needs grow significantly.

2. Astro (Islands)
- Not selected now due to low proportion of purely static UI regions.
- May be revisited for content-centric pages in future.

## Notes

This ADR aligns with the implementation policy in [Architecture implementation policy](../implement-policy.md).
