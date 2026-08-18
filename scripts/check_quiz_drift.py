#!/usr/bin/env python3
"""本番シードと最新シードマイグレーションの drift 検出ツール。

`packages/admin-web/src/data/quizzes.json` の `published: true` 分を
`scripts/generate_migration.py` で仮想的に生成した SQL と、
`packages/backend/migrations/` の **最新シード SQL**（`001_create_tables.up.sql`
の `INSERT INTO quizzes` 以降、または後続の `*_seed_quizzes*.up.sql`）と
比較し、内容差分があれば検出する。

CI で「シード JSON を編集したのにマイグレーションを生成し忘れた」ケースを
落とすことを目的とする。

例:
  python3 scripts/check_quiz_drift.py \\
    --seed packages/admin-web/src/data/quizzes.json \\
    --migrations-dir packages/backend/migrations
"""

from __future__ import annotations

import argparse
import re
import subprocess
import sys
from pathlib import Path
from typing import Iterable

MIGRATION_PATTERN = re.compile(r"^(\d+)_seed_quizzes(?:[_a-z0-9]*)\.up\.sql$")
INITIAL_MIGRATION = "001_create_tables.up.sql"
SEED_START = "INSERT INTO quizzes"


def find_latest_seed_migration(migrations_dir: Path) -> Path:
    candidates: list[tuple[int, Path]] = []
    for entry in migrations_dir.iterdir():
        if not entry.is_file():
            continue
        match = MIGRATION_PATTERN.match(entry.name)
        if match is None:
            continue
        candidates.append((int(match.group(1)), entry))
    if candidates:
        candidates.sort(key=lambda item: item[0])
        return candidates[-1][1]

    initial = migrations_dir / INITIAL_MIGRATION
    if initial.is_file():
        return initial

    raise FileNotFoundError(
        f"No seed SQL found in {migrations_dir}",
    )


def extract_seed_sql(sql: str) -> str:
    index = sql.find(SEED_START)
    if index < 0:
        raise ValueError(f"seed SQL must contain {SEED_START!r}")
    return sql[index:]


def normalize_sql(sql: str) -> str:
    lines: list[str] = []
    for raw in sql.splitlines():
        stripped = raw.rstrip()
        if stripped.startswith("--"):
            continue
        if stripped == "":
            continue
        lines.append(stripped)
    return "\n".join(lines)


def render_seed_sql(generator: Path, seed: Path) -> str:
    completed = subprocess.run(
        [sys.executable, str(generator), "--mode", "up", "--input", str(seed)],
        check=True,
        capture_output=True,
        text=True,
    )
    return completed.stdout


def parse_args(argv: list[str] | None = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--seed",
        type=Path,
        default=Path("packages/admin-web/src/data/quizzes.json"),
        help="quizzes.json（published: true がシード対象）",
    )
    parser.add_argument(
        "--migrations-dir",
        type=Path,
        default=Path("packages/backend/migrations"),
        help="マイグレーション格納ディレクトリ",
    )
    parser.add_argument(
        "--generator",
        type=Path,
        default=Path("scripts/generate_migration.py"),
        help="マイグレーション SQL 生成スクリプト",
    )
    parser.add_argument(
        "--print-diff",
        action="store_true",
        help="差分があった場合に詳細を表示する",
    )
    return parser.parse_args(argv)


def unified_diff(left: str, right: str) -> Iterable[str]:
    import difflib

    return difflib.unified_diff(
        left.splitlines(),
        right.splitlines(),
        fromfile="latest_migration",
        tofile="generated_from_seed",
        lineterm="",
    )


def main(argv: list[str] | None = None) -> int:
    args = parse_args(argv)
    latest = find_latest_seed_migration(args.migrations_dir)
    print(f"latest seed migration: {latest}")

    generated_sql = render_seed_sql(args.generator, args.seed)
    actual_sql = extract_seed_sql(latest.read_text(encoding="utf-8"))

    normalized_generated = normalize_sql(generated_sql)
    normalized_actual = normalize_sql(actual_sql)

    if normalized_generated == normalized_actual:
        print("OK: published quizzes.json matches latest migration")
        return 0

    print("FAIL: quizzes.json seed drift detected", file=sys.stderr)
    print(
        "      run scripts/create_seed_migration.py and commit the result.",
        file=sys.stderr,
    )

    if args.print_diff:
        for line in unified_diff(normalized_actual, normalized_generated):
            print(line)
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
