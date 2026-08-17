import { useMemo, useState } from 'react'
import { Link } from 'react-router-dom'

const architectureFamilies = [
  { id: 'all', label: 'すべて', description: '全13アーキテクチャを一覧表示' },
  { id: 'interactive', label: 'インタラクション重視', description: '高頻度で状態が変わるUI向け' },
  { id: 'content', label: 'コンテンツ配信', description: 'SEOや初期描画を重視するサイト' },
  { id: 'edge', label: 'エッジ/超高速', description: '即時応答や分散配信が必要なケース' },
  { id: 'native', label: 'マルチプラットフォーム', description: 'ハイブリッド/ネイティブアプリ' },
]

const architectures = [
  {
    id: 'vite-react',
    name: 'Vite + React SPA',
    tagline: 'クイズ管理UIの現在地。高速開発が最優先な領域。',
    docUrl: 'https://vitejs.dev/guide/why.html',
    family: 'interactive',
    renderMode: 'CSR',
    strengths: ['最速のHMR', '簡易構成', 'Reactエコシステム'],
    metrics: { perf: 'B+', dx: 'A', coverage: 'Web' },
  },
  {
    id: 'next-app-router',
    name: 'Next.js App Router (RSC)',
    tagline: 'SEOとパーソナライズを同時に達成するReactフルスタック。',
    docUrl: 'https://nextjs.org/docs/app',
    family: 'content',
    renderMode: 'SSR + RSC',
    strengths: ['柔軟なデータ取得', 'Route Handlers', '画像最適化'],
    metrics: { perf: 'A', dx: 'A-', coverage: 'Web' },
  },
  {
    id: 'astro',
    name: 'Astro Islands',
    tagline: 'ほぼ静的な学習ガイドを最小JSで提供。',
    docUrl: 'https://docs.astro.build',
    family: 'content',
    renderMode: 'SSG + Islands',
    strengths: ['ゼロJS配信', '部分的なReact/Svelte', 'MDX最適'],
    metrics: { perf: 'A+', dx: 'B+', coverage: 'Web' },
  },
  {
    id: 'remix',
    name: 'Remix',
    tagline: 'ルーター中心のUX。アクション/ローダーがそのままドメインAPI。',
    docUrl: 'https://remix.run/docs',
    family: 'interactive',
    renderMode: 'SSR',
    strengths: ['フォールバックないForm', 'プリフェッチ', 'プログレッシブエンハンス'],
    metrics: { perf: 'A-', dx: 'A-', coverage: 'Web' },
  },
  {
    id: 'sveltekit',
    name: 'SvelteKit',
    tagline: '軽量コンポーネントでレスポンス重視の体験を。',
    docUrl: 'https://kit.svelte.dev/docs',
    family: 'edge',
    renderMode: 'SSR/SSG/Edge',
    strengths: ['最適化済みストア', '小さなバンドル', 'アダプター多数'],
    metrics: { perf: 'A', dx: 'A', coverage: 'Web' },
  },
  {
    id: 'solidstart',
    name: 'SolidStart',
    tagline: 'Fine-grained reactivity でCSR/SSRを統合。',
    docUrl: 'https://start.solidjs.com',
    family: 'edge',
    renderMode: 'SSR + Islands',
    strengths: ['Signals', 'Partial hydration', '強力型推論'],
    metrics: { perf: 'A', dx: 'B+', coverage: 'Web' },
  },
  {
    id: 'qwik',
    name: 'Qwik City',
    tagline: 'Resumability によるサブ50ms表示。',
    docUrl: 'https://qwik.dev',
    family: 'edge',
    renderMode: 'SSR + Resumable',
    strengths: ['遅延ロード自動化', 'シグナル', 'Edge first'],
    metrics: { perf: 'A+', dx: 'B', coverage: 'Web' },
  },
  {
    id: 'nuxt',
    name: 'Nuxt 3',
    tagline: 'Vue ベースのフルスタックで管理画面を多国籍展開。',
    docUrl: 'https://nuxt.com/docs',
    family: 'content',
    renderMode: 'SSG/SSR/Hybrid',
    strengths: ['Nitro server', 'Auto-import composables', '多言語対応'],
    metrics: { perf: 'A-', dx: 'A', coverage: 'Web' },
  },
  {
    id: 'angular-universal',
    name: 'Angular Universal',
    tagline: 'エンタープライズUIでSSRが必要な場合の定番。',
    docUrl: 'https://angular.dev/guide/ssr',
    family: 'content',
    renderMode: 'SSR',
    strengths: ['Strict DI', 'RxJS', '長期保守に強い'],
    metrics: { perf: 'B+', dx: 'B', coverage: 'Web' },
  },
  {
    id: 'gatsby',
    name: 'Gatsby',
    tagline: 'データレイヤー統合が強い静的サイトジェネレータ。',
    docUrl: 'https://www.gatsbyjs.com/docs',
    family: 'content',
    renderMode: 'SSG + DSG',
    strengths: ['GraphQLデータ層', 'プレビュー', '画像最適化'],
    metrics: { perf: 'A-', dx: 'B+', coverage: 'Web' },
  },
  {
    id: 'redwood',
    name: 'RedwoodJS',
    tagline: 'GraphQL + Prisma で管理系を丸ごと統合。',
    docUrl: 'https://redwoodjs.com/docs',
    family: 'interactive',
    renderMode: 'SSR/SPA',
    strengths: ['Cells', 'Storybook統合', 'Auth接続'],
    metrics: { perf: 'B+', dx: 'B+', coverage: 'Web' },
  },
  {
    id: 'expo',
    name: 'Expo + React Native',
    tagline: 'Push通知付きのモバイルクイズ体験を共有コードで。',
    docUrl: 'https://docs.expo.dev',
    family: 'native',
    renderMode: 'Native/Hybrid',
    strengths: ['OTA更新', 'アプリストア出力', 'Webサポート'],
    metrics: { perf: 'A (Native)', dx: 'A-', coverage: 'iOS/Android/Web' },
  },
  {
    id: 'flutter-web',
    name: 'Flutter Web',
    tagline: '単一コードベースでWeb+モバイルのクイズUIを統一。',
    docUrl: 'https://docs.flutter.dev',
    family: 'native',
    renderMode: 'Canvas/WebAssembly',
    strengths: ['Skia描画', 'Widget再利用', 'Firebase連携'],
    metrics: { perf: 'B+', dx: 'A', coverage: 'iOS/Android/Web/Desktop' },
  },
]

