import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/session.dart';
import '../../data/mock_data.dart';
import '../../models/models.dart';
import '../../services/auth_api.dart';
import '../../services/giving_channels_api.dart';
import '../../theme/tpm_theme.dart';
import '../../widgets/common.dart';

/// Giving, handled honestly.
///
/// In-app payment isn't built yet, so rather than bouncing people out to the
/// web this screen carries the ministry's actual MoMo and bank accounts, each
/// with a one-tap copy — the same numbers `frontend/give.html` publishes.
class GiveScreen extends StatefulWidget {
  const GiveScreen({super.key});

  @override
  State<GiveScreen> createState() => _GiveScreenState();
}

class _GiveScreenState extends State<GiveScreen> {
  bool _loaded = false;
  List<GivingChannel> _channels = MockData.givingChannels;

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
    if (token == null) return; // Guest preview — the sample accounts stand in.
    try {
      final channels = await GivingChannelsApi(token: token).fetch();
      if (!mounted || channels.isEmpty) return;
      setState(() => _channels = channels);
    } on ApiException {
      // Keep the fallback list.
    }
  }

  @override
  Widget build(BuildContext context) {
    final momo = _channels.where((c) => !c.isBank);
    final banks = _channels.where((c) => c.isBank);

    return ListView(
      // The shell's tab bar floats over the body (extendBody: true), so the
      // last card needs real clearance or it ends up sitting behind it.
      padding: const EdgeInsets.only(top: 28, bottom: 110),
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 22),
          child: ScreenTitle(eyebrow: 'Partner with us', title: 'Give'),
        ),
        const SizedBox(height: 16),
        const _GiveOptionsGrid(),
        const SizedBox(height: 22),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 22),
          child: Eyebrow('Mobile Money'),
        ),
        const SizedBox(height: 12),
        for (final channel in momo) ...[
          _AccountCard(channel: channel),
          const SizedBox(height: 10),
        ],
        const SizedBox(height: 10),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 22),
          child: Eyebrow('Bank Transfer'),
        ),
        const SizedBox(height: 12),
        for (final channel in banks) ...[
          _AccountCard(channel: channel),
          const SizedBox(height: 10),
        ],
        const SizedBox(height: 4),
        const _GivingNote(),
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
    final options = MockData.giveOptions;

    // Paired rows rather than a fixed-aspect grid, so a longer blurb grows the
    // pair instead of being clipped by a ratio guessed up front.
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Column(
        children: [
          for (var i = 0; i < options.length; i += 2) ...[
            if (i > 0) const SizedBox(height: 12),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: _GiveTile(option: options[i])),
                  const SizedBox(width: 12),
                  if (i + 1 < options.length)
                    Expanded(child: _GiveTile(option: options[i + 1]))
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

class _GiveTile extends StatelessWidget {
  const _GiveTile({required this.option});

  final GiveOption option;

  @override
  Widget build(BuildContext context) {
    return TpmCard(
      radius: 16,
      border: Border.all(color: TpmColors.navy.withValues(alpha: 0.06)),
      onTap: () {},
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TpmText.body(
              14.5,
              color: TpmColors.ink,
              weight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            option.blurb,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TpmText.body(11.5),
          ),
        ],
      ),
    );
  }
}

/// One real account, with the number sized to be read off the screen and
/// copied without typing it out.
class _AccountCard extends StatelessWidget {
  const _AccountCard({required this.channel});

  final GivingChannel channel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: TpmCard(
        radius: 18,
        padding: const EdgeInsets.all(16),
        border: Border.all(color: TpmColors.navy.withValues(alpha: 0.06)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: TpmColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: TpmColors.hairline),
                  ),
                  child: Image.asset(
                    channel.logo,
                    fit: BoxFit.contain,
                    semanticLabel: channel.name,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        channel.name,
                        style: TpmText.body(
                          14.5,
                          color: TpmColors.ink,
                          weight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        channel.accountName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TpmText.body(11.5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Eyebrow(channel.numberLabel, size: 9.5, tracking: 1.2),
                      const SizedBox(height: 3),
                      Text(
                        channel.number,
                        style: TpmText.display(19, color: TpmColors.navy),
                      ),
                    ],
                  ),
                ),
                _CopyButton(channel: channel),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CopyButton extends StatelessWidget {
  const _CopyButton({required this.channel});

  final GivingChannel channel;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: TpmColors.tintAmber,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () async {
          await Clipboard.setData(ClipboardData(text: channel.copyValue));
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${channel.name} ${channel.numberLabel} copied'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.copy_rounded,
                size: 15,
                color: TpmColors.goldDeep,
              ),
              const SizedBox(width: 6),
              Text(
                'Copy',
                style: TpmText.body(
                  12.5,
                  color: TpmColors.goldDeep,
                  weight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Nothing reconciles these transfers automatically, so the ask to tell the
/// office is the actual process, not a courtesy.
class _GivingNote extends StatelessWidget {
  const _GivingNote();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: TpmColors.tintBlue,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.notifications_active_rounded,
              size: 18,
              color: TpmColors.navy,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                MockData.givingNote,
                style: TpmText.body(
                  12.5,
                  color: TpmColors.inkSoft,
                  height: 1.6,
                ),
              ),
            ),
          ],
        ),
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
                    style: TpmText.body(
                      13,
                      color: TpmColors.subtle,
                      weight: FontWeight.w700,
                    ),
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
