// ignore_for_file: prefer_initializing_formals

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

  Future<http.Response> deleteRaw(
    String path, {
    String? accessToken,
    Duration? timeout,
  }) {
    return _client
        .delete(_uri(path), headers: _jsonHeaders(accessToken: accessToken))
        .timeout(timeout ?? _timeout);
  }

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

  ApiException decodeError(http.Response res) {
    String code = 'HTTP_${res.statusCode}';
    String message = 'Error ${res.statusCode}';
    try {
      final body = jsonDecode(res.body);
      if (body is Map<String, dynamic>) {
        if (body['code'] is String) code = body['code'] as String;
        if (body['message'] is String) message = body['message'] as String;
      }
    } catch (_) {}
    return ApiException(statusCode: res.statusCode, code: code, message: message);
  }
}