const gradients: Record<string, string> = {
  'Vite + React SPA': 'from-[#f9c952] to-[#f6864a]',
  'Next.js App Router (RSC)': 'from-[#0f172a] to-[#475569]',
  'Astro Islands': 'from-[#5b21b6] to-[#db2777]',
  Remix: 'from-[#2563eb] to-[#22d3ee]',
  SvelteKit: 'from-[#f97316] to-[#ea580c]',
  SolidStart: 'from-[#0ea5e9] to-[#6366f1]',
  'Qwik City': 'from-[#22c55e] to-[#16a34a]',
  'Nuxt 3': 'from-[#0ea5e9] to-[#14b8a6]',
  'Angular Universal': 'from-[#dc2626] to-[#ea580c]',
  Gatsby: 'from-[#9333ea] to-[#e879f9]',
  RedwoodJS: 'from-[#b91c1c] to-[#f97316]',
  'Expo + React Native': 'from-[#0ea5e9] to-[#ec4899]',
  'Flutter Web': 'from-[#1d4ed8] to-[#38bdf8]',
}

const comparisonBadges = {
  perf: { 'A+': 'bg-emerald-100 text-emerald-800', A: 'bg-teal-100 text-teal-800', 'A-': 'bg-sky-100 text-sky-800', 'B+': 'bg-amber-100 text-amber-800', B: 'bg-orange-100 text-orange-800' },
  dx: { 'A+': 'bg-purple-100 text-purple-800', A: 'bg-indigo-100 text-indigo-800', 'A-': 'bg-sky-100 text-sky-800', 'B+': 'bg-amber-100 text-amber-800', B: 'bg-orange-100 text-orange-800' },
}

const familyLabels: Record<string, string> = {
  interactive: 'インタラクション重視',
  content: 'コンテンツ配信',
  edge: 'エッジ/高速描画',
  native: 'マルチプラットフォーム',
}

function ArchitectureIcon({ name }: { name: string }) {
  const initials = name
    .replace(/[+()/]/g, ' ')
    .split(' ')
    .filter(Boolean)
    .slice(0, 2)
    .map((part) => part[0]?.toUpperCase())
    .join('')

  return (
    <div className="size-14 rounded-2xl bg-white/80 text-[#14213d] shadow-[0_10px_20px_rgba(20,33,61,0.08)] grid place-items-center font-semibold">
      {initials}
    </div>
  )
}

