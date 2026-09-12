import '../models/models.dart';
import 'api_client.dart';

/// Talks to `backend/src/routes/users.routes.js` — admin-only account
/// management: every user in the church, with the power to change a
/// role/branch, deactivate an account, or delete one outright.
class AdminUsersApi {
  const AdminUsersApi({required this.token});

  final String token;

  Future<List<AppUser>> fetch() async {
    final data = await ApiClient(token: token).get('/api/users');
    final list = data['users'] as List? ?? const [];
    return list
        .map((u) => AppUser.fromJson(u as Map<String, dynamic>))
        .toList();
  }

  Future<AppUser> setActive(String id, bool active) async {
    final data = await ApiClient(
      token: token,
    ).patch('/api/users/$id', {'active': active});
    return AppUser.fromJson(data['user'] as Map<String, dynamic>);
  }

  Future<AppUser> setRole(String id, AppRole role) async {
    final data = await ApiClient(
      token: token,
    ).patch('/api/users/$id', {'role': role.name.toUpperCase()});
    return AppUser.fromJson(data['user'] as Map<String, dynamic>);
  }

  Future<void> delete(String id) {
    return ApiClient(token: token).delete('/api/users/$id');
  }
}
