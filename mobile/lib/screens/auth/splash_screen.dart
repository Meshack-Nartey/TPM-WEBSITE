import 'dart:ui';

import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../theme/tpm_theme.dart';
import 'welcome_screen.dart';

/// First run. A collage of real congregation photography behind the logo
/// lockup, pulled far enough back by the scrim that the gold reads cleanly.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TpmColors.deepNavy,
      body: GestureDetector(
        onTap: () => _continue(context),
        child: Stack(
          fit: StackFit.expand,
          children: [
            const _PhotoCollage(),
            // Scrim: navy at the top, blue through the middle, dark at the base.
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0, 0.55, 1],
                  colors: [
                    TpmColors.deepNavy.withValues(alpha: 0.72),
                    TpmColors.navy.withValues(alpha: 0.62),
                    TpmColors.deepNavy.withValues(alpha: 0.86),
                  ],
                ),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.16),
                  radius: 0.75,
                  colors: [
                    TpmColors.gold.withValues(alpha: 0.22),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            const _LogoLockup(),
            Positioned(
              left: 0,
              right: 0,
              bottom: 70,
              child: Center(
                child: _TapToContinue(onTap: () => _continue(context)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _continue(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
    );
  }
}

class _PhotoCollage extends StatelessWidget {
  const _PhotoCollage();

  @override
  Widget build(BuildContext context) {
    final photos = MockData.splashCollage;
    return Column(
      children: [
        Expanded(
          flex: 11,
          child: Row(
            children: [
              Expanded(child: _Tile(photos[0])),
              const SizedBox(width: 6),
              Expanded(child: _Tile(photos[1])),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Expanded(flex: 9, child: _Tile(photos[2])),
        const SizedBox(height: 6),
        Expanded(
          flex: 10,
          child: Row(
            children: [
              Expanded(child: _Tile(photos[3])),
              const SizedBox(width: 6),
              Expanded(child: _Tile(photos[4])),
            ],
          ),
        ),
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile(this.asset);

  final String asset;

  @override
  Widget build(BuildContext context) => SizedBox.expand(
        // Both axes must be constrained, or the image keeps its own aspect
        // ratio in the free one and leaves a gap the scrim renders as a band.
        child: Image.asset(asset, fit: BoxFit.cover),
      );
}

class _LogoLockup extends StatelessWidget {
  const _LogoLockup();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Vignette that darkens the photography directly behind the wordmark.
          Container(
            width: 340,
            height: 360,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF080C16).withValues(alpha: 0.96),
                  const Color(0xFF080C16).withValues(alpha: 0.8),
                  Colors.transparent,
                ],
                stops: const [0, 0.5, 0.8],
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                  child: Container(
                    width: 100,
                    height: 100,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                    ),
                    child: Image.asset('assets/brand/logo-mark.png', fit: BoxFit.contain),
                  ),
                ),
              ),
              const SizedBox(height: 26),
              Text(
                'Transformation',
                textAlign: TextAlign.center,
                style: TpmText.display(27, color: Colors.white, height: 1.15).copyWith(
                  letterSpacing: 0.5,
                  shadows: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.85),
                      blurRadius: 24,
                    ),
                  ],
                ),
              ),
              Text(
                'Project Ministries',
                textAlign: TextAlign.center,
                style: TpmText.display(
                  19,
                  color: Colors.white.withValues(alpha: 0.92),
                  weight: FontWeight.w500,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'TRANSFORMING LIVES',
                style: TpmText.eyebrow(color: const Color(0xFFF0D375), size: 11, tracking: 3),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TapToContinue extends StatelessWidget {
  const _TapToContinue({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Material(
          color: Colors.white.withValues(alpha: 0.16),
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
              child: Text(
                'Tap to continue',
                style: TpmText.body(13.5, color: Colors.white, weight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
