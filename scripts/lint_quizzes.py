#!/usr/bin/env python3
"""クイズ JSON の静的検証スクリプト。

`packages/admin-web/src/data/quizzes.json` のクイズ配列に対して、
ID 一意性 / `published` / `correctAnswerIndex` の範囲 / オプション数の妥当性 / 必須フィールド充足を検査する。

CI で `python3 scripts/lint_quizzes.py packages/admin-web/src/data/quizzes.json` のように実行する想定。
失敗時は終了コード 1 を返し、検出された違反を 1 行 1 件で stderr に出力する。
"""

from __future__ import annotations

import argparse
import json
import sys
from collections import Counter
from pathlib import Path
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

    published = quiz.get("published")
    if not isinstance(published, bool):
        yield f"{prefix}: 'published' must be a boolean"

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

    published_count = sum(1 for quiz in quizzes if quiz.get("published") is True)
    print(f"OK: {path} ({len(quizzes)} quizzes, {published_count} published)")
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
