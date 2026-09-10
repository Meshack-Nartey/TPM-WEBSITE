import 'package:flutter/material.dart';

import '../../app/navigation.dart';
import '../../data/mock_data.dart';
import '../../models/models.dart';
import '../../services/announcements_api.dart';
import '../../services/auth_api.dart';
import '../../theme/tpm_theme.dart';
import '../../widgets/common.dart';
import 'announcement_detail_screen.dart';

class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  bool _loaded = false;
  bool _loading = true;
  String? _error;
  List<Announcement> _items = const [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      _load();
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await const AnnouncementsApi().fetch();
      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TpmColors.canvas,
      body: SafeArea(
        child: RefreshIndicator(
          color: TpmColors.navy,
          onRefresh: _load,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
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
              if (_loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_error != null)
                _LoadError(message: _error!, onRetry: _load)
              else if (_items.isEmpty)
                const _NoAnnouncements()
              else
                for (final item in _items)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 0, 22, 12),
                    child: _NewsRow(item: item),
                  ),
            ],
          ),
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
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(18),
                  ),
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

class _NoAnnouncements extends StatelessWidget {
  const _NoAnnouncements();

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
            IconTile(
              icon: Icons.newspaper_rounded,
              background: TpmColors.tintBlue,
              foreground: TpmColors.navy,
              size: 54,
              radius: 16,
              iconSize: 24,
            ),
            const SizedBox(height: 14),
            Text(
              'Nothing posted yet',
              style: TpmText.body(
                14.5,
                color: TpmColors.ink,
                weight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'New announcements show up here.',
              textAlign: TextAlign.center,
              style: TpmText.body(12.5, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

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
            IconTile(
              icon: Icons.wifi_off_rounded,
              background: TpmColors.tintBlue,
              foreground: TpmColors.navy,
              size: 54,
              radius: 16,
              iconSize: 24,
            ),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TpmText.body(
                13,
                color: TpmColors.ink,
                weight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 14),
            TpmOutlineButton(
              label: 'Retry',
              icon: Icons.refresh_rounded,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
