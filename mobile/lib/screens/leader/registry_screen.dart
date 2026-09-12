import 'package:flutter/material.dart';

import '../../app/navigation.dart';
import '../../app/session.dart';
import '../../data/mock_data.dart';
import '../../models/models.dart';
import '../../services/auth_api.dart';
import '../../services/members_api.dart';
import '../../theme/tpm_theme.dart';
import '../../widgets/common.dart';
import 'member_detail_screen.dart';
import 'register_member_screen.dart';

/// The branch's people. Search first, because a leader looking someone up
/// already knows the name — they just need the record.
class RegistryScreen extends StatefulWidget {
  const RegistryScreen({super.key, this.embedded = false, this.fetchMembers});

  final bool embedded;

  /// Overrides the real `MembersApi` call — tests use this to exercise the
  /// screen's search/loading/error states without a live server.
  final Future<List<Member>> Function(String token)? fetchMembers;

  @override
  State<RegistryScreen> createState() => _RegistryScreenState();
}

class _RegistryScreenState extends State<RegistryScreen> {
  final _search = TextEditingController();
  String _query = '';

  bool _loaded = false;
  bool _loading = true;
  String? _error;
  List<Member> _members = const [];

  @override
  void initState() {
    super.initState();
    _search.addListener(
      () => setState(() => _query = _search.text.trim().toLowerCase()),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      _load();
    }
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final token = AppSession.of(context).token;
    if (token == null) {
      // Role-preview browsing with no real account behind it.
      setState(() => _loading = false);
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final fetch = widget.fetchMembers ?? (t) => MembersApi(token: t).fetch();
      final members = await fetch(token);
      if (!mounted) return;
      setState(() {
        _members = members;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    }
  }

  /// Refreshes the list on return from Register Member, so a newly added
  /// person shows up without a manual pull-to-refresh.
  Future<void> _openRegister() async {
    await pushScreen(context, const RegisterMemberScreen());
    _load();
  }

  List<Member> get _visible {
    if (_query.isEmpty) return _members;
    return _members
        .where(
          (m) =>
              m.fullName.toLowerCase().contains(_query) ||
              m.department.toLowerCase().contains(_query),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final results = _visible;
    final branch = AppSession.of(context).user?.branch;

    final body = ListView(
      padding: const EdgeInsets.only(top: 28, bottom: 110),
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
                    Eyebrow(
                      (branch == null || branch.isEmpty)
                          ? '${_members.length} members'
                          : '$branch · ${_members.length} members',
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
              _AddButton(onTap: _openRegister),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _SearchField(controller: _search),
        ),
        const SizedBox(height: 14),
        if (_loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: CircularProgressIndicator(color: TpmColors.portalGold),
            ),
          )
        else if (_error != null)
          _LoadError(message: _error!, onRetry: _load)
        else if (results.isEmpty)
          const _NoResults()
        else
          for (var i = 0; i < results.length; i++)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 9),
              child: _MemberRow(member: results[i], index: i, onChanged: _load),
            ),
      ],
    );

    if (widget.embedded) return body;
    return Scaffold(
      backgroundColor: TpmColors.night,
      body: SafeArea(child: body),
    );
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
          child: const Icon(
            Icons.person_add_rounded,
            color: TpmColors.night,
            size: 19,
          ),
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
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MemberRow extends StatelessWidget {
  const _MemberRow({
    required this.member,
    required this.index,
    required this.onChanged,
  });

  final Member member;
  final int index;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final status = member.membershipStatus.isEmpty
        ? 'Regular Member'
        : member.membershipStatus;
    final (fg, bg) = MockData.statusColor(status);

    return PortalCard(
      radius: 14,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      onTap: () async {
        await pushScreen(context, MemberDetailScreen(member: member));
        onChanged();
      },
      child: Row(
        children: [
          InitialsAvatar(
            initials: member.initials,
            color: MockData.avatarFor(index),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.fullName,
                  style: TpmText.body(
                    14.5,
                    color: TpmColors.portalInk,
                    weight: FontWeight.w600,
                  ),
                ),
                Text(
                  member.department.isEmpty ? '—' : member.department,
                  style: TpmText.body(
                    11.5,
                    color: Colors.white.withValues(alpha: 0.45),
                  ),
                ),
              ],
            ),
          ),
          Pill(
            status,
            foreground: fg,
            background: bg,
            uppercase: false,
            fontSize: 9.5,
          ),
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

class _LoadError extends StatelessWidget {
  const _LoadError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: PortalCard(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
        child: Column(
          children: [
            IconTile(
              icon: Icons.wifi_off_rounded,
              background: TpmColors.portalGold.withValues(alpha: 0.1),
              foreground: TpmColors.portalGold,
              size: 54,
              radius: 16,
              iconSize: 24,
            ),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TpmText.body(
                13,
                color: TpmColors.portalInk,
                weight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 14),
            TpmOutlineButton(
              label: 'Retry',
              icon: Icons.refresh_rounded,
              foreground: TpmColors.portalInk,
              background: Colors.white.withValues(alpha: 0.06),
              borderColor: Colors.white.withValues(alpha: 0.15),
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
