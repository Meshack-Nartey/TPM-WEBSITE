import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app/navigation.dart';
import '../../data/mock_data.dart';
import '../../models/models.dart';
import '../../theme/tpm_theme.dart';
import '../../widgets/common.dart';
import 'books_screen.dart';
import 'player_screen.dart';

/// The member's landing screen: who you are, what's coming, and the quickest
/// routes back into the ministry.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.onSelectTab});

  final ValueChanged<MemberTab> onSelectTab;

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
        now.year, now.month, now.day + daysUntilSunday, MockData.nextServiceHour);
    if (!target.isAfter(now)) target = target.add(const Duration(days: 7));
    return target;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final greeting = now.hour < 12
        ? 'Good morning'
        : now.hour < 17
            ? 'Good afternoon'
            : 'Good evening';

    return ListView(
      padding: const EdgeInsets.only(top: 12, bottom: 24),
      children: [
        _Greeting(greeting: greeting, date: DateFormat('EEEE, d MMMM').format(now)),
        const SizedBox(height: 18),
        const _AnnouncementCarousel(),
        const SizedBox(height: 8),
        _CountdownCard(target: _nextService),
        const SizedBox(height: 18),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: const Eyebrow('Quick Actions'),
        ),
        const SizedBox(height: 12),
        _QuickActions(onSelectTab: widget.onSelectTab),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: const Eyebrow('Featured Message'),
        ),
        const SizedBox(height: 12),
        const _FeaturedSermon(),
      ],
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting({required this.greeting, required this.date});

  final String greeting;
  final String date;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 0, 22, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Eyebrow(date),
                const SizedBox(height: 3),
                Text(
                  '$greeting,\n${MockData.firstName}',
                  style: TpmText.display(27, height: 1.1),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: TpmColors.blueGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: TpmColors.navy.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Text(
              MockData.initials,
              style: TpmText.body(15, color: Colors.white, weight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnnouncementCarousel extends StatelessWidget {
  const _AnnouncementCarousel();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 152,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 22),
        physics: const PageScrollPhysics(),
        itemCount: MockData.carousel.length,
        separatorBuilder: (_, _) => const SizedBox(width: 14),
        itemBuilder: (context, i) {
          final item = MockData.carousel[i];
          return Container(
            width: 290,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [TpmColors.navy, TpmColors.blueDeep],
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: TpmColors.navy.withValues(alpha: 0.28),
                  blurRadius: 30,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Stack(
              children: [
                if (item.flyer != null)
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: Image.asset(item.flyer!, fit: BoxFit.cover),
                    ),
                  ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      gradient: item.flyer == null
                          ? TpmColors.goldGlow(opacity: 0.4)
                          : LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.05),
                                Colors.black.withValues(alpha: 0.75),
                              ],
                            ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Pill(
                        item.tag,
                        foreground: TpmColors.night,
                        background: TpmColors.gold,
                      ),
                      const Spacer(),
                      Text(
                        item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TpmText.display(20, color: Colors.white, height: 1.2),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.meta,
                        style: TpmText.body(
                          12.5,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
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
          color: Colors.white.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: TpmColors.navy.withValues(alpha: 0.1)),
          boxShadow: TpmShadows.raised,
        ),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.church_rounded, size: 14, color: TpmColors.navy),
                const SizedBox(width: 8),
                const Flexible(
                  child: Eyebrow('Next Service', size: 10, tracking: 1.2),
                ),
                const Spacer(),
                Text(
                  MockData.nextServiceLabel,
                  style: TpmText.body(12.5, weight: FontWeight.w600),
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
                            style: TpmText.display(24, color: Colors.white, height: 1),
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

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.onSelectTab});

  final ValueChanged<MemberTab> onSelectTab;

  @override
  Widget build(BuildContext context) {
    final actions = <(String, IconData, Color, Color, VoidCallback)>[
      ('Watch', Icons.play_arrow_rounded, TpmColors.tintBlue, TpmColors.navy,
          () => onSelectTab(MemberTab.media)),
      ('Give', Icons.volunteer_activism_rounded, TpmColors.tintAmber, TpmColors.goldDeep,
          () => onSelectTab(MemberTab.give)),
      ('Events', Icons.event_rounded, const Color(0xFFE0E7FF), TpmColors.blue,
          () => onSelectTab(MemberTab.events)),
      ('Books', Icons.menu_book_rounded, TpmColors.tintViolet, TpmColors.violet,
          () => pushScreen(context, const BooksScreen())),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Row(
        children: [
          for (var i = 0; i < actions.length; i++) ...[
            if (i > 0) const SizedBox(width: 10),
            Expanded(
              child: TpmCard(
                onTap: actions[i].$5,
                radius: 18,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
                child: Column(
                  children: [
                    IconTile(
                      icon: actions[i].$2,
                      background: actions[i].$3,
                      foreground: actions[i].$4,
                      size: 42,
                      radius: 13,
                      iconSize: 19,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      actions[i].$1,
                      style: TpmText.body(11, color: TpmColors.ink, weight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FeaturedSermon extends StatelessWidget {
  const _FeaturedSermon();

  @override
  Widget build(BuildContext context) {
    final sermon = MockData.featured;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: GestureDetector(
        onTap: () => pushScreen(context, PlayerScreen(item: sermon)),
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: TpmColors.deepNavy,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: TpmColors.deepNavy.withValues(alpha: 0.3),
                blurRadius: 30,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 150,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    BrandedPhoto(asset: sermon.image, scrimOpacity: 0.4),
                    Positioned(
                      left: 18,
                      top: 16,
                      child: Pill(
                        sermon.kind.label,
                        foreground: TpmColors.night,
                        background: TpmColors.gold,
                      ),
                    ),
                    Positioned(
                      right: 16,
                      bottom: 16,
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sermon.title,
                      style: TpmText.display(19, color: Colors.white, height: 1.2),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      sermon.meta,
                      style: TpmText.body(
                        13,
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
