# ADR 0003: Styling Approach (Tailwind CSS)

- Status: Accepted
- Date: 2026-04-04
- Deciders: Quiz App Team

## Context

The project requires a consistent and maintainable styling approach.

Primary requirements:
- Rapid UI development with minimal context switching
- Consistent design tokens (spacing, colors, typography)
- Good compatibility with Vite + React + TypeScript stack
- Low overhead for small team / solo development

Candidate options considered:
- Tailwind CSS (utility-first)
- CSS Modules
- Emotion (CSS-in-JS)
- Plain CSS / global stylesheets

## Decision

Adopt Tailwind CSS as the primary styling solution.

## Rationale

1. Utility-first accelerates development
   - Styles are applied directly in JSX without switching to separate files.
   - Reduces boilerplate and naming overhead common with BEM / CSS Modules.

2. Consistent design system out of the box
   - Tailwind's default scale provides coherent spacing, color, and typography tokens.
   - Eliminates ad-hoc magic numbers in stylesheets.

3. Excellent Vite integration
   - First-class support via PostCSS plugin; no additional build complexity.
   - Works well with the existing Vite + React SPA decision (ADR 0002).

4. CSS-in-JS trade-offs avoided
   - Emotion and styled-components add runtime cost and bundle size.
   - Utility classes are statically extracted at build time, resulting in smaller production CSS.

5. CSS Modules trade-offs
   - CSS Modules remain a valid alternative but require separate `.module.css` files per component.
   - Tailwind reduces file count and co-locates style intent with component markup.

## Consequences

### Positive

- Faster prototyping and consistent visual output
- Production CSS is minimal (PurgeCSS / content scanning built-in)
- Broad community support and up-to-date VS Code IntelliSense via Tailwind CSS IntelliSense extension

### Negative / Trade-offs

- JSX class strings can become verbose for complex components; use `clsx` or `cn` helper as needed
- Requires initial Tailwind configuration (`tailwind.config.ts` / v4 `@import "tailwindcss"`)
- Team members unfamiliar with utility-first must learn the class naming conventions

## Related

- ADR 0002: Frontend Architecture Selection (SPA)
