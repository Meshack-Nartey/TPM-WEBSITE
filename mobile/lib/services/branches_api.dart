import '../models/models.dart';
import 'api_client.dart';

/// Talks to `backend/src/routes/branches.routes.js` — the public branch
/// directory (address/phone/email), richer than the `Lookup` "branch"
/// category used in dropdowns elsewhere.
class BranchesApi {
  const BranchesApi({required this.token});

  final String token;

  Future<List<Branch>> fetch() async {
    final data = await ApiClient(token: token).get('/api/branches');
    final rows = data['branches'] as List? ?? const [];
    return rows.map((r) => Branch.fromJson(r as Map<String, dynamic>)).toList();
  }

  Future<Branch> create(Map<String, dynamic> fields) async {
    final data = await ApiClient(token: token).post('/api/branches', fields);
    return Branch.fromJson(data['branch'] as Map<String, dynamic>);
  }

  Future<Branch> update(String id, Map<String, dynamic> fields) async {
    final data = await ApiClient(
      token: token,
    ).patch('/api/branches/$id', fields);
    return Branch.fromJson(data['branch'] as Map<String, dynamic>);
  }

  Future<void> delete(String id) {
    return ApiClient(token: token).delete('/api/branches/$id');
  }
}
