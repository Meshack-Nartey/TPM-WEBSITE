import 'dart:ui';

import 'package:flutter/material.dart';

import '../app/navigation.dart';
import '../models/models.dart';
import '../screens/admin/access_screen.dart';
import '../screens/admin/admin_overview_screen.dart';
import '../screens/admin/approvals_screen.dart';
import '../screens/admin/manage_lists_screen.dart';
import '../screens/leader/leader_dashboard_screen.dart';
import '../screens/leader/register_member_screen.dart';
import '../screens/leader/registry_screen.dart';
import '../screens/leader/weekly_report_screen.dart';
import '../screens/member/events_screen.dart';
import '../screens/member/give_screen.dart';
import '../screens/member/home_screen.dart';
import '../screens/member/media_screen.dart';
import '../screens/member/more_screen.dart';
import '../screens/system/data_states_screen.dart';
import '../theme/tpm_theme.dart';
import 'common.dart';

/// The light member surface and its five primary destinations.
class MemberShell extends StatefulWidget {
  const MemberShell({super.key});

  /// Replaces the whole stack — you don't go "back" from the app into sign-in.
  static void enter(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MemberShell()),
      (route) => false,
    );
  }

  @override
  State<MemberShell> createState() => _MemberShellState();
}

class _MemberShellState extends State<MemberShell> {
  MemberTab _tab = MemberTab.home;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TpmColors.canvas,
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: _tab.index,
          children: [
            HomeScreen(onSelectTab: (t) => setState(() => _tab = t)),
            const MediaScreen(),
            const EventsScreen(),
            const GiveScreen(),
            const MoreScreen(),
          ],
        ),
      ),
      bottomNavigationBar: _MemberTabBar(
        current: _tab,
        onSelect: (t) => setState(() => _tab = t),
      ),
    );
  }
}

class _MemberTabBar extends StatelessWidget {
  const _MemberTabBar({required this.current, required this.onSelect});

  final MemberTab current;
  final ValueChanged<MemberTab> onSelect;

