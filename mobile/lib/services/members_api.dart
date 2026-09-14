import '../models/models.dart';
import 'api_client.dart';

/// Talks to `backend/src/routes/members.routes.js`. A leader's requests are
/// automatically scoped to their own branch server-side — this client never
/// needs to filter by branch itself.
class MembersApi {
  const MembersApi({required this.token});

  final String token;

  Future<List<Member>> fetch() async {
    final data = await ApiClient(token: token).get('/api/members');
    final list = data['members'] as List? ?? const [];
    return list.map((m) => Member.fromJson(m as Map<String, dynamic>)).toList();
  }

  Future<Member> create({
    required String firstName,
    required String lastName,
    String phone = '',
    String email = '',
    String department = '',
    String branch = '',
    String membershipStatus = '',
  }) async {
    final data = await ApiClient(token: token).post('/api/members', {
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'email': email,
      'department': department,
      'branch': branch,
      'membershipStatus': membershipStatus,
    });
    return Member.fromJson(data['member'] as Map<String, dynamic>);
  }
}
