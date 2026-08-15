#!/usr/bin/env python3
"""Zod-style docs audit: frontmatter, orphans, folder meta, relative links, llms drift."""

from __future__ import annotations

from docs_lib import (
    DETAILED,
    LLMS,
    LLMS_FULL,
    LINK_RE,
    META,
    ROOT,
    fail,
    load_meta_pages,
    page_path,
    parse_frontmatter,
    product_pages,
)
from generate_llms_txt import catalog_text, full_text

SKIP_LINK_PREFIXES = ("http://", "https://", "mailto:", "#")


def check_orphans() -> None:
    listed = {page_path(slug).resolve() for slug in load_meta_pages(META) if not slug.startswith("---")}
    found = {path.resolve() for path in DETAILED.rglob("*.md")}
    extra = sorted(path.relative_to(ROOT).as_posix() for path in found - listed)
    missing = sorted(path.relative_to(ROOT).as_posix() for path in listed - found)
    if extra:
        fail(f"detailed-design markdown not listed in meta.json: {extra}")
    if missing:
        fail(f"meta.json lists missing files: {missing}")


def check_folder_meta() -> None:
    for folder in (DETAILED / "web", DETAILED / "backend", DETAILED / "admin-web", DETAILED / "mobile"):
        meta = folder / "meta.json"
        if not meta.is_file():
            fail(f"missing {meta.relative_to(ROOT)}")
        pages = [slug for slug in load_meta_pages(meta) if not slug.startswith("---")]
        listed = {folder / f"{slug}.md" for slug in pages}
        found = {path for path in folder.glob("*.md")}
        extra = sorted(path.name for path in found - listed)
        missing = sorted(path.name for path in listed - found)
        if extra:
            fail(f"{folder.name}/meta.json missing pages: {extra}")
        if missing:
            fail(f"{folder.name}/meta.json lists missing files: {missing}")


def check_frontmatter_and_h1() -> None:
    for slug, path, fields, body in product_pages():
        if not body.lstrip().startswith("# "):
            fail(f"{path.relative_to(ROOT)} body must start with an H1")
        h1 = body.lstrip().splitlines()[0][2:].strip()
        if not h1:
            fail(f"{path.relative_to(ROOT)} has an empty H1")
        _ = fields


def resolve_link(source: Path, target: str) -> Path | None:
    stripped = target.strip()
    if not stripped or stripped.startswith(SKIP_LINK_PREFIXES):
        return None
    path_part = stripped.split("#", 1)[0]
    if not path_part:
        return None
    return (source.parent / path_part).resolve()


def check_relative_links() -> None:
    for path in DETAILED.rglob("*.md"):
        text = path.read_text(encoding="utf-8")
        for match in LINK_RE.finditer(text):
            resolved = resolve_link(path, match.group(1))
            if resolved is None:
                continue
            if not resolved.exists():
                fail(
                    f"broken link in {path.relative_to(ROOT)}: {match.group(1)} -> {resolved}"
                )


def check_llms_fresh() -> None:
    expected_catalog = catalog_text()
    expected_full = full_text()
    if not LLMS.is_file() or LLMS.read_text(encoding="utf-8") != expected_catalog:
        fail("docs/llms.txt is stale; run python3 scripts/generate_llms_txt.py")
    if not LLMS_FULL.is_file() or LLMS_FULL.read_text(encoding="utf-8") != expected_full:
        fail("docs/llms-full.txt is stale; run python3 scripts/generate_llms_txt.py")


def main() -> None:
    check_orphans()
    check_folder_meta()
    check_frontmatter_and_h1()
    check_relative_links()
    check_llms_fresh()
    print("docs check ok")


if __name__ == "__main__":
    main()
