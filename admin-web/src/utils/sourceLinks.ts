export interface SourceLink {
  href: string
  label: string
}

type SourceLinkMapValue = string | SourceLink[]

const sourceLinkMap: Record<string, SourceLinkMapValue> = {
  'Browser DevTools': 'https://developer.chrome.com/docs/devtools',
  'Build Optimization': 'https://vite.dev/guide/features.html',
  'Docker Compose Build Specification': 'https://docs.docker.com/reference/compose-file/build/',
  'Docker Compose / Dockerfile build behavior': 'https://docs.docker.com/reference/compose-file/build/',
  'Docker Compose build reflection behavior': 'https://docs.docker.com/reference/compose-file/build/',
  'Docker development vs production architecture': 'https://docs.docker.com/build/building/best-practices/',
  'ECMAScript 2015+': 'https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference',
  'ES6 Modules': 'https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Modules',
  'Error Handling Best Practices': 'https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Control_flow_and_error_handling',
  'Go os.LookupEnv implementation': 'https://pkg.go.dev/os#LookupEnv',
  'Go runtime package': 'https://pkg.go.dev/runtime',
  'Go runtime.GOMAXPROCS': 'https://pkg.go.dev/runtime#GOMAXPROCS',
  'Go runtime.NumGoroutine': 'https://pkg.go.dev/runtime#NumGoroutine',
  'Go runtime.Version': 'https://pkg.go.dev/runtime#Version',
  'Go runtime constants': 'https://pkg.go.dev/runtime#pkg-constants',
  'Goroutine lifecycle in HTTP server': 'https://pkg.go.dev/net/http',
  'JavaScript Async': 'https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/async_function',
  'JavaScript Patterns': 'https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide',
  'Jest Matchers': 'https://jestjs.io/docs/expect',
  'MDN CORS': 'https://developer.mozilla.org/en-US/docs/Web/HTTP/Guides/CORS',
  'MDN/各種Migrationベストプラクティス要約': [
    {
      href: 'https://www.postgresql.org/docs/current/sql-createtable.html',
      label: 'PostgreSQL CREATE TABLE',
    },
    {
      href: 'https://www.postgresql.org/docs/current/sql-droptable.html',
      label: 'PostgreSQL DROP TABLE',
    },
  ],
  'OWASP HTML5 Security Cheat Sheet / JWT Cheat Sheet': [
    {
      href: 'https://cheatsheetseries.owasp.org/cheatsheets/HTML5_Security_Cheat_Sheet.html',
      label: 'OWASP HTML5 Security Cheat Sheet',
    },
    {
      href: 'https://cheatsheetseries.owasp.org/cheatsheets/JSON_Web_Token_for_Java_Cheat_Sheet.html',
      label: 'OWASP JWT Cheat Sheet',
    },
  ],
  'PostgreSQL checkpoint logs': 'https://www.postgresql.org/docs/current/wal-configuration.html',
  'PostgreSQL checkpoint timing fields': 'https://www.postgresql.org/docs/current/monitoring-stats.html',
  'PostgreSQL shared buffers metrics': 'https://www.postgresql.org/docs/current/monitoring-stats.html',
  'PostgreSQL WAL checkpoint counters': 'https://www.postgresql.org/docs/current/monitoring-stats.html',
  'PostgreSQL WAL/LSN fundamentals': 'https://www.postgresql.org/docs/current/wal-intro.html',
  'Promise MDN': 'https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise',
  'React Design Patterns': 'https://react.dev/learn/passing-data-deeply-with-context',
  'React Forms': 'https://react.dev/reference/react-dom/components/input',
  'React Hooks': 'https://react.dev/reference/react/hooks',
  'React Official Documentation': 'https://react.dev/',
  'React Optimization': 'https://react.dev/reference/react/memo',
  'React Server Components': 'https://react.dev/reference/rsc/server-components',
  'React Strict Mode': 'https://react.dev/reference/react/StrictMode',
  'React StrictMode': 'https://react.dev/reference/react/StrictMode',
  'React Testing Library': 'https://testing-library.com/docs/react-testing-library/intro/',
  'React.StrictMode': 'https://react.dev/reference/react/StrictMode',
  'Security Best Practices': 'https://owasp.org/www-project-top-ten/',
  'TypeScript Advanced': 'https://www.typescriptlang.org/docs/handbook/2/generics.html',
  'TypeScript Handbook': 'https://www.typescriptlang.org/docs/handbook/intro.html',
  'TypeScript Utility Types': 'https://www.typescriptlang.org/docs/handbook/utility-types.html',
  'Tailwind utility classes / arbitrary values': [
    {
      href: 'https://tailwindcss.com/docs/margin',
      label: 'Tailwind margin',
    },
    {
      href: 'https://tailwindcss.com/docs/border-radius',
      label: 'Tailwind border-radius',
    },
    {
      href: 'https://tailwindcss.com/docs/border-color',
      label: 'Tailwind border-color',
    },
    {
      href: 'https://tailwindcss.com/docs/background-color',
      label: 'Tailwind background-color',
    },
    {
      href: 'https://tailwindcss.com/docs/padding',
      label: 'Tailwind padding',
    },
    {
      href: 'https://tailwindcss.com/docs/box-shadow',
      label: 'Tailwind box-shadow',
    },
    {
      href: 'https://tailwindcss.com/docs/adding-custom-styles',
      label: 'Tailwind arbitrary values',
    },
  ],
  'Tailwind production optimization': [
    {
      href: 'https://tailwindcss.com/docs/detecting-classes-in-source-files',
      label: 'Tailwind detecting classes in source files',
    },
    {
      href: 'https://v3.tailwindcss.com/',
      label: 'Tailwind CSS v3 overview',
    },
  ],
  'Go runtime / Prometheus / OpenTelemetry monitoring': [
    {
      href: 'https://pkg.go.dev/runtime',
      label: 'Go runtime package',
    },
    {
      href: 'https://pkg.go.dev/github.com/prometheus/client_golang/prometheus',
      label: 'Prometheus Go client',
    },
    {
      href: 'https://pkg.go.dev/go.opentelemetry.io/contrib/instrumentation/runtime',
      label: 'OpenTelemetry runtime instrumentation',
    },
  ],
  'Vite Public Directory / MDN Fetch API': [
    {
      href: 'https://vite.dev/guide/assets.html#the-public-directory',
      label: 'Vite The public Directory',
    },
    {
      href: 'https://developer.mozilla.org/en-US/docs/Web/API/Fetch_API',
      label: 'MDN Fetch API',
    },
  ],
  'Vite Guide': 'https://vite.dev/guide/',
  'air / Docker Compose development setup': 'https://github.com/air-verse/air',
  'air build configuration troubleshooting': 'https://github.com/air-verse/air',
  'air cmd vs entrypoint semantics': 'https://github.com/air-verse/air',
  'air configuration semantics': 'https://github.com/air-verse/air',
  'air exclude_dir troubleshooting': 'https://github.com/air-verse/air',
  'air root directory behavior': 'https://github.com/air-verse/air',
  'air watch configuration': 'https://github.com/air-verse/air',
}

function isHttpUrl(value: string): boolean {
  return /^https?:\/\//.test(value)
}

function createSearchLink(label: string): SourceLink {
  return {
    href: `https://duckduckgo.com/?q=${encodeURIComponent(label)}`,
    label,
  }
}

export function resolveSourceLinks(source: string): SourceLink[] {
  const normalizedSource = source.trim()
  if (normalizedSource === '') {
    return []
  }

  const splitSources = normalizedSource.split(/\s*,\s*/).filter(Boolean)
  if (splitSources.length > 1 && splitSources.every(isHttpUrl)) {
    return splitSources.map((href) => ({
      href,
      label: href,
    }))
  }

  if (isHttpUrl(normalizedSource)) {
    return [
      {
        href: normalizedSource,
        label: normalizedSource,
      },
    ]
  }

  const mappedLink = sourceLinkMap[normalizedSource]
  if (mappedLink) {
    if (Array.isArray(mappedLink)) {
      return mappedLink
    }

    return [
      {
        href: mappedLink,
        label: normalizedSource,
      },
    ]
  }

  return [createSearchLink(normalizedSource)]
}
