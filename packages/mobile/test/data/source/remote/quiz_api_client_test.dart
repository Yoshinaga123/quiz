import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_mobile/layers/data/source/remote/quiz_api_client.dart';
import 'package:quiz_mobile/layers/domain/errors/quiz_failure.dart';

/// QuizApiClient はローカル HTTP サーバを建ててブラックボックス検証する。
///
/// `pubspec.yaml` を変更しない方針のため、`mockito` 等は使わず
/// `dart:io` の [HttpServer] のみで E2E に近いテストにする。
void main() {
  group('QuizApiClient.getJson', () {
    late HttpServer server;
    late QuizApiClient client;
    late List<HttpRequest> received;

    Future<void> startServer(
      FutureOr<void> Function(HttpRequest request) handler,
    ) async {
      server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      received = [];
      server.listen((request) async {
        received.add(request);
        await handler(request);
      });
      client = QuizApiClient(
        baseUri: Uri.parse('http://${server.address.host}:${server.port}'),
        timeout: const Duration(seconds: 2),
      );
    }

    tearDown(() async {
      client.close();
      await server.close(force: true);
    });

    test('200 + JSON ボディをデコードして返す', () async {
      await startServer((request) async {
        request.response
          ..statusCode = HttpStatus.ok
          ..headers.contentType = ContentType.json
          ..write(jsonEncode({'ok': true, 'value': 42}));
        await request.response.close();
      });

      final result = await client.getJson('/v1/ping', query: {'foo': 'bar'});

      expect(result, isA<Map<String, dynamic>>());
      expect((result as Map)['ok'], true);
      expect(result['value'], 42);

      expect(received, hasLength(1));
      expect(received.single.uri.path, '/v1/ping');
      expect(received.single.uri.queryParameters, {'foo': 'bar'});
      expect(received.single.headers.value(HttpHeaders.acceptHeader),
          'application/json');
    });

    test('404 のときは QuizNotFoundFailure を投げる', () async {
      await startServer((request) async {
        request.response
          ..statusCode = HttpStatus.notFound
          ..write('{}');
        await request.response.close();
      });

      await expectLater(
        () => client.getJson('/v1/quizzes/9999'),
        throwsA(isA<QuizNotFoundFailure>()),
      );
    });

    test('500 のときは QuizServerFailure を statusCode 付きで投げる', () async {
      await startServer((request) async {
        request.response
          ..statusCode = HttpStatus.internalServerError
          ..write('{"code":"internal_error","message":"boom"}');
        await request.response.close();
      });

      await expectLater(
        () => client.getJson('/v1/quizzes'),
        throwsA(
          isA<QuizServerFailure>().having((e) => e.statusCode, 'statusCode', 500),
        ),
      );
    });

    test('不正な JSON を返すと QuizParseFailure を投げる', () async {
      await startServer((request) async {
        request.response
          ..statusCode = HttpStatus.ok
          ..write('this-is-not-json');
        await request.response.close();
      });

      await expectLater(
        () => client.getJson('/v1/quizzes'),
        throwsA(isA<QuizParseFailure>()),
      );
    });

    test('ボディが空のときは null を返す', () async {
      await startServer((request) async {
        request.response.statusCode = HttpStatus.ok;
        await request.response.close();
      });

      final result = await client.getJson('/v1/empty');
      expect(result, isNull);
    });
  });
}
