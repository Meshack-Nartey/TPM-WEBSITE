import 'dart:convert';

import 'package:http/http.dart' as http;

import 'auth_api.dart' show ApiException;

/// Shared plumbing for calls that carry the signed-in leader/admin's JWT —
/// everything `AuthApi` doesn't cover, since login/register happen before
/// there's a token to send. Points at the same local API; see `AuthApi` for
/// why (`adb reverse tcp:4000 tcp:4000` on a physical device).
class ApiClient {
  const ApiClient({
    required this.token,
    this.baseUrl = 'http://localhost:4000',
  });

  final String token;
  final String baseUrl;

  Future<Map<String, dynamic>> get(String path) => _send('GET', path);

  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body) =>
      _send('POST', path, body);

  Future<Map<String, dynamic>> patch(String path, Map<String, dynamic> body) =>
      _send('PATCH', path, body);

  Future<Map<String, dynamic>> delete(String path) => _send('DELETE', path);

  Future<Map<String, dynamic>> _send(
    String method,
    String path, [
    Map<String, dynamic>? body,
  ]) async {
    final uri = Uri.parse('$baseUrl$path');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    http.Response response;
    try {
      final request = switch (method) {
        'GET' => http.get(uri, headers: headers),
        'POST' => http.post(
          uri,
          headers: headers,
          body: jsonEncode(body ?? {}),
        ),
        'PATCH' => http.patch(
          uri,
          headers: headers,
          body: jsonEncode(body ?? {}),
        ),
        'DELETE' => http.delete(uri, headers: headers),
        _ => throw UnsupportedError('Unknown method: $method'),
      };
      response = await request.timeout(const Duration(seconds: 10));
    } catch (_) {
      throw ApiException(
        "Can't reach the server. Make sure the API is running on this network.",
        isNetworkError: true,
      );
    }

    if (response.body.isEmpty) return {};

    Map<String, dynamic> data;
    try {
      data = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw ApiException('The server sent back something unexpected.');
    }

    if (response.statusCode >= 400) {
      final fieldErrors = _fieldErrors(data);
      final message = fieldErrors.isNotEmpty
          ? fieldErrors.values.toSet().join('\n')
          : (data['error'] as String?) ?? 'Something went wrong.';
      throw ApiException(message, fieldErrors: fieldErrors);
    }

    return data;
  }

  /// Same zod `details` shape `AuthApi` surfaces — see there for why.
  Map<String, String> _fieldErrors(Map<String, dynamic> data) {
    final details = data['details'];
    if (details is! List) return const {};
    return {
      for (final entry in details.whereType<Map>())
        if (entry['field'] is String && entry['message'] is String)
          entry['field'] as String: entry['message'] as String,
    };
  }
}
