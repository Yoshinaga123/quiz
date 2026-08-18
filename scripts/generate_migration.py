import argparse
import os
import json
import sys
import select
from datetime import date
from pathlib import Path
from typing import Any


def log_debug(message: str) -> None:
  """デバッグメッセージを標準エラーに出力する"""
  print(message, file=sys.stderr)


def esc(value: str) -> str:
  """アポストロフィをエスケープする"""
  return value.replace("'", "''") if value else ''


def code_val(code: str | None) -> str:
  """オプションのコードフィールドをエスケープする"""
  if code is None:
    return 'NULL'
  return f"'{esc(code)}'"

"""CLIスクリプト"""
def load_quizzes(input_path: str | None, stdin_timeout: float) -> list[dict[str, Any]]:
  data: Any
  if input_path:
    try:
      with open(input_path, 'r', encoding='utf-8') as file:
        data = json.load(file)
    except json.JSONDecodeError as e:
      raise ValueError(
          f"Failed to load JSON from {input_path}: {e}"
          f" (JSON の読み込みに失敗: {input_path}: {e})\n"
          f"\n{e.doc}\n{' ' * (e.pos)}^ "
      ) from e
  else:
    if sys.stdin.isatty():
      raise ValueError(
          'Provide --input or pipe JSON to stdin.\n'
          '--input を指定するか、JSON を標準入力にパイプしてください。'
      )
    if not select.select([sys.stdin], [], [], stdin_timeout)[0]:
      raise ValueError(
          f'No input provided on stdin within {stdin_timeout}s.\n'
          f'{stdin_timeout}秒以内に標準入力にデータが提供されていません。'
      )
      
    try:
      data = json.load(sys.stdin)
    except json.JSONDecodeError as e:
      raise ValueError(
          f"Failed to load JSON from stdin: {e}"
          
      ) from e
    
  if not isinstance(data, dict):
    raise ValueError("JSON root must be an object.\n"
      "JSON のルートはオブジェクトでなければなりません。")

  quizzes = data.get('quizzes')
  if not isinstance(quizzes, list):
    raise ValueError("JSON must contain a 'quizzes' array.\n "
    "JSON のトップレベルに 'quizzes' 配列が必要です")

  return quizzes


def select_seed_quizzes(quizzes: list[dict[str, Any]]) -> list[dict[str, Any]]:
  selected: list[dict[str, Any]] = []
  for quiz in quizzes:
    published = quiz.get('published')
    if not isinstance(published, bool):
      raise ValueError(
          f"quiz id={quiz.get('id', '?')}: 'published' must be a boolean.\n"
          f"quiz id={quiz.get('id', '?')}: 'published' は boolean である必要があります。"
      )
    if published:
      selected.append(quiz)
  return selected


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


def delete_replaced_quiz_rows_sql(ids: str | None) -> list[str]:
  """Remove quizzes that left the published seed set, plus dependent deliveries."""
  if ids:
    return [
        f'DELETE FROM push_deliveries WHERE NOT (quiz_id = ANY(ARRAY[{ids}]::bigint[]));',
        f'DELETE FROM quizzes WHERE NOT (id = ANY(ARRAY[{ids}]::bigint[]));',
    ]
  return [
      'DELETE FROM push_deliveries;',
      'DELETE FROM quizzes;',
  ]


def build_up_sql(quizzes: list[dict[str, Any]], source_label: str) -> str:
  lines = [
      f'-- Migration: seed quizzes from {source_label}',
      f'-- Generated: {date.today().isoformat()}',
      '',
  ]

  if quizzes:
    ids = ', '.join(str(quiz['id']) for quiz in quizzes)
    lines += [
        'INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source, status, push_enabled)',
        'VALUES',
        ',\n'.join(f"{build_row(quiz)[:-1]}, 'unpublished', false)" for quiz in quizzes),
        'ON CONFLICT (id) DO UPDATE SET',
        '  section = EXCLUDED.section,',
        '  title = EXCLUDED.title,',
        '  question = EXCLUDED.question,',
        '  code = EXCLUDED.code,',
        '  options = EXCLUDED.options,',
        '  correct_answer_index = EXCLUDED.correct_answer_index,',
        '  explanation = EXCLUDED.explanation,',
        '  source = EXCLUDED.source,',
        '  updated_at = NOW();',
        '',
        *delete_replaced_quiz_rows_sql(ids),
        '',
        "SELECT setval('quizzes_id_seq', COALESCE((SELECT MAX(id) FROM quizzes), 1), (SELECT COUNT(*) > 0 FROM quizzes));",
    ]
  else:
    lines += [
        *delete_replaced_quiz_rows_sql(None),
        '',
        "SELECT setval('quizzes_id_seq', COALESCE((SELECT MAX(id) FROM quizzes), 1), (SELECT COUNT(*) > 0 FROM quizzes));",
    ]

  return '\n'.join(lines)


def build_down_sql(quizzes: list[dict[str, Any]], source_label: str) -> str:
  lines = [
      f'-- Rollback: remove quizzes seeded from {source_label}',
      f'-- Generated: {date.today().isoformat()}',
      '',
  ]

  if not quizzes:
    lines.append('-- No quizzes selected.')
    return '\n'.join(lines)

  ids = ', '.join(str(quiz['id']) for quiz in quizzes)
  lines += [
      f'DELETE FROM push_deliveries WHERE quiz_id IN ({ids});',
      f'DELETE FROM quizzes WHERE id IN ({ids});',
      '',
      "SELECT setval('quizzes_id_seq', COALESCE((SELECT MAX(id) FROM quizzes), 1), (SELECT COUNT(*) > 0 FROM quizzes));",
  ]
  return '\n'.join(lines)


def parse_args() -> argparse.Namespace:
  parser = argparse.ArgumentParser(
      description='Generate SQL text for quiz seed migrations.',
  )
  parser.add_argument(
      '--mode',
      choices=('up', 'down'),
      default='up',
      help='Which migration direction to generate.',
  )
  parser.add_argument(
      '--input',
      help='Path to the seed JSON file. If omitted, stdin is used.',
  )
  parser.add_argument(
      '--source-label',
      help='Label used in the generated SQL comments.',
  )
  parser.add_argument(
      '--stdin-timeout',
      type=float,
      default=3.0,
      help='Seconds to wait for stdin before failing when --input is omitted.',
  )
  return parser.parse_args()


def main() -> None:
  args = parse_args()
  log_debug(f"here: {Path(__file__).resolve().parent}")
  log_debug(f"cwd: {Path.cwd()}")
  log_debug(f"home: {Path.home()}")
  # log_debug(f"")
  # log_debug('fspath: str/bytes are passed through, __fspath__() is supported, and other types raise TypeError.')
  config_path = Path(__file__).parent.parent / "backend" / ".env"
  log_debug("this is a config path")
  log_debug(f"os.fspath(config_path): {os.fspath(config_path)}")      

  quizzes = select_seed_quizzes(load_quizzes(args.input, args.stdin_timeout))
  source_label = args.source_label or (Path(args.input).name if args.input else 'stdin')

  if args.mode == 'down':
    print(build_down_sql(quizzes, source_label))
    return

  print(build_up_sql(quizzes, source_label))

if __name__ == '__main__':
  main()
