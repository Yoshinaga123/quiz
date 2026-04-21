import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:quiz_mobile/layers/domain/errors/quiz_failure.dart';

/// 公開クイズ API（ADR 0006）を叩く薄い HTTP クライアント。
///
/// 設計方針:
///  - `pubspec.yaml` を変更しない方針のため、`http` などの追加依存は使わず
///    `dart:io` の [HttpClient] のみで構成する。
///  - ベース URL はビルド時 `--dart-define=QUIZ_API_BASE_URL=...` で上書き可能。
///    既定は `backend/docker-compose.yml` の dev ポートマッピング `localhost:8082`。
///  - JSON のパース・スキーマ検証は呼び出し側 DTO の責務。本クライアントは
///    HTTP 結果を素の Dart オブジェクトに復号するところまでを担う。
///  - 失敗は必ず [QuizFailure] のサブタイプで投げる（呼び出し側が `switch` で
///    type narrow できる）。
class QuizApiClient {
  QuizApiClient({
    Uri? baseUri,
    HttpClient? httpClient,
    Duration? timeout,
  })  : _baseUri = baseUri ?? Uri.parse(_defaultBaseUrl),
        _httpClient = httpClient ?? HttpClient(),
        _timeout = timeout ?? const Duration(seconds: 10),
        _ownsClient = httpClient == null;

  static const String _defaultBaseUrl = String.fromEnvironment(
    'QUIZ_API_BASE_URL',
    defaultValue: 'http://localhost:8082',
  );

  final Uri _baseUri;
  final HttpClient _httpClient;
  final Duration _timeout;
  final bool _ownsClient;

  /// 任意エンドポイントに GET し、JSON をデコードして返す。
  ///
  /// レスポンス本文が空のときは `null` を返す。
  Future<Object?> getJson(
    String path, {
    Map<String, String>? query,
  }) async {
    final uri = _resolve(path, query);

    final HttpClientResponse response;
    try {
      final request = await _httpClient.getUrl(uri).timeout(_timeout);
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      response = await request.close().timeout(_timeout);
    } on TimeoutException catch (e) {
      throw QuizNetworkFailure(message: 'Request to $uri timed out: $e');
    } on SocketException catch (e) {
      throw QuizNetworkFailure(message: 'Network error to $uri: ${e.message}');
    } on HttpException catch (e) {
      throw QuizNetworkFailure(message: 'HTTP error to $uri: ${e.message}');
    }

    final body = await response
        .transform(utf8.decoder)
        .join()
        .timeout(_timeout);

    if (response.statusCode == HttpStatus.notFound) {
      throw QuizNotFoundFailure(message: 'Not found: $uri');
    }
    if (response.statusCode >= 400) {
      throw QuizServerFailure(
        statusCode: response.statusCode,
        message: 'Failed $uri: HTTP ${response.statusCode} body=$body',
      );
    }

    if (body.isEmpty) return null;
    try {
      return jsonDecode(body);
    } on FormatException catch (e) {
      throw QuizParseFailure(message: 'Invalid JSON from $uri: ${e.message}');
    }
  }

  /// 自身が生成した [HttpClient] を解放する。
  /// 外部から注入された場合は責任分離のため何もしない。
  void close() {
    if (_ownsClient) {
      _httpClient.close(force: false);
    }
  }

  Uri _resolve(String path, Map<String, String>? query) {
    final normalized = path.startsWith('/') ? path : '/$path';
    return Uri(
      scheme: _baseUri.scheme,
      host: _baseUri.host,
      port: _baseUri.hasPort ? _baseUri.port : null,
      path: normalized,
      queryParameters: (query == null || query.isEmpty) ? null : query,
    );
  }
}
