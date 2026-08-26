import 'package:flutter/material.dart';

import '../../app/session.dart';
import '../../models/models.dart';
import '../../services/auth_api.dart';
import '../../theme/tpm_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/shells.dart';
import 'biometric_screen.dart';
import 'forgot_password_screen.dart';
import 'welcome_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool _obscure = true;
  bool _loading = false;
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
          padding: const EdgeInsets.fromLTRB(26, 24, 26, 34),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Image.asset(
                  'assets/brand/logo-mark.png',
                  height: 64,
                  fit: BoxFit.contain,
                  semanticLabel: 'Transformation Project Ministries',
                ),
              ),
              const SizedBox(height: 22),
              Text('Welcome back', style: TpmText.display(28)),
              const SizedBox(height: 4),
              Text('Sign in to continue your journey.', style: TpmText.body(13.8)),
              const SizedBox(height: 24),
              TpmField(
                label: 'Email',
                hint: 'you@email.com',
                icon: Icons.email_outlined,
                controller: _emailController,
                error: _fieldErrors.containsKey('email'),
              ),
              const SizedBox(height: 16),
              TpmField(
                label: 'Password',
                hint: '••••••••',
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
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                  ),
                  child: Text(
                    'Forgot password?',
                    style: TpmText.body(12.5, color: TpmColors.navy, weight: FontWeight.w600),
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
                label: _loading ? 'Signing in…' : 'Sign in',
                onPressed: _loading ? null : () => _signIn(context),
              ),
              const SizedBox(height: 12),
              TpmOutlineButton(
                label: 'Use Face / Touch ID',
                icon: Icons.fingerprint_rounded,
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const BiometricScreen()),
                ),
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
                  Flexible(
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                      ),
                      child: Text(
                        'Create an account',
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

  Future<void> _signIn(BuildContext context) async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _error = 'Enter your email and password.';
        _fieldErrors = {
          if (email.isEmpty) 'email': 'Required',
          if (password.isEmpty) 'password': 'Required',
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
      final result = await const AuthApi().login(email: email, password: password);
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
