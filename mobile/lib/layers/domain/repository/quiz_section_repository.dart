import 'package:quiz_mobile/layers/domain/entity/section_summary.dart';

/// `GET /v1/sections` を表す追加リポジトリ。
///
/// 既存の `QuizRepository` インターフェースには `getQuizList` / `getQuizDetails`
/// しか無いため、セクション一覧用に並行する別インターフェースを用意して
/// 既存契約に手を入れずに拡張する。
abstract class QuizSectionRepository {
  Future<List<SectionSummary>> getSectionSummaries();
}
