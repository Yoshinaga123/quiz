# The Magic of TypeScript with Matt Pocock - Transcript

出典: https://www.epicweb.dev/bonuses/interviews-with-experts/the-magic-of-typescript-with-matt-pocock

Kent C. Dodds と Matt Pocock の対談トランスクリプト。

ユーザーが提供したトランスクリプトに基づく要約・注釈付きノートです。

---

## 00:00:00 - 00:01:44 自己紹介と経歴

- Kent が Matt を紹介。「TypeScript の人」として知られる
- Matt の経歴: Vercel（Developer Advocate） → Stately（XState コアチーム） → フルタイム TypeScript 教育者
- XState の複雑な型問題と格闘する中で TypeScript に深くのめり込んだ
- 同僚の Mateusz Brzezinski（TypeScript エキスパート）から多くを学んだ

## 00:01:44 - 00:03:41 「○○の人」になる過程

- Kent: 自分も「テスティングの人」になるつもりはなかった。Testing Library を作り、質問に答えているうちに自然とそうなった
- Matt: XState の動画を出していたが、TypeScript の動画を投稿したら大反響。「TypeScript の Rodney Mullen」と呼ばれるように
- **Matt の名言: "It turns out if you reply, they just ask you more."**（返信すれば、もっと質問が来る）

## 00:03:41 - 00:06:27 教育者としての課題

- 両者とも「日常の開発現場から離れるリスク」を認識
- Matt: JIRA もバーンダウンチャートもないが、人々の質問が日常の開発感覚を維持してくれる
- Kent: 2019年にフルタイム教育者になった時、同じ懸念があった

## 00:06:42 - 00:09:19 なぜ TypeScript を使うべきか

- TypeScript 誕生の背景: 約11年前、JavaScript は大規模アプリに向いていなかった
- 現代の JavaScript の最大の問題は **IDE 体験の悪さ**
- TypeScript を使うと: 自動補完、IDE 内エラー、リファクタリングツール、Go to Definition が使える
- **Matt の比喩: 「英語の先生が肩越しにずっと見ていて、赤い波線を引いてくれる」**
- **Airbnb の事例: "I can't remember what the exact figure was, but it was something like 38% of all of their bugs they shipped to production could have been prevented by TypeScript"**

## 00:09:19 - 00:10:54 TypeScript は表現の自由を制限するか

- Kent の質問: TypeScript は JavaScript の表現力を制限しないか？
- **Matt: "TypeScript, basically TypeScript describes JavaScript"**（TypeScript は JavaScript を記述するもの）
- ほとんどの JavaScript コードは少ない型注釈で済む
- プロトタイプ操作や deprecated 機能には弱い
- TypeScript はメインパスに集中させ、「魔法のようなダンス」を減らす方向に誘導する
- チーム設定ではこの制約は良いもの

## 00:10:54 - 00:13:42 ジェネリクスとライブラリ開発

- **Jared Forsyth の名言: "If it's hard to type, then it's probably hard to understand as well"**
- ライブラリ開発では「未知の穴（slot）」を埋める必要がある
- 例: `groupBy` 関数 — 渡されるオブジェクトの型やキーが事前に不明
- TanStack Query は 4〜5 個のジェネリクスパラメータを持つ
- アプリケーションコードでは通常、すべての入出力を具体的に知っている

## 00:13:42 - 00:15:24 キャスティングの倫理

- Kent: ライブラリの内部では `as any` などのキャストを使うことがある。適切なセーフガードがあれば許容できる
- **Kent の重要なルール: `JSON.parse` や `fetch` の戻り値にジェネリクスを使って型安全性を装うな**
  - ジェネリクスは「ライブラリがこの型を保証してくれている」と見えるが、実際は any を隠しているだけ
  - 嘘を自覚してつくのはいいが、ジェネリクスで嘘に気づかなくなるのが問題
- **Matt: "What you're doing really is you're just hiding in any underneath a beautiful look generic signature"**
- Matt: `fetch` でも同じ問題。エンドポイントが壊れる可能性は常にある
- TypeScript はまだ完成していない。5.3 でジェネリック関数内の推論が改善される予定

## 00:17:49 - 00:20:09 TypeScript が「うるさい」ケースの対処

- Kent: `useRef` で DOM ノードに渡す場合、use effect 内では必ず存在するのに TypeScript が null かもしれないと言う
- Matt: search params も同様。ID が必ずあると分かっているのにチェックを強いられる
- GraphQL の型生成で全てが undefined になるケースも
- **Matt の対処: `!` 演算子（bang operator）を使う。「これはここにあると分かっている」と宣言する**
- TypeScript を学ぶ過程には「いつルールを少し曲げていいか」を学ぶことも含まれる

