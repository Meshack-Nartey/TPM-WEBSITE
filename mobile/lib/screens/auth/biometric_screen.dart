import 'package:flutter/material.dart';

import '../../app/session.dart';
import '../../models/models.dart';
import '../../theme/tpm_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/shells.dart';

/// One of two dark moments in an otherwise light onboarding flow — the system
/// is taking over the screen, so the app steps back into the brand's night
/// palette rather than pretending it is still in charge.
class BiometricScreen extends StatefulWidget {
  const BiometricScreen({super.key, this.role = AppRole.member});

  final AppRole role;

  @override
  State<BiometricScreen> createState() => _BiometricScreenState();
}

class _BiometricScreenState extends State<BiometricScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TpmColors.deepNavy,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomRight,
            colors: [TpmColors.deepNavy, TpmColors.navy],
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.3),
                  radius: 0.75,
                  colors: [
                    TpmColors.gold.withValues(alpha: 0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FadeTransition(
                    opacity: Tween<double>(begin: 1, end: 0.35).animate(_pulse),
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: TpmColors.gold.withValues(alpha: 0.5),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.face_rounded,
                        size: 54,
                        color: TpmColors.gold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    'Unlock with Face ID',
                    style: TpmText.display(25, color: Colors.white),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Look at your phone to sign in securely.',
                    style: TpmText.body(
                      13.8,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 26,
              right: 26,
              bottom: 60,
              child: Column(
                children: [
                  TpmButton(
                    label: 'Simulate unlock',
                    icon: Icons.fingerprint_rounded,
                    gradient: TpmColors.goldGradient,
                    foreground: TpmColors.night,
                    onPressed: () {
                      AppSession.of(context).signInAs(widget.role);
                      MemberShell.enter(context);
                    },
                  ),
                  const SizedBox(height: 12),
                  TpmOutlineButton(
                    label: 'Use password instead',
                    foreground: Colors.white,
                    background: Colors.white.withValues(alpha: 0.08),
                    borderColor: Colors.white.withValues(alpha: 0.25),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
