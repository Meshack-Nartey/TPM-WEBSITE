import 'package:flutter/material.dart';

import '../../app/navigation.dart';
import '../../data/mock_data.dart';
import '../../models/models.dart';
import '../../theme/tpm_theme.dart';
import '../../widgets/common.dart';
import 'announcement_detail_screen.dart';

class AnnouncementsScreen extends StatelessWidget {
  const AnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TpmColors.canvas,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(top: 20, bottom: 24),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: ScreenTitle(
                eyebrow: 'News & Updates',
                title: 'Announcements',
                titleSize: 24,
                onBack: () => Navigator.of(context).pop(),
              ),
            ),
            const SizedBox(height: 14),
            for (final item in MockData.newsFeed)
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 12),
                child: _NewsRow(item: item),
              ),
          ],
        ),
      ),
    );
  }
}

class _NewsBody extends StatelessWidget {
  const _NewsBody({required this.item, required this.fg, required this.bg});

  final Announcement item;
  final Color fg;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Pill(item.tag, foreground: fg, background: bg, fontSize: 9),
        const SizedBox(height: 9),
        Text(item.title, style: TpmText.display(18, height: 1.25)),
        const SizedBox(height: 5),
        Text(item.excerpt, style: TpmText.body(12.8, height: 1.5)),
        const SizedBox(height: 8),
        Text(item.date, style: TpmText.body(11, color: TpmColors.faint)),
      ],
    );
  }
}

class _NewsRow extends StatelessWidget {
  const _NewsRow({required this.item});

  final Announcement item;

  @override
  Widget build(BuildContext context) {
    final (fg, bg) = MockData.tagColor(item.tag);

    return TpmCard(
      onTap: () => pushScreen(context, AnnouncementDetailScreen(item: item)),
      padding: item.flyer == null ? const EdgeInsets.all(16) : EdgeInsets.zero,
      child: item.flyer == null
          ? _NewsBody(item: item, fg: fg, bg: bg)
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(18)),
                  child: Image.asset(
                    item.flyer!,
                    width: 88,
                    height: 128,
                    fit: BoxFit.cover,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: _NewsBody(item: item, fg: fg, bg: bg),
                  ),
                ),
              ],
            ),
    );
  }
}
