import 'package:flutter/material.dart';

import '../../app/navigation.dart';
import '../../data/mock_data.dart';
import '../../models/models.dart';
import '../../services/podcast_api.dart';
import '../../theme/tpm_theme.dart';
import '../../widgets/common.dart';
import 'player_screen.dart';

/// Which source a message plays from — the two are different enough in kind
/// (a ~1,300-episode audio feed vs. two YouTube videos) that a shared
/// "category" filter chip row undersold both; a tab each fits better.
enum _MediaTab { podcasts, youtube }

/// Sermons and audio messages. The download state is deliberately visible on
/// every podcast row — patchy data is the norm, so "do I already have this?"
/// is a first-class question rather than something buried in a detail screen.
class MediaScreen extends StatefulWidget {
  const MediaScreen({super.key});

  @override
  State<MediaScreen> createState() => _MediaScreenState();
}

class _MediaScreenState extends State<MediaScreen> {
  _MediaTab _tab = _MediaTab.podcasts;
  final _search = TextEditingController();
  String _query = '';

  /// The two YouTube sermon videos are known up front; the ~1,300-episode
  /// audio-message feed is fetched once and appended when it lands, rather
  /// than blocking the whole screen behind that network call.
  List<MediaItem> _items = MockData.media;
  bool _loadingEpisodes = true;

  @override
  void initState() {
    super.initState();
    _search.addListener(
      () => setState(() => _query = _search.text.trim().toLowerCase()),
    );
    _loadEpisodes();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _loadEpisodes() async {
    try {
      final episodes = await const PodcastApi().fetchEpisodes();
      if (!mounted) return;
      setState(() {
        _items = [...MockData.media, ...episodes];
        _loadingEpisodes = false;
      });
    } on PodcastApiException {
      if (!mounted) return;
      // The two YouTube items still work; only the fetched episodes are
      // missing, so this fails quiet rather than blocking the screen.
      setState(() => _loadingEpisodes = false);
    }
  }

  List<MediaItem> get _visible {
    final source = _items.where(
      (m) => _tab == _MediaTab.podcasts ? m.hasAudio : m.hasVideo,
    );
    if (_query.isEmpty) return source.toList();
    return source.where((m) => m.title.toLowerCase().contains(_query)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final items = _visible;
    final onPodcasts = _tab == _MediaTab.podcasts;

    return ListView(
      // The shell's tab bar floats over the body (extendBody: true), so the
      // last card needs real clearance or it ends up sitting behind it.
      padding: const EdgeInsets.only(top: 20, bottom: 110),
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 22),
          child: ScreenTitle(eyebrow: 'Media Library', title: 'Watch & Listen'),
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Row(
            children: [
              ChoiceChipPill(
                label: 'Podcasts',
                selected: onPodcasts,
                expand: true,
                onTap: () => setState(() => _tab = _MediaTab.podcasts),
              ),
              const SizedBox(width: 10),
              ChoiceChipPill(
                label: 'YouTube',
                selected: !onPodcasts,
                expand: true,
                onTap: () => setState(() => _tab = _MediaTab.youtube),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: _SearchField(controller: _search, onPodcasts: onPodcasts),
        ),
        const SizedBox(height: 16),
        if (items.isEmpty)
          _NoMedia(searching: _query.isNotEmpty, onPodcasts: onPodcasts)
        else
          for (final item in items)
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 12),
              child: _MediaRow(item: item),
            ),
        if (onPodcasts && _loadingEpisodes) const _LoadingMoreMessages(),
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
                  BrandedPhoto(
                    asset: item.image,
                    networkUrl: item.thumbnailUrl,
                    scrimOpacity: 0.35,
                  ),
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
            item.downloaded
                ? Icons.check_circle_rounded
                : Icons.download_rounded,
            size: 19,
            color: item.downloaded ? TpmColors.green : TpmColors.faint,
          ),
        ],
      ),
    );
  }
}

class _LoadingMoreMessages extends StatelessWidget {
  const _LoadingMoreMessages();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 10),
          Text('Loading more messages…', style: TpmText.body(12.5)),
        ],
      ),
    );
  }
}

class _NoMedia extends StatelessWidget {
  const _NoMedia({required this.searching, required this.onPodcasts});

  final bool searching;
  final bool onPodcasts;

  @override
  Widget build(BuildContext context) {
    final kind = onPodcasts ? 'podcast episodes' : 'videos';
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
            IconTile(
              icon: searching
                  ? Icons.search_off_rounded
                  : Icons.library_music_rounded,
              background: TpmColors.tintBlue,
              foreground: TpmColors.navy,
              size: 54,
              radius: 16,
              iconSize: 24,
            ),
            const SizedBox(height: 14),
            Text(
              searching ? 'No messages match that search' : 'No $kind yet',
              style: TpmText.body(
                14.5,
                color: TpmColors.ink,
                weight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              searching
                  ? 'Try a different title or word.'
                  : 'New messages are added after each service.',
              textAlign: TextAlign.center,
              style: TpmText.body(12.5, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.onPodcasts});

  final TextEditingController controller;
  final bool onPodcasts;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: TpmColors.surface,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: TpmColors.hairline),
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, size: 18, color: TpmColors.faint),
          Expanded(
            child: TextField(
              controller: controller,
              style: TpmText.body(14.5, color: TpmColors.ink),
              cursorColor: TpmColors.navy,
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: onPodcasts
                    ? 'Search podcast episodes…'
                    : 'Search videos…',
                hintStyle: TpmText.body(14.5, color: TpmColors.faint),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 13,
                ),
              ),
            ),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) => value.text.isEmpty
                ? const SizedBox.shrink()
                : InkWell(
                    onTap: controller.clear,
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(
                        Icons.close_rounded,
                        size: 16,
                        color: TpmColors.faint,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
