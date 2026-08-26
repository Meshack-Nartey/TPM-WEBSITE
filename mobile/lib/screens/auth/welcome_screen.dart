import 'package:flutter/material.dart';

import '../../app/session.dart';
import '../../models/models.dart';
import '../../theme/tpm_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/shells.dart';
import 'register_screen.dart';
import 'sign_in_screen.dart';

/// The first real choice in the app: how does this person want to join?
/// Tapping a role goes straight into the sign-up form for that role, with an
/// invite code asked for where the role needs one.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TpmColors.canvas,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(26, 20, 26, 34),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.asset(
                'assets/brand/logo-mark.png',
                height: 56,
                fit: BoxFit.contain,
                semanticLabel: 'Transformation Project Ministries',
              ),
              const SizedBox(height: 22),
              Text('Continue as', style: TpmText.display(28)),
              const SizedBox(height: 4),
              Text(
                'Pick the role that describes you — you\'ll set up your account next.',
                style: TpmText.body(13.8),
              ),
              const SizedBox(height: 24),
              for (final role in const [AppRole.member, AppRole.leader, AppRole.admin]) ...[
                _RoleTile(
                  role: role,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => RegisterScreen(role: role)),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              const SizedBox(height: 8),
              Wrap(
                alignment: WrapAlignment.center,
                children: [
                  Text('Already have an account? ', style: TpmText.body(13.5)),
                  GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SignInScreen()),
                    ),
                    child: Text(
                      'Sign in',
                      style: TpmText.body(
                        13.5,
                        color: TpmColors.navy,
                        weight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              TextButton(
                onPressed: () {
                  AppSession.of(context).signInAs(AppRole.guest);
                  MemberShell.enter(context);
                },
                child: Text(
                  'Continue as guest',
                  style: TpmText.body(13.8, color: TpmColors.subtle, weight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleTile extends StatelessWidget {
  const _RoleTile({required this.role, required this.onTap});

  final AppRole role;
  final VoidCallback onTap;

  static const _icons = {
    AppRole.member: Icons.person_rounded,
    AppRole.leader: Icons.groups_rounded,
    AppRole.admin: Icons.shield_rounded,
  };

  @override
  Widget build(BuildContext context) {
    return TpmCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconTile(
            icon: _icons[role]!,
            background: TpmColors.tintBlue,
            foreground: TpmColors.navy,
            size: 44,
            radius: 12,
            iconSize: 21,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(role.label, style: TpmText.display(16.5, height: 1.2)),
                const SizedBox(height: 2),
                Text(role.blurb, style: TpmText.body(12.5, color: TpmColors.muted)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Color(0xFFCBD5E1)),
        ],
      ),
    );
  }
}
