import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../models/models.dart';
import '../../theme/tpm_theme.dart';
import '../../widgets/common.dart';

/// One person's record — contact details and status, the two things a
/// leader usually opens this screen to check or act on.
class MemberDetailScreen extends StatelessWidget {
  const MemberDetailScreen({super.key, required this.member});

  final Member member;

  @override
  Widget build(BuildContext context) {
    final status = member.membershipStatus.isEmpty
        ? 'Regular Member'
        : member.membershipStatus;
    final (statusFg, statusBg) = MockData.statusColor(status);

    return Scaffold(
      backgroundColor: TpmColors.night,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          _Header(
            member: member,
            status: status,
            statusFg: statusFg,
            statusBg: statusBg,
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Eyebrow('Contact', color: TpmColors.portalGold, size: 10),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _ContactCard(member: member),
          ),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
            child: Row(
              children: [
                Expanded(
                  child: TpmButton.gold(
                    label: 'Edit',
                    icon: Icons.edit_rounded,
                    height: 48,
                    fontSize: 13,
                    onPressed: () {},
                  ),
                ),
                const SizedBox(width: 10),
                _SquareAction(icon: Icons.phone_rounded, onTap: () {}),
                const SizedBox(width: 10),
                _SquareAction(icon: Icons.chat_rounded, onTap: () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.member,
    required this.status,
    required this.statusFg,
    required this.statusBg,
  });

  final Member member;
  final String status;
  final Color statusFg;
  final Color statusBg;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    final group = member.department.isNotEmpty
        ? member.department
        : (member.fellowship.isNotEmpty ? member.fellowship : 'Member');

    return Container(
      padding: EdgeInsets.fromLTRB(20, topInset + 18, 20, 22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomRight,
          colors: [TpmColors.nightRaised, Color(0xFF0B0B0B)],
        ),
        border: Border(
          bottom: BorderSide(
            color: TpmColors.portalGold.withValues(alpha: 0.12),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleBackButton(
            dark: true,
            size: 36,
            onTap: () => Navigator.of(context).pop(),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              InitialsAvatar(
                initials: member.initials,
                color: TpmColors.portalGold,
                size: 64,
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.fullName,
                      style: TpmText.display(22, color: TpmColors.portalInk),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      member.branch.isEmpty
                          ? group
                          : '$group · ${member.branch}',
                      style: TpmText.body(
                        12.2,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Pill(
                status,
                foreground: statusFg,
                background: statusBg,
                uppercase: false,
                fontSize: 10,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
              ),
              if (member.dateJoined.isNotEmpty) ...[
                const SizedBox(width: 8),
                Pill(
                  'Since ${member.dateJoined}',
                  foreground: TpmColors.portalGold,
                  background: TpmColors.portalGold.withValues(alpha: 0.12),
                  uppercase: false,
                  fontSize: 10,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({required this.member});

  final Member member;

  @override
  Widget build(BuildContext context) {
    String orNotSet(String value) => value.isEmpty ? 'Not set' : value;

    final rows = <(IconData, String, String)>[
      (Icons.phone_rounded, 'Phone', orNotSet(member.phone)),
      (Icons.email_rounded, 'Email', orNotSet(member.email)),
      (Icons.calendar_month_rounded, 'Joined', orNotSet(member.dateJoined)),
    ];

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: TpmColors.nightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
              decoration: BoxDecoration(
                border: i == 0
                    ? null
                    : Border(
                        top: BorderSide(
                          color: Colors.white.withValues(alpha: 0.06),
                        ),
                      ),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 18,
                    child: Icon(
                      rows[i].$1,
                      size: 15,
                      color: TpmColors.portalGold,
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Text(
                      rows[i].$2,
                      style: TpmText.body(
                        11.5,
                        color: Colors.white.withValues(alpha: 0.45),
                      ),
                    ),
                  ),
                  Text(
                    rows[i].$3,
                    style: TpmText.body(
                      13.5,
                      color: TpmColors.portalInk,
                      weight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _SquareAction extends StatelessWidget {
  const _SquareAction({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: TpmColors.nightSurface,
      borderRadius: BorderRadius.circular(13),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: 52,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: Icon(icon, size: 18, color: TpmColors.portalInk),
        ),
      ),
    );
  }
}
