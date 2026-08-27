import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../models/models.dart';
import '../../theme/tpm_theme.dart';
import '../../widgets/common.dart';

class AnnouncementDetailScreen extends StatelessWidget {
  const AnnouncementDetailScreen({super.key, required this.item});

  final Announcement item;

  @override
  Widget build(BuildContext context) {
    final (fg, bg) = MockData.tagColor(item.tag);

    return Scaffold(
      backgroundColor: TpmColors.canvas,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleBackButton(size: 38, onTap: () => Navigator.of(context).pop()),
              const SizedBox(height: 16),
              if (item.flyer != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.asset(item.flyer!, fit: BoxFit.cover),
                ),
                const SizedBox(height: 18),
              ],
              Pill(item.tag, foreground: fg, background: bg),
              const SizedBox(height: 12),
              Text(item.title, style: TpmText.display(27, height: 1.2)),
              const SizedBox(height: 4),
              Text(item.date, style: TpmText.body(11.5, color: TpmColors.faint)),
              const SizedBox(height: 18),
              Text(
                item.body,
                style: TpmText.body(14.5, color: TpmColors.inkSoft, height: 1.75),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
