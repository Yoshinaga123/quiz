# packages

商品（実行するアプリ）と、Zod と同じ実行速度計測だけを置く。説明書は [`../docs/`](../docs/INDEX.md)。kB 計測の `scratch/` は gitignore。

| パッケージ | 役割 |
| --- | --- |
| [`web/`](web/) | ユーザー向け解答 UI |
| [`admin-web/`](admin-web/) | 管理画面 |
| [`backend/`](backend/) | Go API |
| [`mobile/`](mobile/) | Flutter クライアント |
| [`bench/`](bench/) | 実行速度（ops/sec）。商品ではない。運用経緯は [Issue #19](https://github.com/Yoshinaga123/quiz/issues/19) |
