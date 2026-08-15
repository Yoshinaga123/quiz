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
  'web/{src,tests}/**/*.{ts,tsx}': (filenames) => eslintIn('web', filenames),
  'admin-web/{src,tests}/**/*.{ts,tsx}': (filenames) => eslintIn('admin-web', filenames),
  'backend/**/*.go': 'gofmt -w',
  '{docs/api/**,web/src/schemas/**,web/src/api/quiz.ts,backend/types.go,docs/detailed-design/web/**,docs/detailed-design/meta.json}':
    'python3 scripts/check_public_contract.py',
  'docs/detailed-design/**': 'python3 scripts/check_docs.py',
  '{AGENTS.md,docs/detailed-design/meta.json,package.json,.nvmrc,.editorconfig}':
    'python3 scripts/check_repo_hygiene.py',
}
