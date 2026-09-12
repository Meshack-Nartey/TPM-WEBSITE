import 'package:flutter/material.dart';

import '../../app/session.dart';
import '../../data/mock_data.dart';
import '../../services/auth_api.dart';
import '../../services/lookups_api.dart';
import '../../services/members_api.dart';
import '../../theme/tpm_theme.dart';
import '../../widgets/common.dart';

/// Entering someone into the branch registry. Status is a deliberate choice
/// rather than a default, because "Visitor" and "Member" mean different
/// follow-up for the person who has just walked in.
class RegisterMemberScreen extends StatefulWidget {
  const RegisterMemberScreen({super.key});

  @override
  State<RegisterMemberScreen> createState() => _RegisterMemberScreenState();
}

class _RegisterMemberScreenState extends State<RegisterMemberScreen> {
  int _status = 0;
  bool _saving = false;
  String? _error;

  /// Starts as the seed-matching fallback so the picker is never empty;
  /// replaced once the real list loads.
  List<String> _memberStatuses = MockData.memberStatuses;

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _groupController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadStatuses();
  }

  Future<void> _loadStatuses() async {
    try {
      final grouped = await const PublicLookups().fetch();
      final statuses = grouped['membershipStatuses'];
      if (!mounted || statuses == null || statuses.isEmpty) return;
      setState(() {
        _memberStatuses = statuses;
        if (_status >= statuses.length) _status = 0;
      });
    } on ApiException {
      // Keep the fallback list.
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _groupController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final fullName = _nameController.text.trim();
    if (fullName.isEmpty) {
      setState(() => _error = 'Enter their name.');
      return;
    }

    final session = AppSession.of(context);
    final token = session.token;
    if (token == null) {
      setState(() => _error = 'Sign in as a leader to register a member.');
      return;
    }

    final parts = fullName.split(RegExp(r'\s+'));
    final firstName = parts.first;
    final lastName = parts.length > 1
        ? parts.sublist(1).join(' ')
        : parts.first;

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      await MembersApi(token: token).create(
        firstName: firstName,
        lastName: lastName,
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        department: _groupController.text.trim(),
        branch: session.user?.branch ?? '',
        membershipStatus: _memberStatuses[_status],
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Saved as ${_memberStatuses[_status]}'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = e.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final branch = AppSession.of(context).user?.branch;

    return Scaffold(
      backgroundColor: TpmColors.night,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 34),
          children: [
            Row(
              children: [
                CircleBackButton(
                  dark: true,
                  size: 36,
                  onTap: () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Eyebrow(
                        (branch == null || branch.isEmpty)
                            ? 'New member'
                            : branch,
                        color: TpmColors.portalGold,
                        size: 10,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Register Member',
                        style: TpmText.display(22, color: TpmColors.portalInk),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TpmField(
              label: 'Full name',
              hint: 'e.g. Kwame Asante',
              icon: Icons.person_rounded,
              dark: true,
              controller: _nameController,
            ),
            const SizedBox(height: 14),
            TpmField(
              label: 'Phone',
              hint: '+233 …',
              icon: Icons.phone_rounded,
              dark: true,
              controller: _phoneController,
            ),
            const SizedBox(height: 14),
            TpmField(
              label: 'Email (optional)',
              hint: 'name@email.com',
              icon: Icons.email_rounded,
              dark: true,
              controller: _emailController,
            ),
            const SizedBox(height: 14),
            TpmField(
              label: 'Worker group',
              hint: 'e.g. Ushering, Music',
              icon: Icons.diversity_3_rounded,
              dark: true,
              controller: _groupController,
            ),
            const SizedBox(height: 14),
            Text(
              'STATUS',
              style: TpmText.eyebrow(
                color: Colors.white.withValues(alpha: 0.5),
                size: 10,
                tracking: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                for (var i = 0; i < _memberStatuses.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  ChoiceChipPill(
                    label: _memberStatuses[i],
                    selected: i == _status,
                    dark: true,
                    expand: true,
                    onTap: () => setState(() => _status = i),
                  ),
                ],
              ],
            ),
            if (_error != null) ...[
              const SizedBox(height: 14),
              Text(
                _error!,
                style: TpmText.body(
                  12.5,
                  color: TpmColors.danger,
                  weight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: 24),
            TpmButton.gold(
              label: _saving ? 'Saving…' : 'Save member',
              icon: Icons.person_add_rounded,
              onPressed: _saving ? null : _save,
            ),
          ],
        ),
      ),
    );
  }
}
