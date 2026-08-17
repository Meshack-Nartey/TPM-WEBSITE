import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../models/models.dart';
import '../../theme/tpm_theme.dart';
import '../../widgets/charts.dart';
import '../../widgets/common.dart';

/// One person's record. Attendance over the last six weeks sits right under
/// their contact details, because the reason a leader opens this screen is
/// usually to work out whether to call them.
class MemberDetailScreen extends StatelessWidget {
  const MemberDetailScreen({super.key, required this.member});

  final MemberRecord member;

  @override
  Widget build(BuildContext context) {
    final (statusFg, statusBg) = MockData.statusColor(member.status);

    return Scaffold(
      backgroundColor: TpmColors.night,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          _Header(member: member, statusFg: statusFg, statusBg: statusBg),
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
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Eyebrow(
              'Attendance · last 6 weeks',
              color: TpmColors.portalGold,
              size: 10,
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: PortalCard(
              child: AttendanceStrip(weeks: member.attendance),
            ),
          ),
          const SizedBox(height: 16),
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
    required this.statusFg,
    required this.statusBg,
  });

  final MemberRecord member;
  final Color statusFg;
  final Color statusBg;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;

    return Container(
      padding: EdgeInsets.fromLTRB(20, topInset + 12, 20, 22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomRight,
          colors: [TpmColors.nightRaised, Color(0xFF0B0B0B)],
        ),
        border: Border(
          bottom: BorderSide(color: TpmColors.portalGold.withValues(alpha: 0.12)),
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
                color: member.avatarColor,
                size: 64,
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.name,
                      style: TpmText.display(22, color: TpmColors.portalInk),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${member.group} · ${member.branch}',
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
                member.status,
                foreground: statusFg,
                background: statusBg,
                uppercase: false,
                fontSize: 10,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              ),
              const SizedBox(width: 8),
              Pill(
                'Since ${member.since}',
                foreground: TpmColors.portalGold,
                background: TpmColors.portalGold.withValues(alpha: 0.12),
                uppercase: false,
                fontSize: 10,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({required this.member});

  final MemberRecord member;

  @override
  Widget build(BuildContext context) {
    final rows = <(IconData, String, String)>[
      (Icons.phone_rounded, 'Phone', member.phone),
      (Icons.email_rounded, 'Email', member.email),
      (Icons.calendar_month_rounded, 'Joined', member.joined),
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
                        top: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
                      ),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 18,
                    child: Icon(rows[i].$1, size: 15, color: TpmColors.portalGold),
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
