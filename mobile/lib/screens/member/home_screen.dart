import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/navigation.dart';
import '../../data/mock_data.dart';
import '../../theme/tpm_theme.dart';
import '../../widgets/common.dart';
import 'announcement_detail_screen.dart';

/// The member's landing screen: who you are, what's coming, and the quickest
/// routes back into the ministry.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _ticker;
  late DateTime _nextService = _computeNextService();

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (DateTime.now().isAfter(_nextService)) {
          _nextService = _computeNextService();
        }
      });
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  /// The coming Sunday at 9:00. If that has already passed today, roll forward
  /// a week rather than counting down to a service that has started.
  static DateTime _computeNextService() {
    final now = DateTime.now();
    final daysUntilSunday = (DateTime.sunday - now.weekday) % 7;
    var target = DateTime(
      now.year,
      now.month,
      now.day + daysUntilSunday,
      MockData.nextServiceHour,
    );
    if (!target.isAfter(now)) target = target.add(const Duration(days: 7));
    return target;
  }

  @override
  Widget build(BuildContext context) {
    // Dark from the top of the photo slideshow all the way down — the
    // countdown and quick actions sit on the same surface, not a separate
    // light card floating below.
    return ColoredBox(
      color: TpmColors.night,
      child: ListView(
        // Always scrollable, even if the content happens to be short enough
        // to fit — a fixed-in-place feel here reads as broken, not tidy.
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const _Hero(),
          const SizedBox(height: 40),
          _CountdownCard(target: _nextService),
        ],
      ),
    );
  }
}

/// The website's hero, ported to a phone-width card: a dark, full-bleed
/// photo slideshow — crossfading through the same shots the website cycles —
/// with the ministry's name and tagline overlaid at the bottom, legible over
/// a dark gradient. Replaces the personal "Good evening" greeting.
class _Hero extends StatefulWidget {
  const _Hero();

  @override
  State<_Hero> createState() => _HeroState();
}

class _HeroState extends State<_Hero> {
  // hero1–hero6 (and about-1) are tight portrait crops or busy stage shots
  // with faces right at the top of the frame — no amount of cropping here
  // gives the banner clearance on all of them. These three are actually
  // composed with headroom at the top instead.
  static const _photos = [
    'assets/photos/gathering.jpg',
    'assets/photos/join-us.jpg',
    'assets/photos/growth.jpg',
  ];

  Timer? _ticker;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      setState(() => _index = (_index + 1) % _photos.length);
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 500,
      width: double.infinity,
      child: ColoredBox(
        color: TpmColors.night,
        child: Stack(
          fit: StackFit.expand,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 900),
              // AnimatedSwitcher lays its child out loosely, so without an
              // explicit size the image would shrink to its own intrinsic
              // size instead of covering the hero — leaving a bare gap of
              // the ColoredBox behind it.
              child: Image.asset(
                _photos[_index],
                key: ValueKey(_index),
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                alignment: const Alignment(0, -0.3),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.25),
                    Colors.black.withValues(alpha: 0.2),
                    TpmColors.night,
                  ],
                  stops: const [0, 0.55, 1],
                ),
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Eyebrow('Transforming Lives', color: TpmColors.gold),
                  const SizedBox(height: 8),
                  Text(
                    MockData.ministryName,
                    style: TpmText.display(
                      24,
                      color: Colors.white,
                      height: 1.15,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              right: 20,
              top: 98,
              child: Row(
                children: [
                  for (var i = 0; i < _photos.length; i++) ...[
                    if (i > 0) const SizedBox(width: 5),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: i == _index ? 14 : 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(
                          alpha: i == _index ? 0.95 : 0.4,
                        ),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Positioned(
              top: 14,
              left: 14,
              right: 14,
              child: _AnnouncementTicker(),
            ),
          ],
        ),
      ),
    );
  }
}

/// A slim banner pinned above the hero slideshow, cycling through the same
/// announcements the website surfaces — dismissible, the way the reference
/// site's "New and Featured" strip works.
class _AnnouncementTicker extends StatefulWidget {
  const _AnnouncementTicker();

  @override
  State<_AnnouncementTicker> createState() => _AnnouncementTickerState();
}

class _AnnouncementTickerState extends State<_AnnouncementTicker> {
  Timer? _ticker;
  int _index = 0;
  bool _dismissed = false;

  @override
  void initState() {
    super.initState();
    if (MockData.carousel.length > 1) {
      _ticker = Timer.periodic(const Duration(seconds: 5), (_) {
        if (!mounted) return;
        setState(() => _index = (_index + 1) % MockData.carousel.length);
      });
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_dismissed || MockData.carousel.isEmpty) return const SizedBox.shrink();
    final item = MockData.carousel[_index];

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      // A BackdropFilter blur here silently fails to paint anything on this
      // device's Impeller/Vulkan backend, so the banner reads as fine when
      // reviewed in code but is invisible on screen — a solid translucent
      // surface avoids that entirely.
      child: Material(
        color: TpmColors.navy.withValues(alpha: 0.9),
        child: InkWell(
          onTap: () =>
              pushScreen(context, AnnouncementDetailScreen(item: item)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
            child: Row(
              children: [
                const Icon(
                  Icons.notifications_rounded,
                  size: 18,
                  color: TpmColors.gold,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: Column(
                      key: ValueKey(item.title),
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TpmText.body(
                            14,
                            color: Colors.white,
                            weight: FontWeight.w600,
                          ),
                        ),
                        if (item.date.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            item.date,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TpmText.body(
                              12,
                              color: Colors.white.withValues(alpha: 0.72),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => setState(() => _dismissed = true),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.close_rounded,
                      size: 19,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CountdownCard extends StatelessWidget {
  const _CountdownCard({required this.target});

  final DateTime target;

  @override
  Widget build(BuildContext context) {
    final remaining = target.difference(DateTime.now());
    final safe = remaining.isNegative ? Duration.zero : remaining;
    final units = [
      (safe.inDays, 'Days'),
      (safe.inHours % 24, 'Hrs'),
      (safe.inMinutes % 60, 'Min'),
      (safe.inSeconds % 60, 'Sec'),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
        decoration: BoxDecoration(
          // nightSurface sits almost flush with the page's own night
          // background (#111 on #080808), so the card reads as a separate
          // surface here instead of nearly vanishing into it.
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: TpmColors.portalGold.withValues(alpha: 0.22),
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(
                  Icons.church_rounded,
                  size: 14,
                  color: TpmColors.portalGold,
                ),
                const SizedBox(width: 8),
                const Flexible(
                  child: Eyebrow(
                    'Next Service',
                    size: 10,
                    tracking: 1.2,
                    color: TpmColors.portalGold,
                  ),
                ),
                const Spacer(),
                Text(
                  MockData.nextServiceLabel,
                  style: TpmText.body(
                    12.5,
                    color: TpmColors.portalInk,
                    weight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                for (var i = 0; i < units.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        gradient: TpmColors.blueGradient,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        children: [
                          Text(
                            units[i].$1.toString().padLeft(2, '0'),
                            style: TpmText.display(
                              24,
                              color: Colors.white,
                              height: 1,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            units[i].$2.toUpperCase(),
                            style: TpmText.body(
                              9,
                              color: Colors.white.withValues(alpha: 0.75),
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
