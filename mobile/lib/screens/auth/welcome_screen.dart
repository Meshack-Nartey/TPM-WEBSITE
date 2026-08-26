import 'package:flutter/material.dart';

import '../../app/session.dart';
import '../../models/models.dart';
import '../../theme/tpm_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/shells.dart';
import 'sign_in_screen.dart';

/// The promise of the app, in one line, before anyone is asked to sign in.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TpmColors.canvas,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(26, 12, 26, 34),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => _goSignIn(context),
                  child: Text(
                    'Skip',
                    style: TpmText.body(13.5, color: TpmColors.subtle, weight: FontWeight.w600),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        gradient: TpmColors.blueGradient,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: TpmColors.navy.withValues(alpha: 0.3),
                            blurRadius: 50,
                            offset: const Offset(0, 24),
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(32),
                              gradient: TpmColors.goldGlow(opacity: 0.4),
                            ),
                            child: const SizedBox.expand(),
                          ),
                          const Icon(
                            Icons.volunteer_activism_rounded,
                            color: Colors.white,
                            size: 74,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 34),
                    Text(
                      'Carry the ministry\nin your pocket',
                      textAlign: TextAlign.center,
                      style: TpmText.display(28, height: 1.15),
                    ),
                    const SizedBox(height: 14),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 270),
                      child: Text(
                        'Sermons, services, giving and your church family — always with '
                        'you, wherever you are.',
                        textAlign: TextAlign.center,
                        style: TpmText.body(14.5, height: 1.6),
                      ),
                    ),
                    const SizedBox(height: 26),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 22,
                          height: 6,
                          decoration: BoxDecoration(
                            color: TpmColors.navy,
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xFFCBD5E1),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              TpmButton(
                label: 'Get started',
                onPressed: () => _goSignIn(context),
              ),
              const SizedBox(height: 4),
              TextButton(
                onPressed: () {
                  AppSession.of(context).signInAs(AppRole.guest);
                  MemberShell.enter(context);
                },
                child: Text(
                  'Continue as guest',
                  style: TpmText.body(13.8, color: TpmColors.navy, weight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _goSignIn(BuildContext context) => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const SignInScreen()),
      );
}
