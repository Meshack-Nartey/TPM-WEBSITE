import 'package:flutter/material.dart';

import '../../data/about_content.dart';
import '../../data/mock_data.dart';
import '../../theme/tpm_theme.dart';
import '../../widgets/common.dart';

/// Who the ministry is, in its own words.
///
/// Every line here is the church's own copy from the website — this screen
/// re-sections it for a phone rather than rewriting it. The founder sits at the
/// end on the night palette: it is the one part of the member surface that is
/// about a person rather than a service, and the change of ground gives it the
/// weight the website gives it with a full-width band.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TpmColors.canvas,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _Hero()),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    AboutContent.intro,
                    style: TpmText.body(14.5, color: TpmColors.muted, height: 1.7),
                  ),
                  const SizedBox(height: 20),
                  const _PullQuote(AboutContent.pullQuote),
                  const SizedBox(height: 24),
                  const _MissionVision(),
                  const SizedBox(height: 22),
                  const _BulletCard(
                    eyebrow: 'Our mandate',
                    items: AboutContent.mandate,
                    icon: Icons.flag_rounded,
                  ),
                  const SizedBox(height: 14),
                  const _BulletCard(
                    eyebrow: 'What we believe',
                    items: AboutContent.beliefs,
                    icon: Icons.menu_book_rounded,
                    note: AboutContent.beliefsNote,
                  ),
                  const SizedBox(height: 26),
                  for (final section in AboutContent.sections) ...[
                    _Section(section: section),
                    const SizedBox(height: 26),
                  ],
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: _Founder()),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 26, 22, 34),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Eyebrow('For first-time visitors'),
                  const SizedBox(height: 10),
                  Text(
                    AboutContent.welcome,
                    style: TpmText.body(14.5, color: TpmColors.muted, height: 1.7),
                  ),
                  const SizedBox(height: 18),
                  _ContactRow(
                    icon: Icons.location_on_rounded,
                    label: MockData.officeAddress,
                  ),
                  const SizedBox(height: 10),
                  _ContactRow(icon: Icons.phone_rounded, label: MockData.officePhone),
                  const SizedBox(height: 10),
                  _ContactRow(icon: Icons.email_rounded, label: MockData.officeEmail),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;

    return SizedBox(
      height: 240 + topInset,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const BrandedPhoto(asset: 'assets/photos/congregation.jpg', scrimOpacity: 0.6),
          Positioned(
            top: topInset + 12,
            left: 20,
            child: Material(
              color: Colors.white.withValues(alpha: 0.2),
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => Navigator.of(context).pop(),
                child: const SizedBox(
                  width: 38,
                  height: 38,
                  child: Icon(Icons.chevron_left_rounded, color: Colors.white),
                ),
              ),
            ),
          ),
          Positioned(
            left: 22,
            right: 22,
            bottom: 22,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset('assets/brand/logo-mark.png', height: 52),
                const SizedBox(height: 12),
                Text(
                  'WHO WE ARE',
                  style: TpmText.eyebrow(color: TpmColors.gold, size: 10.5, tracking: 2.4),
                ),
                const SizedBox(height: 6),
                Text(
                  MockData.ministryName,
                  style: TpmText.display(25, color: Colors.white, height: 1.15),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PullQuote extends StatelessWidget {
  const _PullQuote(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: TpmColors.tintIndigo,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: TpmColors.gold, width: 3)),
      ),
      child: Text(
        text,
        style: TpmText.display(16.5, color: TpmColors.navy, height: 1.45),
      ),
    );
  }
}

class _MissionVision extends StatelessWidget {
  const _MissionVision();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _StatementCard(
          eyebrow: 'Our mission',
          body: AboutContent.mission,
          icon: Icons.explore_rounded,
          tintBg: TpmColors.tintBlue,
          tintFg: TpmColors.navy,
        ),
        const SizedBox(height: 12),
        _StatementCard(
          eyebrow: 'Our vision',
          body: AboutContent.vision,
          icon: Icons.visibility_rounded,
          tintBg: TpmColors.tintAmber,
          tintFg: TpmColors.goldDeep,
        ),
      ],
    );
  }
}

