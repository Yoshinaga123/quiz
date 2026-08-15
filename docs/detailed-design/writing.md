---
title: Writing detailed design
description: Page conventions borrowed from Zod docs — frontmatter, kebab-case, executable examples
---

# Writing detailed design

Zod の `packages/docs/content` と同じ約束を、このフォルダに適用する。Fumadocs / MDX サイトは置かない。GitHub 上の Markdown が正本である。

## 新しいページ

1. kebab-case 英語のファイル名（例: `error-formatting.md`）。
2. YAML frontmatter に `title` と `description` を書く（[zod.dev の各 MDX](https://github.com/colinhacks/zod/blob/main/packages/docs/content/basics.mdx) と同じ）。
3. 本文の先頭は `#` 見出し。続けて参照する基本設計（ADR / OpenAPI / architecture）へのリンクを置く。
4. ルート [`meta.json`](./meta.json) と、パッケージフォルダの `meta.json` の両方に載せる。
5. TypeScript の fence を書いたら、`web/tests/contract/docs-examples.test.ts`（または admin 側）で実装と突き合わせる。

```bash
python3 scripts/check_docs.py
python3 scripts/generate_llms_txt.py
```

`check_docs.py` は frontmatter・孤児ページ・相対リンク切れを落とす。`generate_llms_txt.py` は [`../llms.txt`](../llms.txt) と [`../llms-full.txt`](../llms-full.txt) を作り直す。

## 含めるもの / 含めないもの

含める: シーケンス、SQL、`.refine`、画面内状態、実行できるコード例。

含めない: URL 契約そのもの（`docs/api/`）、全体図（`docs/architecture/`）、経緯（`docs/adr/`）、学習メモ（`docs/security-tools/`）。

## 書き方

- 1 ファイル 1 関心事。巨大な「詳細設計書」にまとめない。
- 補足は Zod と同じ callout にする。

> **Note** — OpenAPI に書けない業務ルールは `quiz-schema.md` に残す。yaml の description だけでは契約テストが落ちない。

- 公開 JSON の shape を変えたら [`web/public-contract.md`](./web/public-contract.md) の層を同じ PR で直す。
- 未着手のページは作らない。