  static const _items = <(MemberTab, String, IconData)>[
    (MemberTab.home, 'Home', Icons.home_rounded),
    (MemberTab.media, 'Watch', Icons.play_circle_fill_rounded),
    (MemberTab.events, 'Events', Icons.event_rounded),
    (MemberTab.give, 'Give', Icons.volunteer_activism_rounded),
    (MemberTab.more, 'More', Icons.more_horiz_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.85),
            border: Border(
              top: BorderSide(color: TpmColors.navy.withValues(alpha: 0.08)),
            ),
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 62,
              child: Row(
                children: [
                  for (final (tab, label, icon) in _items)
                    Expanded(
                      child: _TabButton(
                        label: label,
                        icon: icon,
                        selected: tab == current,
                        activeColor: TpmColors.navy,
                        inactiveColor: TpmColors.faint,
                        onTap: () => onSelect(tab),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The gold-on-black work portal. Leaders and admins get different destinations
/// behind the same chrome.
class PortalShell extends StatefulWidget {
  const PortalShell({super.key, required this.role});

  final AppRole role;

  static void enter(BuildContext context, AppRole role) {
    pushScreen(context, PortalShell(role: role));
  }

  @override
  State<PortalShell> createState() => _PortalShellState();
}

class _PortalShellState extends State<PortalShell> {
  int _index = 0;

  bool get _isAdmin => widget.role == AppRole.admin;

  List<(String, IconData)> get _tabs => _isAdmin
      ? const [
          ('Overview', Icons.speed_rounded),
          ('Approvals', Icons.done_all_rounded),
          ('Access', Icons.admin_panel_settings_rounded),
          ('More', Icons.more_horiz_rounded),
        ]
      : const [
          ('Dashboard', Icons.speed_rounded),
          ('Report', Icons.edit_document),
          ('Members', Icons.groups_rounded),
          ('More', Icons.more_horiz_rounded),
        ];

  List<Widget> get _screens => _isAdmin
      ? [
          const AdminOverviewScreen(),
          const ApprovalsScreen(embedded: true),
          const AccessScreen(embedded: true),
          _PortalMoreScreen(role: widget.role),
        ]
      : [
          LeaderDashboardScreen(onOpenReport: () => setState(() => _index = 1)),
          const WeeklyReportScreen(embedded: true),
          const RegistryScreen(embedded: true),
          _PortalMoreScreen(role: widget.role),
        ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TpmColors.night,
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: IndexedStack(index: _index, children: _screens),
      ),
      bottomNavigationBar: _PortalTabBar(
        tabs: _tabs,
        current: _index,
        onSelect: (i) => setState(() => _index = i),
      ),
    );
  }
}

class _PortalTabBar extends StatelessWidget {
  const _PortalTabBar({
    required this.tabs,
    required this.current,
    required this.onSelect,
  });

  final List<(String, IconData)> tabs;
  final int current;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          decoration: BoxDecoration(
            color: TpmColors.nightSurface.withValues(alpha: 0.9),
            border: Border(
              top: BorderSide(color: TpmColors.portalGold.withValues(alpha: 0.14)),
            ),
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 62,
              child: Row(
                children: [
                  for (var i = 0; i < tabs.length; i++)
                    Expanded(
                      child: _TabButton(
                        label: tabs[i].$1,
                        icon: tabs[i].$2,
                        selected: i == current,
                        activeColor: TpmColors.portalGold,
                        inactiveColor: Colors.white.withValues(alpha: 0.4),
                        onTap: () => onSelect(i),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.activeColor,
    required this.inactiveColor,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final Color activeColor;
  final Color inactiveColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? activeColor : inactiveColor;
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 22, color: color),
          const SizedBox(height: 4),
          Text(label, style: TpmText.body(9.8, color: color, weight: FontWeight.w600)),
        ],
      ),
    );
  }
}

/// The portal's fourth tab. Holds the role's remaining destinations plus the
/// way back out — without this, crossing into the portal would be one-way.
class _PortalMoreScreen extends StatelessWidget {
  const _PortalMoreScreen({required this.role});

  final AppRole role;

  @override
  Widget build(BuildContext context) {
    final isAdmin = role == AppRole.admin;

    final entries = <(String, String, IconData, VoidCallback)>[
      if (isAdmin)
        (
          'Manage lists & publishing',
          'Directories, branches, worker groups',
          Icons.tune_rounded,
          () => pushScreen(context, const ManageListsScreen()),
        )
      else
        (
          'Register new member',
          'Add someone to this branch',
          Icons.person_add_rounded,
          () => pushScreen(context, const RegisterMemberScreen()),
        ),
      (
        'Data states & rigor',
        'Loading · empty · error · sync',
        Icons.layers_rounded,
        () => pushScreen(context, const DataStatesScreen()),
      ),
    ];

    return ListView(
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Eyebrow(
                isAdmin ? "Pastor's Office" : 'My Ministry · Leader',
                color: TpmColors.portalGold,
                size: 10,
              ),
              const SizedBox(height: 3),
              Text('More', style: TpmText.display(24, color: TpmColors.portalInk)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        for (final (title, subtitle, icon, onTap) in entries)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 11),
            child: PortalCard(
              radius: 14,
              padding: const EdgeInsets.all(14),
              onTap: onTap,
              child: Row(
                children: [
                  IconTile(
                    icon: icon,
                    background: TpmColors.portalGold.withValues(alpha: 0.12),
                    foreground: TpmColors.portalGold,
                    size: 40,
                    iconSize: 18,
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TpmText.body(
                            14.5,
                            color: TpmColors.portalInk,
                            weight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: TpmText.body(
                            11.5,
                            color: Colors.white.withValues(alpha: 0.45),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TpmOutlineButton(
            label: 'Back to the member app',
            icon: Icons.arrow_back_rounded,
            foreground: TpmColors.portalInk,
            background: TpmColors.nightSurface,
            borderColor: Colors.white.withValues(alpha: 0.15),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ],
    );
  }
}
