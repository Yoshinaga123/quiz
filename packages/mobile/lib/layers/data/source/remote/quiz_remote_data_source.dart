import 'package:quiz_mobile/layers/data/dto/public_quiz_dto.dart';
import 'package:quiz_mobile/layers/data/dto/section_summary_dto.dart';
import 'package:quiz_mobile/layers/data/source/remote/quiz_api_client.dart';
import 'package:quiz_mobile/layers/domain/errors/quiz_failure.dart';

/// バックエンドの公開エンドポイント (`/v1/...`) を抽象化したデータソース。
abstract class QuizRemoteDataSource {
  Future<List<PublicQuizDto>> fetchQuizList({
    String? section,
    int? limit,
    int? offset,
  });
  Future<PublicQuizDto> fetchQuizDetails({required int id});
  Future<List<SectionSummaryDto>> fetchSectionSummaries();
}

class QuizRemoteDataSourceImpl implements QuizRemoteDataSource {
  QuizRemoteDataSourceImpl({required QuizApiClient client}) : _client = client;

  final QuizApiClient _client;

  static const int publicListPageSize = 100;

  @override
  Future<List<PublicQuizDto>> fetchQuizList({
    String? section,
    int? limit,
    int? offset,
  }) async {
    if (limit != null || offset != null) {
      return (await _fetchQuizPage(
        section: section,
        limit: limit,
        offset: offset ?? 0,
      )).quizzes;
    }

    final collected = <PublicQuizDto>[];
    var pageOffset = 0;
    var totalCount = 1 << 30;
    while (collected.length < totalCount) {
      final page = await _fetchQuizPage(
        section: section,
        limit: publicListPageSize,
        offset: pageOffset,
      );
      totalCount = page.totalCount;
      if (page.quizzes.isEmpty) {
        break;
      }
      collected.addAll(page.quizzes);
      pageOffset += page.quizzes.length;
    }
    return List<PublicQuizDto>.unmodifiable(collected);
  }

  Future<({List<PublicQuizDto> quizzes, int totalCount})> _fetchQuizPage({
    String? section,
    int? limit,
    required int offset,
  }) async {
    final query = <String, String>{};
    if (section != null && section.isNotEmpty) {
      query['section'] = section;
    }
    if (limit != null) {
      if (limit < 1 || limit > publicListPageSize) {
        throw QuizParseFailure(
          message: 'limit must be between 1 and $publicListPageSize, got $limit',
        );
      }
      query['limit'] = '$limit';
    }
    if (offset < 0) {
      throw QuizParseFailure(message: 'offset must be >= 0, got $offset');
    }
    query['offset'] = '$offset';

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

    final parsed = quizzes
        .map((entry) {
          if (entry is! Map<String, dynamic>) {
            throw const QuizParseFailure(
              message: '/v1/quizzes entry is not an object',
            );
          }
          return PublicQuizDto.fromJson(entry);
        })
        .toList(growable: false);

    return (quizzes: parsed, totalCount: _readTotalCount(payload, parsed.length));
  }

  int _readTotalCount(Map<String, dynamic> payload, int pageLength) {
    final raw = payload['totalCount'];
    if (raw is int && raw >= 0) {
      return raw;
    }
    if (raw is num && raw >= 0) {
      return raw.toInt();
    }
    return pageLength;
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
