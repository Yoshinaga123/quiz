#!/usr/bin/env python3
"""Contrast / one-shot helper next to generate_migration.py.

Why this file exists
--------------------
On 2026-08-19 we published all 839 candidate quizzes from
``packages/admin-web/src/data/quizzes.json`` onto Lightsail by hand.
``scripts/generate_migration.py`` was close, but several gaps forced an
ad-hoc Python snippet:

1. Seed status is hard-coded to ``unpublished``.
2. ``ON CONFLICT DO UPDATE`` does not touch ``status``, so already-seeded
   rows stay unpublished even after a re-sync.
3. There is no path from the admin candidate pool JSON to
   ``packages/backend/seeds/quizzes.production.json``.
4. ``main()`` still has debug ``log_debug`` / wrong ``backend/.env`` path
   noise that belongs in a cleanup pass.

This script is the captured workflow for comparison — not a replacement
for ``generate_migration.py`` / ``create_seed_migration.py`` yet. Prefer
improving those scripts and deleting this file once they cover the same
ground.

Examples
--------
# Rewrite production seed from the admin candidate pool
python3 scripts/contrast_publish_candidate_quizzes.py sync-seed

# Emit upsert SQL with status=published (stdout)
python3 scripts/contrast_publish_candidate_quizzes.py sql \\
  --input packages/backend/seeds/quizzes.production.json

# Write SQL to a file
python3 scripts/contrast_publish_candidate_quizzes.py sql \\
  --input packages/backend/seeds/quizzes.production.json \\
  --output /tmp/seed_published.sql
"""

from __future__ import annotations

import argparse
import json
import sys
from datetime import date
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
DEFAULT_CANDIDATE = ROOT / "packages" / "admin-web" / "src" / "data" / "quizzes.json"
DEFAULT_PRODUCTION = ROOT / "packages" / "backend" / "seeds" / "quizzes.production.json"

PRODUCTION_FIELDS = (
    "id",
    "section",
    "title",
    "question",
    "options",
    "correctAnswerIndex",
    "explanation",
    "source",
)


def esc(value: str) -> str:
    return value.replace("'", "''") if value else ""


def code_val(code: str | None) -> str:
    if code is None:
        return "NULL"
    return f"'{esc(code)}'"


def load_document(path: Path) -> list[dict[str, Any]]:
    data = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(data, dict):
        raise ValueError(f"{path}: JSON root must be an object")
    quizzes = data.get("quizzes")
    if not isinstance(quizzes, list):
        raise ValueError(f"{path}: missing quizzes array")
    return quizzes


def validate_quizzes(quizzes: list[dict[str, Any]]) -> None:
    errors: list[str] = []
    seen: set[Any] = set()
    for index, quiz in enumerate(quizzes):
        for required in PRODUCTION_FIELDS:
            if required not in quiz:
                errors.append(f"index {index}: missing {required}")
        quiz_id = quiz.get("id")
        if quiz_id in seen:
            errors.append(f"duplicate id {quiz_id}")
        seen.add(quiz_id)
        options = quiz.get("options") or []
        answer_index = quiz.get("correctAnswerIndex")
        if not isinstance(options, list) or len(options) < 2:
            errors.append(f"id={quiz_id}: options must have at least 2 items")
        if not isinstance(answer_index, int) or answer_index < 0 or answer_index >= len(options):
            errors.append(f"id={quiz_id}: invalid correctAnswerIndex={answer_index}")
    if errors:
        raise ValueError("validation failed:\n" + "\n".join(errors[:20]))


def to_production_quiz(quiz: dict[str, Any]) -> dict[str, Any]:
    item = {field: quiz[field] for field in PRODUCTION_FIELDS}
    code = quiz.get("code")
    if code is not None and code != "":
        item["code"] = code
    return item


def build_row(quiz: dict[str, Any]) -> str:
    return (
        f"  ({quiz['id']}, "
        f"'{esc(quiz.get('section', ''))}', "
        f"'{esc(quiz.get('title', ''))}', "
        f"'{esc(quiz.get('question', ''))}', "
        f"{code_val(quiz.get('code'))}, "
        f"'{esc(json.dumps(quiz.get('options', []), ensure_ascii=False))}'::jsonb, "
        f"{quiz.get('correctAnswerIndex', 0)}, "
        f"'{esc(quiz.get('explanation', ''))}', "
        f"'{esc(quiz.get('source', ''))}')"
    )


