import 'package:flutter/material.dart';

import '../../app/navigation.dart';
import '../../data/mock_data.dart';
import '../../models/models.dart';
import '../../theme/tpm_theme.dart';
import '../../widgets/common.dart';
import 'event_detail_screen.dart';

/// What's on. Weekly service times sit above the carousel because they are
/// the answer to the question most people open this screen with.
class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      // The shell's tab bar floats over the body (extendBody: true), so the
      // last card needs real clearance or it ends up sitting behind it.
      padding: const EdgeInsets.only(top: 20, bottom: 110),
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 22),
          child: ScreenTitle(eyebrow: "What's on", title: 'Events'),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              gradient: TpmColors.blueGradient,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.schedule_rounded,
                  color: TpmColors.gold,
                  size: 21,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'WEEKLY SERVICES',
                        style: TpmText.eyebrow(
                          color: Colors.white.withValues(alpha: 0.7),
                          size: 9.5,
                          tracking: 1.4,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        MockData.serviceSummary,
                        style: TpmText.body(13, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const _EventsCarousel(),
      ],
    );
  }
}

/// Each event's own flyer, full-bleed and swipeable — the flyers are already
/// designed posters with the date and title baked in, so this shows them
/// clean rather than laying another card's worth of text over them.
class _EventsCarousel extends StatefulWidget {
  const _EventsCarousel();

  @override
  State<_EventsCarousel> createState() => _EventsCarouselState();
}

class _EventsCarouselState extends State<_EventsCarousel> {
  late final PageController _controller = PageController(
    viewportFraction: 0.88,
  );
  double _page = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(
      () => setState(() => _page = _controller.page ?? 0),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final events = MockData.events;

    return Column(
      children: [
        SizedBox(
          height: 300,
          child: PageView.builder(
            controller: _controller,
            padEnds: false,
            itemCount: events.length,
            itemBuilder: (context, i) => Padding(
              padding: EdgeInsets.only(
                left: i == 0 ? 22 : 8,
                right: i == events.length - 1 ? 22 : 8,
              ),
              child: _EventBannerCard(event: events[i]),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < events.length; i++)
              _PageDot(active: (_page - i).abs() < 0.5),
          ],
        ),
      ],
    );
  }
}

class _EventBannerCard extends StatelessWidget {
  const _EventBannerCard({required this.event});

  final EventItem event;

  @override
  Widget build(BuildContext context) {
    return TpmCard(
      padding: EdgeInsets.zero,
      onTap: () => pushScreen(context, EventDetailScreen(event: event)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                BrandedPhoto(asset: event.image, scrimOpacity: 0),
                Positioned(top: 10, left: 10, child: _DateBadge(event: event)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TpmText.display(16),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 13,
                            color: TpmColors.faint,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              event.location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TpmText.body(12),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFFCBD5E1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DateBadge extends StatelessWidget {
  const _DateBadge({required this.event});

  final EventItem event;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(12),
      ),
      child: event.isDated
          ? Column(
              children: [
                Text(
                  event.day!,
                  style: TpmText.display(20, color: TpmColors.navy, height: 1),
                ),
                const SizedBox(height: 2),
                Text(
                  event.month!.toUpperCase(),
                  style: TpmText.eyebrow(size: 9, tracking: 1.2),
                ),
              ],
            )
          // Several of the ministry's events are genuinely undated. Saying
          // so beats inventing a day that someone might plan around.
          : Column(
              children: [
                const Icon(
                  Icons.event_rounded,
                  color: TpmColors.navy,
                  size: 18,
                ),
                const SizedBox(height: 3),
                Text('TBA', style: TpmText.eyebrow(size: 9, tracking: 1.2)),
              ],
            ),
    );
  }
}

class _PageDot extends StatelessWidget {
  const _PageDot({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 3),
      width: active ? 20 : 6,
      height: 6,
      decoration: BoxDecoration(
        color: active ? TpmColors.navy : TpmColors.hairline,
        borderRadius: BorderRadius.circular(99),
      ),
    );
  }
}
