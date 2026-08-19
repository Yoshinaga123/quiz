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
ZOD_QUIZ = ROOT / "packages" / "web" / "src" / "schemas" / "quiz.ts"
ZOD_LIST = ROOT / "packages" / "web" / "src" / "api" / "quiz.ts"
GO_TYPES = ROOT / "packages" / "backend" / "types.go"
DETAIL = ROOT / "docs" / "detailed-design" / "web" / "quiz-schema.md"
CONTRACT_DOC = ROOT / "docs" / "detailed-design" / "web" / "public-contract.md"
MOBILE_DTO = ROOT / "packages" / "mobile" / "lib" / "layers" / "data" / "dto" / "public_quiz_dto.dart"
AGENTS = ROOT / "AGENTS.md"

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
ATTEMPT_CREATE_REQUIRED = ["clientSessionId", "completedAt", "answers"]
ATTEMPT_ANSWER_REQUIRED = ["quizId", "selectedIndex", "isCorrect"]
ATTEMPT_ACCEPTED_REQUIRED = ["clientSessionId", "status"]


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


def schema_block(yaml_text: str, schema_name: str) -> str:
    match = re.search(rf"\n    {re.escape(schema_name)}:\n", yaml_text)
    if not match:
        fail(f"OpenAPI schema {schema_name} not found")
    rest = yaml_text[match.end() :]
    next_schema = re.search(r"\n    [A-Z][A-Za-z0-9]+:\n", rest)
    return rest[: next_schema.start()] if next_schema else rest


