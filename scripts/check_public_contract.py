#!/usr/bin/env python3
"""公開契約（OpenAPI / fixtures / Zod / Go / 詳細設計）のフィールド同期チェック。"""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OPENAPI = ROOT / "docs" / "api" / "public-quiz-api.yaml"
FIXTURES = ROOT / "docs" / "api" / "fixtures"
ZOD_QUIZ = ROOT / "web" / "src" / "schemas" / "quiz.ts"
ZOD_LIST = ROOT / "web" / "src" / "api" / "quiz.ts"
GO_TYPES = ROOT / "backend" / "types.go"
DETAIL = ROOT / "docs" / "detailed-design" / "web" / "quiz-schema.md"
CONTRACT_DOC = ROOT / "docs" / "detailed-design" / "web" / "public-contract.md"

QUIZ_REQUIRED = [
    "id",
    "section",
    "title",
    "question",
    "options",
    "correctAnswerIndex",
    "explanation",
    "source",
]
LIST_REQUIRED = ["quizzes", "totalCount", "generatedAt"]
ERROR_REQUIRED = ["code", "message"]
SECTION_REQUIRED = ["section", "count"]
PUSH_REQUIRED = ["deliveryId", "quizId", "title", "body", "sentAt", "channel"]


def fail(message: str) -> None:
    print(f"error: {message}", file=sys.stderr)
    raise SystemExit(1)


def load_json(path: Path) -> object:
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except FileNotFoundError:
        fail(f"missing {path.relative_to(ROOT)}")
    except json.JSONDecodeError as exc:
        fail(f"invalid JSON {path.relative_to(ROOT)}: {exc}")


def schema_required(yaml_text: str, schema_name: str) -> list[str]:
    match = re.search(rf"\n    {re.escape(schema_name)}:\n", yaml_text)
    if not match:
        fail(f"OpenAPI schema {schema_name} not found")
    rest = yaml_text[match.end() :]
    next_schema = re.search(r"\n    [A-Z][A-Za-z0-9]+:\n", rest)
    block = rest[: next_schema.start()] if next_schema else rest
    inline = re.search(r"\n      required:\s*\[([^\]]+)\]", block)
    if inline:
        return [item.strip() for item in inline.group(1).split(",") if item.strip()]
    multiline = re.search(r"\n      required:\n((?:        - \S+\n)+)", block)
    if not multiline:
        fail(f"OpenAPI schema {schema_name} has no required list")
    return re.findall(r"        - (\S+)", multiline.group(1))


def assert_required(actual: list[str], expected: list[str], label: str) -> None:
    if actual != expected:
        fail(f"{label} required mismatch\n  openapi: {actual}\n  expected: {expected}")


def assert_keys_contain(payload: dict, required: list[str], label: str) -> None:
    missing = [key for key in required if key not in payload]
    if missing:
        fail(f"{label} missing keys: {missing}")


def go_struct_json_tags(source: str, struct_name: str) -> set[str]:
    match = re.search(
        rf"type {re.escape(struct_name)} struct \{{(.*?)\n\}}",
        source,
        re.S,
    )
    if not match:
        fail(f"Go struct {struct_name} not found")
    return set(re.findall(r'`json:"([^,"]+)', match.group(1)))


def main() -> None:
    openapi = OPENAPI.read_text(encoding="utf-8")
    quiz = load_json(FIXTURES / "quiz.json")
    invalid = load_json(FIXTURES / "quiz-invalid-answer-index.json")
    quiz_list = load_json(FIXTURES / "quiz-list.json")
    sections = load_json(FIXTURES / "sections.json")
    error = load_json(FIXTURES / "error.json")
    push_feed = load_json(FIXTURES / "push-feed.json")

    if not isinstance(quiz, dict) or not isinstance(invalid, dict):
        fail("quiz fixtures must be objects")
    if not isinstance(quiz_list, dict) or not isinstance(sections, dict):
        fail("list/sections fixtures must be objects")
    if not isinstance(error, dict) or not isinstance(push_feed, dict):
        fail("error/push-feed fixtures must be objects")

    assert_required(schema_required(openapi, "Quiz"), QUIZ_REQUIRED, "Quiz")
    assert_required(schema_required(openapi, "QuizListResponse"), LIST_REQUIRED, "QuizListResponse")
    assert_required(schema_required(openapi, "Error"), ERROR_REQUIRED, "Error")
    assert_required(schema_required(openapi, "SectionSummary"), SECTION_REQUIRED, "SectionSummary")
    assert_required(schema_required(openapi, "PushFeed"), PUSH_REQUIRED, "PushFeed")

    assert_keys_contain(quiz, QUIZ_REQUIRED, "quiz.json")
    assert_keys_contain(quiz_list, LIST_REQUIRED, "quiz-list.json")
    assert_keys_contain(error, ERROR_REQUIRED, "error.json")
    assert_keys_contain(push_feed, PUSH_REQUIRED, "push-feed.json")

    quizzes = quiz_list.get("quizzes")
    if not isinstance(quizzes, list) or not quizzes:
        fail("quiz-list.json.quizzes must be a non-empty array")
    if quizzes[0] != quiz:
        fail("quiz-list.json.quizzes[0] must equal quiz.json")

    options = quiz.get("options")
    if not isinstance(options, list) or len(options) < 2:
        fail("quiz.json.options must have at least 2 entries")
    invalid_index = invalid.get("correctAnswerIndex")
    invalid_options = invalid.get("options")
    if not isinstance(invalid_index, int) or not isinstance(invalid_options, list):
        fail("invalid fixture must include correctAnswerIndex and options")
    if 0 <= invalid_index < len(invalid_options):
        fail("quiz-invalid-answer-index.json must be out of range")

    zod_quiz = ZOD_QUIZ.read_text(encoding="utf-8")
    for field in QUIZ_REQUIRED + ["code"]:
        if f"{field}:" not in zod_quiz and f"{field} :" not in zod_quiz:
            fail(f"web/src/schemas/quiz.ts missing field {field}")
    if ".refine(" not in zod_quiz:
        fail("web/src/schemas/quiz.ts must keep .refine for correctAnswerIndex")

    zod_list = ZOD_LIST.read_text(encoding="utf-8")
    for field in LIST_REQUIRED:
        if f"{field}:" not in zod_list:
            fail(f"web/src/api/quiz.ts missing list field {field}")

    go_types = GO_TYPES.read_text(encoding="utf-8")
    quiz_tags = go_struct_json_tags(go_types, "publicQuiz")
    missing_tags = [field for field in QUIZ_REQUIRED if field not in quiz_tags]
    extra_required = [field for field in ("status", "pushEnabled", "createdAt", "updatedAt") if field in quiz_tags]
    if missing_tags:
        fail(f"publicQuiz json tags missing {missing_tags}")
    if extra_required:
        fail(f"publicQuiz must not expose admin fields {extra_required}")

    list_tags = go_struct_json_tags(go_types, "publicQuizListResponse")
    if any(field not in list_tags for field in LIST_REQUIRED):
        fail(f"publicQuizListResponse json tags missing; have {sorted(list_tags)}")

    detail = DETAIL.read_text(encoding="utf-8")
    if "correctAnswerIndex" not in detail or ".refine" not in detail:
        fail("docs/detailed-design/web/quiz-schema.md must document .refine")
    if "fixtures" not in detail:
        fail("docs/detailed-design/web/quiz-schema.md must point to docs/api/fixtures")

    if not CONTRACT_DOC.exists():
        fail("docs/detailed-design/web/public-contract.md is required")

    print("public contract check ok")


if __name__ == "__main__":
    main()
