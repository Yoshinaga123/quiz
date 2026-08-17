#!/usr/bin/env python3
"""Zod-style repo hygiene: required root files, Node pin, detailed-design index."""

from __future__ import annotations

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
META = ROOT / "docs" / "detailed-design" / "meta.json"

REQUIRED_FILES = [
    "AGENTS.md",
    "CLAUDE.md",
    "CODE_OF_CONDUCT.md",
    "CONTRIBUTING.md",
    "LICENSE",
    "README.md",
    "SECURITY.md",
    "CHANGELOG.md",
    ".editorconfig",
    ".nvmrc",
    ".gitattributes",
    "play.ts",
    "lint-staged.config.mjs",
    ".husky/pre-commit",
    ".husky/pre-push",
    "docs/llms.txt",
    "docs/llms-full.txt",
    "docs/detailed-design/meta.json",
    "docs/detailed-design/writing.md",
    "docs/detailed-design/web/quiz-schema.md",
    "docs/detailed-design/web/public-contract.md",
    "docs/detailed-design/web/basics.md",
    "docs/detailed-design/repo-ops.md",
]


def fail(message: str) -> None:
    print(f"error: {message}", file=sys.stderr)
    raise SystemExit(1)


def main() -> None:
    for relative in REQUIRED_FILES:
        path = ROOT / relative
        if not path.is_file():
            fail(f"missing {relative}")

    nvmrc = (ROOT / ".nvmrc").read_text(encoding="utf-8").strip()
    if nvmrc != "22":
        fail(f".nvmrc must be 22, got {nvmrc!r}")

    package_json = json.loads((ROOT / "package.json").read_text(encoding="utf-8"))
    workspaces = package_json.get("workspaces")
    if not isinstance(workspaces, list) or "packages/web" not in workspaces or "packages/admin-web" not in workspaces:
        fail("package.json workspaces must include packages/web and packages/admin-web")
    for nested in ("packages/web/package-lock.json", "packages/admin-web/package-lock.json"):
        if (ROOT / nested).is_file():
            fail(f"{nested} must not exist; install from the repo root lockfile")

    agents = (ROOT / "AGENTS.md").read_text(encoding="utf-8")
    for needle in ("docs/api/fixtures/", "publicQuiz", ".refine", "play.ts"):
        if needle not in agents:
            fail(f"AGENTS.md must mention {needle}")

    meta = json.loads(META.read_text(encoding="utf-8"))
    pages = meta.get("pages")
    if not isinstance(pages, list) or not pages:
        fail("docs/detailed-design/meta.json pages must be a non-empty list")
    for page in pages:
        if not isinstance(page, str) or page.startswith("---"):
            continue
        path = ROOT / "docs" / "detailed-design" / f"{page}.md"
        if not path.is_file():
            fail(f"meta.json page missing file: {page}.md")

    print("repo hygiene check ok")


if __name__ == "__main__":
    main()
