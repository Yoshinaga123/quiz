import 'package:quiz_mobile/layers/data/dto/public_quiz_dto.dart';
import 'package:quiz_mobile/layers/data/dto/section_summary_dto.dart';
import 'package:quiz_mobile/layers/data/source/remote/quiz_api_client.dart';
import 'package:quiz_mobile/layers/domain/errors/quiz_failure.dart';

/// バックエンドの公開エンドポイント (`/v1/...`) を抽象化したデータソース。
abstract class QuizRemoteDataSource {
  Future<List<PublicQuizDto>> fetchQuizList({String? section, int? limit});
  Future<PublicQuizDto> fetchQuizDetails({required int id});
  Future<List<SectionSummaryDto>> fetchSectionSummaries();
}

class QuizRemoteDataSourceImpl implements QuizRemoteDataSource {
  QuizRemoteDataSourceImpl({required QuizApiClient client}) : _client = client;

  final QuizApiClient _client;

  @override
  Future<List<PublicQuizDto>> fetchQuizList({
    String? section,
    int? limit,
  }) async {
    final query = <String, String>{};
    if (section != null && section.isNotEmpty) {
      query['section'] = section;
    }
    if (limit != null) {
      if (limit < 1 || limit > 100) {
        throw QuizParseFailure(
          message: 'limit must be between 1 and 100, got $limit',
        );
      }
      query['limit'] = '$limit';
    }

    final raw = await _client.getJson(
      '/v1/quizzes',
      query: query.isEmpty ? null : query,
    );

    final payload = _asJsonObject(raw, '/v1/quizzes');
    final quizzes = payload['quizzes'];
    if (quizzes is! List) {
      throw const QuizParseFailure(
        message: '/v1/quizzes response missing "quizzes" array',
      );
    }

    return quizzes
        .map((entry) {
          if (entry is! Map<String, dynamic>) {
            throw const QuizParseFailure(
              message: '/v1/quizzes entry is not an object',
            );
          }
          return PublicQuizDto.fromJson(entry);
        })
        .toList(growable: false);
  }

  @override
  Future<PublicQuizDto> fetchQuizDetails({required int id}) async {
    if (id < 1) {
      throw QuizParseFailure(message: 'id must be >= 1, got $id');
    }
    final raw = await _client.getJson('/v1/quizzes/$id');
    final payload = _asJsonObject(raw, '/v1/quizzes/$id');
    return PublicQuizDto.fromJson(payload);
  }

  @override
  Future<List<SectionSummaryDto>> fetchSectionSummaries() async {
    final raw = await _client.getJson('/v1/sections');
    final payload = _asJsonObject(raw, '/v1/sections');
    final sections = payload['sections'];
    if (sections is! List) {
      throw const QuizParseFailure(
        message: '/v1/sections response missing "sections" array',
      );
    }

    return sections
        .map((entry) {
          if (entry is! Map<String, dynamic>) {
            throw const QuizParseFailure(
              message: '/v1/sections entry is not an object',
            );
          }
          return SectionSummaryDto.fromJson(entry);
        })
        .toList(growable: false);
  }

  Map<String, dynamic> _asJsonObject(Object? raw, String path) {
    if (raw is! Map<String, dynamic>) {
      throw QuizParseFailure(message: '$path response is not a JSON object');
    }
    return raw;
  }
}
