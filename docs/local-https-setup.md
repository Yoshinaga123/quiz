# ローカル HTTPS 設定

## 概要

ローカル開発環境で HTTPS を使えるようにするための自己署名証明書と Vite 設定の手順。

## 証明書の場所

```
certs/
  localhost-cert.pem   # 証明書
  localhost-key.pem    # 秘密鍵
```

- `certs/` はリポジトリルートに配置
- `.gitignore` で除外推奨（秘密鍵を含む）
- 有効期限: 365 日

## 起動 URL

| サービス | URL |
|---|---|
| `packages/web/` | `https://localhost:5174/` |
| `packages/admin-web/` | `https://localhost:5173/` |

## セットアップ手順

### 1. 証明書を生成する

リポジトリルートで実行する。

```bash
mkdir -p certs && cd certs
openssl req -x509 -newkey rsa:2048 -nodes \
  -keyout localhost-key.pem -out localhost-cert.pem \
  -days 365 -subj "/CN=localhost" \
  -addext "subjectAltName=DNS:localhost,IP:127.0.0.1"
```

### 2. .gitignore に追加する

```bash
echo "certs/" >> .gitignore
```

### 3. Vite 設定を更新する

`packages/web/vite.config.ts` と `packages/admin-web/vite.config.ts` の両方に以下を追加する。

```ts
import fs from 'node:fs'
import path from 'node:path'

const certDir = path.resolve(__dirname, '../certs')

export default defineConfig({
  // ...
  server: {
    https: {
      key: fs.readFileSync(path.join(certDir, 'localhost-key.pem')),
      cert: fs.readFileSync(path.join(certDir, 'localhost-cert.pem')),
    },
  },
})
```

### 4. 起動して確認する

```bash
cd packages/web && npm run dev       # https://localhost:5174/
cd packages/admin-web && npm run dev # https://localhost:5173/
```

証明書が適用されているか確認する場合:

```bash
echo | openssl s_client -connect localhost:5173 2>/dev/null \
  | openssl x509 -noout -text \
  | grep -E "Issuer:|Subject:|Not Before|Not After|DNS:|IP Address"
```

## Windows 証明書ストアへの登録（WSL2 環境）

ブラウザの警告を消すには、証明書を Windows の信頼済みルート証明機関に登録する。
WSL2 ターミナルから以下を実行する。

```bash
CERT_PATH=$(wslpath -w /path/to/certs/localhost-cert.pem)
powershell.exe -Command "Import-Certificate -FilePath '$CERT_PATH' -CertStoreLocation Cert:\\CurrentUser\\Root"
```

登録後は Chrome / Edge を再起動する。

> `LocalMachine\Root` に登録するには管理者権限が必要。`CurrentUser\Root` であれば管理者権限不要で同様の効果が得られる。

## 証明書の再生成

有効期限切れや鍵の再作成が必要な場合は `certs/` を削除して手順 1 からやり直す。

```bash
rm -rf certs/
# 手順 1 を再実行
```
