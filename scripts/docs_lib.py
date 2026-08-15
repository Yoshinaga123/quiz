#!/usr/bin/env python3
"""Shared helpers for detailed-design frontmatter, TOC, and page lists."""

from __future__ import annotations

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DETAILED = ROOT / "docs" / "detailed-design"
META = DETAILED / "meta.json"
LLMS = ROOT / "docs" / "llms.txt"
LLMS_FULL = ROOT / "docs" / "llms-full.txt"

HEADING_RE = re.compile(r"^(#{2,4})\s+(.+?)\s*$", re.M)
LINK_RE = re.compile(r"\[[^\]]+\]\(([^)]+)\)")


def fail(message: str) -> None:
    raise SystemExit(f"error: {message}")


def load_meta_pages(path: Path) -> list[str]:
    meta = json.loads(path.read_text(encoding="utf-8"))
    pages = meta.get("pages")
    if not isinstance(pages, list) or not pages:
        fail(f"{path.relative_to(ROOT)} pages must be a non-empty list")
    return [page for page in pages if isinstance(page, str)]


def page_path(slug: str) -> Path:
    return DETAILED / f"{slug}.md"


def parse_frontmatter(text: str, label: str) -> tuple[dict[str, str], str]:
    if not text.startswith("---\n"):
        fail(f"{label} must start with YAML frontmatter")
    end = text.find("\n---\n", 4)
    if end == -1:
        fail(f"{label} frontmatter is not closed")
    raw = text[4:end]
    body = text[end + 5 :]
    fields: dict[str, str] = {}
    for line in raw.splitlines():
        if not line.strip() or line.strip().startswith("#"):
            continue
        if ":" not in line:
            fail(f"{label} frontmatter line is not key: value: {line!r}")
        key, value = line.split(":", 1)
        fields[key.strip()] = value.strip().strip('"').strip("'")
    if not fields.get("title") or not fields.get("description"):
        fail(f"{label} frontmatter needs title and description")
    return fields, body


def slugify_heading(title: str) -> str:
    text = title.lower()
    text = re.sub(r"[`*_\[\]()]", "", text)
    text = re.sub(r"[^\w\s\-一-�*_\[\]()]", "", text)
    text = re.sub(r"[^\w\s\-一-龥ぁ-んァ-ン]", "", text, flags=re.UNICODE)
    text = re.sub(r"\s+", "-", text.strip())
    return text


def headings(body: str) -> list[tuple[int, str]]:
    found: list[tuple[int, str]] = []
    for match in HEADING_RE.finditer(body):
        found.append((len(match.group(1)), match.group(2).strip()))
    return found


def product_pages() -> list[tuple[str, Path, dict[str, str], str]]:
    pages: list[tuple[str, Path, dict[str, str], str]] = []
    for slug in load_meta_pages(META):
        if slug.startswith("---"):
            continue
        path = page_path(slug)
        if not path.is_file():
            fail(f"meta.json page missing file: {slug}.md")
        fields, body = parse_frontmatter(path.read_text(encoding="utf-8"), str(path.relative_to(ROOT)))
        pages.append((slug, path, fields, body))
    return pages
