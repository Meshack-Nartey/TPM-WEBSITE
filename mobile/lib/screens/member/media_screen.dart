import 'package:flutter/material.dart';

import '../../app/navigation.dart';
import '../../data/mock_data.dart';
import '../../models/models.dart';
import '../../theme/tpm_theme.dart';
import '../../widgets/common.dart';
import 'player_screen.dart';

/// Sermons, teachings and podcasts. The download state is deliberately visible
/// on every row — patchy data is the norm, so "do I already have this?" is a
/// first-class question rather than something buried in a detail screen.
class MediaScreen extends StatefulWidget {
  const MediaScreen({super.key});

  @override
  State<MediaScreen> createState() => _MediaScreenState();
}

class _MediaScreenState extends State<MediaScreen> {
  int _filter = 0;

  List<MediaItem> get _visible {
    if (_filter == 0) return MockData.media;
    final wanted = switch (_filter) {
      1 => MediaKind.sermon,
      2 => MediaKind.teaching,
      _ => MediaKind.podcast,
    };
    return MockData.media.where((m) => m.kind == wanted).toList();
  }

  @override
  Widget build(BuildContext context) {
    final items = _visible;

    return ListView(
      padding: const EdgeInsets.only(top: 12, bottom: 24),
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 22),
          child: ScreenTitle(eyebrow: 'Media Library', title: 'Watch & Listen'),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 22),
            itemCount: MockData.mediaFilters.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, i) => ChoiceChipPill(
              label: MockData.mediaFilters[i],
              selected: i == _filter,
              onTap: () => setState(() => _filter = i),
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (items.isEmpty)
          const _NoMedia()
        else
          for (final item in items)
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 12),
              child: _MediaRow(item: item),
            ),
      ],
    );
  }
}

class _MediaRow extends StatelessWidget {
  const _MediaRow({required this.item});

  final MediaItem item;

  @override
  Widget build(BuildContext context) {
    return TpmCard(
      padding: const EdgeInsets.all(12),
      onTap: () => pushScreen(context, PlayerScreen(item: item)),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              width: 64,
              height: 64,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  BrandedPhoto(asset: item.image, scrimOpacity: 0.35),
                  Center(
                    child: Icon(item.kind.icon, color: Colors.white, size: 20),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Eyebrow(item.kind.label, size: 9.5),
                const SizedBox(height: 2),
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TpmText.display(16),
                ),
                const SizedBox(height: 2),
                Text(item.meta, style: TpmText.body(12)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            item.downloaded ? Icons.check_circle_rounded : Icons.download_rounded,
            size: 19,
            color: item.downloaded ? TpmColors.green : TpmColors.faint,
          ),
        ],
      ),
    );
  }
}

class _NoMedia extends StatelessWidget {
  const _NoMedia();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
        decoration: BoxDecoration(
          color: TpmColors.slateWash,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            const IconTile(
              icon: Icons.library_music_rounded,
              background: TpmColors.tintBlue,
              foreground: TpmColors.navy,
              size: 54,
              radius: 16,
              iconSize: 24,
            ),
            const SizedBox(height: 14),
            Text(
              'Nothing in this category yet',
              style: TpmText.body(14.5, color: TpmColors.ink, weight: FontWeight.w700),
            ),
            const SizedBox(height: 5),
            Text(
              'New messages are added after each service.',
              textAlign: TextAlign.center,
              style: TpmText.body(12.5, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
