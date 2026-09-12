import 'package:flutter/material.dart';

import '../../app/navigation.dart';
import '../../app/session.dart';
import '../../data/mock_data.dart';
import '../../models/models.dart';
import '../../services/auth_api.dart';
import '../../services/books_api.dart';
import '../../theme/tpm_theme.dart';
import '../../widgets/common.dart';
import 'book_detail_screen.dart';

/// Study guides and resources. These are the ministry's real covers, so the
/// artwork carries the title — the caption underneath stays quiet and only
/// repeats the title for accessibility and search.
class BooksScreen extends StatefulWidget {
  const BooksScreen({super.key});

  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  bool _loaded = false;
  List<Book> _books = MockData.books;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      _load();
    }
  }

  Future<void> _load() async {
    final token = AppSession.of(context).token;
    if (token == null) return; // Guest preview — the sample shelf stands in.
    try {
      final books = await BooksApi(token: token).fetch();
      if (!mounted || books.isEmpty) return;
      setState(() => _books = books);
    } on ApiException {
      // Keep the fallback list.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TpmColors.canvas,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 12, 22, 0),
                child: ScreenTitle(
                  eyebrow: 'Grow deeper',
                  title: 'Books & Resources',
                  titleSize: 24,
                  onBack: () => Navigator.of(context).pop(),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(22, 16, 22, 24),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 18,
                  childAspectRatio: 0.6,
                ),
                delegate: SliverChildBuilderDelegate(
                  childCount: _books.length,
                  (context, i) => _BookTile(book: _books[i]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookTile extends StatelessWidget {
  const _BookTile({required this.book});

  final Book book;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => pushScreen(context, BookDetailScreen(book: book)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: TpmColors.navy.withValues(alpha: 0.18),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Image.asset(
                  book.cover,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  semanticLabel: book.title,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            book.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TpmText.body(
              13,
              color: TpmColors.ink,
              weight: FontWeight.w700,
            ),
          ),
          Text(
            book.author,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TpmText.body(11.5),
          ),
        ],
      ),
    );
  }
}
