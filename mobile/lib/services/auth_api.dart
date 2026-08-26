import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/models.dart';

/// Thrown for anything the API rejected, or that couldn't be reached at all —
/// the message is written to be shown to the user directly.
class ApiException implements Exception {
  ApiException(this.message);

  final String message;

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
  Future<void> forgotPassword({required String email, required String newPassword}) {
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

  Future<Map<String, dynamic>> _postRaw(String path, Map<String, dynamic> body) async {
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
      );
    }

    Map<String, dynamic> data;
    try {
      data = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw ApiException('The server sent back something unexpected.');
    }

    if (response.statusCode >= 400) {
      throw ApiException((data['error'] as String?) ?? 'Something went wrong.');
    }

    return data;
  }
}
