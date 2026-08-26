import 'package:flutter/material.dart';

import '../../app/session.dart';
import '../../data/mock_data.dart';
import '../../models/models.dart';
import '../../theme/tpm_theme.dart';
import '../../widgets/common.dart';

/// Your details, as the church holds them.
///
/// Members cannot edit these directly — they raise a request that the pastor's
/// office approves, which is why the action reads "Request to update" rather
/// than "Edit". That request is what surfaces on the admin approvals screen.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final List<bool> _notifications =
      MockData.notificationSettings.map((n) => n.enabled).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TpmColors.canvas,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(top: 12, bottom: 24),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Row(
                children: [
                  CircleBackButton(onTap: () => Navigator.of(context).pop()),
                  const SizedBox(width: 12),
                  Text('Profile', style: TpmText.display(24)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const _IdentityCard(),
            const SizedBox(height: 14),
            _DetailsCard(onRequest: _showRequestSheet),
            const SizedBox(height: 14),
            _NotificationsCard(
              values: _notifications,
              onChanged: (i, v) => setState(() => _notifications[i] = v),
            ),
            const SizedBox(height: 14),
            const _SavedCard(),
          ],
        ),
      ),
    );
  }

  void _showRequestSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: TpmColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 22,
          right: 22,
          top: 22,
          bottom: MediaQuery.of(context).viewInsets.bottom + 26,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Request a change', style: TpmText.display(20)),
            const SizedBox(height: 6),
            Text(
              'The pastor’s office reviews every change before it takes effect.',
              style: TpmText.body(13, height: 1.5),
            ),
            const SizedBox(height: 18),
            const TpmField(
              label: 'Which detail?',
              hint: 'e.g. Phone',
              icon: Icons.edit_outlined,
            ),
            const SizedBox(height: 14),
            const TpmField(
              label: 'New value',
              hint: 'e.g. +233 20 222 2222',
              icon: Icons.arrow_forward_rounded,
            ),
            const SizedBox(height: 20),
            TpmButton(
              label: 'Send request',
              icon: Icons.send_rounded,
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Request sent for approval'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _IdentityCard extends StatelessWidget {
  const _IdentityCard();

  @override
  Widget build(BuildContext context) {
    final user = AppSession.of(context).user;

    // A real sign-in carries the name and branch; the guest/preview paths
    // (no real account) fall back to the design board's sample member.
    final fullName = user?.fullName.trim().isNotEmpty == true
        ? user!.fullName
        : MockData.fullName;
    final branch = user?.branch?.trim().isNotEmpty == true
        ? user!.branch!
        : MockData.homeBranch;
    final roleLabel = user?.role.label ?? AppSession.of(context).role.label;
    final initials = _initialsOf(fullName);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: TpmCard(
        radius: 20,
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                gradient: TpmColors.blueGradient,
                shape: BoxShape.circle,
              ),
              child: Text(
                initials,
                style: TpmText.body(19, color: Colors.white, weight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(fullName, style: TpmText.display(19)),
                  Text('$roleLabel · $branch', style: TpmText.body(12.2)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _initialsOf(String fullName) {
    final parts = fullName.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    final letters = parts.take(2).map((p) => p[0].toUpperCase()).join();
    return letters.isEmpty ? MockData.initials : letters;
  }
}

class _DetailsCard extends StatelessWidget {
  const _DetailsCard({required this.onRequest});

  final VoidCallback onRequest;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: TpmColors.surface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: TpmShadows.card,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 6),
              child: Eyebrow('Personal details', size: 10),
            ),
            for (final field in MockData.profileFields)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: TpmColors.divider)),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 88,
                      child: Text(field.label, style: TpmText.body(12.8)),
                    ),
                    Expanded(
                      child: Text(
                        field.value,
                        style: TpmText.body(
                          13.5,
                          color: TpmColors.ink,
                          weight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Material(
              color: TpmColors.slateWash,
              child: InkWell(
                onTap: onRequest,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: TpmColors.divider)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.edit_outlined, size: 15, color: TpmColors.navy),
                      const SizedBox(width: 7),
                      Flexible(
                        child: Text(
                          'Request to update details',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TpmText.body(
                            13,
                            color: TpmColors.navy,
                            weight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationsCard extends StatelessWidget {
  const _NotificationsCard({required this.values, required this.onChanged});

  final List<bool> values;
  final void Function(int index, bool value) onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: TpmColors.surface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: TpmShadows.card,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 6),
              child: Eyebrow('Notifications', size: 10),
            ),
            for (var i = 0; i < MockData.notificationSettings.length; i++)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: TpmColors.divider)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        MockData.notificationSettings[i].label,
                        style: TpmText.body(13.5, color: TpmColors.ink),
                      ),
                    ),
                    Switch.adaptive(
                      value: values[i],
                      activeThumbColor: Colors.white,
                      activeTrackColor: TpmColors.navy,
                      onChanged: (v) => onChanged(i, v),
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

class _SavedCard extends StatelessWidget {
  const _SavedCard();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: TpmCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        onTap: () {},
        child: Row(
          children: [
            const Icon(Icons.download_rounded, size: 19, color: TpmColors.navy),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Saved & offline content',
                style: TpmText.body(13.5, color: TpmColors.ink),
              ),
            ),
            Text('4 items', style: TpmText.body(12.5)),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFFCBD5E1)),
          ],
        ),
      ),
    );
  }
}
