import 'package:flutter/material.dart';

import '../../app/session.dart';
import '../../data/mock_data.dart';
import '../../models/models.dart';
import '../../theme/tpm_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/shells.dart';

/// Creating an account. The home-branch selector matters more than it looks —
/// it is what scopes a member to a branch for the rest of the app.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  String? _branch;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TpmColors.canvas,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(26, 18, 26, 34),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: CircleBackButton(
                  size: 38,
                  onTap: () => Navigator.of(context).pop(),
                ),
              ),
              const SizedBox(height: 16),
              Text('Create account', style: TpmText.display(27)),
              const SizedBox(height: 4),
              Text('Join the TPM family in a few steps.', style: TpmText.body(13.8)),
              const SizedBox(height: 22),
              const TpmField(
                label: 'Full name',
                hint: 'Ama Boateng',
                icon: Icons.person_outline_rounded,
              ),
              const SizedBox(height: 14),
              const TpmField(
                label: 'Email',
                hint: 'you@email.com',
                icon: Icons.email_outlined,
              ),
              const SizedBox(height: 14),
              const TpmField(
                label: 'Password',
                hint: 'Create a password',
                icon: Icons.lock_outline_rounded,
                obscure: true,
              ),
              const SizedBox(height: 14),
              _BranchPicker(
                value: _branch,
                onChanged: (b) => setState(() => _branch = b),
              ),
              const SizedBox(height: 24),
              TpmButton(
                label: 'Create account',
                onPressed: () {
                  AppSession.of(context).signInAs(AppRole.member);
                  MemberShell.enter(context);
                },
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Already a member? ', style: TpmText.body(13.5)),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Text(
                      'Sign in',
                      style: TpmText.body(13.5, color: TpmColors.navy, weight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BranchPicker extends StatelessWidget {
  const _BranchPicker({required this.value, required this.onChanged});

  final String? value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'HOME BRANCH',
          style: TpmText.eyebrow(color: TpmColors.goldDeep, size: 10, tracking: 1.2),
        ),
        const SizedBox(height: 7),
        Material(
          color: TpmColors.surface,
          borderRadius: BorderRadius.circular(13),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => _pick(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: TpmColors.hairline),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 17, color: TpmColors.faint),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      value ?? 'Select your branch',
                      style: TpmText.body(
                        14.5,
                        color: value == null ? TpmColors.faint : TpmColors.ink,
                      ),
                    ),
                  ),
                  const Icon(Icons.expand_more_rounded, size: 18, color: TpmColors.faint),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pick(BuildContext context) async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: TpmColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Text('Choose your home branch', style: TpmText.display(17)),
            const SizedBox(height: 8),
            for (final branch in MockData.branchNames)
              ListTile(
                leading: const Icon(Icons.location_on_outlined, color: TpmColors.navy),
                title: Text(
                  branch,
                  style: TpmText.body(14.5, color: TpmColors.ink, weight: FontWeight.w600),
                ),
                onTap: () => Navigator.of(context).pop(branch),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (picked != null) onChanged(picked);
  }
}
