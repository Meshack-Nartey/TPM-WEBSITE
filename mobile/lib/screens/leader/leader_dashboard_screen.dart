import 'package:flutter/material.dart';

import '../../app/navigation.dart';
import '../../app/session.dart';
import '../../models/models.dart';
import '../../services/auth_api.dart';
import '../../services/reports_api.dart';
import '../../services/statistics_api.dart';
import '../../theme/tpm_theme.dart';
import '../../widgets/charts.dart';
import '../../widgets/common.dart';
import 'register_member_screen.dart';
import 'weekly_report_screen.dart';

/// A branch leader's home in the portal.
///
/// The scope banner is not decoration — a leader sees their own branch and
/// nothing else, and saying so on screen is cheaper than having them wonder
/// why the numbers look small.
class LeaderDashboardScreen extends StatefulWidget {
  const LeaderDashboardScreen({super.key, this.onOpenReport});

  final VoidCallback? onOpenReport;

  @override
  State<LeaderDashboardScreen> createState() => _LeaderDashboardScreenState();
}

class _LeaderDashboardScreenState extends State<LeaderDashboardScreen> {
  bool _loaded = false;
  bool _loading = true;
  DashboardStatistics? _stats;
  List<double> _titheWeeks = const [];
  List<String> _titheLabels = const [];

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
      final results = await Future.wait([
        StatisticsApi(token: token).fetch(),
        ReportsApi(token: token).fetch(),
      ]);
      if (!mounted) return;
      final stats = results[0] as DashboardStatistics;
      final reports = results[1] as List<ReportRecord>;
      final (titheWeeks, titheLabels) = _titheByDate(reports);
      setState(() {
        _stats = stats;
        _titheWeeks = titheWeeks;
        _titheLabels = titheLabels;
        _loading = false;
      });
    } on ApiException {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  /// Tithe summed per distinct report date, oldest to newest, last 6 — the
  /// same "distinct dates as weeks" approximation the backend's own
  /// attendance trend uses, since there's no separate weekly-tithe endpoint.
  (List<double>, List<String>) _titheByDate(List<ReportRecord> reports) {
    final byDate = <String, double>{};
    for (final r in reports) {
      byDate.update(r.date, (v) => v + r.tithe, ifAbsent: () => r.tithe);
    }
    final dates = byDate.keys.toList()..sort();
    final recent = dates.length > 6 ? dates.sublist(dates.length - 6) : dates;
    return (
      recent.map((d) => byDate[d]! / 1000).toList(),
      List.generate(recent.length, (i) => 'W${i + 1}'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final branch = AppSession.of(context).user?.branch;
    final stats = _stats;
    final maxTithe = _titheWeeks.isEmpty
        ? 1.0
        : _titheWeeks.reduce((a, b) => a > b ? a : b);
    final titheAxisMax = maxTithe <= 0 ? 1.0 : maxTithe * 1.25;

    return RefreshIndicator(
      color: TpmColors.portalGold,
      backgroundColor: TpmColors.nightRaised,
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 28, bottom: 110),
        children: [
          const _PortalHeader(
            eyebrow: 'My Ministry · Leader',
            title: 'Dashboard',
            icon: Icons.badge_rounded,
          ),
          const SizedBox(height: 14),
          _ScopeBanner(
            icon: Icons.location_on_rounded,
            label: (branch == null || branch.isEmpty)
                ? 'No branch set'
                : branch,
            note: 'Your branch only',
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
            _StatGrid(
              stats: [
                StatTile(
                  label: 'Attendance',
                  value: '${stats?.attendanceThisWeek ?? 0}',
                  icon: Icons.groups_rounded,
                ),
                StatTile(
                  label: 'Tithe (GHS)',
                  value: (stats?.titheThisMonth ?? 0).toStringAsFixed(0),
                  icon: Icons.savings_rounded,
                ),
                StatTile(
                  label: 'Souls won',
                  value: '${stats?.soulsWon ?? 0}',
                  icon: Icons.volunteer_activism_rounded,
                ),
                StatTile(
                  label: 'Members',
                  value: '${stats?.totalMembers ?? 0}',
                  icon: Icons.contacts_rounded,
                ),
              ],
            ),
            const SizedBox(height: 14),
            _ChartCard(
              title: 'Attendance · recent reports',
              note: (stats?.attendanceTrend.isEmpty ?? true) ? '' : 'headcount',
              child: (stats?.attendanceTrend.isEmpty ?? true)
                  ? const _NoChartData()
                  : AttendanceLineChart(values: stats!.attendanceTrend),
            ),
            const SizedBox(height: 14),
            _ChartCard(
              title: "Tithe · GHS ('000)",
              note: _titheWeeks.isEmpty ? '' : 'recent reports',
              child: _titheWeeks.isEmpty
                  ? const _NoChartData()
                  : TitheBarChart(
                      values: _titheWeeks,
                      labels: _titheLabels,
                      axisMax: titheAxisMax,
                    ),
            ),
          ],
          const SizedBox(height: 18),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Eyebrow('Actions', color: TpmColors.portalGold, size: 10),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: _ActionCard(
                    label: 'Submit weekly report',
                    icon: Icons.edit_document,
                    onTap: () {
                      if (widget.onOpenReport != null) {
                        widget.onOpenReport!();
                      } else {
                        pushScreen(context, const WeeklyReportScreen());
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionCard(
                    label: 'Register new member',
                    icon: Icons.person_add_rounded,
                    onTap: () =>
                        pushScreen(context, const RegisterMemberScreen()),
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

class _NoChartData extends StatelessWidget {
  const _NoChartData();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: Center(
        child: Text(
          'No reports submitted yet',
          style: TpmText.body(12, color: Colors.white.withValues(alpha: 0.4)),
        ),
      ),
    );
  }
}

class _PortalHeader extends StatelessWidget {
  const _PortalHeader({
    required this.eyebrow,
    required this.title,
    required this.icon,
  });

  final String eyebrow;
  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Eyebrow(eyebrow, color: TpmColors.portalGold, size: 10),
                const SizedBox(height: 3),
                Text(
                  title,
                  style: TpmText.display(
                    26,
                    color: TpmColors.portalInk,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: TpmColors.portalGold.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: TpmColors.portalGold.withValues(alpha: 0.3),
              ),
            ),
            child: Icon(icon, color: TpmColors.portalGold, size: 20),
          ),
        ],
      ),
    );
  }
}

class _ScopeBanner extends StatelessWidget {
  const _ScopeBanner({
    required this.icon,
    required this.label,
    required this.note,
  });

  final IconData icon;
  final String label;
  final String note;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: TpmColors.portalGold.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: TpmColors.portalGold.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 15, color: TpmColors.portalGold),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TpmText.body(
                  13,
                  color: TpmColors.portalInk,
                  weight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              note.toUpperCase(),
              style: TpmText.eyebrow(
                color: Colors.white.withValues(alpha: 0.4),
                size: 9.5,
                tracking: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatGrid extends StatelessWidget {
  const _StatGrid({required this.stats});

  final List<StatTile> stats;

  /// Paired rows rather than a fixed-aspect grid: a label like "Weekly
  /// attendance" wraps to two lines where "Members" does not, and IntrinsicHeight
  /// lets the pair agree on a height instead of clipping the taller one.
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          for (var i = 0; i < stats.length; i += 2) ...[
            if (i > 0) const SizedBox(height: 12),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: _StatCard(stat: stats[i])),
                  const SizedBox(width: 12),
                  if (i + 1 < stats.length)
                    Expanded(child: _StatCard(stat: stats[i + 1]))
                  else
                    const Spacer(),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.stat});

  final StatTile stat;

  @override
  Widget build(BuildContext context) {
    return PortalCard(
      radius: 18,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconTile(
                icon: stat.icon,
                background: TpmColors.portalGold.withValues(alpha: 0.12),
                foreground: TpmColors.portalGold,
                size: 34,
                radius: 10,
                iconSize: 16,
              ),
              if (stat.trend case final trend?)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      stat.up
                          ? Icons.arrow_upward_rounded
                          : Icons.arrow_downward_rounded,
                      size: 11,
                      color: stat.up ? TpmColors.success : TpmColors.danger,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      trend,
                      style: TpmText.body(
                        10.5,
                        color: stat.up ? TpmColors.success : TpmColors.danger,
                        weight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            stat.value,
            maxLines: 1,
            style: TpmText.display(28, color: TpmColors.portalInk, height: 1),
          ),
          const SizedBox(height: 6),
          Text(
            stat.label.toUpperCase(),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TpmText.eyebrow(
              color: Colors.white.withValues(alpha: 0.45),
              size: 9.5,
              tracking: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({
    required this.title,
    required this.note,
    required this.child,
  });

  final String title;
  final String note;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: PortalCard(
        radius: 18,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Eyebrow(title, color: TpmColors.portalGold, size: 10),
                ),
                Text(
                  note,
                  style: TpmText.body(
                    11.5,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PortalCard(
      color: TpmColors.nightRaised,
      borderColor: Colors.white.withValues(alpha: 0.08),
      radius: 16,
      padding: const EdgeInsets.all(15),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconTile(
            icon: icon,
            background: Colors.transparent,
            gradient: TpmColors.portalGoldGradient,
            foreground: TpmColors.night,
            size: 36,
            radius: 10,
            iconSize: 17,
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: TpmText.body(
              13,
              color: TpmColors.portalInk,
              weight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Shared with the administrator overview, which uses the same furniture.
class PortalHeader extends StatelessWidget {
  const PortalHeader({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.icon,
  });

  final String eyebrow;
  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) =>
      _PortalHeader(eyebrow: eyebrow, title: title, icon: icon);
}

class PortalScopeBanner extends StatelessWidget {
  const PortalScopeBanner({
    super.key,
    required this.icon,
    required this.label,
    required this.note,
  });

  final IconData icon;
  final String label;
  final String note;

  @override
  Widget build(BuildContext context) =>
      _ScopeBanner(icon: icon, label: label, note: note);
}

class PortalStatGrid extends StatelessWidget {
  const PortalStatGrid({super.key, required this.stats});

  final List<StatTile> stats;

  @override
  Widget build(BuildContext context) => _StatGrid(stats: stats);
}
