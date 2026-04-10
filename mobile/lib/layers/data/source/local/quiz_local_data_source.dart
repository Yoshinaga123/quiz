import 'package:quiz_mobile/layers/data/dto/quiz_dto.dart';

abstract class QuizLocalDataSource {
  Future<List<QuizDto>> fetchQuizList();
  Future<QuizDto> fetchQuizDetails({required int id});
}

class QuizLocalDataSourceImpl implements QuizLocalDataSource {
  static const List<QuizDto> _quizzes = [
    QuizDto(
      id: 1,
      section: 'React & TypeScript',
      title: 'useEffect の依存配列',
      question: '依存配列に userId を含める主な理由はどれですか？',
      options: [
        '最新の userId 変更に追従して再実行するため',
        'レンダリングを完全に止めるため',
        '常に一度だけ実行するため',
        'useState を不要にするため',
      ],
      correctAnswerIndex: 0,
      explanation:
          'Effect は依存している値が変わった時に再実行されます。userId を依存配列へ入れることで、対象ユーザーが変わった時だけ安全に再取得できます。',
      source: 'React useEffect guidance',
      code: 'useEffect(() => {\n  fetchUser(userId);\n}, [userId]);',
    ),
    QuizDto(
      id: 2,
      section: 'JavaScript Async',
      title: 'Promise.all の性質',
      question: 'Promise.all の説明として最も正しいものはどれですか？',
      options: [
        '1つ失敗しても残りを成功扱いで返す',
        'すべて成功した時に fulfill し、1つでも失敗すると reject する',
        '最初に成功した Promise だけを返す',
        '結果を返さず必ず pending のままになる',
      ],
      correctAnswerIndex: 1,
      explanation:
          'Promise.all は複数非同期処理をまとめて待ちますが、1件でも reject されると全体が reject されます。',
      source: 'MDN Promise.all',
      code: 'await Promise.all([fetchA(), fetchB(), fetchC()]);',
    ),
    QuizDto(
      id: 3,
      section: 'CSS Positioning',
      title: 'position: static と top',
      question: 'position: static な要素に top を書いたときの挙動はどれですか？',
      options: [
        '構文エラーになる',
        '要素が親基準で移動する',
        'CSS としては書けるが、配置には効かない',
        'padding-top と同じ意味になる',
      ],
      correctAnswerIndex: 2,
      explanation:
          'static は通常フローの配置で、top/left/right/bottom はレイアウトに影響しません。効かせたいなら relative/absolute/fixed/sticky を使います。',
      source: 'CSS positioning basics',
      code: '.box {\n  position: static;\n  top: 30px;\n}',
    ),
  ];

  @override
  Future<List<QuizDto>> fetchQuizList() async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    return _quizzes;
  }

  @override
  Future<QuizDto> fetchQuizDetails({required int id}) async {
    await Future<void>.delayed(const Duration(milliseconds: 220));

    return _quizzes.firstWhere(
      (quiz) => quiz.id == id,
      orElse: () => throw Exception('Quiz not found'),
    );
  }
}
