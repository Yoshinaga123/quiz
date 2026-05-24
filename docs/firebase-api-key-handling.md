# Firebase API Key Handling

このドキュメントは、`mobile/ios/Runner/GoogleService-Info.plist` に含まれる Firebase API キーの扱いを整理するためのメモである。

## 現在の状態

- 対象ファイル: `mobile/ios/Runner/GoogleService-Info.plist`
- 含まれる値:
  - `API_KEY`
  - `GOOGLE_APP_ID`
  - `PROJECT_ID`
  - `GCM_SENDER_ID`
- 初回追加コミット:
  - `517e263` (`Commit all current workspace changes`)
- 現在の到達先:
  - `develop`
  - `origin/develop`

つまり、このファイルは**すでに Git 履歴に存在し、push 済みとみなしてよい**。

## 結論

現時点で、`GoogleService-Info.plist` に含まれる Firebase の `API_KEY` だけを理由に、**緊急で Git 履歴を書き換える必要性は低い**。

理由:

- Firebase 公式ドキュメントでは、Firebase サービス用の API キーは通常の API キーとは異なり、バックエンド リソースへのアクセス制御には使われない
- Firebase 公式ドキュメントでは、Firebase サービス用の API キーはコードやチェックイン済み設定ファイルに含めても問題ないとしている

ただし、これは「何も気にしなくてよい」という意味ではない。**制限と周辺設定の確認は必要**。

## 公式ドキュメントで確認できること

Firebase 公式ドキュメント:

- Firebase API keys
  - <https://firebase.google.com/docs/projects/api-keys?hl=ja>
- Firebase security checklist
  - <https://firebase.google.com/support/guides/security-checklist>
- Firebase App Check
  - <https://firebase.google.com/docs/app-check?hl=ja>

要点:

- Firebase サービスの API キーは、バックエンド リソースの認可には使われない
- Firebase サービスの API キーは、コードまたはチェックイン済みの構成ファイルに含めてもよい
- Firebase が自動作成する `iOS key` / `Android key` / `Browser key` には、デフォルトで API 制限が付く
- Firebase は Apple アプリではバンドル ID にマッチする「アプリケーションの制限」を見てキーを関連付ける
- バックエンド保護には API キー秘匿ではなく、Security Rules と App Check を使う

## このリポジトリでの判断

### 履歴削除の要否

不要寄り。

`GoogleService-Info.plist` の `API_KEY` は、Firebase 公式の整理では「クライアント配布前提の設定値」に近い。一般的な秘密鍵やサーバー側トークンと同列には扱わない。

### 追跡方針

次のどちらかに統一する。

1. Firebase をこのアプリで使う前提なら、追跡を継続する
2. まだ使わないなら、いったんリポジトリから外し、導入時に再追加する

中途半端なのが一番よくない。現状は iOS のみ設定ファイルがあり、Android 側の `google-services.json` は存在しないため、**「将来使う予定の半端な設定が先に入っている状態」** ではある。

## 継続して追跡する場合の確認項目

Firebase Console / Google Cloud Console で次を確認する。

1. 対象キーが Firebase により自動作成された `iOS key` であること
2. API 制限が Firebase 関連 API に絞られていること
3. Apple アプリ向けのアプリケーション制限が妥当であること
4. 不要な Google API に使い回していないこと
5. Firebase を使うデータ系サービスでは Security Rules を閉じること
6. 対応サービスでは App Check を有効化すること

## 絶対に分けて扱うもの

次は `GoogleService-Info.plist` の `API_KEY` とは別物なので、**秘密として扱う必要がある**。

- FCM server key
- service account private key
- Firebase Admin SDK 用の秘密鍵
- 任意の汎用 Google API キー（Places API, Gemini API など）

Firebase の security checklist でも、FCM server keys と service account private keys は secret として保持すべきと明示されている。

## 実務上のおすすめ

このリポジトリでは次を推奨する。

1. まず Firebase Console で当該 `API_KEY` の制限を確認する
2. Firebase をまだ本格利用していないなら、追跡継続の是非を決める
3. Firebase を使うなら `mobile/README.md` に「なぜこのファイルを追跡してよいか」を明記する
4. 将来 FCM server key や service account key を使う場合は、絶対に Git に入れない
