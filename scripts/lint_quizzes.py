#!/usr/bin/env python3
"""クイズ JSON の静的検証スクリプト。

`packages/admin-web/src/data/quizzes.json` などのクイズ配列に対して、
ID 一意性 / `correctAnswerIndex` の範囲 / オプション数の妥当性 / 必須フィールド充足を検査する。

CI で `python3 scripts/lint_quizzes.py packages/admin-web/src/data/quizzes.json` のように実行する想定。
失敗時は終了コード 1 を返し、検出された違反を 1 行 1 件で stderr に出力する。
"""

from __future__ import annotations
"""
from __futire__ import annotationとは、Pythonの型ヒントの評価を遅延させる
自動的に文字列として扱わせる特殊な設定である。
Pythonの組み込み機能であり、将来の標準仕様挙動を先取したものである。
主なメリット

- 前方参照をそのまま書くことができる。クラス定義の中で自分自身の型を指定する際に通常発生するNamedErrorを回避することができる。
- モジュール読み込み時に型ヒントををその場で評価しなくなるため、インポート時の処理速度を向上します。
- 型定義のためだけに読み込んでいる別モジュールとの循環インポートを回避することができる。

# 「設定なし」 エラーになるケース
class Node:
    まだ、Nodeの定義が終わっていないのに、引数の型ヒントで使用するとNamedError
    def set_next(self, node: Node) -> None:
        pass

# 「設定あり」 正常に動くケース
from __future__ import annotations

class Node:
    # 内部で文字列として扱われるため、エラーにならない
    def set_next(self, node: Node) -> None:
        pass

Python 3.7で導入された機能で、型ヒントを多用するモダンなPythonコード (FastAPIやPydanticなどを使う
プロジェクト)では標準的にファイル先頭に書かれることが多い。

型名オブジェクトの評価が行われることが問題
関数を定義する際に、型ヒントに書かれたNodeという名前を見て「Nodeクラス」を存在するかを探して保持する処理
クラス定義の最中に、自身のクラス名を型とするとNameErrorになってしまう。
また、型チェックで使わないにもかかわらず、大量の型オブジェクトをファイルを読み込み時に
一つずつ探して準備するため、アプリの起動が遅くなってしまう。

もともとAnnotationはメタデータを付与することができ、あらゆるPythonオブジェクトがメモとして記述できた。


"""

import argparse
"""
argparseは、Pythonの標準ライブラリに含まれているコマンドライン引数の解析モジュールです。

argparseの三つの主要機能
    - handles both optional and positional arguments
        - 位置引数と任意引数の両方を処理する
    - produces highly informative usage messages
        - 非常に有益な使用法メッセージを生成する
    - supports parsers that dispatch to sub-parsers
        - サブパーサにディスパッチするパーサをサポートする

import argparse

# 1. パーサーの作成
parser = argparse.ArgumentParser(description="ファイル処理用スクリプト")

# 2. 引数の定義
parser.add_argument("filename", help="処理対象のファイルパス")
parser.add_argument(
    "c", "--count", type=int, default=1, help="処理の繰り返し回数"
)
parser.add_argument(
    "-v", "--verbose", action="store_true", help="詳細ログを出力する"
)

# 3. 引数の解析

カッコ内に何も渡していないように見えますが、
引数を省略した場合
parse_args() はターミナルで実行時に入力されたコマンドライン引数(sys.argv)を
自動的に読み込む仕様になっています。

args = parser.parse_args()

# 4. 取得した値の利用
print(f"ファイル名: {args.filename}")

type     引数の型を指定する                 type = int
default  デフォルト値                       default="output.txt"
required オプション引数を必須にするか        required=True
choises  値を限定する                       choices["dev", "prod"]
action   フラグ指定時の動作を設定            action="store_true"

"""
import json
"""
import jsonは、PythonでJSON (JavaScript Object Notation) 形式のデータを読み書き・変換
するための標準ライブラリです。
Pythonの辞書やリストと、JSONフォーマットのテキストやファイルを相互に変換する際に使用する

主な4つの関数

Pythonオブジェクト    →     JSON文字列  json.dumps()
JSON文字列           →     Pythonオブジェクト  json.loads()
JSONファイル         →     Pythonオブジェクト json.dump()

import json

data = {"name": "Alice", "age": 25, "is_admin": False}

# Pythonオブジェクト -> JSON文字列に変換
json_str = jspn.dumps(data, indent=2)
print(json_str)

# JSON文字列 -> Pythonオブジェクトに変換
parsed_data = json.loads(json_str)
print(parsed_data["name"])

# ファイルへの書き込み
with open("data.json", "w") as f:
    json.dump(data, f, indent=2)

# ファイルからの読み込み
with open("data.json", "r") as f:
    loaded_data = json.load(f)

型の自動変換

変換時には以下のようにデータ型が自動でマッピングされます。
dict <-> JSONオブジェクト ({})
list, tuple <-> JSON配列
True / False <-> true / false
None <-> null

"""

