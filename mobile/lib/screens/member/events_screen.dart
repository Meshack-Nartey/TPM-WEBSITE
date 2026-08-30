import 'package:flutter/material.dart';

import '../../app/navigation.dart';
import '../../data/mock_data.dart';
import '../../models/models.dart';
import '../../theme/tpm_theme.dart';
import '../../widgets/common.dart';
import 'event_detail_screen.dart';

/// What's on. Weekly service times sit above the list because they are the
/// answer to the question most people open this screen with.
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
        for (final event in MockData.events)
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 12),
            child: _EventRow(event: event),
          ),
      ],
    );
  }
}

class _EventRow extends StatelessWidget {
  const _EventRow({required this.event});

  final EventItem event;

  @override
  Widget build(BuildContext context) {
    final (tagFg, tagBg) = MockData.tagColor(event.tag);

    return TpmCard(
      padding: const EdgeInsets.all(14),
      onTap: () => pushScreen(context, EventDetailScreen(event: event)),
      child: Row(
        children: [
          Container(
            width: 56,
            padding: const EdgeInsets.symmetric(vertical: 9),
            decoration: BoxDecoration(
              color: TpmColors.tintBlue,
              borderRadius: BorderRadius.circular(13),
            ),
            child: event.isDated
                ? Column(
                    children: [
                      Text(
                        event.day!,
                        style: TpmText.display(
                          22,
                          color: TpmColors.navy,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        event.month!.toUpperCase(),
                        style: TpmText.eyebrow(size: 9.5, tracking: 1.4),
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
                        size: 20,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'TBA',
                        style: TpmText.eyebrow(size: 9.5, tracking: 1.4),
                      ),
                    ],
                  ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Pill(
                  event.tag,
                  foreground: tagFg,
                  background: tagBg,
                  fontSize: 9,
                ),
                const SizedBox(height: 6),
                Text(event.title, style: TpmText.display(17)),
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
          const Icon(Icons.chevron_right_rounded, color: Color(0xFFCBD5E1)),
        ],
      ),
    );
  }
}
