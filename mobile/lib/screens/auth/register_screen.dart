import 'package:flutter/material.dart';

import '../../app/session.dart';
import '../../data/mock_data.dart';
import '../../models/models.dart';
import '../../services/auth_api.dart';
import '../../theme/tpm_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/shells.dart';

/// Creating an account. The home-branch selector matters more than it looks —
/// it is what scopes a member to a branch for the rest of the app.
///
/// [role] comes from the "Continue as" screen. Leader and admin need an
/// invite code — the server checks it against the InviteCode table, this
/// screen just decides whether to ask for one.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, this.role = AppRole.member});

  final AppRole role;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  String? _branch;
  bool _loading = false;
  bool _obscure = true;
  String? _error;
  Map<String, String> _fieldErrors = const {};

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _inviteCodeController = TextEditingController();

  bool get _needsInviteCode => widget.role != AppRole.member;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _inviteCodeController.dispose();
    super.dispose();
  }

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
              Eyebrow(widget.role.label),
              const SizedBox(height: 6),
              Text('Create account', style: TpmText.display(27)),
              const SizedBox(height: 4),
              Text('Join the TPM family in a few steps.', style: TpmText.body(13.8)),
              const SizedBox(height: 22),
              TpmField(
                label: 'Full name',
                hint: 'Ama Boateng',
                icon: Icons.person_outline_rounded,
                controller: _nameController,
                error: _fieldErrors.containsKey('firstName') ||
                    _fieldErrors.containsKey('lastName'),
              ),
              const SizedBox(height: 14),
              TpmField(
                label: 'Email',
                hint: 'you@email.com',
                icon: Icons.email_outlined,
                controller: _emailController,
                error: _fieldErrors.containsKey('email'),
              ),
              const SizedBox(height: 14),
              TpmField(
                label: 'Password',
                hint: 'Create a password',
                icon: Icons.lock_outline_rounded,
                obscure: _obscure,
                controller: _passwordController,
                error: _fieldErrors.containsKey('password'),
                trailing: GestureDetector(
                  onTap: () => setState(() => _obscure = !_obscure),
                  child: Icon(
                    _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    size: 18,
                    color: TpmColors.faint,
                  ),
                ),
              ),
              if (_needsInviteCode) ...[
                const SizedBox(height: 14),
                TpmField(
                  label: 'Invite code',
                  hint: "Ask the pastor's office for yours",
                  icon: Icons.vpn_key_outlined,
                  controller: _inviteCodeController,
                  error: _fieldErrors.containsKey('inviteCode'),
                ),
              ],
              const SizedBox(height: 14),
              _BranchPicker(
                value: _branch,
                onChanged: (b) => setState(() => _branch = b),
              ),
              if (_error != null) ...[
                const SizedBox(height: 14),
                Text(
                  _error!,
                  style: TpmText.body(12.5, color: TpmColors.danger, weight: FontWeight.w600),
                ),
              ],
              const SizedBox(height: 24),
              TpmButton(
                label: _loading ? 'Creating account…' : 'Create account',
                onPressed: _loading ? null : () => _register(context),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Already a member? ', style: TpmText.body(13.5)),
                  Flexible(
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Text(
                        'Sign in',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TpmText.body(
                          13.5,
                          color: TpmColors.navy,
                          weight: FontWeight.w700,
                        ),
                      ),
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

  Future<void> _register(BuildContext context) async {
    final fullName = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (fullName.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() {
        _error = 'Fill in your name, email and password.';
        _fieldErrors = {
          if (fullName.isEmpty) 'firstName': 'Required',
          if (email.isEmpty) 'email': 'Required',
          if (password.isEmpty) 'password': 'Required',
        };
      });
      return;
    }

    final inviteCode = _inviteCodeController.text.trim();
    if (_needsInviteCode && inviteCode.isEmpty) {
      setState(() {
        _error = "Enter the invite code from the pastor's office.";
        _fieldErrors = const {'inviteCode': 'Required'};
      });
      return;
    }

    // The API wants first/last separately; the form asks for one field.
    final parts = fullName.split(RegExp(r'\s+'));
    final firstName = parts.first;
    final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : parts.first;

    setState(() {
      _loading = true;
      _error = null;
      _fieldErrors = const {};
    });

    try {
      final result = await const AuthApi().register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        role: widget.role,
        inviteCode: inviteCode,
        branch: _branch ?? '',
      );
      if (!context.mounted) return;
      await AppSession.of(context).signInWithAuth(result.token, result.user);
      if (!context.mounted) return;
      MemberShell.enter(context);
    } on ApiException catch (e) {
      setState(() {
        _loading = false;
        _error = e.message;
        _fieldErrors = e.fieldErrors;
      });
    }
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
    // Nine branches don't fit a fixed-height sheet on shorter phones —
    // isScrollControlled plus a capped height lets the list scroll instead
    // of overflowing past the bottom of the screen.
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: TpmColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              Text('Choose your home branch', style: TpmText.display(17)),
              const SizedBox(height: 8),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final branch in MockData.branchNames)
                      ListTile(
                        leading: const Icon(
                          Icons.location_on_outlined,
                          color: TpmColors.navy,
                        ),
                        title: Text(
                          branch,
                          style: TpmText.body(
                            14.5,
                            color: TpmColors.ink,
                            weight: FontWeight.w600,
                          ),
                        ),
                        onTap: () => Navigator.of(context).pop(branch),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
    if (picked != null) onChanged(picked);
  }
}
