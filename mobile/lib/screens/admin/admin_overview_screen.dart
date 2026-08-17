import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../theme/tpm_theme.dart';
import '../../widgets/charts.dart';
import '../../widgets/common.dart';
import '../leader/leader_dashboard_screen.dart';

/// The pastor's office view: every branch, aggregated.
///
/// Same furniture as the leader dashboard, but the scope banner says "all 14
/// branches" rather than naming one — the difference between the two roles is
/// exactly the difference between those two banners.
class AdminOverviewScreen extends StatelessWidget {
  const AdminOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      children: [
        const PortalHeader(
          eyebrow: "Pastor's Office · Church-wide",
          title: 'Overview',
          icon: Icons.admin_panel_settings_rounded,
        ),
        const SizedBox(height: 14),
        const PortalScopeBanner(
          icon: Icons.public_rounded,
          label: 'All 14 branches',
          note: 'Aggregated',
        ),
        const SizedBox(height: 18),
        const PortalStatGrid(stats: MockData.adminStats),
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
        for (final branch in MockData.branchRanks)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 11),
            child: PortalCard(
              radius: 14,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: BranchRankBar(
                name: branch.name,
                value: branch.value,
                fraction: branch.fraction,
              ),
            ),
          ),
      ],
    );
  }
}
