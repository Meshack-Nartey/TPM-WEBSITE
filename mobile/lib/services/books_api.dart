import '../models/models.dart';
import 'api_client.dart';

/// Talks to `backend/src/routes/books.routes.js` — the Books & Resources
/// shelf.
class BooksApi {
  const BooksApi({required this.token});

  final String token;

  Future<List<Book>> fetch() async {
    final data = await ApiClient(token: token).get('/api/books');
    final rows = data['books'] as List? ?? const [];
    return rows.map((r) => Book.fromJson(r as Map<String, dynamic>)).toList();
  }

  Future<Book> create(Map<String, dynamic> fields) async {
    final data = await ApiClient(token: token).post('/api/books', fields);
    return Book.fromJson(data['book'] as Map<String, dynamic>);
  }

  Future<Book> update(String id, Map<String, dynamic> fields) async {
    final data = await ApiClient(token: token).patch('/api/books/$id', fields);
    return Book.fromJson(data['book'] as Map<String, dynamic>);
  }

  Future<void> delete(String id) {
    return ApiClient(token: token).delete('/api/books/$id');
  }
}