class _StatementCard extends StatelessWidget {
  const _StatementCard({
    required this.eyebrow,
    required this.body,
    required this.icon,
    required this.tintBg,
    required this.tintFg,
  });

  final String eyebrow;
  final String body;
  final IconData icon;
  final Color tintBg;
  final Color tintFg;

  @override
  Widget build(BuildContext context) {
    return TpmCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconTile(icon: icon, background: tintBg, foreground: tintFg, size: 34, iconSize: 17),
              const SizedBox(width: 10),
              Eyebrow(eyebrow, size: 10),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            body,
            style: TpmText.body(14, color: TpmColors.ink, height: 1.6, weight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _BulletCard extends StatelessWidget {
  const _BulletCard({
    required this.eyebrow,
    required this.items,
    required this.icon,
    this.note,
  });

  final String eyebrow;
  final List<String> items;
  final IconData icon;
  final String? note;

  @override
  Widget build(BuildContext context) {
    return TpmCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconTile(
                icon: icon,
                background: TpmColors.tintViolet,
                foreground: TpmColors.violet,
                size: 34,
                iconSize: 17,
              ),
              const SizedBox(width: 10),
              Eyebrow(eyebrow, size: 10),
            ],
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 7),
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: TpmColors.gold,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Text(
                    items[i],
                    style: TpmText.body(13.5, color: TpmColors.inkSoft, height: 1.5),
                  ),
                ),
              ],
            ),
          ],
          if (note != null) ...[
            const SizedBox(height: 14),
            Text(note!, style: TpmText.body(12.5, height: 1.55)),
          ],
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.section});

  final AboutSection section;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Eyebrow(section.eyebrow),
        const SizedBox(height: 6),
        Text(section.title, style: TpmText.display(21, height: 1.2)),
        const SizedBox(height: 12),
        for (var i = 0; i < section.paragraphs.length; i++) ...[
          if (i > 0) const SizedBox(height: 12),
          Text(
            section.paragraphs[i],
            style: TpmText.body(14, color: TpmColors.muted, height: 1.7),
          ),
        ],
        if (section.scripture != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: TpmColors.slateWash,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '“${section.scripture!}”',
                  style: TpmText.display(
                    15,
                    color: TpmColors.inkSoft,
                    weight: FontWeight.w500,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Eyebrow(section.scriptureRef ?? '', size: 9.5, tracking: 1.4),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// The founder, on the night palette — the one part of the member surface that
/// is about a person, and the website gives it the same separation.
class _Founder extends StatelessWidget {
  const _Founder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: TpmColors.night,
      padding: const EdgeInsets.fromLTRB(22, 28, 22, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Eyebrow('The founder', color: TpmColors.portalGold),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                width: 96,
                height: 112,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      TpmColors.portalGold.withValues(alpha: 0.18),
                      TpmColors.nightSurface,
                    ],
                  ),
                ),
                child: Image.asset(
                  AboutContent.founderPhoto,
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  semanticLabel: AboutContent.founderName,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AboutContent.founderName,
                      style: TpmText.display(20, color: TpmColors.portalInk, height: 1.2),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      AboutContent.founderRole,
                      style: TpmText.body(
                        11.5,
                        color: TpmColors.portalGold,
                        height: 1.45,
                        weight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            AboutContent.founderIntro,
            style: TpmText.body(
              13.5,
              color: Colors.white.withValues(alpha: 0.72),
              height: 1.7,
            ),
          ),
          const SizedBox(height: 18),
          for (final fact in AboutContent.founderFacts) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: PortalCard(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Eyebrow(fact.label, color: TpmColors.portalGold, size: 9.5, tracking: 1.4),
                    const SizedBox(height: 7),
                    Text(
                      fact.body,
                      style: TpmText.body(
                        13,
                        color: Colors.white.withValues(alpha: 0.75),
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconTile(
          icon: icon,
          background: TpmColors.tintBlue,
          foreground: TpmColors.navy,
          size: 34,
          radius: 10,
          iconSize: 16,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TpmText.body(13.5, color: TpmColors.ink, weight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
