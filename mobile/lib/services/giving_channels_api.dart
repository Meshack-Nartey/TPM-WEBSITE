import '../models/models.dart';
import 'api_client.dart';

/// Talks to `backend/src/routes/givingChannels.routes.js` — the office's
/// real MoMo/bank accounts shown on the Give screen.
class GivingChannelsApi {
  const GivingChannelsApi({required this.token});

  final String token;

  Future<List<GivingChannel>> fetch() async {
    final data = await ApiClient(token: token).get('/api/giving-channels');
    final rows = data['channels'] as List? ?? const [];
    return rows
        .map((r) => GivingChannel.fromJson(r as Map<String, dynamic>))
        .toList();
  }
}
