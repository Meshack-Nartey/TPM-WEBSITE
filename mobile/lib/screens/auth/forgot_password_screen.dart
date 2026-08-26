import 'package:flutter/material.dart';

import '../../services/auth_api.dart';
import '../../theme/tpm_theme.dart';
import '../../widgets/common.dart';

/// Resets a password from the email address alone — see the note on
/// `AuthApi.forgotPassword` for why that's a dev-only shortcut, not something
/// to ship as-is. Good enough to unblock testing without hand-editing the
/// database every time someone forgets a test password.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  bool _obscure = true;
  bool _loading = false;
  bool _done = false;
  String? _error;
  Map<String, String> _fieldErrors = const {};

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
              Text('Reset password', style: TpmText.display(27)),
              const SizedBox(height: 4),
              Text(
                _done
                    ? 'Your password has been changed.'
                    : 'Enter your account email and a new password.',
                style: TpmText.body(13.8),
              ),
              const SizedBox(height: 22),
              if (_done) ...[
                TpmButton(
                  label: 'Back to sign in',
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ] else ...[
                TpmField(
                  label: 'Email',
                  hint: 'you@email.com',
                  icon: Icons.email_outlined,
                  controller: _emailController,
                  error: _fieldErrors.containsKey('email'),
                ),
                const SizedBox(height: 14),
                TpmField(
                  label: 'New password',
                  hint: 'At least 6 characters',
                  icon: Icons.lock_outline_rounded,
                  obscure: _obscure,
                  controller: _passwordController,
                  error: _fieldErrors.containsKey('newPassword'),
                  trailing: GestureDetector(
                    onTap: () => setState(() => _obscure = !_obscure),
                    child: Icon(
                      _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      size: 18,
                      color: TpmColors.faint,
                    ),
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 14),
                  Text(
                    _error!,
                    style: TpmText.body(12.5, color: TpmColors.danger, weight: FontWeight.w600),
                  ),
                ],
                const SizedBox(height: 22),
                TpmButton(
                  label: _loading ? 'Resetting…' : 'Reset password',
                  onPressed: _loading ? null : _submit,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _error = 'Enter your email and a new password.';
        _fieldErrors = {
          if (email.isEmpty) 'email': 'Required',
          if (password.isEmpty) 'newPassword': 'Required',
        };
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _fieldErrors = const {};
    });

    try {
      await const AuthApi().forgotPassword(email: email, newPassword: password);
      if (!mounted) return;
      setState(() {
        _loading = false;
        _done = true;
      });
    } on ApiException catch (e) {
      setState(() {
        _loading = false;
        _error = e.message;
        _fieldErrors = e.fieldErrors;
      });
    }
  }
}
