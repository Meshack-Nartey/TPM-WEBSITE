import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/models.dart';
import 'api_client.dart';
import 'auth_api.dart' show ApiException;

/// The public, unauthenticated side of `/api/lookups` — grouped value
/// lists (branches, departments, membership statuses, meeting types, …)
/// for screens that run before login (registration) or that need to stay
/// usable without a live session (a leader filling in a report offline).
/// Callers keep `MockData`'s matching list as a fallback and only replace
/// it once this resolves, so the UI never blocks on the network.
class PublicLookups {
  const PublicLookups({this.baseUrl = 'http://localhost:4000'});

  final String baseUrl;

  Future<Map<String, List<String>>> fetch() async {
    http.Response response;
    try {
      response = await http
          .get(Uri.parse('$baseUrl/api/lookups'))
          .timeout(const Duration(seconds: 10));
    } catch (_) {
      throw ApiException("Can't reach the server.", isNetworkError: true);
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

    return data.map(
      (key, value) => MapEntry(
        key,
        (value as List? ?? const []).map((v) => v as String).toList(),
      ),
    );
  }
}

/// Talks to `backend/src/routes/lookups.routes.js` — the reference lists
/// (branches, departments, fellowships, basenias) that back dropdowns
/// elsewhere in the app. Reading the raw rows requires an admin token;
/// the plain grouped `/api/lookups` is public — see [PublicLookups].
class LookupsApi {
  const LookupsApi({required this.token});

  final String token;

  Future<List<LookupEntry>> fetch() async {
    final data = await ApiClient(token: token).get('/api/lookups/manage');
    final rows = data['lookups'] as List? ?? const [];
    return rows
        .map((r) => LookupEntry.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  Future<LookupEntry> add(
    String category,
    String value, {
    int sortOrder = 0,
  }) async {
    final data = await ApiClient(token: token).post('/api/lookups', {
      'category': category,
      'value': value,
      'sortOrder': sortOrder,
    });
    return LookupEntry.fromJson(data['lookup'] as Map<String, dynamic>);
  }

  Future<void> delete(String id) {
    return ApiClient(token: token).delete('/api/lookups/$id');
  }
}
