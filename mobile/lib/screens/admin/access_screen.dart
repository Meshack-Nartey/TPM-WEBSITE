import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../models/models.dart';
import '../../theme/tpm_theme.dart';
import '../../widgets/common.dart';

/// Who can do what, church-wide. Roles are granted here and nowhere else.
class AccessScreen extends StatefulWidget {
  const AccessScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<AccessScreen> createState() => _AccessScreenState();
}

class _AccessScreenState extends State<AccessScreen> {
  int _tab = 0;

  List<AccessUser> get _visible {
    return switch (_tab) {
      0 => MockData.accessList
          .where((u) => u.role == 'Member' || u.role == 'Worker')
          .toList(),
      1 => MockData.accessList.where((u) => u.role == 'Leader').toList(),
      _ => MockData.accessList.where((u) => u.role == 'Admin').toList(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final users = _visible;

    final body = ListView(
      padding: const EdgeInsets.only(top: 20, bottom: 24),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Eyebrow('Church-wide', color: TpmColors.portalGold, size: 10),
              const SizedBox(height: 3),
              Text(
                'Access Management',
                style: TpmText.display(24, color: TpmColors.portalInk),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              for (var i = 0; i < MockData.accessTabs.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                ChoiceChipPill(
                  label: MockData.accessTabs[i],
                  selected: i == _tab,
                  dark: true,
                  expand: true,
                  onTap: () => setState(() => _tab = i),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
        if (users.isEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: PortalCard(
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              child: Center(
                child: Text(
                  'No one holds this role yet.',
                  style: TpmText.body(
                    13,
                    color: Colors.white.withValues(alpha: 0.45),
                  ),
                ),
              ),
            ),
          )
        else
          for (final user in users)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 9),
              child: _AccessRow(user: user),
            ),
      ],
    );

    if (widget.embedded) return body;
    return Scaffold(backgroundColor: TpmColors.night, body: SafeArea(child: body));
  }
}

class _AccessRow extends StatelessWidget {
  const _AccessRow({required this.user});

  final AccessUser user;

  @override
  Widget build(BuildContext context) {
    return PortalCard(
      radius: 14,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      child: Row(
        children: [
          InitialsAvatar(initials: user.initials, color: user.avatarColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: TpmText.body(
                    14.5,
                    color: TpmColors.portalInk,
                    weight: FontWeight.w600,
                  ),
                ),
                Text(
                  user.branch,
                  style: TpmText.body(
                    11.5,
                    color: Colors.white.withValues(alpha: 0.45),
                  ),
                ),
              ],
            ),
          ),
          Pill(
            user.role,
            foreground: TpmColors.portalGold,
            background: TpmColors.portalGold.withValues(alpha: 0.12),
            uppercase: false,
            fontSize: 9.5,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.more_vert_rounded,
            size: 18,
            color: Colors.white.withValues(alpha: 0.35),
          ),
        ],
      ),
    );
  }
}
