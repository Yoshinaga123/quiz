# Dart `late` 修飾子

## 概要

`late` は Dart の null safety における修飾子で、2つのユースケースを持つ。

1. **宣言の後に初期化される non-nullable 変数の宣言**
2. **変数の遅延初期化（lazy initialization）**

## ユースケース 1: 後から代入する non-nullable 変数

### 問題

`async` の結果など、宣言時に値を代入できないケースがある。

```dart
// NG — await はフィールド宣言で使えない
SharedPreferences sharedPref = await SharedPreferences.getInstance();

// NG — インスタンス変数は non-nullable かつ初期値なしで宣言できない
class MyClass {
  String s; // コンパイルエラー
}
```

### なぜコンパイルエラーになるか

Dart コンパイラは「使用前に代入されているか」を静的に分析しようとする。

- **ローカル変数**: 関数内で上から下へ追えるため、分析が成功する
- **インスタンス変数・トップレベル変数**: どこから・どの順でアクセスされるか追跡できないため、分析を諦める。結果として non-nullable + 初期値なしは一律コンパイルエラーになる

### `late` による解決

```dart
late SharedPreferences sharedPref;
```

`late` を付けると、コンパイラの静的検証をスキップし、代わりに**実行時に未代入チェック**を行う。

- 代入後にアクセス → 正常動作
- 未代入のままアクセス → `LateInitializationError`（ランタイムエラー）

### `late` vs nullable の比較

| 方法 | non-nullable | 未代入検知 |
|---|---|---|
| `late String s;` | ○ | ○（実行時エラー） |
| `String? s;` | ✕（nullable） | ✕（null のまま素通り） |
| `String s;`（インスタンス変数） | ー | ー（コンパイルエラーで宣言自体できない） |

### `late` は静的検証の妥協である

`late` は静的検証を**強化**するものではなく、**緩める**ものである。

```
通常:     コンパイル時に「初期値がない」→ コンパイルエラー（静的検証）
late付き: コンパイル時はスルー → 実行時に未代入ならエラー（ランタイム検証）
```

安全性を重視する場合は、`late` よりも nullable + null チェックの方が静的検証の恩恵を受けられる。

```dart
SharedPreferences? _prefs;

void greet() {
  final prefs = _prefs;
  if (prefs == null) return; // 静的検証で安全
  print(prefs.getString('key'));
}
```

開発者が `late` を使う動機は「安全のために積極的に使う」よりも、「`late` を使わないと書けないからやむを得ず使う」が実態である。

## ユースケース 2: 遅延初期化（lazy initialization）

`late` を付けつつ宣言時に初期化子を書くと、**変数が最初に使われた時点で**初期化子が実行される。

```dart
// temperature が一度も使われなければ readThermometer() は呼ばれない
late String temperature = readThermometer();
```

※ 初期化子 = `=` の右側の式（変数に最初の値を与える式）のこと。

### 便利なケース

- **使われない可能性があり、初期化コストが高い場合** — ユーザーの操作によっては通らない画面の重い処理など
- **インスタンス変数の初期化子が `this`（他のフィールド）にアクセスする必要がある場合**

### `this` アクセスの問題

Dart ではインスタンス変数の初期化子はオブジェクトの生成途中に実行される。フィールドは上から順に1つずつ初期化されるため、途中で他のフィールドを参照すると未完成のオブジェクトにアクセスすることになる。Dart はこれを禁止している。

```dart
class Rectangle {
  final int width = 10;
  final int height = 20;

  // NG — 初期化時点で他のフィールドを参照できない
  int area = width * height; // コンパイルエラー
}
```

`late` を付けると初期化がアクセス時まで遅延されるため、その時点では全フィールドが代入済みであり参照できる。

```dart
class Rectangle {
  final int width = 10;
  final int height = 20;

  // OK — area を読む時点では全フィールドが完成済み
  late int area = width * height;
}
```

この制約は Dart 言語仕様で明確に定められている（`An instance variable initializer cannot access this`）。理由は、フィールドの宣言順を入れ替えただけで壊れるバグを防ぐための設計判断である。

### 他の言語との比較

| 言語 | 初期化子での他フィールド参照 | 方針 |
|---|---|---|
| **Dart** | 禁止 | 初期化子で `this` を使えない |
| **Swift** | 禁止 | 2フェーズ初期化。全プロパティ代入完了まで `self` 使用不可 |
| **Java** | 許可（危険） | 上から順に初期化。未初期化フィールドはデフォルト値（0, null）で見え、静かにバグになる |
| **Kotlin** | 許可（危険） | 宣言順に初期化。未初期化のプロパティを参照すると 0 や null が返る |
| **C++** | 許可（危険） | 宣言順に初期化。順序を間違えると未定義動作 |

Java / Kotlin / C++ は許可する代わりに、順序を間違えると静かにバグになる：

```java
// Java — コンパイル通るが area は 0 になる
class Rectangle {
    int area = width * height; // width=0, height=0 の時点で計算
    int width = 10;
    int height = 20;
}
```

Dart と Swift は「そもそも許可しない」ことでこの種のバグを根絶する設計であり、より安全側に倒している。
