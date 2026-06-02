/// Single exception type bubbled up from the network layer. Data sources
/// in any feature can catch this without knowing which package was used
/// to perform the HTTP call.
class ApiException implements Exception {
  final int statusCode;
  final String code;
  final String message;

  const ApiException({
    required this.statusCode,
    required this.code,
    required this.message,
  });

  @override
  String toString() => 'ApiException($statusCode, $code): $message';
}
