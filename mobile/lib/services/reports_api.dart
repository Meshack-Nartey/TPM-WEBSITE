import '../models/models.dart';
import 'api_client.dart';

/// Talks to `backend/src/routes/reports.routes.js`. As with [MembersApi], a
/// leader's requests are scoped to their own branch server-side.
class ReportsApi {
  const ReportsApi({required this.token});

  final String token;

  Future<List<ReportRecord>> fetch() async {
    final data = await ApiClient(token: token).get('/api/reports');
    final list = data['reports'] as List? ?? const [];
    return list
        .map((r) => ReportRecord.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  Future<ReportRecord> create({
    required String meetingType,
    required String branch,
    required String date,
    int attMale = 0,
    int attFemale = 0,
    double tithe = 0,
    int soulsMale = 0,
    int soulsFemale = 0,
    String notes = '',
  }) async {
    final data = await ApiClient(token: token).post('/api/reports', {
      'meetingType': meetingType,
      'branch': branch,
      'date': date,
      'attMale': attMale,
      'attFemale': attFemale,
      'tithe': tithe,
      'soulsMale': soulsMale,
      'soulsFemale': soulsFemale,
      'notes': notes,
    });
    return ReportRecord.fromJson(data['report'] as Map<String, dynamic>);
  }
}
