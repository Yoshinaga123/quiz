import sys
from pathlib import Path


FIELDS = [
    ("DB_HOST", "localhost"),
    ("DB_PORT", "5433"),
    ("DB_USER", "postgres"),
    ("DB_PASSWORD", "password"),
    ("DB_NAME", "counter"),
    ("ADMIN_USER", "admin"),
    ("ADMIN_PASSWORD", "password"),
    ("JWT_SECRET", "dev-only-secret"),
    (
        "QUIZ_SEED_GENERATOR_SCRIPT",
        str(Path(__file__).resolve().parent / "generate_migration.py"),
    ),
]


def prompt_field(key: str, default: str) -> str:
    value = input(f"{key} [{default}]: ").strip()
    return value if value else default


def generate_env(output_path: Path) -> None:
    if output_path.exists():
        overwrite = input(f"{output_path} は既に存在します。上書きしますか？ [y/N]: ").strip().lower()
        if overwrite != "y":
            print("キャンセルしました。")
            sys.exit(0)

    print("\nbackend/.env に書き込む値を入力してください（Enterでデフォルト値を使用）:\n")

    lines = []
    for key, default in FIELDS:
        value = prompt_field(key, default)
        lines.append(f"{key}={value}")

    lines.extend(
        [
            "QUIZ_PYTHON_BIN=python3",
            "QUIZ_MIGRATIONS_DIR=migrations",
        ]
    )

    output_path.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(f"\n{output_path} を生成しました。")


def main() -> None:
    project_root = Path(__file__).resolve().parent.parent
    output_path = project_root / "backend" / ".env"
    generate_env(output_path)


if __name__ == "__main__":
    main()
