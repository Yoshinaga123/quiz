# Firebase API Key Handling

Phase A の Push は Firebase / FCM を使わない（モック配信 + 公開 feed）。`GoogleService-Info.plist` と `google-services.json` は **gitignore** する。手元に残して参照してよい。Git には入れない。

## このリポジトリでの判断

- 他プロダクトの Firebase プロジェクト（別の `PROJECT_ID` / `BUNDLE_ID`）を quiz に載せない
- quiz 用 Firebase を後から足すときも、導入までファイルは gitignore のままにする
- 入れるならこのアプリ自身のプロジェクトだけにする

## 公式ドキュメント

- Firebase API keys: <https://firebase.google.com/docs/projects/api-keys?hl=ja>
- Firebase security checklist: <https://firebase.google.com/support/guides/security-checklist>
- Firebase App Check: <https://firebase.google.com/docs/app-check?hl=ja>

クライアント向け `API_KEY` は「自アプリの設定ファイルに含めてよい」ことがある。それでも **別プロダクトのプロジェクトをこのリポジトリに置いてはならない**。

## 絶対に Git に入れないもの

- FCM server key
- service account private key
- Firebase Admin SDK 用の秘密鍵
- 任意の汎用 Google API キー（Places API, Gemini API など）