def build_up_sql(quizzes: list[dict[str, Any]], source_label: str, status: str) -> str:
    if status not in ("published", "unpublished"):
        raise ValueError("status must be published or unpublished")

    lines = [
        f"-- Contrast script: seed quizzes from {source_label}",
        f"-- Generated: {date.today().isoformat()}",
        f"-- Diff vs generate_migration.py: status={status!r} and status is updated on conflict.",
        "",
    ]

    if not quizzes:
        lines += [
            "DELETE FROM quizzes;",
            "",
            "SELECT setval('quizzes_id_seq', COALESCE((SELECT MAX(id) FROM quizzes), 1), (SELECT COUNT(*) > 0 FROM quizzes));",
        ]
        return "\n".join(lines)

    ids = ", ".join(str(quiz["id"]) for quiz in quizzes)
    lines += [
        "INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source, status, push_enabled)",
        "VALUES",
        ",\n".join(f"{build_row(quiz)[:-1]}, '{status}', false)" for quiz in quizzes),
        "ON CONFLICT (id) DO UPDATE SET",
        "  section = EXCLUDED.section,",
        "  title = EXCLUDED.title,",
        "  question = EXCLUDED.question,",
        "  code = EXCLUDED.code,",
        "  options = EXCLUDED.options,",
        "  correct_answer_index = EXCLUDED.correct_answer_index,",
        "  explanation = EXCLUDED.explanation,",
        "  source = EXCLUDED.source,",
        "  status = EXCLUDED.status,",
        "  updated_at = NOW();",
        "",
        f"DELETE FROM quizzes WHERE NOT (id = ANY(ARRAY[{ids}]::bigint[]));",
        "",
        "SELECT setval('quizzes_id_seq', COALESCE((SELECT MAX(id) FROM quizzes), 1), (SELECT COUNT(*) > 0 FROM quizzes));",
    ]
    return "\n".join(lines)


def cmd_sync_seed(args: argparse.Namespace) -> int:
    candidate = Path(args.candidate)
    production = Path(args.production)
    quizzes = load_document(candidate)
    validate_quizzes(quizzes)
    document = {"quizzes": [to_production_quiz(quiz) for quiz in quizzes]}
    production.parent.mkdir(parents=True, exist_ok=True)
    production.write_text(
        json.dumps(document, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    print(f"wrote {production} ({len(document['quizzes'])} quizzes)", file=sys.stderr)
    return 0


def cmd_sql(args: argparse.Namespace) -> int:
    input_path = Path(args.input)
    quizzes = load_document(input_path)
    validate_quizzes(quizzes)
    sql = build_up_sql(quizzes, input_path.name, args.status)
    if args.output:
        output = Path(args.output)
        output.write_text(sql + "\n", encoding="utf-8")
        print(f"wrote {output} ({len(sql)} bytes, {len(quizzes)} quizzes)", file=sys.stderr)
    else:
        print(sql)
    return 0


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description=__doc__.split("Examples", 1)[0].strip(),
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    sub = parser.add_subparsers(dest="command", required=True)

    sync = sub.add_parser(
        "sync-seed",
        help="Copy admin candidate pool into packages/backend/seeds/quizzes.production.json",
    )
    sync.add_argument("--candidate", type=Path, default=DEFAULT_CANDIDATE)
    sync.add_argument("--production", type=Path, default=DEFAULT_PRODUCTION)
    sync.set_defaults(func=cmd_sync_seed)

    sql = sub.add_parser(
        "sql",
        help="Emit upsert SQL (contrast: configurable status + status on conflict)",
    )
    sql.add_argument("--input", type=Path, default=DEFAULT_PRODUCTION)
    sql.add_argument(
        "--status",
        choices=("published", "unpublished"),
        default="published",
        help="Row status to insert/update (default: published)",
    )
    sql.add_argument("--output", type=Path, help="Write SQL to this path instead of stdout")
    sql.set_defaults(func=cmd_sql)

    return parser


def main() -> int:
    parser = build_parser()
    args = parser.parse_args()
    try:
        return args.func(args)
    except (OSError, ValueError, json.JSONDecodeError) as err:
        print(f"error: {err}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
