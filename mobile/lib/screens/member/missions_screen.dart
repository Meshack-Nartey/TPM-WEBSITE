import 'package:flutter/material.dart';

import '../../data/missions_content.dart';
import '../../theme/tpm_theme.dart';
import '../../widgets/common.dart';

/// Sending the Gospel beyond our local walls — the website's Missions page,
/// re-sectioned for a phone: intro, a grid of moments from recent trips, and
/// what partnering means.
class MissionsScreen extends StatelessWidget {
  const MissionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: TpmColors.canvas,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SizedBox(
              height: 220 + topInset,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const BrandedPhoto(asset: 'assets/missions/mission-1.jpg', scrimOpacity: 0.55),
                  Positioned(
                    top: topInset + 12,
                    left: 20,
                    child: CircleBackButton(onTap: () => Navigator.of(context).pop()),
                  ),
                  Positioned(
                    left: 22,
                    right: 22,
                    bottom: 22,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MISSIONS',
                          style: TpmText.eyebrow(color: TpmColors.gold, size: 10.5, tracking: 2.4),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Our Missions',
                          style: TpmText.display(25, color: Colors.white, height: 1.15),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 34),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    MissionsContent.intro,
                    style: TpmText.body(14.5, color: TpmColors.muted, height: 1.7),
                  ),
                  const SizedBox(height: 22),
                  const Eyebrow('Mission moments'),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: MissionsContent.moments.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemBuilder: (context, i) => ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(MissionsContent.moments[i], fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(height: 26),
                  TpmCard(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Eyebrow('What partnering means'),
                        const SizedBox(height: 12),
                        Text(
                          MissionsContent.partnering,
                          style: TpmText.body(14, color: TpmColors.ink, height: 1.65),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
