import 'package:flutter/material.dart';

import '../../app/navigation.dart';
import '../../data/mock_data.dart';
import '../../models/models.dart';
import '../../theme/tpm_theme.dart';
import '../../widgets/common.dart';
import 'member_detail_screen.dart';
import 'register_member_screen.dart';

/// The branch's people. Search first, because a leader looking someone up
/// already knows the name — they just need the record.
class RegistryScreen extends StatefulWidget {
  const RegistryScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<RegistryScreen> createState() => _RegistryScreenState();
}

class _RegistryScreenState extends State<RegistryScreen> {
  final _search = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _search.addListener(() => setState(() => _query = _search.text.trim().toLowerCase()));
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<MemberRecord> get _visible {
    if (_query.isEmpty) return MockData.members;
    return MockData.members
        .where((m) =>
            m.name.toLowerCase().contains(_query) ||
            m.group.toLowerCase().contains(_query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final results = _visible;

    final body = ListView(
      padding: const EdgeInsets.only(top: 20, bottom: 24),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Eyebrow(
                      MockData.registrySubtitle,
                      color: TpmColors.portalGold,
                      size: 10,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Member Registry',
                      style: TpmText.display(24, color: TpmColors.portalInk),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _AddButton(
                onTap: () => pushScreen(context, const RegisterMemberScreen()),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _SearchField(controller: _search),
        ),
        const SizedBox(height: 14),
        if (results.isEmpty)
          const _NoResults()
        else
          for (final member in results)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 9),
              child: _MemberRow(member: member),
            ),
      ],
    );

    if (widget.embedded) return body;
    return Scaffold(backgroundColor: TpmColors.night, body: SafeArea(child: body));
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: TpmColors.portalGoldGradient,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.person_add_rounded, color: TpmColors.night, size: 19),
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: TpmColors.nightSurface,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            size: 18,
            color: Colors.white.withValues(alpha: 0.4),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              style: TpmText.body(14.5, color: TpmColors.portalInk),
              cursorColor: TpmColors.portalGold,
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: 'Search members…',
                hintStyle: TpmText.body(
                  14.5,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MemberRow extends StatelessWidget {
  const _MemberRow({required this.member});

  final MemberRecord member;

  @override
  Widget build(BuildContext context) {
    final (fg, bg) = MockData.statusColor(member.status);

    return PortalCard(
      radius: 14,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      onTap: () => pushScreen(context, MemberDetailScreen(member: member)),
      child: Row(
        children: [
          InitialsAvatar(initials: member.initials, color: member.avatarColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name,
                  style: TpmText.body(
                    14.5,
                    color: TpmColors.portalInk,
                    weight: FontWeight.w600,
                  ),
                ),
                Text(
                  member.group,
                  style: TpmText.body(11.5, color: Colors.white.withValues(alpha: 0.45)),
                ),
              ],
            ),
          ),
          Pill(member.status, foreground: fg, background: bg, uppercase: false, fontSize: 9.5),
          const SizedBox(width: 6),
          Icon(
            Icons.chevron_right_rounded,
            color: Colors.white.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }
}

class _NoResults extends StatelessWidget {
  const _NoResults();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: PortalCard(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
        child: Column(
          children: [
            IconTile(
              icon: Icons.person_search_rounded,
              background: TpmColors.portalGold.withValues(alpha: 0.1),
              foreground: TpmColors.portalGold,
              size: 54,
              radius: 16,
              iconSize: 24,
            ),
            const SizedBox(height: 14),
            Text(
              'No one matches that search',
              style: TpmText.body(
                14.5,
                color: TpmColors.portalInk,
                weight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Try a different name, or register them as a new member.',
              textAlign: TextAlign.center,
              style: TpmText.body(
                12.5,
                color: Colors.white.withValues(alpha: 0.45),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
