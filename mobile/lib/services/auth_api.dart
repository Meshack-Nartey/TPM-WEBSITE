import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/models.dart';

/// Thrown for anything the API rejected, or that couldn't be reached at all —
/// the message is written to be shown to the user directly.
class ApiException implements Exception {
  ApiException(
    this.message, {
    this.fieldErrors = const {},
    this.isNetworkError = false,
  });

  final String message;

  /// Field name (matching the request body, e.g. "email", "password") to
  /// its specific message — from the API's zod `details` array, when
  /// present — so the offending field can be highlighted, not just named
  /// in the message text.
  final Map<String, String> fieldErrors;

  /// True when the request never reached the server at all (no signal, API
  /// down) — as opposed to reaching it and being rejected. Callers that can
  /// queue-and-retry (e.g. the weekly report) use this to tell "try again
  /// later" apart from "this data was invalid."
  final bool isNetworkError;

  @override
  String toString() => message;
}

class AuthResult {
  const AuthResult({required this.token, required this.user});

  final String token;
  final AppUser user;
}

/// Talks to `backend/src/routes/auth.routes.js`.
///
/// Points at localhost:4000 — the Node API run locally per its README. On a
/// physical Android device that means `adb reverse tcp:4000 tcp:4000` first,
/// so the phone's "localhost" reaches this Mac over the USB connection.
class AuthApi {
  const AuthApi({this.baseUrl = 'http://localhost:4000'});

  final String baseUrl;

  Future<AuthResult> login({required String email, required String password}) {
    return _post('/api/auth/login', {'email': email, 'password': password});
  }

  Future<AuthResult> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    AppRole role = AppRole.member,
    String inviteCode = '',
    String branch = '',
  }) async {
    final data = await _postRaw('/api/auth/register', {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'password': password,
      'role': role.name.toUpperCase(),
      'inviteCode': inviteCode,
      'branch': branch,
    });
    return _asAuthResult(data);
  }

  /// Dev-only shortcut — see `backend/src/routes/auth.routes.js` for why this
  /// resets the password from the email alone rather than a verified link.
  Future<void> forgotPassword({
    required String email,
    required String newPassword,
  }) {
    return _postRaw('/api/auth/forgot-password', {
      'email': email,
      'newPassword': newPassword,
    });
  }

  Future<AuthResult> _post(String path, Map<String, dynamic> body) async {
    final data = await _postRaw(path, body);
    return _asAuthResult(data);
  }

  AuthResult _asAuthResult(Map<String, dynamic> data) => AuthResult(
    token: data['token'] as String,
    user: AppUser.fromJson(data['user'] as Map<String, dynamic>),
  );

  /// PATCH `/api/auth/me/notifications` — self-service, any signed-in role.
  Future<AppUser> updateNotifications({
    required String token,
    required Map<String, bool> prefs,
  }) async {
    final data = await _patchRaw('/api/auth/me/notifications', prefs, token);
    return AppUser.fromJson(data['user'] as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> _patchRaw(
    String path,
    Map<String, dynamic> body,
    String token,
  ) async {
    http.Response response;
    try {
      response = await http
          .patch(
            Uri.parse('$baseUrl$path'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 10));
    } catch (_) {
      throw ApiException(
        "Can't reach the server. Make sure the API is running on this network.",
        isNetworkError: true,
      );
    }
    return _parse(response);
  }

  Future<Map<String, dynamic>> _postRaw(
    String path,
    Map<String, dynamic> body,
  ) async {
    http.Response response;
    try {
      response = await http
          .post(
            Uri.parse('$baseUrl$path'),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 10));
    } catch (_) {
      throw ApiException(
        "Can't reach the server. Make sure the API is running on this network.",
        isNetworkError: true,
      );
    }
    return _parse(response);
  }

  Map<String, dynamic> _parse(http.Response response) {
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

  /// The API's zod validation returns a generic "Validation failed" plus a
  /// `details` array of {field, message} — surface the actual field-level
  /// messages, and which field each belongs to, instead of that generic
  /// top-line error.
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