## 00:20:09 - 00:25:32 データ境界のバリデーション

- **Kent の名言: "TypeScript doesn't make your life terrible. It just shows you how terrible your life is."**
- Matt の風呂のシーリング比喩: 道具が不十分だと余計な労力がかかる。良い道具があれば他のことにエネルギーを使える
- Kent の反論: `useRef` の場合、今日は null にならなくても、明日同僚が条件付きレンダリングを入れたら null になる。今のうちに対処すべき
- **Kent の Zod 推奨: ランタイムで来る値は、ランタイムでパースすべき**
- Matt: `document.getElementById` は null でも即座にエラーが分かる。しかし API データが欠けている場合、14層下でエラーになると地獄
- **核心: アプリケーションの境界（API、フォーム、公開エンドポイント）でデータを検証せよ**

## 00:26:27 - 00:29:00 初心者へのアドバイス

- Total TypeScript の無料チュートリアル（ビギナー向け、React 向け）
- TypeScript 公式ハンドブック
- **始めるのに必要な最低限: 関数パラメータの型注釈、基本型、オブジェクト型、配列型のみ**
- 現在はほぼすべてのフロントエンドフレームワークが TypeScript をオプションまたはデフォルトで提供

## 00:29:00 - 00:33:20 戻り値型を常に明示すべきか

- TypeScript の設定で「戻り値型の明示を強制する」ルールがある
- **Matt: このルールはトラブルの方が多い**
  - 戻り値型が実際より広くなる（`string | number` と書いたが実際は `string` のみ）
  - 関数本体を変更しても戻り値型の更新を忘れる
  - サードパーティライブラリの内部型を知る必要がある（例: React Query）
  - React コンポーネントは常に `ReactNode` を返すので注釈不要
- **明示すべき場面: utils フォルダの関数、ドメイン関数、複雑な内部ロジック**
- **Matt: "I think you shouldn't [always require explicit return types]. I still think you should use return types when you need to and when it makes sense."**

## 00:34:17 - 00:40:15 type vs interface

### interface extends の優位性（パフォーマンス）
- 交差型（`&`）は TypeScript にとって計算コストが高い
- `interface extends` は名前を付けるため、TypeScript がキャッシュできる
- **Matt: "interface is the clear winner because over the entire process of your application...it can just do more caching"**

### 宣言マージの落とし穴
- 同名の `type` を2回宣言 → コンパイルエラー（安全）
- 同名の `interface` を2回宣言 → 自動マージ（意図しないバグの原因）
- **Matt: "If you've got a 4,000 line file, if you've got 2 interfaces declared in the same scope with the same name, that's going to kill you"**

### 結論
- 単純なオブジェクト型 → `type` を推奨（宣言マージの罠を避ける）
- extends や型の合成 → `interface extends` を推奨（パフォーマンス）
- **Matt: "They're both first class primitives in the language. I don't see why you have to choose one or the other."**
- Kent: "I'm not your mom, so do whatever you want."

## 00:40:37 - 00:43:03 React.FC について

- 以前の `React.FC` の問題: children を暗黙的に追加、undefined/null/number を返せない
- TypeScript 5.1 以降 + 最新の Types React: 問題は解消
- 唯一の欠点: ジェネリックコンポーネントにリファクタリングする時に `React.FC` を外す手間
- Matt: 「今は問題ない。気にしない」

## 00:43:03 - 00:46:43 TypeScript と関数分割のコスト

- Kent: Clean Code の「関数は数行に」というルールに従っていたが、徐々に長い関数を許容するように
- TypeScript で関数を分割すると、型注釈の定義という追加コストが発生
- 例: Prisma のクエリ結果を別関数に渡す場合、型を明示的に定義する必要がある
- **Matt: 「一時的な混沌を許容する能力は重要」**
- React コンポーネントが2000行あっても問題ない。適切な抽象化が見つかるまで待てばいい
- **TypeScript は「少し散らかっていても大丈夫」というクッションを提供する**

## 00:46:43 - 00:48:35 Utils フォルダの重要性と締め

- Matt: App と Library だけでなく **Utils フォルダが第三の重要空間**
- 4年前に誰かが書いた複雑な関数が全体に使われている場合、その型付けが全体品質を決める
- そこに `any` を入れると全体に伝播する
- **連絡先: Discord（mattpococktt.com/discord）が最良。Twitter（@mattpocockuk）も可**
- Discord には「wizard's council」的な有識者がいて、質問の回答品質が非常に高い
- **学習の最良の方法: 人の質問に答えること**
