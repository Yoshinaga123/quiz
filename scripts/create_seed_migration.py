import argparse
import os
import subprocess
import sys
from datetime import datetime
from pathlib import Path

# This line resolves the root dir of a project by navigating up two levels from the current file.
# __file__ represents the path to the current file path.
# .parent goes up one dir
# This pattern is more robust than os.getcwd() because it works regardless of where you launch the script from.

ROOT_DIR = Path(__file__).parent.parent

# The paths are being concatenated using the `/` operator in `Pathlib`
LOGGER_PATH = ROOT_DIR / 'scripts' / 'create_seed_migration.log'
DEFAULT_JSON = ROOT_DIR / 'packages' / 'admin-web' / 'src' / 'data' / 'quizzes.json'
DEFAULT_MIGRATIONS_DIR = ROOT_DIR / 'packages' / 'backend' / 'migrations'
GENERATOR = ROOT_DIR / 'scripts' / 'generate_migration.py'

# This is a type-annotated function of a function that writes log messages
# None: No return value ()function with only side effects
# strftime is abbreviation for "string format time"
# datetime.now() Retrieves the current system date and time as a datetime object.
def write_log(message: str) -> None:
  timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
  try:
    with LOGGER_PATH.open('a', encoding='utf-8') as log_file:
      log_file.write(f'[{timestamp}] {message}\n')
  except OSError as e:
    print(f'Failed to write log: {e}', file=sys.stderr)

# This function parses command-line arguments and returns them as a Namespace object.
def parse_args() -> argparse.Namespace:
  parser = argparse.ArgumentParser(
      description='Create quiz seed migrations with golang-migrate and fill them from JSON. golang-migrateを使ってクイズのシードマイグレーションを作成し、JSONから内容を埋める。',
  )
  parser.add_argument(
      '--input',
      default=str(DEFAULT_JSON),
      help='Seed JSON path.',
  )
  parser.add_argument(
      '--dir',
      default=str(DEFAULT_MIGRATIONS_DIR),
      help='Migration directory.',
  )
  parser.add_argument(
      '--name',
      default='seed_quizzes',
      help='Migration description used by golang-migrate create.',
  )
  parser.add_argument(
      '--digits',
      type=int,
      default=3,
      help='Sequential digit width for golang-migrate create.',
  )
  parser.add_argument(
      '--apply',
      action='store_true',
      help='Run migrate up after writing the files.',
  )
  parser.add_argument(
      '--no-down',
      action='store_true',
      help='Delete the generated down migration and keep only the up migration.',
  )
  parser.add_argument(
      '--database-url',
      help='Database URL for migrate up. Defaults to DATABASE_URL.',
  )
  return parser.parse_args()


def run(cmd: list[str], *, cwd: Path | None = None) -> subprocess.CompletedProcess[str]:
  return subprocess.run(
      cmd,
      cwd=str(cwd) if cwd else None,
      check=True,
      text=True,
      capture_output=True,
  )


def create_migration_files(migrations_dir: Path, name: str, digits: int) -> tuple[Path, Path]:
  result = run([
      'migrate',
      'create',
      '-ext',
      'sql',
      '-dir',
      str(migrations_dir),
      '-seq',
      '-digits',
      str(digits),
      name,
  ])

  output = '\n'.join(part for part in (result.stdout, result.stderr) if part)
  created_paths = [Path(line.strip()) for line in output.splitlines() if line.strip()]
  up_path = next((path for path in created_paths if path.name.endswith('.up.sql')), None)
  down_path = next((path for path in created_paths if path.name.endswith('.down.sql')), None)

  if up_path is None or down_path is None:
    raise RuntimeError(f'Unexpected migrate create output:\n{output}')

  return up_path, down_path


def generate_sql(mode: str, input_path: Path) -> str:
  result = run([
      sys.executable,
      str(GENERATOR),
      '--mode',
      mode,
      '--input',
      str(input_path),
      '--source-label',
      input_path.name,
  ], cwd=ROOT_DIR)
  return result.stdout


def apply_migrations(migrations_dir: Path, database_url: str) -> None:
  run([
      'migrate',
      '-path',
      str(migrations_dir),
      '-database',
      database_url,
      'up',
  ], cwd=ROOT_DIR)


def main() -> None:
  args = parse_args()
  input_path = Path(args.input).resolve()
  migrations_dir = Path(args.dir).resolve()

  if not input_path.exists():
    write_log(f'ERROR: Seed JSON not found: {input_path}')
    raise FileNotFoundError(f'Seed JSON not found: {input_path}')
  if not migrations_dir.exists():
    write_log(f'ERROR: Migration directory not found: {migrations_dir}')
    raise FileNotFoundError(f'Migration directory not found: {migrations_dir}')

  up_path: Path | None = None
  down_path: Path | None = None

  try:
    up_path, down_path = create_migration_files(migrations_dir, args.name, args.digits)
    up_path.write_text(generate_sql('up', input_path), encoding='utf-8')

    if args.no_down:
      down_path.unlink()
      down_path = None
    else:
      down_path.write_text(generate_sql('down', input_path), encoding='utf-8')
  except Exception as e:
    if up_path and up_path.exists():
      up_path.unlink()
    if down_path and down_path.exists():
      down_path.unlink()
    write_log(f'ERROR: {e}')
    raise

  print(f'created: {up_path}')
  if down_path is None:
    print('created: down migration skipped (--no-down)')
  else:
    print(f'created: {down_path}')

  if not args.apply:
    return

  database_url = args.database_url or os.environ.get('DATABASE_URL')
  if not database_url:
    raise RuntimeError('--apply requires --database-url or DATABASE_URL.')

  apply_migrations(migrations_dir, database_url)
  print('applied: migrate up')


if __name__ == '__main__':
  main()
