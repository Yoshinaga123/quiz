#!/usr/bin/env python3
"""2 つのクイズ JSON の差分を要約するツール。

2 つのクイズ JSON を ID 単位で比較し、

  - 基準側にしか存在しない ID
  - 比較対象にしか存在しない ID
  - 両者に存在するが内容が異なる ID

を一覧化する。公開可否は `quizzes.json` の `published` で管理する。

例:
  python3 scripts/diff_quiz_data.py \
    packages/admin-web/src/data/quizzes.json \
    other-quizzes.json
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path
from typing import Any

DIFF_FIELDS = (
    "section",
    "title",
    "question",
    "code",
    "options",
    "correctAnswerIndex",
    "explanation",
    "source",
)


def load_quizzes(path: Path) -> dict[int, dict[str, Any]]:
    with path.open("r", encoding="utf-8") as fp:
        payload = json.load(fp)

    if isinstance(payload, dict) and isinstance(payload.get("quizzes"), list):
        items = payload["quizzes"]
    elif isinstance(payload, list):
        items = payload
    else:
        raise ValueError(f"Unsupported JSON shape in {path}")

    indexed: dict[int, dict[str, Any]] = {}
    for entry in items:
        if not isinstance(entry, dict):
            continue
        quiz_id = entry.get("id")
        if isinstance(quiz_id, int):
            indexed[quiz_id] = entry
    return indexed


def quiz_field_diff(left: dict[str, Any], right: dict[str, Any]) -> list[str]:
    diffs: list[str] = []
    for field in DIFF_FIELDS:
        if left.get(field) != right.get(field):
            diffs.append(field)
    return diffs


def parse_args(argv: list[str] | None = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("base", type=Path, help="基準となる JSON（候補プール側）")
    parser.add_argument("target", type=Path, help="比較対象 JSON（本番側）")
    parser.add_argument(
        "--strict",
        action="store_true",
        help="内容差分があれば終了コード 1 を返す",
    )
    return parser.parse_args(argv)


def main(argv: list[str] | None = None) -> int:
    args = parse_args(argv)
    base = load_quizzes(args.base)
    target = load_quizzes(args.target)

    only_in_base = sorted(set(base) - set(target))
    only_in_target = sorted(set(target) - set(base))
    common = sorted(set(base) & set(target))

    print(f"base    ({args.base}): {len(base)} quizzes")
    print(f"target  ({args.target}): {len(target)} quizzes")
    print(f"common: {len(common)} / only_in_base: {len(only_in_base)} / only_in_target: {len(only_in_target)}")

    if only_in_base:
        print("\n[only in base]")
        for quiz_id in only_in_base:
            title = base[quiz_id].get("title", "")
            print(f"  + {quiz_id}: {title}")

    if only_in_target:
        print("\n[only in target]")
        for quiz_id in only_in_target:
            title = target[quiz_id].get("title", "")
            print(f"  - {quiz_id}: {title}")

    field_changes: list[tuple[int, list[str]]] = []
    for quiz_id in common:
        diffs = quiz_field_diff(base[quiz_id], target[quiz_id])
        if diffs:
            field_changes.append((quiz_id, diffs))

    if field_changes:
        print("\n[field differences]")
        for quiz_id, fields in field_changes:
            joined = ", ".join(fields)
            print(f"  ~ {quiz_id}: {joined}")

    if args.strict and (only_in_base or only_in_target or field_changes):
        print("\nstrict mode: differences detected", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
