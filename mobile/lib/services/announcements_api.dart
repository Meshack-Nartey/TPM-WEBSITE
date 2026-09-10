import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/models.dart';
import 'api_client.dart';
import 'auth_api.dart' show ApiException;

/// Talks to `backend/src/routes/announcements.routes.js`.
///
/// Reading is public — no token, so a guest browsing before signing up still
/// sees the news feed. Publishing needs a leader or admin token.
class AnnouncementsApi {
  const AnnouncementsApi({this.baseUrl = 'http://localhost:4000'});

  final String baseUrl;

  Future<List<Announcement>> fetch() async {
    http.Response response;
    try {
      response = await http
          .get(Uri.parse('$baseUrl/api/announcements'))
          .timeout(const Duration(seconds: 15));
    } catch (_) {
      throw ApiException(
        "Can't reach the server. Make sure the API is running on this network.",
        isNetworkError: true,
      );
    }

    if (response.statusCode >= 400) {
      throw ApiException('The server returned an error.');
    }

    Map<String, dynamic> data;
    try {
      data = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw ApiException('The server sent back something unexpected.');
    }

    final list = data['announcements'] as List? ?? const [];
    return list
        .map((a) => Announcement.fromJson(a as Map<String, dynamic>))
        .toList();
  }

  Future<Announcement> create({
    required String token,
    required String tag,
    required String title,
    required String body,
  }) async {
    final data = await ApiClient(token: token, baseUrl: baseUrl).post(
      '/api/announcements',
      {'tag': tag, 'title': title, 'body': body, 'date': _today()},
    );
    return Announcement.fromJson(data['announcement'] as Map<String, dynamic>);
  }

  /// e.g. "September 10, 2026" — matches the style the design board's mock
  /// announcements already use.
  String _today() {
    final now = DateTime.now();
    const months = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[now.month]} ${now.day}, ${now.year}';
  }
}
