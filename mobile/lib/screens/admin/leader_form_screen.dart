import 'package:flutter/material.dart';

import '../../app/session.dart';
import '../../models/models.dart';
import '../../services/auth_api.dart';
import '../../services/leaders_api.dart';
import '../../theme/tpm_theme.dart';
import '../../widgets/common.dart';

/// Add or edit one entry in the leadership directory. Pops `true` when a
/// save/delete actually changed something, so the list screen knows to
/// refetch rather than reload on every back-navigation.
class LeaderFormScreen extends StatefulWidget {
  const LeaderFormScreen({super.key, this.leader});

  /// Null when adding a new leader.
  final ChurchLeader? leader;

  @override
  State<LeaderFormScreen> createState() => _LeaderFormScreenState();
}

class _LeaderFormScreenState extends State<LeaderFormScreen> {
  late final _name = TextEditingController(text: widget.leader?.name ?? '');
  late final _title = TextEditingController(text: widget.leader?.title ?? '');
  late final _branch = TextEditingController(text: widget.leader?.branch ?? '');
  late final _fellowship = TextEditingController(
    text: widget.leader?.fellowship ?? '',
  );
  late final _quote = TextEditingController(text: widget.leader?.quote ?? '');
  late final _bio = TextEditingController(text: widget.leader?.bio ?? '');
  late final _photo = TextEditingController(text: widget.leader?.photo ?? '');
  late final _email = TextEditingController(text: widget.leader?.email ?? '');
  late final _phone = TextEditingController(text: widget.leader?.phone ?? '');

  bool _saving = false;
  bool _deleting = false;
  String? _error;

  bool get _editing => widget.leader != null;

  @override
  void dispose() {
    _name.dispose();
    _title.dispose();
    _branch.dispose();
    _fellowship.dispose();
    _quote.dispose();
    _bio.dispose();
    _photo.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Give this leader a name.');
      return;
    }
    final token = AppSession.of(context).token;
    if (token == null) {
      setState(() => _error = 'Sign in to save.');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    final fields = {
      'name': name,
      'title': _title.text.trim(),
      'branch': _branch.text.trim(),
      'fellowship': _fellowship.text.trim(),
      'quote': _quote.text.trim(),
      'bio': _bio.text.trim(),
      'photo': _photo.text.trim(),
      'email': _email.text.trim(),
      'phone': _phone.text.trim(),
    };

    try {
      final api = LeadersApi(token: token);
      if (_editing) {
        await api.update(widget.leader!.id, fields);
      } else {
        await api.create(fields);
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_editing ? 'Leader updated' : 'Leader added'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = e.message;
      });
    }
  }

  Future<void> _delete() async {
    final token = AppSession.of(context).token;
    if (token == null || widget.leader == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: TpmColors.nightRaised,
        title: Text(
          'Remove ${widget.leader!.name}?',
          style: TpmText.body(
            15,
            color: TpmColors.portalInk,
            weight: FontWeight.w700,
          ),
        ),
        content: Text(
          "They'll no longer appear in the directory. This can't be undone.",
          style: TpmText.body(13, color: Colors.white.withValues(alpha: 0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: TpmText.body(
                13.5,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Remove',
              style: TpmText.body(
                13.5,
                color: TpmColors.danger,
                weight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _deleting = true);
    try {
      await LeadersApi(token: token).delete(widget.leader!.id);
      if (!mounted) return;
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Leader removed'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _deleting = false;
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
                      Eyebrow(
                        _editing ? 'Edit leader' : 'New leader',
                        color: TpmColors.portalGold,
                        size: 10,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _editing ? widget.leader!.name : 'Add a leader',
                        style: TpmText.display(22, color: TpmColors.portalInk),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TpmField(
              label: 'Name',
              hint: 'Full name',
              dark: true,
              controller: _name,
            ),
            const SizedBox(height: 14),
            TpmField(
              label: 'Title',
              hint: 'e.g. Branch Pastor',
              dark: true,
              controller: _title,
            ),
            const SizedBox(height: 14),
            TpmField(
              label: 'Branch',
              hint: 'e.g. DAYSPRING',
              dark: true,
              controller: _branch,
            ),
            const SizedBox(height: 14),
            TpmField(
              label: 'Fellowship',
              hint: 'Optional',
              dark: true,
              controller: _fellowship,
            ),
            const SizedBox(height: 14),
            TpmField(
              label: 'Quote',
              hint: 'A short quote for their profile',
              dark: true,
              controller: _quote,
            ),
            const SizedBox(height: 14),
            TpmField(
              label: 'Bio',
              hint: 'A short biography',
              dark: true,
              maxLines: 4,
              controller: _bio,
            ),
            const SizedBox(height: 14),
            TpmField(
              label: 'Photo URL',
              hint: 'https://…',
              dark: true,
              controller: _photo,
            ),
            const SizedBox(height: 14),
            TpmField(
              label: 'Email',
              hint: 'Optional',
              dark: true,
              controller: _email,
            ),
            const SizedBox(height: 14),
            TpmField(
              label: 'Phone',
              hint: 'Optional',
              dark: true,
              controller: _phone,
            ),
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
            TpmButton.gold(
              label: _saving
                  ? 'Saving…'
                  : (_editing ? 'Save changes' : 'Add leader'),
              icon: Icons.check_rounded,
              height: 50,
              onPressed: (_saving || _deleting) ? null : _save,
            ),
            if (_editing) ...[
              const SizedBox(height: 10),
              TpmOutlineButton(
                label: _deleting ? 'Removing…' : 'Remove from directory',
                icon: Icons.delete_outline_rounded,
                foreground: TpmColors.danger,
                background: TpmColors.danger.withValues(alpha: 0.08),
                borderColor: TpmColors.danger.withValues(alpha: 0.25),
                onPressed: (_saving || _deleting) ? null : _delete,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