function ArchitecturesPage() {
  const [filter, setFilter] = useState('all')
  const [activeId, setActiveId] = useState(architectures[0].id)

  const visibleArchitectures = useMemo(() => {
    if (filter === 'all') return architectures
    return architectures.filter((arch) => arch.family === filter)
  }, [filter])

  const activeArchitecture = architectures.find((arch) => arch.id === activeId) ?? architectures[0]

  return (
    <div className="min-h-screen bg-[#fdfcf5] text-[#14213d]">
      <div className="mx-auto flex max-w-6xl flex-col gap-12 px-4 py-12 lg:px-8">
        <section className="grid gap-8 rounded-[28px] bg-gradient-to-br from-[#0f172a] via-[#1e1b4b] to-[#0f766e] p-[clamp(28px,5vw,48px)] text-white lg:grid-cols-[3fr,2fr]">
          <div className="space-y-6">
            <p className="text-sm uppercase tracking-[0.22em] text-white/70">Architecture palette</p>
            <h1 className="text-[clamp(2.2rem,4vw,3.4rem)] font-semibold leading-tight">
              クイズプラットフォームの
              <br />
              アーキテクチャ一覧
            </h1>
            <p className="text-white/80">
              インタラクション重視のフロントエンド、SEO を高めるSSR、モバイルのネイティブ体験まで。選択肢を比較しながら、最適な構成をステークホルダーと共有できるようにまとめました。
            </p>
            <div className="flex flex-wrap gap-4">
              {['Latency 90ms以下', '13アーキテクチャ', '4つのレンダリングモード'].map((stat) => (
                <span key={stat} className="rounded-full bg-white/15 px-4 py-2 text-sm font-medium">
                  {stat}
                </span>
              ))}
            </div>
            <div className="flex flex-wrap gap-3 text-sm text-white/80">
              <span>Hover すると推奨ポイントが更新されます。</span>
              <span>リンクから公式ドキュメントへ。</span>
            </div>
          </div>
          <div className="rounded-3xl bg-white/10 p-6 backdrop-blur">
            <p className="text-sm uppercase tracking-[0.18em] text-white/70">Recommend</p>
            <h2 className="text-2xl font-semibold">{activeArchitecture.name}</h2>
            <p className="mt-2 text-white/80">{activeArchitecture.tagline}</p>
            <dl className="mt-6 space-y-3 text-sm">
              <div className="flex justify-between">
                <dt className="text-white/70">レンダリング</dt>
                <dd>{activeArchitecture.renderMode}</dd>
              </div>
              <div className="flex justify-between">
                <dt className="text-white/70">強み</dt>
                <dd>{activeArchitecture.strengths.join(' / ')}</dd>
              </div>
            </dl>
            <a
              className="mt-6 inline-flex items-center justify-center rounded-full bg-white/90 px-5 py-3 text-sm font-semibold text-[#0f172a] transition hover:-translate-y-0.5 hover:shadow-lg"
              href={activeArchitecture.docUrl}
              target="_blank"
              rel="noreferrer"
            >
              公式ドキュメントを開く
            </a>
          </div>
        </section>

        <section className="space-y-6">
          <div className="flex flex-wrap gap-3">
            {architectureFamilies.map((family) => (
              <button
                key={family.id}
                className={`rounded-full border px-4 py-2 text-sm font-medium transition ${
                  filter === family.id ? 'border-transparent bg-[#14213d] text-white shadow-[0_10px_20px_rgba(20,33,61,0.16)]' : 'border-[#14213d]/15 bg-white text-[#14213d]'
                }`}
                onClick={() => setFilter(family.id)}
              >
                {family.label}
              </button>
            ))}
          </div>
          <p className="text-sm text-[#4f5d75]">
            {architectureFamilies.find((f) => f.id === filter)?.description ?? ''}
          </p>

          <div className="grid gap-6 md:grid-cols-2">
            {visibleArchitectures.map((arch) => (
              <article
                key={arch.id}
                className={`relative overflow-hidden rounded-[26px] border border-[#14213d]/10 bg-white p-5 shadow-[0_18px_36px_rgba(20,33,61,0.08)] transition hover:-translate-y-1 hover:shadow-[0_24px_48px_rgba(20,33,61,0.18)]`}
                onMouseEnter={() => setActiveId(arch.id)}
              >
                <div className={`absolute inset-0 opacity-0 transition-opacity pointer-events-none ${activeId === arch.id ? 'opacity-100' : ''}`}>
                  <div className={`h-full w-full bg-gradient-to-br ${gradients[arch.name]} opacity-5`} />
                </div>
                <div className="relative flex items-start gap-4">
                  <ArchitectureIcon name={arch.name} />
                  <div>
                    <p className="text-xs uppercase tracking-[0.18em] text-[#4f5d75]">{familyLabels[arch.family]}</p>
                    <h3 className="text-lg font-semibold">{arch.name}</h3>
                    <p className="text-sm text-[#4f5d75]">{arch.tagline}</p>
                  </div>
                </div>
                <div className="relative mt-4 flex flex-wrap gap-2">
                  {arch.strengths.map((strength) => (
                    <span key={strength} className="rounded-full bg-[#f7f4ea] px-3 py-1 text-xs text-[#4f5d75]">
                      {strength}
                    </span>
                  ))}
                </div>
                <div className="relative mt-5 flex flex-wrap items-center gap-3 text-xs text-[#4f5d75]">
                  <span className="rounded-full bg-[#14213d]/8 px-3 py-1">{arch.renderMode}</span>
                  <a className="text-[#1768ac] underline underline-offset-2" href={arch.docUrl} target="_blank" rel="noreferrer">
                    Docs
                  </a>
                </div>
              </article>
            ))}
          </div>
        </section>

        <section className="space-y-4">
          <div>
            <p className="text-sm uppercase tracking-[0.2em] text-[#4f5d75]">Comparison</p>
            <h2 className="text-[clamp(1.8rem,3vw,2.4rem)] font-semibold">ユースケース別サマリー</h2>
          </div>
          <div className="overflow-x-auto rounded-[24px] border border-[#14213d]/10 bg-white shadow-[0_18px_36px_rgba(20,33,61,0.08)]">
            <table className="min-w-full border-collapse text-sm">
              <thead className="bg-[#f7f4ea] text-[#4f5d75]">
                <tr>
                  <th className="px-4 py-3 text-left font-semibold">Architecture</th>
                  <th className="px-4 py-3 text-left font-semibold">主なユースケース</th>
                  <th className="px-4 py-3 text-left font-semibold">Performance</th>
                  <th className="px-4 py-3 text-left font-semibold">DX</th>
                  <th className="px-4 py-3 text-left font-semibold">対応プラットフォーム</th>
                </tr>
              </thead>
              <tbody>
                {architectures.map((arch) => (
                  <tr
                    key={arch.id}
                    className={`border-t border-[#14213d]/8 transition hover:bg-[#f9fbff] ${activeId === arch.id ? 'bg-[#f1f5ff]' : ''}`}
                    onMouseEnter={() => setActiveId(arch.id)}
                  >
                    <td className="px-4 py-4 font-semibold">{arch.name}</td>
                    <td className="px-4 py-4 text-[#4f5d75]">{arch.tagline}</td>
                    <td className="px-4 py-4">
                      <span className={`rounded-full px-3 py-1 text-xs font-semibold ${comparisonBadges.perf[arch.metrics.perf as keyof typeof comparisonBadges.perf] ?? 'bg-slate-100'}`}>
                        {arch.metrics.perf}
                      </span>
                    </td>
                    <td className="px-4 py-4">
                      <span className={`rounded-full px-3 py-1 text-xs font-semibold ${comparisonBadges.dx[arch.metrics.dx as keyof typeof comparisonBadges.dx] ?? 'bg-slate-100'}`}>
                        {arch.metrics.dx}
                      </span>
                    </td>
                    <td className="px-4 py-4 text-[#4f5d75]">{arch.metrics.coverage}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </section>

        <section className="rounded-[28px] border border-dashed border-[#14213d]/25 bg-white p-8 text-center shadow-[0_18px_36px_rgba(20,33,61,0.08)]">
          <p className="text-sm uppercase tracking-[0.3em] text-[#4f5d75]">Next Step</p>
          <h3 className="mt-3 text-[clamp(1.6rem,3vw,2.2rem)] font-semibold">検証したいアーキテクチャを選んで PoC を開始しましょう</h3>
          <p className="mt-3 text-[#4f5d75]">
            管理画面の `/architectures` はログインなしでも参照可能です。概要を関係者と共有し、次に試す構成を合意してから実装に着手しましょう。
          </p>
          <div className="mt-6 flex flex-wrap justify-center gap-4">
            <Link
              to="/login"
              className="inline-flex items-center rounded-full bg-[#14213d] px-6 py-3 text-white shadow-[0_12px_24px_rgba(20,33,61,0.22)] transition hover:-translate-y-0.5"
            >
              管理画面に戻る
            </Link>
            <a
              className="inline-flex items-center rounded-full border border-[#14213d]/30 px-6 py-3 text-[#14213d]"
              href="https://github.com/vercel/next.js/tree/canary/examples"
              target="_blank"
              rel="noreferrer"
            >
              参考実装を探す
            </a>
          </div>
        </section>
      </div>
    </div>
  )
}

export default ArchitecturesPage
