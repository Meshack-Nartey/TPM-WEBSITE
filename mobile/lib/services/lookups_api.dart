import '../models/models.dart';
import 'api_client.dart';

/// Talks to `backend/src/routes/lookups.routes.js` — the reference lists
/// (branches, departments, fellowships, basenias) that back dropdowns
/// elsewhere in the app. Reading the raw rows requires an admin token;
/// the plain grouped `/api/lookups` is public and used at registration.
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
