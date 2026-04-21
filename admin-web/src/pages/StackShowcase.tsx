import reactLogo from '../assets/react.svg'

interface LogoItem {
  name: string
  href: string
  src: string
  bg?: string
}

const logos: LogoItem[] = [
  { name: 'Vite', href: 'https://vite.dev', src: '/vite.svg' },
  { name: 'React', href: 'https://react.dev', src: reactLogo },
  { name: 'TypeScript', href: 'https://www.typescriptlang.org/', src: 'https://cdn.simpleicons.org/typescript/3178C6' },
  { name: 'Flutter', href: 'https://www.flutter.dev', src: 'https://cdn.simpleicons.org/flutter/02569B' },
  { name: 'PostgreSQL', href: 'https://www.postgresql.org/', src: 'https://cdn.simpleicons.org/postgresql/336791' },
  { name: 'Docker', href: 'https://www.docker.com/', src: 'https://cdn.simpleicons.org/docker/2496ED' },
  { name: 'JWT', href: 'https://jwt.io/', src: 'https://cdn.simpleicons.org/jsonwebtokens/000000', bg: 'bg-[#f5f5f5]' },
  { name: 'Firebase Cloud Messaging', href: 'https://firebase.google.com/docs/cloud-messaging', src: 'https://cdn.simpleicons.org/firebase/FFCA28' },
  { name: 'Apple Push Notification service', href: 'https://developer.apple.com/notifications/', src: 'https://cdn.simpleicons.org/apple/000000', bg: 'bg-white' },
  { name: 'Go', href: 'https://golang.org/', src: 'https://cdn.simpleicons.org/go/00ADD8' },
]

function StackShowcase() {
  return (
    <main className="min-h-screen bg-[#fdfcf5] px-4 py-12 text-center text-[#14213d]">
      <section className="mx-auto flex max-w-5xl flex-col gap-6">
        <div className="grid gap-3">
          <p className="text-sm uppercase tracking-[0.24em] text-[#4f5d75]">Tech Stack</p>
          <h1 className="text-[clamp(1.8rem,4vw,2.8rem)] font-semibold">
            Vite + React + TypeScript + Flutter + Go + PostgreSQL + Docker + JWT + FCM / APNs
          </h1>
          <p className="text-[#4f5d75]">このプロジェクトで採用している主要スタックの公式サイトリンクです。</p>
        </div>
        <div className="grid gap-4 rounded-[28px] border border-[#14213d]/10 bg-white/90 p-6 shadow-[0_18px_36px_rgba(20,33,61,0.08)] md:grid-cols-5">
          {logos.map((logo) => (
            <a
              key={logo.name}
              className="group flex flex-col items-center gap-2 rounded-2xl p-3 transition hover:-translate-y-1 hover:shadow-[0_12px_24px_rgba(20,33,61,0.14)]"
              href={logo.href}
              target="_blank"
              rel="noreferrer"
              title={logo.name}
            >
              <div className={`flex size-20 items-center justify-center rounded-2xl bg-[#f5f5f5] ${logo.bg ?? ''}`}>
                <img alt={`${logo.name} logo`} className="max-h-[56px] max-w-[56px]" src={logo.src} />
              </div>
              <span className="text-sm font-medium text-[#4f5d75]">{logo.name}</span>
            </a>
          ))}
        </div>
      </section>
    </main>
  )
}

export default StackShowcase
