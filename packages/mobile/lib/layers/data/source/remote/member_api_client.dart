import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:quiz_mobile/layers/data/dto/answer_history_entry_dto.dart';
import 'package:quiz_mobile/layers/data/dto/mastery_dto.dart';
import 'package:quiz_mobile/layers/data/dto/public_member_dto.dart';
import 'package:quiz_mobile/layers/domain/errors/member_failure.dart';

/// 会員 API（`/api/members`, `/api/session`, `/api/me`, `/api/me/answers`）を叩く
/// 薄い HTTP クライアント。
///
/// - 公開 `QuizApiClient` と同様に `dart:io` の [HttpClient] だけで構成（依存を増やさない）。
/// - ベース URL は `--dart-define=QUIZ_API_BASE_URL=...`（QuizApiClient と共有）。
class MemberApiClient {
  MemberApiClient({
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

  Future<PublicMemberDto> registerMember({
    required String handle,
    required String password,
  }) async {
    final response = await _request(
      method: 'POST',
      path: '/api/members',
      body: {'handle': handle, 'password': password},
    );
    return PublicMemberDto.fromJson(_expectJsonObject(response));
  }

  Future<String> createSession({
    required String handle,
    required String password,
  }) async {
    final response = await _request(
      method: 'POST',
      path: '/api/session',
      body: {'handle': handle, 'password': password},
    );
    final payload = _expectJsonObject(response);
    final token = payload['token'];
    if (token is! String || token.isEmpty) {
      throw const MemberParseFailure(message: 'token must be a non-empty string');
    }
    return token;
  }

  Future<PublicMemberDto> fetchMe({required String token}) async {
    final response = await _request(
      method: 'GET',
      path: '/api/me',
      bearer: token,
    );
    return PublicMemberDto.fromJson(_expectJsonObject(response));
  }

  Future<void> deleteMe({required String token}) async {
    await _request(method: 'DELETE', path: '/api/me', bearer: token);
  }

  Future<AnswerHistoryListDto> listAnswerHistory({
    required String token,
    int? quizId,
    int? limit,
  }) async {
    final query = <String, String>{};
    if (quizId != null) query['quizId'] = '$quizId';
    if (limit != null) query['limit'] = '$limit';
    final response = await _request(
      method: 'GET',
      path: '/api/me/answers',
      bearer: token,
      query: query.isEmpty ? null : query,
    );
    return AnswerHistoryListDto.fromJson(_expectJsonObject(response));
  }

  Future<AnswerHistoryEntryDto> createAnswer({
    required String token,
    required int quizId,
    required int selectedIndex,
  }) async {
    final response = await _request(
      method: 'POST',
      path: '/api/me/answers',
      bearer: token,
      body: {'quizId': quizId, 'selectedIndex': selectedIndex},
    );
    return AnswerHistoryEntryDto.fromJson(_expectJsonObject(response));
  }

  /// ADR 0018 §3: email を設定・変更し、検証メールを送信させる。202 応答。
  Future<void> setEmail({
    required String token,
    required String email,
  }) async {
    await _request(
      method: 'POST',
      path: '/api/me/email',
      bearer: token,
      body: {'email': email},
    );
  }

  /// ADR 0018 §3: 検証トークンを消費し email_verified_at を立てる。204 応答。
  Future<void> consumeEmailVerification({required String token}) async {
    await _request(
      method: 'POST',
      path: '/api/email-verifications/${Uri.encodeComponent(token)}',
    );
  }

  /// ADR 0018 §3: 常に 202 を返し、実在有無を隠す。
  Future<void> requestPasswordReset({required String handleOrEmail}) async {
    await _request(
      method: 'POST',
      path: '/api/password-resets',
      body: {'handleOrEmail': handleOrEmail},
    );
  }

  /// ADR 0018 §3: リセットトークンを消費し新パスワードに更新。204 応答。
  Future<void> consumePasswordReset({
    required String token,
    required String newPassword,
  }) async {
    await _request(
      method: 'POST',
      path: '/api/password-resets/${Uri.encodeComponent(token)}',
      body: {'newPassword': newPassword},
    );
  }

  /// ADR 0018 系のフォローアップ: `GET /api/me/mastery` で段位計算用の streak を取得する。
  Future<MasteryResponseDto> fetchMastery({required String token}) async {
    final response = await _request(
      method: 'GET',
      path: '/api/me/mastery',
      bearer: token,
    );
    return MasteryResponseDto.fromJson(_expectJsonObject(response));
  }

  void close() {
    if (_ownsClient) _httpClient.close(force: false);
  }

  Future<Object?> _request({
    required String method,
    required String path,
    Map<String, dynamic>? body,
    Map<String, String>? query,
    String? bearer,
  }) async {
    final uri = _resolve(path, query);

    final HttpClientResponse response;
    try {
      final request = await _httpClient.openUrl(method, uri).timeout(_timeout);
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      if (bearer != null) {
        request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $bearer');
      }
      if (body != null) {
        request.headers.contentType = ContentType.json;
        request.write(jsonEncode(body));
      }
      response = await request.close().timeout(_timeout);
    } on TimeoutException catch (e) {
      throw MemberParseFailure(message: 'Request to $uri timed out: $e');
    } on SocketException catch (e) {
      throw MemberParseFailure(message: 'Network error to $uri: ${e.message}');
    } on HttpException catch (e) {
      throw MemberParseFailure(message: 'HTTP error to $uri: ${e.message}');
    }

    final rawBody =
        await response.transform(utf8.decoder).join().timeout(_timeout);

    if (response.statusCode == HttpStatus.noContent) return null;
    if (response.statusCode == HttpStatus.unauthorized) {
      throw MemberParseFailure(message: 'Unauthorized: HTTP 401 body=$rawBody');
    }
    if (response.statusCode == HttpStatus.conflict) {
      throw MemberParseFailure(message: 'Conflict: HTTP 409 body=$rawBody');
    }
    if (response.statusCode >= 400) {
      throw MemberParseFailure(
        message: 'Failed $uri: HTTP ${response.statusCode} body=$rawBody',
      );
    }

    if (rawBody.isEmpty) return null;
    try {
      return jsonDecode(rawBody);
    } on FormatException catch (e) {
      throw MemberParseFailure(message: 'Invalid JSON from $uri: ${e.message}');
    }
  }

  Map<String, dynamic> _expectJsonObject(Object? raw) {
    if (raw is! Map<String, dynamic>) {
      throw const MemberParseFailure(message: 'expected a JSON object');
    }
    return raw;
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
