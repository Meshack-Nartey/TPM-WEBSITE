import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../models/models.dart';
import '../../theme/tpm_theme.dart';
import '../../widgets/common.dart';

/// Giving, handled honestly.
///
/// In-app payment isn't built yet, so the screen says so plainly and hands off
/// to the existing web giving page rather than dressing up a dead end. The real
/// MTN MoMo / Telecel Cash / Stanbic marks are shown up front so people can see
/// their channel is supported before they leave the app.
class GiveScreen extends StatelessWidget {
  const GiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(top: 12, bottom: 24),
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 22),
          child: ScreenTitle(eyebrow: 'Partner with us', title: 'Give'),
        ),
        const SizedBox(height: 16),
        const _GiveOptionsGrid(),
        const SizedBox(height: 12),
        const _WebHandoffCard(),
        const SizedBox(height: 14),
        const _ChannelStrip(),
        const SizedBox(height: 14),
        const _ComingLater(),
      ],
    );
  }
}

class _GiveOptionsGrid extends StatelessWidget {
  const _GiveOptionsGrid();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.55,
        children: [
          for (final option in MockData.giveOptions)
            TpmCard(
              radius: 16,
              border: Border.all(color: TpmColors.navy.withValues(alpha: 0.06)),
              onTap: () {},
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconTile(
                    icon: option.icon,
                    background: option.tintBg,
                    foreground: option.tintFg,
                    size: 38,
                    iconSize: 18,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    option.label,
                    style: TpmText.body(14.5, color: TpmColors.ink, weight: FontWeight.w700),
                  ),
                  const SizedBox(height: 3),
                  Text(option.blurb, style: TpmText.body(11.5)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _WebHandoffCard extends StatelessWidget {
  const _WebHandoffCard();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: TpmCard(
        radius: 20,
        padding: const EdgeInsets.all(20),
        shadow: TpmShadows.raised,
        border: Border.all(color: TpmColors.navy.withValues(alpha: 0.06)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const IconTile(
                  icon: Icons.shield_rounded,
                  background: TpmColors.tintBlue,
                  foreground: TpmColors.navy,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Secure giving on the web',
                        style: TpmText.body(
                          14.5,
                          color: TpmColors.ink,
                          weight: FontWeight.w700,
                        ),
                      ),
                      Text('Opens the TPM giving page', style: TpmText.body(11.5)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              "For now, giving happens on our trusted web portal — you'll continue "
              "in an in-app browser and return here when you're done.",
              style: TpmText.body(12.8, color: TpmColors.muted, height: 1.6),
            ),
            const SizedBox(height: 16),
            TpmButton(
              label: 'Continue to giving',
              icon: Icons.open_in_new_rounded,
              gradient: TpmColors.goldGradient,
              foreground: TpmColors.night,
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Opens transformationpm.org/give in an in-app browser'),
                  behavior: SnackBarBehavior.floating,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The channels already advertised on the website, shown with their real marks.
class _ChannelStrip extends StatelessWidget {
  const _ChannelStrip();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Eyebrow('Accepted channels'),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 0; i < MockData.givingChannels.length; i++) ...[
                if (i > 0) const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    height: 62,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: TpmColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: TpmColors.hairline),
                    ),
                    child: Image.asset(
                      MockData.givingChannels[i].logo,
                      fit: BoxFit.contain,
                      semanticLabel: MockData.givingChannels[i].name,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _ComingLater extends StatelessWidget {
  const _ComingLater();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: TpmColors.slateWash,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFCBD5E1)),
        ),
        child: Row(
          children: [
            const IconTile(
              icon: Icons.history_rounded,
              background: Color(0xFFE2E8F0),
              foreground: TpmColors.faint,
              size: 34,
              radius: 10,
              iconSize: 17,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'In-app giving — coming later',
                    style: TpmText.body(13, color: TpmColors.subtle, weight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Pay with Mobile Money & card without leaving the app.',
                    style: TpmText.body(11.5, color: TpmColors.faint),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
