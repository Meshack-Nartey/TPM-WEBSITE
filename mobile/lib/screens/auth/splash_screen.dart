import 'dart:ui';

import 'package:flutter/material.dart';

import '../../app/session.dart';
import '../../data/mock_data.dart';
import '../../theme/tpm_theme.dart';
import '../../widgets/shells.dart';
import 'welcome_screen.dart';

/// First run. A 4x4 collage of real congregation photography, shown as-is —
/// no scrim over it — with the logo lockup on a small frosted panel so it
/// stays legible over whatever photo lands behind it.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TpmColors.deepNavy,
      body: GestureDetector(
        onTap: () => _continue(context),
        // The collage shouldn't run under the status bar or the bottom
        // gesture area — SafeArea keeps it clear of both.
        child: SafeArea(
          child: Stack(
            fit: StackFit.expand,
            children: [
              const _PhotoCollage(),
              const _LogoLockup(),
              Positioned(
                left: 0,
                right: 0,
                bottom: 40,
                child: Center(
                  child: _TapToContinue(onTap: () => _continue(context)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _continue(BuildContext context) {
    // A restored session (see AppSession.restore, called at app start) skips
    // straight past sign-in rather than making someone log in every launch.
    if (AppSession.of(context).isSignedIn) {
      MemberShell.enter(context);
      return;
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
    );
  }
}

/// A plain 4x4 grid — sixteen photos, no scrim, no cropping tricks — that
/// fades in one column at a time, left to right (top and bottom of a column
/// together, rather than the bottom rows waiting on the top ones), then
/// holds and repeats the
/// whole wave every 4 seconds for as long as the splash screen is up.
class _PhotoCollage extends StatefulWidget {
  const _PhotoCollage();

  @override
  State<_PhotoCollage> createState() => _PhotoCollageState();
}

class _PhotoCollageState extends State<_PhotoCollage>
    with SingleTickerProviderStateMixin {
  // Tiles stagger by column, not by tile — so a column's top and bottom
  // photo start fading in together instead of the bottom rows waiting for
  // every row above them to finish first.
  static const _columnCount = 4;

  // The wave itself only fills the first 60% of each 2s cycle — the rest is
  // a hold at full opacity before it resets and plays again.
  static const _activeFraction = 0.6;
  static const _tileSpan = 0.35;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Each column gets its own slice of the controller's 0–1 span, so columns
  /// fade in left to right rather than all together — and every tile in a
  /// column shares that same slice, so it fades in as one unit.
  Animation<double> _fadeForColumn(int col) {
    final step = (_activeFraction - _tileSpan) / (_columnCount - 1);
    final start = col * step;
    return CurvedAnimation(
      parent: _controller,
      curve: Interval(start, start + _tileSpan, curve: Curves.easeOut),
    );
  }

  @override
  Widget build(BuildContext context) {
    final photos = MockData.splashCollage;
    return Column(
      children: [
        for (var row = 0; row < 4; row++) ...[
          if (row > 0) const SizedBox(height: 4),
          Expanded(
            child: Row(
              children: [
                for (var col = 0; col < 4; col++) ...[
                  if (col > 0) const SizedBox(width: 4),
                  Expanded(
                    child: _Tile(
                      photos[row * 4 + col],
                      fade: _fadeForColumn(col),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile(this.asset, {required this.fade});

  final String asset;
  final Animation<double> fade;

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: fade,
        child: ScaleTransition(
          scale: Tween(begin: 0.94, end: 1.0).animate(fade),
          child: SizedBox.expand(
            // Both axes must be constrained, or the image keeps its own aspect
            // ratio in the free one and leaves a gap.
            child: Image.asset(asset, fit: BoxFit.cover),
          ),
        ),
      );
}

class _LogoLockup extends StatelessWidget {
  const _LogoLockup();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: ConstrainedBox(
          // On the very first frame, before the engine reports real window
          // metrics, MediaQuery.size can briefly be 0x0 — clamp so that never
          // produces a negative (and invalid) max width.
          constraints: BoxConstraints(
            maxWidth: (MediaQuery.sizeOf(context).width - 64).clamp(200.0, double.infinity),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
                decoration: BoxDecoration(
                  color: TpmColors.deepNavy.withValues(alpha: 0.42),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/brand/logo-mark.png',
                          width: 64,
                          height: 64,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(width: 14),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'TRANSFORMATION',
                                style: TpmText.display(16.5, color: Colors.white, height: 1.1)
                                    .copyWith(letterSpacing: 0.3),
                              ),
                              Text(
                                'PROJECT MINISTRIES',
                                style: TpmText.display(
                                  14.5,
                                  color: Colors.white.withValues(alpha: 0.92),
                                  weight: FontWeight.bold,
                                  height: 1.25,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'TRANSFORMING LIVES',
                      style: TpmText.eyebrow(
                        color: const Color(0xFFF0D375),
                        size: 11,
                        tracking: 3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TapToContinue extends StatelessWidget {
  const _TapToContinue({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: TpmColors.gold, width: 2),
          ),
          child: Text(
            'Tap to continue',
            style: TpmText.body(13.5, color: TpmColors.navy, weight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}
