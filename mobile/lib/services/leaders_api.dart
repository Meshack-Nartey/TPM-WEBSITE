import '../models/models.dart';
import 'api_client.dart';

/// Talks to `backend/src/routes/leaders.routes.js` — the church leadership
/// directory shown on the public site and managed here.
class LeadersApi {
  const LeadersApi({required this.token});

  final String token;

  Future<List<ChurchLeader>> fetch() async {
    final data = await ApiClient(token: token).get('/api/leaders');
    final rows = data['leaders'] as List? ?? const [];
    return rows
        .map((r) => ChurchLeader.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  Future<ChurchLeader> create(Map<String, dynamic> fields) async {
    final data = await ApiClient(token: token).post('/api/leaders', fields);
    return ChurchLeader.fromJson(data['leader'] as Map<String, dynamic>);
  }

  Future<ChurchLeader> update(String id, Map<String, dynamic> fields) async {
    final data = await ApiClient(
      token: token,
    ).patch('/api/leaders/$id', fields);
    return ChurchLeader.fromJson(data['leader'] as Map<String, dynamic>);
  }

  Future<void> delete(String id) {
    return ApiClient(token: token).delete('/api/leaders/$id');
  }
}
