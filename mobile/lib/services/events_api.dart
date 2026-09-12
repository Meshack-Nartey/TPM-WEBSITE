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

  Future<EventItem> create(Map<String, dynamic> fields) async {
    final data = await ApiClient(token: token).post('/api/events', fields);
    return EventItem.fromJson(data['event'] as Map<String, dynamic>);
  }

  Future<EventItem> update(String id, Map<String, dynamic> fields) async {
    final data = await ApiClient(token: token).patch('/api/events/$id', fields);
    return EventItem.fromJson(data['event'] as Map<String, dynamic>);
  }

  Future<void> delete(String id) {
    return ApiClient(token: token).delete('/api/events/$id');
  }
}
