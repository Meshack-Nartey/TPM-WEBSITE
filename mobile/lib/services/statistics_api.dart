import '../models/models.dart';
import 'api_client.dart';

/// Talks to `backend/src/routes/statistics.routes.js` — real aggregates
/// computed server-side from members and reports, scoped to the caller's
/// own branch for a leader, church-wide for an admin.
class StatisticsApi {
  const StatisticsApi({required this.token});

  final String token;

  Future<DashboardStatistics> fetch() async {
    final data = await ApiClient(token: token).get('/api/statistics');
    return DashboardStatistics.fromJson(data);
  }
}
