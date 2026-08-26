import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../theme/tpm_theme.dart';
import '../../widgets/common.dart';

/// Where announcements and events on the member surface come from.
///
/// Audience is a first-class field, not a setting buried behind a gear. A post
/// that goes to every branch reads very differently from one meant for Kumasi
/// Central, and the office should have to look at that choice before publishing.
class ComposeScreen extends StatefulWidget {
  const ComposeScreen({super.key});

  @override
  State<ComposeScreen> createState() => _ComposeScreenState();
}

class _ComposeScreenState extends State<ComposeScreen> {
  bool _isAnnouncement = true;
  int _tag = 0;

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
                      const Eyebrow('New post', color: TpmColors.portalGold, size: 10),
                      const SizedBox(height: 3),
                      Text(
                        'Publish',
                        style: TpmText.display(22, color: TpmColors.portalInk),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _FieldLabel('Type'),
            const SizedBox(height: 8),
            Row(
              children: [
                ChoiceChipPill(
                  label: 'Announcement',
                  selected: _isAnnouncement,
                  dark: true,
                  expand: true,
                  onTap: () => setState(() => _isAnnouncement = true),
                ),
                const SizedBox(width: 8),
                ChoiceChipPill(
                  label: 'Event',
                  selected: !_isAnnouncement,
                  dark: true,
                  expand: true,
                  onTap: () => setState(() => _isAnnouncement = false),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _FieldLabel('Tag'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var i = 0; i < MockData.composeTags.length; i++)
                  ChoiceChipPill(
                    label: MockData.composeTags[i],
                    selected: i == _tag,
                    dark: true,
                    onTap: () => setState(() => _tag = i),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            const TpmField(
              label: 'Title',
              hint: 'Give it a clear title',
              dark: true,
            ),
            const SizedBox(height: 16),
            const TpmField(
              label: 'Message',
              hint: 'Write the announcement…',
              dark: true,
              maxLines: 5,
            ),
            const SizedBox(height: 16),
            const _AudienceRow(),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: TpmOutlineButton(
                    label: 'Save draft',
                    foreground: Colors.white.withValues(alpha: 0.75),
                    background: TpmColors.nightSurface,
                    borderColor: Colors.white.withValues(alpha: 0.15),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 3,
                  child: TpmButton.gold(
                    label: 'Publish',
                    icon: Icons.send_rounded,
                    height: 50,
                    onPressed: () {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${_isAnnouncement ? 'Announcement' : 'Event'} published '
                            'to all branches',
                          ),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text.toUpperCase(),
        style: TpmText.eyebrow(
          color: Colors.white.withValues(alpha: 0.5),
          size: 10,
          tracking: 1.2,
        ),
      );
}

class _AudienceRow extends StatelessWidget {
  const _AudienceRow();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: TpmColors.nightSurface,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          const Icon(Icons.public_rounded, size: 17, color: TpmColors.portalGold),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Audience',
              style: TpmText.body(13.5, color: TpmColors.portalInk),
            ),
          ),
          Text(
            'All branches',
            style: TpmText.body(13, color: Colors.white.withValues(alpha: 0.6)),
          ),
          const SizedBox(width: 6),
          Icon(
            Icons.expand_more_rounded,
            size: 16,
            color: Colors.white.withValues(alpha: 0.6),
          ),
        ],
      ),
    );
  }
}
