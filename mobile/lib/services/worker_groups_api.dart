import '../models/models.dart';
import 'api_client.dart';

/// Talks to `backend/src/routes/workerGroups.routes.js` — the "Get
/// Involved" descriptions, richer than the `Lookup` "department" category
/// used in dropdowns elsewhere.
class WorkerGroupsApi {
  const WorkerGroupsApi({required this.token});

  final String token;

  Future<List<WorkerGroup>> fetch() async {
    final data = await ApiClient(token: token).get('/api/worker-groups');
    final rows = data['workerGroups'] as List? ?? const [];
    return rows
        .map((r) => WorkerGroup.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  Future<WorkerGroup> create(Map<String, dynamic> fields) async {
    final data = await ApiClient(
      token: token,
    ).post('/api/worker-groups', fields);
    return WorkerGroup.fromJson(data['workerGroup'] as Map<String, dynamic>);
  }

  Future<WorkerGroup> update(String id, Map<String, dynamic> fields) async {
    final data = await ApiClient(
      token: token,
    ).patch('/api/worker-groups/$id', fields);
    return WorkerGroup.fromJson(data['workerGroup'] as Map<String, dynamic>);
  }

  Future<void> delete(String id) {
    return ApiClient(token: token).delete('/api/worker-groups/$id');
  }
}
