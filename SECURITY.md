# Security Policy

## 対象

本番想定の公開面は `https://socrates-quiz.jp`（未デプロイ時はローカル `backend`）。  
公開 API は匿名・`published` クイズのみ。管理 API は JWT 必須。

## 報告

脆弱性は **GitHub Security Advisories**（このリポジトリの Security タブ）で非公開報告してください。  
Issue に PoC や認証情報を貼らないでください。

診断手順の教材（`docs/security-tools/`、`archive/`）はプロダクトの保証範囲ではありません。

## 既知の開発時前提

- docker-compose の管理者パスワードと `JWT_SECRET` は開発用。本番では必ず差し替える。
- 現状の CORS は Origin 反射（開発向け）。本番では allowlist 化する（`docs/counter-api.md`）。
