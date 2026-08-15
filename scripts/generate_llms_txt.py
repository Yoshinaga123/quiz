#!/usr/bin/env python3
"""Build docs/llms.txt (catalog) and docs/llms-full.txt (concatenated pages).

Mirrors zod.dev/llms.txt and /llms-full.txt without a Fumadocs site.
"""

from __future__ import annotations

from docs_lib import LLMS, LLMS_FULL, ROOT, headings, product_pages, slugify_heading


def catalog_text() -> str:
    lines = [
        "# Socrates Quiz",
        "",
        "> High-difficulty IT quiz app. Monorepo, not a published library. Public JSON is OpenAPI + fixtures + handwritten Zod. Learning trees (samples/, archive/, docs/security-tools/) are not product.",
        "",
    ]
    for slug, path, fields, body in product_pages():
        rel = path.relative_to(ROOT).as_posix()
        title = fields["title"]
        lines.append(f"## {title}")
        lines.append("")
        lines.append(f"- [{title}]({rel}): {fields['description']}")
        toc = [item for item in headings(body) if 2 <= item[0] <= 4]
        if toc:
            lines.append("")
            for _depth, heading in toc:
                anchor = slugify_heading(heading)
                lines.append(f"- [{heading}]({rel}#{anchor})")
        lines.append("")
    lines.append("---")
    lines.append("")
    lines.append(
        "Use AGENTS.md for agent rules and docs/INDEX.md for the human map. "
        "docs/llms-full.txt concatenates these detailed-design pages in meta.json order."
    )
    lines.append("")
    return "\n".join(lines)


def full_text() -> str:
    chunks = [
        "# Socrates Quiz",
        "",
        "Concatenated detailed-design pages in `docs/detailed-design/meta.json` order.",
        "Regenerate with `python3 scripts/generate_llms_txt.py`.",
        "",
    ]
    for _slug, path, fields, body in product_pages():
        rel = path.relative_to(ROOT).as_posix()
        chunks.append(f"# {fields['title']}")
        chunks.append("")
        chunks.append(f"Source: {rel}")
        chunks.append("")
        chunks.append(body.strip())
        chunks.append("")
        chunks.append("")
    return "\n".join(chunks).rstrip() + "\n"


def main() -> None:
    LLMS.write_text(catalog_text(), encoding="utf-8")
    LLMS_FULL.write_text(full_text(), encoding="utf-8")
    print(f"wrote {LLMS.relative_to(ROOT)} and {LLMS_FULL.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
