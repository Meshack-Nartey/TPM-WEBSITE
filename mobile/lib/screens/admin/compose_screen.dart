import 'package:flutter/material.dart';

import '../../app/session.dart';
import '../../data/mock_data.dart';
import '../../services/announcements_api.dart';
import '../../services/auth_api.dart';
import '../../theme/tpm_theme.dart';
import '../../widgets/common.dart';

/// Where announcements on the member surface come from.
///
/// Events aren't wired here — the API has no way to create one yet, only
/// announcements — so picking "Event" explains that rather than pretending
/// to publish something that goes nowhere.
class ComposeScreen extends StatefulWidget {
  const ComposeScreen({super.key});

  @override
  State<ComposeScreen> createState() => _ComposeScreenState();
}

class _ComposeScreenState extends State<ComposeScreen> {
  bool _isAnnouncement = true;
  int _tag = 0;
  bool _publishing = false;
  String? _error;

  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  final _flyerController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    _flyerController.dispose();
    super.dispose();
  }

  Future<void> _publish() async {
    final title = _titleController.text.trim();
    final message = _messageController.text.trim();
    if (title.isEmpty || message.isEmpty) {
      setState(() => _error = 'Give it a title and a message.');
      return;
    }

    final token = AppSession.of(context).token;
    if (token == null) {
      setState(() => _error = 'Sign in to publish.');
      return;
    }

    setState(() {
      _publishing = true;
      _error = null;
    });

    try {
      await const AnnouncementsApi().create(
        token: token,
        tag: MockData.composeTags[_tag],
        title: title,
        body: message,
        flyer: _flyerController.text.trim(),
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Announcement published to all branches'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _publishing = false;
        _error = e.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TpmColors.night,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 34),
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
                        'New post',
                        color: TpmColors.portalGold,
                        size: 10,
                      ),
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
            if (!_isAnnouncement) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: TpmColors.warning.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(
                    color: TpmColors.warning.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      size: 16,
                      color: TpmColors.warning,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Events aren't published from here yet — post this "
                        'as an announcement instead for now.',
                        style: TpmText.body(
                          12,
                          color: TpmColors.portalInk,
                          weight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
            TpmField(
              label: 'Title',
              hint: 'Give it a clear title',
              dark: true,
              controller: _titleController,
            ),
            const SizedBox(height: 16),
            TpmField(
              label: 'Message',
              hint: 'Write the announcement…',
              dark: true,
              maxLines: 5,
              controller: _messageController,
            ),
            const SizedBox(height: 16),
            TpmField(
              label: 'Flyer image URL (optional)',
              hint: 'A link to a hosted image',
              dark: true,
              controller: _flyerController,
            ),
            const SizedBox(height: 4),
            Text(
              'Adding a flyer also puts this post in the Home screen carousel.',
              style: TpmText.body(
                11.5,
                color: Colors.white.withValues(alpha: 0.4),
              ),
            ),
            const SizedBox(height: 16),
            const _AudienceRow(),
            if (_error != null) ...[
              const SizedBox(height: 14),
              Text(
                _error!,
                style: TpmText.body(
                  12.5,
                  color: TpmColors.danger,
                  weight: FontWeight.w600,
                ),
              ),
            ],
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
                    label: _publishing ? 'Publishing…' : 'Publish',
                    icon: Icons.send_rounded,
                    height: 50,
                    onPressed: (!_isAnnouncement || _publishing)
                        ? null
                        : _publish,
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
          const Icon(
            Icons.public_rounded,
            size: 17,
            color: TpmColors.portalGold,
          ),
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
