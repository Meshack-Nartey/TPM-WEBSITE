import 'package:flutter/material.dart';

import '../../theme/tpm_theme.dart';
import '../../widgets/common.dart';

/// The states every data screen owes its user.
///
/// This is a reference sheet, not a destination — it exists so loading, empty,
/// error and sync are designed once and reused, rather than improvised per
/// screen. The last block is deliberately in the member theme: the same four
/// states have to work on both surfaces.
class DataStatesScreen extends StatelessWidget {
  const DataStatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TpmColors.nightCanvas,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(top: 20, bottom: 30),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  CircleBackButton(
                    dark: true,
                    size: 36,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Eyebrow('Rigor', color: TpmColors.portalGold, size: 10),
                        const SizedBox(height: 3),
                        Text(
                          'Data States',
                          style: TpmText.display(24, color: TpmColors.portalInk),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
              child: Text(
                'Every data screen ships loading, empty, error & sync states.',
                style: TpmText.body(12.5, color: Colors.white.withValues(alpha: 0.5)),
              ),
            ),
            const SizedBox(height: 20),
            const _SectionLabel(icon: Icons.hourglass_top_rounded, label: 'Loading · skeletons'),
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: PortalCard(
                padding: EdgeInsets.all(14),
                child: Column(
                  children: [
                    _SkeletonRow(titleWidth: 0.60, subWidth: 0.40),
                    SizedBox(height: 12),
                    _SkeletonRow(titleWidth: 0.48, subWidth: 0.55),
                    SizedBox(height: 12),
                    _SkeletonRow(titleWidth: 0.66, subWidth: 0.38),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 22),
            const _SectionLabel(icon: Icons.inbox_rounded, label: 'Empty'),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: PortalCard(
                padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
                child: Column(
                  children: [
                    IconTile(
                      icon: Icons.folder_open_rounded,
                      background: TpmColors.portalGold.withValues(alpha: 0.1),
                      foreground: TpmColors.portalGold,
                      size: 54,
                      radius: 16,
                      iconSize: 25,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'No reports yet',
                      style: TpmText.body(
                        14.5,
                        color: TpmColors.portalInk,
                        weight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 210),
                      child: Text(
                        'Weekly reports for this branch will appear here once submitted.',
                        textAlign: TextAlign.center,
                        style: TpmText.body(
                          12.5,
                          color: Colors.white.withValues(alpha: 0.45),
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: 170,
                      child: TpmButton.gold(
                        label: 'Submit first report',
                        height: 40,
                        fontSize: 12,
                        radius: 11,
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 22),
            const _SectionLabel(
              icon: Icons.warning_amber_rounded,
              label: 'Error · offline',
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: PortalCard(
                borderColor: TpmColors.danger.withValues(alpha: 0.25),
                padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 20),
                child: Column(
                  children: [
                    IconTile(
                      icon: Icons.wifi_off_rounded,
                      background: TpmColors.danger.withValues(alpha: 0.12),
                      foreground: TpmColors.danger,
                      size: 54,
                      radius: 16,
                      iconSize: 25,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      "You're offline",
                      style: TpmText.body(
                        14.5,
                        color: TpmColors.portalInk,
                        weight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 220),
                      child: Text(
                        "We couldn't reach the office. Showing last saved data — "
                        "we'll retry automatically.",
                        textAlign: TextAlign.center,
                        style: TpmText.body(
                          12.5,
                          color: Colors.white.withValues(alpha: 0.45),
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: 140,
                      child: TpmOutlineButton(
                        label: 'Retry now',
                        icon: Icons.refresh_rounded,
                        height: 40,
                        radius: 11,
                        foreground: TpmColors.portalInk,
                        background: Colors.transparent,
                        borderColor: Colors.white.withValues(alpha: 0.15),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 22),
            const _SectionLabel(icon: Icons.cloud_upload_rounded, label: 'Sync badges'),
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: _SyncBadges(),
            ),
            const SizedBox(height: 22),
            const _SectionLabel(
              icon: Icons.light_mode_rounded,
              label: 'Member theme · empty',
            ),
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: _LightEmptyState(),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Icon(icon, size: 12, color: TpmColors.portalGold),
          const SizedBox(width: 7),
          Flexible(child: Eyebrow(label, color: TpmColors.portalGold, size: 10)),
        ],
      ),
    );
  }
}

/// Shimmering placeholder row. The sweep runs left to right so it reads as
/// "loading", not as a broken gradient.
class _SkeletonRow extends StatefulWidget {
  const _SkeletonRow({required this.titleWidth, required this.subWidth});

  final double titleWidth;
  final double subWidth;

  @override
  State<_SkeletonRow> createState() => _SkeletonRowState();
}

class _SkeletonRowState extends State<_SkeletonRow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          children: [
            _Shimmer(progress: _controller.value, width: 40, height: 40, circle: true),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FractionallySizedBox(
                    widthFactor: widget.titleWidth,
                    child: _Shimmer(progress: _controller.value, height: 11),
                  ),
                  const SizedBox(height: 8),
                  FractionallySizedBox(
                    widthFactor: widget.subWidth,
                    child: _Shimmer(progress: _controller.value, height: 9),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Shimmer extends StatelessWidget {
  const _Shimmer({
    required this.progress,
    required this.height,
    this.width,
    this.circle = false,
  });

  final double progress;
  final double height;
  final double? width;
  final bool circle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: circle ? null : BorderRadius.circular(6),
        shape: circle ? BoxShape.circle : BoxShape.rectangle,
        gradient: LinearGradient(
          begin: Alignment(-1 + progress * 2 - 0.6, 0),
          end: Alignment(-1 + progress * 2 + 0.6, 0),
          colors: const [
            Color(0xFF1A1A1A),
            Color(0xFF242424),
            Color(0xFF1A1A1A),
          ],
        ),
      ),
    );
  }
}

class _SyncBadges extends StatelessWidget {
  const _SyncBadges();

  @override
  Widget build(BuildContext context) {
    final badges = <(String, IconData, Color)>[
      ('Synced', Icons.check_circle_rounded, TpmColors.success),
      ('Queued', Icons.schedule_rounded, TpmColors.warning),
      ('Syncing', Icons.sync_rounded, TpmColors.portalGold),
      ('Offline', Icons.cloud_off_rounded, TpmColors.danger),
    ];

    return Wrap(
      spacing: 9,
      runSpacing: 9,
      children: [
        for (final (label, icon, color) in badges)
          Pill(
            label,
            icon: icon,
            foreground: color,
            background: color.withValues(alpha: 0.12),
            borderColor: color.withValues(alpha: 0.3),
            uppercase: false,
            fontSize: 11.5,
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
          ),
      ],
    );
  }
}

class _LightEmptyState extends StatelessWidget {
  const _LightEmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      decoration: BoxDecoration(
        color: TpmColors.slateWash,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const IconTile(
            icon: Icons.bookmark_rounded,
            background: TpmColors.tintBlue,
            foreground: TpmColors.navy,
            size: 54,
            radius: 16,
            iconSize: 25,
          ),
          const SizedBox(height: 14),
          Text(
            'Nothing saved yet',
            style: TpmText.body(14.5, color: TpmColors.ink, weight: FontWeight.w700),
          ),
          const SizedBox(height: 5),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 210),
            child: Text(
              'Sermons and books you save for offline will show up here.',
              textAlign: TextAlign.center,
              style: TpmText.body(12.5, height: 1.5),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 150,
            child: TpmButton(
              label: 'Browse media',
              height: 40,
              fontSize: 12,
              radius: 11,
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }
}
