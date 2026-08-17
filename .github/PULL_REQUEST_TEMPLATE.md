## Summary

-

## Checklist

- [ ] プロダクトコードのみ（`samples/` / 診断教材を不用意に増やしていない）
- [ ] 公開契約を変えた場合は OpenAPI・`docs/api/fixtures/`・Zod・Go・詳細設計・テストを同じ PR で更新した
- [ ] 詳細設計のコード例を変えた場合は `packages/web/tests/contract/docs-examples.test.ts` も更新した
- [ ] 詳細設計のページを足した場合は frontmatter と `meta.json` を更新し `npm run docs:llms` を走らせた
- [ ] `npm test` / `npm run lint`（または対象パッケージの同等コマンド）をローカルで通した
