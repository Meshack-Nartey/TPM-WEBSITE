import 'package:flutter/material.dart';

import '../../app/navigation.dart';
import '../../data/mock_data.dart';
import '../../models/models.dart';
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
class LeaderDashboardScreen extends StatelessWidget {
  const LeaderDashboardScreen({super.key, this.onOpenReport});

  final VoidCallback? onOpenReport;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(top: 20, bottom: 24),
      children: [
        const _PortalHeader(
          eyebrow: 'My Ministry · Leader',
          title: 'Dashboard',
          icon: Icons.badge_rounded,
        ),
        const SizedBox(height: 14),
        const _ScopeBanner(
          icon: Icons.location_on_rounded,
          label: MockData.leaderBranch,
          note: 'Your branch only',
        ),
        const SizedBox(height: 18),
        const _StatGrid(stats: MockData.leaderStats),
        const SizedBox(height: 14),
        const _ChartCard(
          title: 'Attendance · 8 weeks',
          note: 'avg 214',
          child: AttendanceLineChart(values: MockData.attendanceTrend),
        ),
        const SizedBox(height: 14),
        const _ChartCard(
          title: "Tithe · GHS ('000)",
          note: 'last 6 wks',
          child: TitheBarChart(
            values: MockData.titheWeeks,
            labels: MockData.weekLabels,
            axisMax: MockData.titheAxisMax,
          ),
        ),
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
                    if (onOpenReport != null) {
                      onOpenReport!();
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
                  onTap: () => pushScreen(context, const RegisterMemberScreen()),
                ),
              ),
            ],
          ),
        ),
      ],
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
                  style: TpmText.display(26, color: TpmColors.portalInk, height: 1.1),
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
              border: Border.all(color: TpmColors.portalGold.withValues(alpha: 0.3)),
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
          border: Border.all(color: TpmColors.portalGold.withValues(alpha: 0.2)),
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
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    stat.up ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                    size: 11,
                    color: stat.up ? TpmColors.success : TpmColors.danger,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    stat.trend,
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
  const _ChartCard({required this.title, required this.note, required this.child});

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
                Flexible(child: Eyebrow(title, color: TpmColors.portalGold, size: 10)),
                Text(
                  note,
                  style: TpmText.body(11.5, color: Colors.white.withValues(alpha: 0.5)),
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
  const _ActionCard({required this.label, required this.icon, required this.onTap});

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
            style: TpmText.body(13, color: TpmColors.portalInk, weight: FontWeight.w600),
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