def schema_example_keys(yaml_text: str, schema_name: str) -> set[str]:
    block = schema_block(yaml_text, schema_name)
    example = re.search(r"\n      example:\n((?:        .+\n)+)", block)
    if not example:
        fail(f"OpenAPI schema {schema_name} has no example")
    return set(re.findall(r"^        ([A-Za-z][A-Za-z0-9]*):", example.group(1), re.M))


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
    attempt_create = load_json(FIXTURES / "attempt-create.json")
    attempt_accepted = load_json(FIXTURES / "attempt-accepted.json")
    attempt_invalid = load_json(FIXTURES / "attempt-invalid-empty-answers.json")

    if not isinstance(quiz, dict) or not isinstance(invalid, dict):
        fail("quiz fixtures must be objects")
    if not isinstance(quiz_list, dict) or not isinstance(sections, dict):
        fail("list/sections fixtures must be objects")
    if not isinstance(error, dict) or not isinstance(push_feed, dict):
        fail("error/push-feed fixtures must be objects")
    if not isinstance(attempt_create, dict) or not isinstance(attempt_accepted, dict):
        fail("attempt fixtures must be objects")
    if not isinstance(attempt_invalid, dict):
        fail("attempt-invalid-empty-answers.json must be an object")

    assert_required(schema_required(openapi, "Quiz"), QUIZ_REQUIRED, "Quiz")
    assert_required(schema_required(openapi, "QuizListResponse"), LIST_REQUIRED, "QuizListResponse")
    assert_required(schema_required(openapi, "Error"), ERROR_REQUIRED, "Error")
    assert_required(schema_required(openapi, "SectionSummary"), SECTION_REQUIRED, "SectionSummary")
    assert_required(schema_required(openapi, "PushFeed"), PUSH_REQUIRED, "PushFeed")
    assert_required(schema_required(openapi, "AttemptCreateRequest"), ATTEMPT_CREATE_REQUIRED, "AttemptCreateRequest")
    assert_required(schema_required(openapi, "AttemptAnswer"), ATTEMPT_ANSWER_REQUIRED, "AttemptAnswer")
    assert_required(schema_required(openapi, "AttemptAccepted"), ATTEMPT_ACCEPTED_REQUIRED, "AttemptAccepted")

    assert_keys_contain(quiz, QUIZ_REQUIRED, "quiz.json")
    assert_keys_contain(quiz_list, LIST_REQUIRED, "quiz-list.json")
    assert_keys_contain(error, ERROR_REQUIRED, "error.json")
    assert_keys_contain(push_feed, PUSH_REQUIRED, "push-feed.json")
    assert_keys_contain(attempt_create, ATTEMPT_CREATE_REQUIRED, "attempt-create.json")
    assert_keys_contain(attempt_accepted, ATTEMPT_ACCEPTED_REQUIRED, "attempt-accepted.json")
    assert_keys_contain(attempt_invalid, ATTEMPT_CREATE_REQUIRED, "attempt-invalid-empty-answers.json")

    answers = attempt_create.get("answers")
    if not isinstance(answers, list) or not answers or not isinstance(answers[0], dict):
        fail("attempt-create.json.answers must be a non-empty array of objects")
    assert_keys_contain(answers[0], ATTEMPT_ANSWER_REQUIRED, "attempt-create.json.answers[0]")
    invalid_answers = attempt_invalid.get("answers")
    if not isinstance(invalid_answers, list) or len(invalid_answers) != 0:
        fail("attempt-invalid-empty-answers.json.answers must be an empty array")

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
            fail(f"packages/web/src/schemas/quiz.ts missing field {field}")
    if ".refine(" not in zod_quiz:
        fail("packages/web/src/schemas/quiz.ts must keep .refine for correctAnswerIndex")

    zod_list = ZOD_LIST.read_text(encoding="utf-8")
    for field in LIST_REQUIRED:
        if f"{field}:" not in zod_list:
            fail(f"packages/web/src/api/quiz.ts missing list field {field}")
    for field in ATTEMPT_CREATE_REQUIRED + ATTEMPT_ANSWER_REQUIRED + ATTEMPT_ACCEPTED_REQUIRED:
        if f"{field}:" not in zod_list:
            fail(f"packages/web/src/api/quiz.ts missing attempt field {field}")
    if "submitAttempt" not in zod_list:
        fail("packages/web/src/api/quiz.ts must export submitAttempt")

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

    create_tags = go_struct_json_tags(go_types, "attemptCreateRequest")
    missing_create = [field for field in ATTEMPT_CREATE_REQUIRED if field not in create_tags]
    if missing_create:
        fail(f"attemptCreateRequest json tags missing {missing_create}")
    answer_tags = go_struct_json_tags(go_types, "attemptAnswer")
    missing_answer = [field for field in ATTEMPT_ANSWER_REQUIRED if field not in answer_tags]
    if missing_answer:
        fail(f"attemptAnswer json tags missing {missing_answer}")
    accepted_tags = go_struct_json_tags(go_types, "attemptAccepted")
    missing_accepted = [field for field in ATTEMPT_ACCEPTED_REQUIRED if field not in accepted_tags]
    if missing_accepted:
        fail(f"attemptAccepted json tags missing {missing_accepted}")

    detail = DETAIL.read_text(encoding="utf-8")
    if "correctAnswerIndex" not in detail or ".refine" not in detail:
        fail("docs/detailed-design/web/quiz-schema.md must document .refine")
    if "fixtures" not in detail:
        fail("docs/detailed-design/web/quiz-schema.md must point to docs/api/fixtures")

    if not CONTRACT_DOC.exists():
        fail("docs/detailed-design/web/public-contract.md is required")

    quiz_example_keys = schema_example_keys(openapi, "Quiz")
    missing_example = [key for key in quiz if key not in quiz_example_keys]
    if missing_example:
        fail(f"OpenAPI Quiz example missing keys from quiz.json: {missing_example}")

    error_example_keys = schema_example_keys(openapi, "Error")
    missing_error_example = [key for key in ERROR_REQUIRED if key not in error_example_keys]
    if missing_error_example:
        fail(f"OpenAPI Error example missing {missing_error_example}")

    create_example_keys = schema_example_keys(openapi, "AttemptCreateRequest")
    missing_create_example = [key for key in attempt_create if key not in create_example_keys]
    if missing_create_example:
        fail(f"OpenAPI AttemptCreateRequest example missing keys from attempt-create.json: {missing_create_example}")
    accepted_example_keys = schema_example_keys(openapi, "AttemptAccepted")
    missing_accepted_example = [key for key in ATTEMPT_ACCEPTED_REQUIRED if key not in accepted_example_keys]
    if missing_accepted_example:
        fail(f"OpenAPI AttemptAccepted example missing {missing_accepted_example}")

    public_go = (ROOT / "packages" / "backend" / "public.go").read_text(encoding="utf-8")
    attempts_go = (ROOT / "packages" / "backend" / "attempts.go").read_text(encoding="utf-8")
    if "handleSubmitAttempt" not in attempts_go and "handleSubmitAttempt" not in public_go:
        fail("POST /v1/attempts handler is missing")

    if not MOBILE_DTO.is_file():
        fail("mobile public_quiz_dto.dart is required")
    mobile_dto = MOBILE_DTO.read_text(encoding="utf-8")
    for field in QUIZ_REQUIRED + ["code"]:
        if f"'{field}'" not in mobile_dto and f'"{field}"' not in mobile_dto:
            fail(f"public_quiz_dto.dart missing field {field}")

    if not AGENTS.is_file():
        fail("AGENTS.md is required")
    agents = AGENTS.read_text(encoding="utf-8")
    if "docs/api/fixtures/" not in agents or "publicQuiz" not in agents:
        fail("AGENTS.md must document the public-contract same-PR rule")

    print("public contract check ok")


if __name__ == "__main__":
    main()
