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
}
