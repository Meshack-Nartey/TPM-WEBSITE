import 'package:flutter/material.dart';

import '../../app/navigation.dart';
import '../../data/mock_data.dart';
import '../../theme/tpm_theme.dart';
import '../../widgets/common.dart';
import 'compose_screen.dart';

/// The office's admin drawer. Publishing sits at the top as a full-width gold
/// card rather than a list row, because it is the action people come here for.
class ManageListsScreen extends StatelessWidget {
  const ManageListsScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final body = ListView(
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Eyebrow("Pastor's Office", color: TpmColors.portalGold, size: 10),
              const SizedBox(height: 3),
              Text('Manage', style: TpmText.display(24, color: TpmColors.portalInk)),
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
        for (final entry in MockData.manageLists)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 11),
            child: PortalCard(
              radius: 14,
              padding: const EdgeInsets.all(14),
              onTap: () {},
              child: Row(
                children: [
                  IconTile(
                    icon: entry.icon,
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
                          entry.label,
                          style: TpmText.body(
                            14.5,
                            color: TpmColors.portalInk,
                            weight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          entry.count,
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
      ],
    );

    if (embedded) return body;
    return Scaffold(backgroundColor: TpmColors.night, body: SafeArea(child: body));
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
                child: const Icon(Icons.edit_note_rounded, color: TpmColors.night, size: 20),
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
