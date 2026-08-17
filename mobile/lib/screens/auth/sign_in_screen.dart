import 'package:flutter/material.dart';

import '../../app/session.dart';
import '../../models/models.dart';
import '../../theme/tpm_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/shells.dart';
import 'biometric_screen.dart';
import 'register_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool _obscure = true;

  /// Prototype-only. Stands in for the role the API will return on the real
  /// token, so every one of the 29 screens stays reachable without a backend.
  AppRole _previewRole = AppRole.member;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TpmColors.canvas,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(26, 24, 26, 34),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 60,
                  height: 60,
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    gradient: TpmColors.blueGradient,
                    borderRadius: BorderRadius.circular(17),
                    boxShadow: [
                      BoxShadow(
                        color: TpmColors.navy.withValues(alpha: 0.28),
                        blurRadius: 26,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Image.asset('assets/brand/logo-white.png', fit: BoxFit.contain),
                ),
              ),
              const SizedBox(height: 22),
              Text('Welcome back', style: TpmText.display(28)),
              const SizedBox(height: 4),
              Text('Sign in to continue your journey.', style: TpmText.body(13.8)),
              const SizedBox(height: 24),
              const TpmField(
                label: 'Email',
                hint: 'you@email.com',
                icon: Icons.email_outlined,
              ),
              const SizedBox(height: 16),
              TpmField(
                label: 'Password',
                hint: '••••••••',
                icon: Icons.lock_outline_rounded,
                obscure: _obscure,
                trailing: GestureDetector(
                  onTap: () => setState(() => _obscure = !_obscure),
                  child: Icon(
                    _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    size: 18,
                    color: TpmColors.faint,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Forgot password?',
                  style: TpmText.body(12.5, color: TpmColors.navy, weight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 22),
              TpmButton(label: 'Sign in', onPressed: () => _signIn(context)),
              const SizedBox(height: 12),
              TpmOutlineButton(
                label: 'Use Face / Touch ID',
                icon: Icons.fingerprint_rounded,
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => BiometricScreen(role: _previewRole),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              _RolePreviewPicker(
                value: _previewRole,
                onChanged: (r) => setState(() => _previewRole = r),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  const Expanded(child: Divider(color: TpmColors.hairline, height: 1)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text('or', style: TpmText.body(12, color: TpmColors.faint)),
                  ),
                  const Expanded(child: Divider(color: TpmColors.hairline, height: 1)),
                ],
              ),
              const SizedBox(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('New here? ', style: TpmText.body(13.5)),
                  GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const RegisterScreen()),
                    ),
                    child: Text(
                      'Create an account',
                      style: TpmText.body(13.5, color: TpmColors.navy, weight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  AppSession.of(context).signInAs(AppRole.guest);
                  MemberShell.enter(context);
                },
                child: Text(
                  'Continue as guest',
                  style: TpmText.body(13, color: TpmColors.faint, weight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _signIn(BuildContext context) {
    AppSession.of(context).signInAs(_previewRole);
    MemberShell.enter(context);
  }
}

/// A prototype affordance, not a product feature — it replaces the role the
/// server would hand back so leader and admin screens can be walked too.
class _RolePreviewPicker extends StatelessWidget {
  const _RolePreviewPicker({required this.value, required this.onChanged});

  final AppRole value;
  final ValueChanged<AppRole> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: TpmColors.slateWash,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TpmColors.hairline, style: BorderStyle.solid),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.science_outlined, size: 14, color: TpmColors.faint),
              const SizedBox(width: 7),
              Text(
                'PROTOTYPE · SIGN IN AS',
                style: TpmText.eyebrow(color: TpmColors.faint, size: 9.5, tracking: 1.4),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final role in AppRole.values)
                ChoiceChipPill(
                  label: role.label,
                  selected: role == value,
                  onTap: () => onChanged(role),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
