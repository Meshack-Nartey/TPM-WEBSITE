import 'package:flutter/material.dart';

import '../../app/navigation.dart';
import '../../app/session.dart';
import '../../models/models.dart';
import '../../services/auth_api.dart';
import '../../services/leaders_api.dart';
import '../../services/lookups_api.dart';
import '../../theme/tpm_theme.dart';
import '../../widgets/common.dart';
import 'compose_screen.dart';
import 'leaders_directory_screen.dart';
import 'lookup_list_screen.dart';

/// The office's admin drawer. Publishing sits at the top as a full-width gold
/// card rather than a list row, because it is the action people come here for.
/// The rows below open the reference lists that back dropdowns elsewhere in
/// the app (`backend`'s `Lookup` table) and the leadership directory.
class ManageListsScreen extends StatefulWidget {
  const ManageListsScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<ManageListsScreen> createState() => _ManageListsScreenState();
}

class _ManageListsScreenState extends State<ManageListsScreen> {
  bool _loaded = false;
  int? _leaderCount;
  int? _branchCount;
  int? _departmentCount;
  int? _fellowshipBaseniaCount;

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
    if (token == null) return;
    try {
      final results = await Future.wait([
        LeadersApi(token: token).fetch(),
        LookupsApi(token: token).fetch(),
      ]);
      if (!mounted) return;
      final leaders = results[0] as List<ChurchLeader>;
      final lookups = results[1] as List<LookupEntry>;
      setState(() {
        _leaderCount = leaders.length;
        _branchCount = lookups.where((l) => l.category == 'branch').length;
        _departmentCount = lookups
            .where((l) => l.category == 'department')
            .length;
        _fellowshipBaseniaCount = lookups
            .where((l) => l.category == 'fellowship' || l.category == 'basenia')
            .length;
      });
    } on ApiException {
      // Counts stay as "—" — the destination screens surface the real error.
    }
  }

  @override
  Widget build(BuildContext context) {
    final body = ListView(
      padding: const EdgeInsets.only(top: 20, bottom: 110),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Eyebrow(
                "Pastor's Office",
                color: TpmColors.portalGold,
                size: 10,
              ),
              const SizedBox(height: 3),
              Text(
                'Manage',
                style: TpmText.display(24, color: TpmColors.portalInk),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _PublishCard(
            onTap: () => pushScreen(context, const ComposeScreen()),
          ),
        ),
        const SizedBox(height: 14),
        _row(
          label: 'Leaders directory',
          count: _leaderCount == null
              ? 'Pastors & branch leaders'
              : '$_leaderCount leader${_leaderCount == 1 ? '' : 's'}',
          icon: Icons.badge_rounded,
          onTap: () async {
            await pushScreen(context, const LeadersDirectoryScreen());
            _load();
          },
        ),
        _row(
          label: 'Branches',
          count: _branchCount == null ? '—' : '$_branchCount branches',
          icon: Icons.location_on_rounded,
          onTap: () async {
            await pushScreen(
              context,
              const LookupListScreen(
                title: 'Branches',
                eyebrow: "Pastor's Office",
                sections: [
                  LookupSection(category: 'branch', label: 'Branches'),
                ],
              ),
            );
            _load();
          },
        ),
        _row(
          label: 'Worker groups',
          count: _departmentCount == null
              ? '—'
              : '$_departmentCount departments',
          icon: Icons.diversity_3_rounded,
          onTap: () async {
            await pushScreen(
              context,
              const LookupListScreen(
                title: 'Worker groups',
                eyebrow: "Pastor's Office",
                sections: [
                  LookupSection(category: 'department', label: 'Worker groups'),
                ],
              ),
            );
            _load();
          },
        ),
        _row(
          label: 'Fellowships & Basenias',
          count: _fellowshipBaseniaCount == null
              ? '—'
              : '$_fellowshipBaseniaCount total',
          icon: Icons.groups_2_rounded,
          onTap: () async {
            await pushScreen(
              context,
              const LookupListScreen(
                title: 'Fellowships & Basenias',
                eyebrow: "Pastor's Office",
                sections: [
                  LookupSection(category: 'fellowship', label: 'Fellowships'),
                  LookupSection(category: 'basenia', label: 'Basenias'),
                ],
              ),
            );
            _load();
          },
        ),
      ],
    );

    if (widget.embedded) return body;
    return Scaffold(
      backgroundColor: TpmColors.night,
      body: SafeArea(child: body),
    );
  }

  Widget _row({
    required String label,
    required String count,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Padding(
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
                    label,
                    style: TpmText.body(
                      14.5,
                      color: TpmColors.portalInk,
                      weight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    count,
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
    );
  }
}

class _PublishCard extends StatelessWidget {
  const _PublishCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: TpmColors.portalGoldGradient,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: TpmColors.night.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.edit_note_rounded,
                  color: TpmColors.night,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Publish announcement / event',
                      style: TpmText.display(15, color: TpmColors.night),
                    ),
                    Text(
                      'Compose & send to the app',
                      style: TpmText.body(
                        11.5,
                        color: TpmColors.night.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: TpmColors.night),
            ],
          ),
        ),
      ),
    );
  }
}
