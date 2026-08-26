import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../theme/tpm_theme.dart';
import '../../widgets/common.dart';

/// Immersive playback. The one member screen that goes full-bleed dark, because
/// listening to a message should not compete with the rest of the app.
class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key, required this.item});

  final MediaItem item;

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  bool _playing = true;
  late bool _downloaded = widget.item.downloaded;

  /// Fixed position for the prototype — real playback lands with the API.
  static const double _progress = 0.38;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomRight,
            stops: [0, 0.6, 1],
            colors: [TpmColors.deepNavy, TpmColors.navy, TpmColors.blueDeep],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _GlassButton(
                      icon: Icons.expand_more_rounded,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                    Text(
                      'NOW PLAYING',
                      style: TpmText.eyebrow(
                        color: Colors.white.withValues(alpha: 0.7),
                        size: 10,
                        tracking: 1.6,
                      ),
                    ),
                    _GlassButton(icon: Icons.ios_share_rounded, onTap: () {}),
                  ],
                ),
                const Spacer(flex: 2),
                ClipRRect(
                  borderRadius: BorderRadius.circular(26),
                  child: SizedBox(
                    width: 230,
                    height: 230,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        BrandedPhoto(asset: widget.item.image, scrimOpacity: 0.35),
                        Center(
                          child: Icon(
                            widget.item.kind.icon,
                            size: 54,
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  widget.item.title,
                  textAlign: TextAlign.center,
                  style: TpmText.display(24, color: Colors.white),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.item.meta,
                  style: TpmText.body(
                    13.5,
                    color: Colors.white.withValues(alpha: 0.65),
                  ),
                ),
                const SizedBox(height: 28),
                const _Scrubber(progress: _progress),
                const SizedBox(height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.skip_previous_rounded,
                      size: 34,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                    const SizedBox(width: 30),
                    GestureDetector(
                      onTap: () => setState(() => _playing = !_playing),
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Icon(
                          _playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          size: 34,
                          color: TpmColors.navy,
                        ),
                      ),
                    ),
                    const SizedBox(width: 30),
                    Icon(
                      Icons.skip_next_rounded,
                      size: 34,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: TpmOutlineButton(
                        label: _downloaded ? 'Downloaded' : 'Download',
                        icon: _downloaded
                            ? Icons.check_circle_rounded
                            : Icons.download_rounded,
                        foreground: Colors.white,
                        background: Colors.white.withValues(alpha: 0.1),
                        borderColor: Colors.white.withValues(alpha: 0.25),
                        height: 48,
                        onPressed: () => setState(() => _downloaded = !_downloaded),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TpmOutlineButton(
                        label: 'Share',
                        icon: Icons.ios_share_rounded,
                        foreground: Colors.white,
                        background: Colors.white.withValues(alpha: 0.1),
                        borderColor: Colors.white.withValues(alpha: 0.25),
                        height: 48,
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Scrubber extends StatelessWidget {
  const _Scrubber({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            return SizedBox(
              height: 12,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.centerLeft,
                children: [
                  Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  Container(
                    height: 4,
                    width: width * progress,
                    decoration: BoxDecoration(
                      color: TpmColors.gold,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  Positioned(
                    left: width * progress - 6,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '16:04',
              style: TpmText.body(11.5, color: Colors.white.withValues(alpha: 0.6)),
            ),
            Text(
              '42:00',
              style: TpmText.body(11.5, color: Colors.white.withValues(alpha: 0.6)),
            ),
          ],
        ),
      ],
    );
  }
}

class _GlassButton extends StatelessWidget {
  const _GlassButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.15),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 38,
          height: 38,
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}
