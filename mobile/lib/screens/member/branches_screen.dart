import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/session.dart';
import '../../data/mock_data.dart';
import '../../models/models.dart';
import '../../services/auth_api.dart';
import '../../services/branches_api.dart';
import '../../theme/tpm_theme.dart';
import '../../widgets/common.dart';

/// Where to find us. Directions, phone, email and WhatsApp are all one tap from
/// the branch card — WhatsApp especially, since that is how most branches
/// actually field questions.
class BranchesScreen extends StatefulWidget {
  const BranchesScreen({super.key});

  @override
  State<BranchesScreen> createState() => _BranchesScreenState();
}

class _BranchesScreenState extends State<BranchesScreen> {
  bool _loaded = false;
  List<Branch> _branches = MockData.branches;

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
    if (token == null) return; // Guest preview — the sample branches stand in.
    try {
      final branches = await BranchesApi(token: token).fetch();
      if (!mounted || branches.isEmpty) return;
      setState(() => _branches = branches);
    } on ApiException {
      // Keep the fallback list.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TpmColors.canvas,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(top: 20, bottom: 24),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: ScreenTitle(
                eyebrow: 'Find us',
                title: 'Branches',
                titleSize: 24,
                onBack: () => Navigator.of(context).pop(),
              ),
            ),
            const SizedBox(height: 16),
            for (final branch in _branches)
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 12),
                child: _BranchCard(branch: branch),
              ),
          ],
        ),
      ),
    );
  }
}

/// Searches Google Maps for the branch by name — not just its address —
/// so the pin that comes up is labelled with the church's name rather than
/// a bare street location.
Future<void> _openDirections(Branch branch) async {
  final query = Uri.encodeComponent(
    '${MockData.ministryName} ${branch.name}, ${branch.address}',
  );
  final uri = Uri.parse(
    'https://www.google.com/maps/search/?api=1&query=$query',
  );
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}

class _BranchCard extends StatelessWidget {
  const _BranchCard({required this.branch});

  final Branch branch;

  @override
  Widget build(BuildContext context) {
    return TpmCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(branch.name, style: TpmText.display(17))),
              const SizedBox(width: 8),
              Pill(
                branch.region,
                foreground: TpmColors.navy,
                background: TpmColors.tintIndigo,
                uppercase: false,
                fontSize: 10,
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 13,
                color: TpmColors.faint,
              ),
              const SizedBox(width: 4),
              Expanded(child: Text(branch.address, style: TpmText.body(12.2))),
            ],
          ),
          const SizedBox(height: 13),
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  label: 'Directions',
                  icon: Icons.directions_rounded,
                  background: TpmColors.navy,
                  foreground: Colors.white,
                  onTap: () => _openDirections(branch),
                ),
              ),
              const SizedBox(width: 8),
              _IconAction(icon: Icons.phone_rounded, onTap: () {}),
              const SizedBox(width: 8),
              _IconAction(icon: Icons.email_rounded, onTap: () {}),
              const SizedBox(width: 8),
              _IconAction(
                icon: Icons.chat_rounded,
                foreground: TpmColors.green,
                background: const Color(0xFFF0FDF4),
                borderColor: TpmColors.tintGreen,
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.background,
    required this.foreground,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(11),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: foreground),
              const SizedBox(width: 6),
              Text(
                label,
                style: TpmText.body(
                  11.5,
                  color: foreground,
                  weight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  const _IconAction({
    required this.icon,
    required this.onTap,
    this.foreground = TpmColors.navy,
    this.background = TpmColors.surface,
    this.borderColor = TpmColors.hairline,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color foreground;
  final Color background;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(11),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: borderColor),
          ),
          child: Icon(icon, size: 16, color: foreground),
        ),
      ),
    );
  }
}
