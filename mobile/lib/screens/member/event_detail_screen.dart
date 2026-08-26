import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../models/models.dart';
import '../../theme/tpm_theme.dart';
import '../../widgets/common.dart';

class EventDetailScreen extends StatelessWidget {
  const EventDetailScreen({super.key, required this.event});

  final EventItem event;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TpmColors.canvas,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _Hero(event: event)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _DetailRow(
                    icon: Icons.event_available_rounded,
                    tintBg: TpmColors.tintBlue,
                    tintFg: TpmColors.navy,
                    label: 'When',
                    value: event.when,
                  ),
                  const SizedBox(height: 14),
                  _DetailRow(
                    icon: Icons.location_on_rounded,
                    tintBg: TpmColors.tintAmber,
                    tintFg: TpmColors.goldDeep,
                    label: 'Where',
                    value: event.location,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    event.description,
                    style: TpmText.body(14, color: TpmColors.muted, height: 1.65),
                  ),
                  const SizedBox(height: 20),
                  TpmButton(
                    label: 'Add to calendar',
                    icon: Icons.calendar_month_rounded,
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('“${event.title}” added to your calendar'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.event});

  final EventItem event;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;

    return SizedBox(
      height: 200 + topInset,
      child: Stack(
        fit: StackFit.expand,
        children: [
          BrandedPhoto(asset: event.image, scrimOpacity: 0.55),
          Positioned(
            top: topInset + 12,
            left: 20,
            child: Material(
              color: Colors.white.withValues(alpha: 0.2),
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => Navigator.of(context).pop(),
                child: const SizedBox(
                  width: 38,
                  height: 38,
                  child: Icon(Icons.chevron_left_rounded, color: Colors.white),
                ),
              ),
            ),
          ),
          Positioned(
            left: 22,
            right: 22,
            bottom: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Pill(
                  event.tag,
                  foreground: TpmColors.night,
                  background: TpmColors.gold,
                ),
                const SizedBox(height: 10),
                Text(
                  event.title,
                  style: TpmText.display(27, color: Colors.white, height: 1.15),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.tintBg,
    required this.tintFg,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color tintBg;
  final Color tintFg;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconTile(icon: icon, background: tintBg, foreground: tintFg),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: TpmText.eyebrow(color: TpmColors.faint, size: 9.5, tracking: 1.2),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TpmText.body(14, color: TpmColors.ink, weight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Kept so the announcement detail screen can reuse the tag palette.
typedef TagPalette = (Color, Color);

TagPalette tagPaletteFor(String tag) => MockData.tagColor(tag);
