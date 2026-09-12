import 'package:flutter/material.dart';

import '../../app/session.dart';
import '../../models/models.dart';
import '../../services/auth_api.dart';
import '../../services/statistics_api.dart';
import '../../theme/tpm_theme.dart';
import '../../widgets/charts.dart';
import '../../widgets/common.dart';
import '../leader/leader_dashboard_screen.dart';

/// The pastor's office view: every branch, aggregated.
///
/// Same furniture as the leader dashboard, but the scope banner says "all
/// branches" rather than naming one — the difference between the two roles
/// is exactly the difference between those two banners. The statistics
/// endpoint is the same one the leader dashboard calls; it just comes back
/// unscoped for an admin token instead of filtered to one branch.
class AdminOverviewScreen extends StatefulWidget {
  const AdminOverviewScreen({super.key});

  @override
  State<AdminOverviewScreen> createState() => _AdminOverviewScreenState();
}

class _AdminOverviewScreenState extends State<AdminOverviewScreen> {
  bool _loaded = false;
  bool _loading = true;
  DashboardStatistics? _stats;

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
      // Role-preview browsing with no real account behind it — nothing to
      // fetch, show the empty/zeroed state rather than fail.
      setState(() => _loading = false);
      return;
    }
    try {
      final stats = await StatisticsApi(token: token).fetch();
      if (!mounted) return;
      setState(() {
        _stats = stats;
        _loading = false;
      });
    } on ApiException {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final stats = _stats;

    return RefreshIndicator(
      color: TpmColors.portalGold,
      backgroundColor: TpmColors.nightRaised,
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 20, bottom: 110),
        children: [
          const PortalHeader(
            eyebrow: "Pastor's Office · Church-wide",
            title: 'Overview',
            icon: Icons.admin_panel_settings_rounded,
          ),
          const SizedBox(height: 14),
          const PortalScopeBanner(
            icon: Icons.public_rounded,
            label: 'Every branch',
            note: 'Aggregated',
          ),
          const SizedBox(height: 18),
          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: CircularProgressIndicator(color: TpmColors.portalGold),
              ),
            )
          else ...[
            PortalStatGrid(
              stats: [
                StatTile(
                  label: 'Total members',
                  value: '${stats?.totalMembers ?? 0}',
                  icon: Icons.groups_rounded,
                ),
                StatTile(
                  label: 'Weekly attendance',
                  value: '${stats?.attendanceThisWeek ?? 0}',
                  icon: Icons.event_seat_rounded,
                ),
                StatTile(
                  label: 'Tithe this month (GHS)',
                  value: (stats?.titheThisMonth ?? 0).toStringAsFixed(0),
                  icon: Icons.savings_rounded,
                ),
                StatTile(
                  label: 'Souls won',
                  value: '${stats?.soulsWon ?? 0}',
                  icon: Icons.volunteer_activism_rounded,
                ),
              ],
            ),
            const SizedBox(height: 18),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Eyebrow(
                'Top branches · attendance',
                color: TpmColors.portalGold,
                size: 10,
              ),
            ),
            const SizedBox(height: 12),
            if (stats == null || stats.branchRanks.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: PortalCard(
                  padding: const EdgeInsets.symmetric(
                    vertical: 24,
                    horizontal: 20,
                  ),
                  child: Center(
                    child: Text(
                      'No reports submitted yet',
                      style: TpmText.body(
                        12.5,
                        color: Colors.white.withValues(alpha: 0.45),
                      ),
                    ),
                  ),
                ),
              )
            else
              for (final branch in stats.branchRanks)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 11),
                  child: PortalCard(
                    radius: 14,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    child: BranchRankBar(
                      name: branch.name,
                      value: branch.value,
                      fraction: branch.fraction,
                    ),
                  ),
                ),
          ],
        ],
      ),
    );
  }
}
