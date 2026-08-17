import 'package:quiz_mobile/layers/data/source/remote/quiz_remote_data_source.dart';
import 'package:quiz_mobile/layers/domain/entity/quiz.dart';
import 'package:quiz_mobile/layers/domain/entity/section_summary.dart';
import 'package:quiz_mobile/layers/domain/repository/quiz_repository.dart';
import 'package:quiz_mobile/layers/domain/repository/quiz_section_repository.dart';

/// 公開 API（ADR 0006）を一次ソースとする `QuizRepository` 実装。
///
/// 既存の `QuizRepositoryImpl`（local data source 経由）には触れず、
/// remote 切替が必要な場面で並行配置するための新クラス。
/// `QuizSectionRepository` も併せて実装し、`/v1/sections` をサーブする。
class QuizRemoteRepositoryImpl
    implements QuizRepository, QuizSectionRepository {
  QuizRemoteRepositoryImpl({required QuizRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final QuizRemoteDataSource _remoteDataSource;

  @override
  Future<List<Quiz>> getQuizList() async {
    final dtos = await _remoteDataSource.fetchQuizList();
    return dtos.map((dto) => dto.toEntity()).toList(growable: false);
  }

  @override
  Future<Quiz> getQuizDetails({required int id}) async {
    final dto = await _remoteDataSource.fetchQuizDetails(id: id);
    return dto.toEntity();
  }

  @override
  Future<List<SectionSummary>> getSectionSummaries() async {
    final dtos = await _remoteDataSource.fetchSectionSummaries();
    return dtos.map((dto) => dto.toEntity()).toList(growable: false);
  }
}
