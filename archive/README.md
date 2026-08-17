# Archive / learning

プロダクトの実行に不要な学習・診断・教材の案内。

`samples/`、`game/`、`reports/`、`falling_puzzle`、juice-shop ダンプは **gitignore** する。手元の作業ツリーには残して参照できる。clone した公開リポジトリには含まれない。他プロダクトのクローンを Git に戻さない。

| パス | 内容 | 公開リポジトリ |
| --- | --- | --- |
| `samples/` | 参考クローン・教材（手元のみ） | 含めない |
| `game/` `falling_puzzle` | 無関係な試作（手元のみ） | 含めない |
| `reports/` | 診断レポート出力（手元のみ） | 含めない |
| [`../docs/security-tools/`](../docs/security-tools/owasp-zap.md) | ZAP / Burp / w3af の手順メモ | 含める |
| [`../docs/penetration-testing.md`](../docs/penetration-testing.md) | ペネトレーション導入メモ | 含める |

本番ラインは `packages/web/` `packages/admin-web/` `packages/mobile/` `packages/backend/` と `docs/architecture/` `docs/api/` `docs/adr/` `docs/detailed-design/` のみ。
