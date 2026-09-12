import '../models/models.dart';
import 'api_client.dart';

/// Talks to `backend/src/routes/events.routes.js`.
class EventsApi {
  const EventsApi({required this.token});

  final String token;

  Future<List<EventItem>> fetch() async {
    final data = await ApiClient(token: token).get('/api/events');
    final rows = data['events'] as List? ?? const [];
    return rows
        .map((r) => EventItem.fromJson(r as Map<String, dynamic>))
        .toList();
  }
}
