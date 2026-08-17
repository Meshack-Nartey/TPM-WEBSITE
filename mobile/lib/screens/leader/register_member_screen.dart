import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../models/models.dart';
import '../../theme/tpm_theme.dart';
import '../../widgets/common.dart';

/// Entering someone into the branch registry. Status is a deliberate choice
/// rather than a default, because "Visitor" and "Member" mean different
/// follow-up for the person who has just walked in.
class RegisterMemberScreen extends StatefulWidget {
  const RegisterMemberScreen({super.key});

  @override
  State<RegisterMemberScreen> createState() => _RegisterMemberScreenState();
}

class _RegisterMemberScreenState extends State<RegisterMemberScreen> {
  int _status = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TpmColors.night,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 34),
          children: [
            Row(
              children: [
                CircleBackButton(
                  dark: true,
                  size: 36,
                  onTap: () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Eyebrow(
                        'Kumasi Central',
                        color: TpmColors.portalGold,
                        size: 10,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Register Member',
                        style: TpmText.display(22, color: TpmColors.portalInk),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            for (final field in MockData.newMemberFields) ...[
              TpmField(
                label: field.label,
                hint: field.hint,
                icon: field.icon,
                dark: true,
              ),
              const SizedBox(height: 14),
            ],
            Text(
              'STATUS',
              style: TpmText.eyebrow(
                color: Colors.white.withValues(alpha: 0.5),
                size: 10,
                tracking: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                for (var i = 0; i < MockData.memberStatuses.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  ChoiceChipPill(
                    label: MockData.memberStatuses[i],
                    selected: i == _status,
                    dark: true,
                    expand: true,
                    onTap: () => setState(() => _status = i),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 24),
            TpmButton.gold(
              label: 'Save member',
              icon: Icons.person_add_rounded,
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Saved as ${MockData.memberStatuses[_status]} · Kumasi Central',
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
