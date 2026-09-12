import 'package:flutter/material.dart';

import '../../app/session.dart';
import '../../data/mock_data.dart';
import '../../models/models.dart';
import '../../services/admin_users_api.dart';
import '../../services/auth_api.dart';
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
  bool _loaded = false;
  bool _loading = true;
  String? _error;
  List<AppUser> _users = const [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      _load();
    }
  }

  Future<void> _load() async {
    final token = AppSession.of(context).token;
    if (token == null) {
      setState(() => _loading = false);
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final users = await AdminUsersApi(token: token).fetch();
      if (!mounted) return;
      setState(() {
        _users = users;
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

  List<AppUser> get _visible {
    final wanted = switch (_tab) {
      1 => AppRole.leader,
      2 => AppRole.admin,
      _ => AppRole.member,
    };
    return _users.where((u) => u.role == wanted).toList();
  }

  Future<void> _manage(AppUser user) async {
    final token = AppSession.of(context).token;
    if (token == null) return;

    final result = await showModalBottomSheet<_AccessAction>(
      context: context,
      backgroundColor: TpmColors.nightRaised,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) => _ManageSheet(user: user),
    );
    if (result == null || !mounted) return;

    try {
      switch (result) {
        case _AccessAction(role: final role?):
          await AdminUsersApi(token: token).setRole(user.id, role);
        case _AccessAction(toggleActive: true):
          await AdminUsersApi(token: token).setActive(user.id, !user.active);
        case _AccessAction(delete: true):
          final confirmed = await _confirmDelete(user);
          if (confirmed != true) return;
          await AdminUsersApi(token: token).delete(user.id);
      }
      if (!mounted) return;
      _load();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Future<bool?> _confirmDelete(AppUser user) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: TpmColors.nightRaised,
        title: Text(
          'Delete this account?',
          style: TpmText.body(
            15,
            color: TpmColors.portalInk,
            weight: FontWeight.w700,
          ),
        ),
        content: Text(
          '${user.fullName}\'s account will be permanently removed. This '
          "can't be undone.",
          style: TpmText.body(13, color: Colors.white.withValues(alpha: 0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: TpmText.body(
                13.5,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Delete',
              style: TpmText.body(
                13.5,
                color: TpmColors.danger,
                weight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final users = _visible;

    final body = RefreshIndicator(
      color: TpmColors.portalGold,
      backgroundColor: TpmColors.nightRaised,
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 20, bottom: 110),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Eyebrow(
                  'Church-wide',
                  color: TpmColors.portalGold,
                  size: 10,
                ),
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
          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: CircularProgressIndicator(color: TpmColors.portalGold),
              ),
            )
          else if (_error != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: PortalCard(
                padding: const EdgeInsets.symmetric(
                  vertical: 30,
                  horizontal: 20,
                ),
                child: Column(
                  children: [
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: TpmText.body(13, color: TpmColors.portalInk),
                    ),
                    const SizedBox(height: 14),
                    TpmOutlineButton(
                      label: 'Retry',
                      icon: Icons.refresh_rounded,
                      foreground: TpmColors.portalInk,
                      background: Colors.white.withValues(alpha: 0.06),
                      borderColor: Colors.white.withValues(alpha: 0.15),
                      onPressed: _load,
                    ),
                  ],
                ),
              ),
            )
          else if (users.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: PortalCard(
                padding: const EdgeInsets.symmetric(
                  vertical: 30,
                  horizontal: 20,
                ),
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
            for (var i = 0; i < users.length; i++)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 9),
                child: _AccessRow(
                  user: users[i],
                  avatarColor: MockData.avatarFor(i),
                  onTap: () => _manage(users[i]),
                ),
              ),
        ],
      ),
    );

    if (widget.embedded) return body;
    return Scaffold(
      backgroundColor: TpmColors.night,
      body: SafeArea(child: body),
    );
  }
}

class _AccessRow extends StatelessWidget {
  const _AccessRow({
    required this.user,
    required this.avatarColor,
    required this.onTap,
  });

  final AppUser user;
  final Color avatarColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PortalCard(
      radius: 14,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      onTap: onTap,
      child: Row(
        children: [
          Opacity(
            opacity: user.active ? 1 : 0.4,
            child: InitialsAvatar(initials: user.initials, color: avatarColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName,
                  style: TpmText.body(
                    14.5,
                    color: user.active
                        ? TpmColors.portalInk
                        : Colors.white.withValues(alpha: 0.5),
                    weight: FontWeight.w600,
                  ),
                ),
                Text(
                  (user.branch == null || user.branch!.isEmpty)
                      ? user.email
                      : '${user.branch} · ${user.email}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TpmText.body(
                    11.5,
                    color: Colors.white.withValues(alpha: 0.45),
                  ),
                ),
              ],
            ),
          ),
          if (!user.active) ...[
            Pill(
              'Inactive',
              foreground: TpmColors.warning,
              background: TpmColors.warning.withValues(alpha: 0.12),
              uppercase: false,
              fontSize: 9.5,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            ),
            const SizedBox(width: 6),
          ],
          Pill(
            user.role.label,
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

/// What `_manage` decided from the sheet — exactly one of these is set.
class _AccessAction {
  const _AccessAction.role(AppRole this.role)
    : toggleActive = false,
      delete = false;
  const _AccessAction.toggleActive()
    : role = null,
      toggleActive = true,
      delete = false;
  const _AccessAction.delete()
    : role = null,
      toggleActive = false,
      delete = true;

  final AppRole? role;
  final bool toggleActive;
  final bool delete;
}

class _ManageSheet extends StatelessWidget {
  const _ManageSheet({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                InitialsAvatar(
                  initials: user.initials,
                  color: TpmColors.portalGold,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.fullName,
                        style: TpmText.body(
                          15,
                          color: TpmColors.portalInk,
                          weight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        user.email,
                        style: TpmText.body(
                          12,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            Text(
              'ROLE',
              style: TpmText.eyebrow(
                color: Colors.white.withValues(alpha: 0.5),
                size: 10,
                tracking: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                for (final role in const [
                  AppRole.member,
                  AppRole.leader,
                  AppRole.admin,
                ]) ...[
                  if (role != AppRole.member) const SizedBox(width: 8),
                  Expanded(
                    child: ChoiceChipPill(
                      label: role.label,
                      selected: role == user.role,
                      dark: true,
                      expand: true,
                      onTap: role == user.role
                          ? () {}
                          : () => Navigator.of(
                              context,
                            ).pop(_AccessAction.role(role)),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 20),
            TpmOutlineButton(
              label: user.active ? 'Deactivate account' : 'Reactivate account',
              icon: user.active
                  ? Icons.block_rounded
                  : Icons.check_circle_outline_rounded,
              foreground: TpmColors.portalInk,
              background: Colors.white.withValues(alpha: 0.06),
              borderColor: Colors.white.withValues(alpha: 0.15),
              onPressed: () =>
                  Navigator.of(context).pop(const _AccessAction.toggleActive()),
            ),
            const SizedBox(height: 10),
            TpmOutlineButton(
              label: 'Delete account',
              icon: Icons.delete_outline_rounded,
              foreground: TpmColors.danger,
              background: TpmColors.danger.withValues(alpha: 0.08),
              borderColor: TpmColors.danger.withValues(alpha: 0.25),
              onPressed: () =>
                  Navigator.of(context).pop(const _AccessAction.delete()),
            ),
          ],
        ),
      ),
    );
  }
}
