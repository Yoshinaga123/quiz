const toPackageRel = (file, prefix) => {
  const normalized = file.replaceAll('\\', '/')
  const marker = `/${prefix}/`
  const index = normalized.lastIndexOf(marker)
  if (index >= 0) {
    return normalized.slice(index + marker.length)
  }
  return normalized.replace(new RegExp(`^${prefix}/`), '')
}

const eslintIn = (prefix, filenames) => {
  const files = filenames.map((file) => toPackageRel(file, prefix)).join(' ')
  return `bash -lc ${JSON.stringify(`cd ${prefix} && npx eslint --max-warnings=0 ${files}`)}`
}

export default {
  'packages/web/{src,tests}/**/*.{ts,tsx}': (filenames) => eslintIn('packages/web', filenames),
  'packages/admin-web/{src,tests}/**/*.{ts,tsx}': (filenames) => eslintIn('packages/admin-web', filenames),
  'packages/backend/**/*.go': 'gofmt -w',
  '{docs/api/**,packages/web/src/schemas/**,packages/web/src/api/quiz.ts,packages/backend/types.go,docs/detailed-design/web/**,docs/detailed-design/meta.json}':
    'python3 scripts/check_public_contract.py',
  'docs/detailed-design/**': 'python3 scripts/check_docs.py',
  '{AGENTS.md,docs/detailed-design/meta.json,package.json,.nvmrc,.editorconfig}':
    'python3 scripts/check_repo_hygiene.py',
}
