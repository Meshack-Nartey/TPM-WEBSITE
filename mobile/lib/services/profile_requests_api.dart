import '../data/mock_data.dart';
import '../models/models.dart';
import 'api_client.dart';

/// Talks to `backend/src/routes/profileRequests.routes.js` — admin-only,
/// the review queue for a member's self-requested profile changes.
class ProfileRequestsApi {
  const ProfileRequestsApi({required this.token});

  final String token;

  Future<List<ApprovalRequest>> fetchPending() async {
    final data = await ApiClient(
      token: token,
    ).get('/api/profile-requests?status=PENDING');
    final list = data['requests'] as List? ?? const [];
    return [
      for (var i = 0; i < list.length; i++)
        ApprovalRequest.fromJson(
          list[i] as Map<String, dynamic>,
          MockData.avatarFor(i),
        ),
    ];
  }

  /// Approving actually applies the change to the member's profile
  /// server-side — see the route for what "approve" does beyond bookkeeping.
  Future<void> decide(String id, {required bool approve}) {
    return ApiClient(token: token).patch('/api/profile-requests/$id', {
      'status': approve ? 'APPROVED' : 'REJECTED',
    });
  }
}