import sys
"""
import sysは、Pythonインタプリタや実行環境と直接やり取りをするための機能を提供する標準ライブラリ
コマンドライン引数の直接参照、処理の即時終了、モジュール検索パスの追加など

sys.argv コマンドライン引数の参照
実行時にターミナルから渡された引数のリストのこと
sys.exit() スクリプトの即時終了
sys.path モジュール検索パスの追加
"""
from collections import Counter
"""
Python標準ライブラリのcollectionsモジュールからCounterクラスを読み込むコードです。

from collection import Counter

fruits = ["apple", "banana", "apple", "orange", "banana", "appple"]

count = Counter(fruits)

print(count)

"""

from pathlib import Path
"""
from pathlib import Pathは、Python標準ライブラリのpathlibからPathクラスを読み込むコード
Pathは、ファイルやフォルダのパスを扱いやすくするための機能です。
"""

from typing import Any, Iterable

REQUIRED_STRING_FIELDS = ("section", "title", "question", "explanation", "source")
OPTIONAL_STRING_FIELDS = ("code",)


def iter_quizzes(payload: Any) -> list[dict[str, Any]]:
    if isinstance(payload, list):
        return payload
    if isinstance(payload, dict) and isinstance(payload.get("quizzes"), list):
        return payload["quizzes"]
    raise ValueError(
        "Unsupported JSON shape: expected an array or { quizzes: [...] } object",
    )


def validate_quiz(quiz: dict[str, Any], index: int) -> Iterable[str]:
    prefix = f"#{index} (id={quiz.get('id', '?')})"

    quiz_id = quiz.get("id")
    if not isinstance(quiz_id, int) or quiz_id <= 0:
        yield f"{prefix}: id must be a positive integer"

    for field in REQUIRED_STRING_FIELDS:
        value = quiz.get(field)
        if not isinstance(value, str) or value.strip() == "":
            yield f"{prefix}: '{field}' must be a non-empty string"

    for field in OPTIONAL_STRING_FIELDS:
        value = quiz.get(field)
        if value is not None and not isinstance(value, str):
            yield f"{prefix}: '{field}' must be a string when present"

    options = quiz.get("options")
    if not isinstance(options, list) or len(options) < 2:
        yield f"{prefix}: 'options' must contain at least 2 entries"
        return

    if any(not isinstance(opt, str) or opt.strip() == "" for opt in options):
        yield f"{prefix}: every option must be a non-empty string"

    correct = quiz.get("correctAnswerIndex")
    if not isinstance(correct, int) or correct < 0 or correct >= len(options):
        yield (
            f"{prefix}: 'correctAnswerIndex' must be in [0, {len(options) - 1}] "
            f"(got {correct!r})"
        )


def detect_duplicates(quizzes: list[dict[str, Any]]) -> Iterable[str]:
    ids = [quiz.get("id") for quiz in quizzes if isinstance(quiz.get("id"), int)]
    duplicate_ids = [item for item, count in Counter(ids).items() if count > 1]
    for dup in sorted(duplicate_ids):
        yield f"duplicate id detected: {dup}"

    titles = [
        (quiz.get("section"), quiz.get("title"))
        for quiz in quizzes
        if isinstance(quiz.get("title"), str)
    ]
    duplicate_titles = [
        item for item, count in Counter(titles).items() if count > 1 and item[1]
    ]
    for section, title in sorted(duplicate_titles):
        yield f"duplicate title within section '{section}': {title!r}"


def lint_file(path: Path) -> int:
    try:
        with path.open("r", encoding="utf-8") as fp:
            payload = json.load(fp)
    except FileNotFoundError:
        print(f"error: file not found: {path}", file=sys.stderr)
        return 2
    except json.JSONDecodeError as exc:
        print(f"error: invalid JSON in {path}: {exc}", file=sys.stderr)
        return 2

    try:
        quizzes = iter_quizzes(payload)
    except ValueError as exc:
        print(f"error: {exc}", file=sys.stderr)
        return 2

    violations: list[str] = []
    for index, quiz in enumerate(quizzes):
        if not isinstance(quiz, dict):
            violations.append(f"#{index}: entry must be an object")
            continue
        violations.extend(validate_quiz(quiz, index))
    violations.extend(detect_duplicates(quizzes))

    if violations:
        for line in violations:
            print(line, file=sys.stderr)
        print(
            f"FAIL: {len(violations)} violation(s) in {path} ({len(quizzes)} quizzes)",
            file=sys.stderr,
        )
        return 1

    print(f"OK: {path} ({len(quizzes)} quizzes)")
    return 0


def parse_args(argv: list[str] | None = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "paths",
        nargs="+",
        type=Path,
        help="lint 対象の JSON ファイルパス（複数指定可）",
    )
    return parser.parse_args(argv)


def main(argv: list[str] | None = None) -> int:
    args = parse_args(argv)
    exit_code = 0
    for path in args.paths:
        result = lint_file(path)
        exit_code = max(exit_code, result)
    return exit_code


if __name__ == "__main__":
    raise SystemExit(main())
