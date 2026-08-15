# admin-web/scripts

Zod リポジトリの [`play.ts`](https://github.com/colinhacks/zod/blob/main/play.ts) 相当。  
管理画面スキーマの試し書きはここに置く。`src/` には残さない。

| ファイル | 用途 |
| --- | --- |
| `try-auth-parse.ts` | ログイン / 確認コードスキーマの手動確認 |

```bash
cd admin-web
npx --yes tsx scripts/try-auth-parse.ts
```

恒久ケースは `tests/schemas/` に書く。
