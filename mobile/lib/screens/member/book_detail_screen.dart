import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../theme/tpm_theme.dart';
import '../../widgets/common.dart';

class BookDetailScreen extends StatelessWidget {
  const BookDetailScreen({super.key, required this.book});

  final Book book;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TpmColors.canvas,
      // Pinned to the bottom of the screen rather than trailing the
      // description — it's the one action here, and shouldn't move with
      // however long the description happens to be.
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: TpmColors.canvas,
          border: Border(
            top: BorderSide(color: TpmColors.faint.withValues(alpha: 0.25)),
          ),
        ),
        child: SafeArea(
          minimum: const EdgeInsets.fromLTRB(26, 12, 26, 16),
          child: Row(
            children: [
              Expanded(
                child: TpmButton(
                  label: 'Read now',
                  icon: Icons.menu_book_rounded,
                  height: 50,
                  onPressed: () {},
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 58,
                child: TpmOutlineButton(
                  label: '',
                  icon: Icons.download_rounded,
                  height: 50,
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '“${book.title}” saved for offline reading',
                      ),
                      behavior: SnackBarBehavior.floating,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(26, 12, 26, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleBackButton(
                size: 38,
                onTap: () => Navigator.of(context).pop(),
              ),
              const SizedBox(height: 28),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: TpmColors.navy.withValues(alpha: 0.28),
                            blurRadius: 34,
                            offset: const Offset(0, 16),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        book.cover,
                        width: 120,
                        height: 160,
                        fit: BoxFit.cover,
                        semanticLabel: book.title,
                      ),
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          book.title,
                          style: TpmText.display(21, height: 1.2),
                        ),
                        const SizedBox(height: 4),
                        Text(book.author, style: TpmText.body(12.8)),
                        const SizedBox(height: 10),
                        const Pill(
                          'Study Guide',
                          foreground: TpmColors.goldDeep,
                          background: TpmColors.tintAmber,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Text(
                'A practical companion for personal and small-group study. Each chapter '
                'closes with reflection questions and Scripture to carry into the week.',
                style: TpmText.body(14, color: TpmColors.muted, height: 1.7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
