import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_mobile/layers/data/source/remote/quiz_api_client.dart';
import 'package:quiz_mobile/layers/data/source/remote/quiz_remote_data_source.dart';

Map<String, Object?> quizJson(int id) {
  return {
    'id': id,
    'section': 'React',
    'title': 't$id',
    'question': 'q$id',
    'options': ['a', 'b'],
    'correctAnswerIndex': 0,
    'explanation': 'e',
    'source': 'https://react.dev',
  };
}

void main() {
  group('QuizRemoteDataSourceImpl.fetchQuizList', () {
    late HttpServer server;
    late QuizApiClient client;
    late QuizRemoteDataSourceImpl source;
    late List<Uri> requested;

    Future<void> startServer(
      FutureOr<void> Function(HttpRequest request) handler,
    ) async {
      server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      requested = [];
      server.listen((request) async {
        requested.add(request.uri);
        await handler(request);
      });
      client = QuizApiClient(
        baseUri: Uri.parse('http://${server.address.host}:${server.port}'),
        timeout: const Duration(seconds: 2),
      );
      source = QuizRemoteDataSourceImpl(client: client);
    }

    tearDown(() async {
      client.close();
      await server.close(force: true);
    });

    test('walks offset pages until totalCount is covered', () async {
      await startServer((request) async {
        final offset = int.parse(request.uri.queryParameters['offset'] ?? '0');
        final quizzes = offset == 0
            ? List<Map<String, Object?>>.generate(100, (index) => quizJson(index + 1))
            : List<Map<String, Object?>>.generate(5, (index) => quizJson(index + 101));
        request.response
          ..statusCode = HttpStatus.ok
          ..headers.contentType = ContentType.json
          ..write(jsonEncode({
            'quizzes': quizzes,
            'totalCount': 105,
            'generatedAt': '2026-01-15T10:30:00.000Z',
          }));
        await request.response.close();
      });

      final quizzes = await source.fetchQuizList();

      expect(quizzes, hasLength(105));
      expect(quizzes.first.id, 1);
      expect(quizzes.last.id, 105);
      expect(requested, hasLength(2));
      expect(requested[0].queryParameters['limit'], '100');
      expect(requested[0].queryParameters['offset'], '0');
      expect(requested[1].queryParameters['offset'], '100');
    });

    test('sends a single page when limit is set', () async {
      await startServer((request) async {
        request.response
          ..statusCode = HttpStatus.ok
          ..headers.contentType = ContentType.json
          ..write(jsonEncode({
            'quizzes': [quizJson(21)],
            'totalCount': 200,
            'generatedAt': '2026-01-15T10:30:00.000Z',
          }));
        await request.response.close();
      });

      final quizzes = await source.fetchQuizList(limit: 1, offset: 20);

      expect(quizzes, hasLength(1));
      expect(quizzes.single.id, 21);
      expect(requested, hasLength(1));
      expect(requested.single.queryParameters['limit'], '1');
      expect(requested.single.queryParameters['offset'], '20');
    });
  });
}
