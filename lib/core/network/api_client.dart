import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_exception.dart';
class ApiClient {
  final http.Client _client;
  final String _baseUrl;
  final Duration _timeout;

  ApiClient({
    http.Client? client,
    required String baseUrl,
    Duration timeout = const Duration(seconds: 15),
  })  : _client = client ?? http.Client(),
        _baseUrl = baseUrl,
        _timeout = timeout;

  Future<Map<String, dynamic>> getJson(
    String path, {
    String? accessToken,
    Duration? timeout,
  }) async {
    final res = await _client
        .get(_uri(path), headers: _jsonHeaders(accessToken: accessToken))
        .timeout(timeout ?? _timeout);
    return _decode(res);
  }

  Future<Map<String, dynamic>> postJson(
    String path,
    Object? body, {
    String? accessToken,
    Duration? timeout,
  }) async {
    final res = await _client
        .post(
          _uri(path),
          headers: _jsonHeaders(accessToken: accessToken),
          body: body == null ? null : jsonEncode(body),
        )
        .timeout(timeout ?? _timeout);
    return _decode(res);
  }

  /// Returns the raw response so callers can branch on `204 No Content` or
  /// other non-JSON outcomes.
  Future<http.Response> post(
    String path,
    Object? body, {
    String? accessToken,
    Duration? timeout,
  }) {
    return _client
        .post(
          _uri(path),
          headers: _jsonHeaders(accessToken: accessToken),
          body: body == null ? null : jsonEncode(body),
        )
        .timeout(timeout ?? _timeout);
  }

  /// Raw PATCH for callers that need to inspect the response (e.g. to decide
  /// between JSON success and an error body).
  Future<http.Response> patch(
    String path,
    Object? body, {
    String? accessToken,
    Duration? timeout,
  }) {
    return _client
        .patch(
          _uri(path),
          headers: _jsonHeaders(accessToken: accessToken),
          body: body == null ? null : jsonEncode(body),
        )
        .timeout(timeout ?? _timeout);
  }

  /// Raw DELETE — returns the response so the caller can branch on 204/200.
  /// Named `deleteRaw` because `delete` is a reserved method-like name in
  /// some style guides for code generation.
  Future<http.Response> deleteRaw(
    String path, {
    String? accessToken,
    Duration? timeout,
  }) {
    return _client
        .delete(_uri(path), headers: _jsonHeaders(accessToken: accessToken))
        .timeout(timeout ?? _timeout);
  }

  /// Decodes a successful JSON response body into a map. Throws ApiException
  /// when the body is not a JSON object. Callers must have already verified
  /// the status code is 2xx.
  Map<String, dynamic> decodeJson(http.Response res) {
    if (res.body.isEmpty) return const {};
    final decoded = jsonDecode(res.body);
    if (decoded is Map<String, dynamic>) return decoded;
    throw ApiException(
      statusCode: res.statusCode,
      code: 'UNEXPECTED_RESPONSE',
      message: 'Expected JSON object, got ${decoded.runtimeType}',
    );
  }

  // ---------- helpers ----------

  Uri _uri(String path) => Uri.parse('$_baseUrl$path');

  Map<String, String> _jsonHeaders({String? accessToken}) {
    final h = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (accessToken != null && accessToken.isNotEmpty) {
      h['Authorization'] = 'Bearer $accessToken';
    }
    return h;
  }

  Map<String, dynamic> _decode(http.Response res) {
    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (res.body.isEmpty) return const {};
      final decoded = jsonDecode(res.body);
      if (decoded is Map<String, dynamic>) return decoded;
      throw ApiException(
        statusCode: res.statusCode,
        code: 'UNEXPECTED_RESPONSE',
        message: 'Expected JSON object, got ${decoded.runtimeType}',
      );
    }
    throw decodeError(res);
  }

  /// Exposed so feature-specific data sources can re-use the error
  /// decoding logic when they consume responses directly (e.g. logout).
  ApiException decodeError(http.Response res) {
    String code = 'HTTP_${res.statusCode}';
    String message = 'Error ${res.statusCode}';
    try {
      final body = jsonDecode(res.body);
      if (body is Map<String, dynamic>) {
        if (body['code'] is String) code = body['code'] as String;
        if (body['message'] is String) message = body['message'] as String;
      }
    } catch (_) {/* keep defaults */}
    return ApiException(statusCode: res.statusCode, code: code, message: message);
  }
}
