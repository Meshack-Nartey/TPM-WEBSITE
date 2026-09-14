import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/session.dart';
import '../../data/mock_data.dart';
import '../../models/models.dart';
import '../../services/api_client.dart';
import '../../services/auth_api.dart';
import '../../services/lookups_api.dart';
import '../../theme/tpm_theme.dart';
import '../../widgets/common.dart';

/// The one screen that has to work with no signal.
///
/// Branch leaders fill this in on the way home from a service, often with
/// nothing but a bar of GPRS. So submitting never just fails outright on a
/// dropped connection: a report that can't reach the server is saved to the
/// device and queued, then this screen syncs it the next time it's opened
/// with a connection. The banner always states which of those states you're
/// in, because a silently-queued report is worse than no report at all.
class WeeklyReportScreen extends StatefulWidget {
  const WeeklyReportScreen({
    super.key,
    this.embedded = false,
    this.submitReport,
  });

  /// True when hosted by the portal shell's tab bar rather than pushed.
  final bool embedded;

  /// Overrides the real `POST /api/reports` call — tests use this to
  /// exercise the queue-on-failure and sync-on-reopen paths deterministically,
  /// without a live server.
  final Future<void> Function(String token, Map<String, dynamic> body)?
  submitReport;

  @override
  State<WeeklyReportScreen> createState() => _WeeklyReportScreenState();
}

class _WeeklyReportScreenState extends State<WeeklyReportScreen> {
  static const _queueKey = 'pending_reports';

  bool _loaded = false;
  SyncStatus _status = SyncStatus.idle;
  int _meetingType = 0;
  String? _error;
  bool _attendanceError = false;
  int _queuedCount = 0;

  /// Starts as the seed-matching fallback so the picker works even if the
  /// leader is offline when this screen opens — see the class doc.
  List<String> _meetingTypes = MockData.meetingTypes;

  final _attendanceController = TextEditingController();
  final _titheController = TextEditingController();
  final _soulsController = TextEditingController();
  final _visitorsController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      _trySyncQueue();
      _loadMeetingTypes();
    }
  }

  Future<void> _loadMeetingTypes() async {
    try {
      final grouped = await const PublicLookups().fetch();
      final types = grouped['meetingTypes'];
      if (!mounted || types == null || types.isEmpty) return;
      setState(() {
        _meetingTypes = types;
        if (_meetingType >= types.length) _meetingType = 0;
      });
    } on ApiException {
      // Keep the fallback list — this screen has to work offline.
    }
  }

  @override
  void dispose() {
    _attendanceController.dispose();
    _titheController.dispose();
    _soulsController.dispose();
    _visitorsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> _readQueue() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_queueKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list.cast<Map<String, dynamic>>();
  }

  Future<void> _writeQueue(List<Map<String, dynamic>> queue) async {
    final prefs = await SharedPreferences.getInstance();
    if (queue.isEmpty) {
      await prefs.remove(_queueKey);
    } else {
      await prefs.setString(_queueKey, jsonEncode(queue));
    }
  }

  /// Runs on open: drains whatever's queued from a previous offline
  /// submission. Reports that fail for a real reason (not just "no signal")
  /// are dropped rather than retried forever.
  Future<void> _trySyncQueue() async {
    final token = AppSession.of(context).token;
    if (token == null) return;

    final queue = await _readQueue();
    if (queue.isEmpty) return;

    final submit =
        widget.submitReport ??
        (t, b) async {
          await ApiClient(token: t).post('/api/reports', b);
        };

    setState(() => _status = SyncStatus.syncing);
    final remaining = <Map<String, dynamic>>[];
    for (final body in queue) {
      try {
        await submit(token, body);
      } on ApiException catch (e) {
        if (e.isNetworkError) remaining.add(body);
      }
    }
    await _writeQueue(remaining);
    if (!mounted) return;
    setState(() {
      _queuedCount = remaining.length;
      _status = remaining.isEmpty ? SyncStatus.synced : SyncStatus.queued;
    });
  }

  Map<String, dynamic> _buildBody(String branch) {
    int parseInt(TextEditingController c) => int.tryParse(c.text.trim()) ?? 0;
    double parseDouble(TextEditingController c) =>
        double.tryParse(c.text.trim()) ?? 0;

    final visitors = _visitorsController.text.trim();
    final notes = _notesController.text.trim();
    final combinedNotes = visitors.isEmpty
        ? notes
        : [
            if (notes.isNotEmpty) notes,
            'First-time visitors: $visitors',
          ].join('\n');

    return {
      'meetingType': _meetingTypes[_meetingType],
      'branch': branch,
      'date': DateTime.now().toIso8601String().substring(0, 10),
      // The form collects one combined headcount rather than a gender
      // split, so the total goes in the male bucket rather than guessing a
      // split — every screen that reads this back sums both buckets anyway.
      'attMale': parseInt(_attendanceController),
      'attFemale': 0,
      'tithe': parseDouble(_titheController),
      'soulsMale': parseInt(_soulsController),
      'soulsFemale': 0,
      'notes': combinedNotes,
    };
  }

  void _clearFields() {
    _attendanceController.clear();
    _titheController.clear();
    _soulsController.clear();
    _visitorsController.clear();
    _notesController.clear();
  }

  Future<void> _submit() async {
    final attendance = int.tryParse(_attendanceController.text.trim());
    if (attendance == null || attendance < 0) {
      setState(() {
        _attendanceError = true;
        _error = 'Enter total attendance.';
      });
      return;
    }

    final session = AppSession.of(context);
    final token = session.token;
    if (token == null) {
      setState(() => _error = 'Sign in as a leader to submit a report.');
      return;
    }

    final body = _buildBody(session.user?.branch ?? '');
    setState(() {
      _status = SyncStatus.syncing;
      _attendanceError = false;
      _error = null;
    });

    try {
      final submit =
          widget.submitReport ??
          (t, b) async {
            await ApiClient(token: t).post('/api/reports', b);
          };
      await submit(token, body);
      if (!mounted) return;
      setState(() {
        _status = SyncStatus.synced;
        _clearFields();
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      if (e.isNetworkError) {
        final queue = await _readQueue();
        queue.add(body);
        await _writeQueue(queue);
        if (!mounted) return;
        setState(() {
          _status = SyncStatus.queued;
          _queuedCount = queue.length;
          _clearFields();
        });
      } else {
        setState(() {
          _status = SyncStatus.idle;
          _error = e.message;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final branch = AppSession.of(context).user?.branch;

    final body = ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
      children: [
        Row(
          children: [
            if (!widget.embedded) ...[
              CircleBackButton(
                dark: true,
                onTap: () => Navigator.of(context).pop(),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Eyebrow(
                    (branch == null || branch.isEmpty)
                        ? 'Weekly report'
                        : branch,
                    color: TpmColors.portalGold,
                    size: 10,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Weekly Report',
                    style: TpmText.display(24, color: TpmColors.portalInk),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _SyncBanner(status: _status, queuedCount: _queuedCount),
        const SizedBox(height: 16),
        Text(
          'MEETING TYPE',
          style: TpmText.eyebrow(
            color: Colors.white.withValues(alpha: 0.5),
            size: 10,
            tracking: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _meetingTypes.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, i) => ChoiceChipPill(
              label: _meetingTypes[i],
              selected: i == _meetingType,
              dark: true,
              onTap: () => setState(() => _meetingType = i),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TpmField(
          label: 'Total attendance',
          hint: 'e.g. 238',
          icon: Icons.groups_rounded,
          dark: true,
          controller: _attendanceController,
          error: _attendanceError,
        ),
        const SizedBox(height: 14),
        TpmField(
          label: 'Tithe collected (GHS)',
          hint: 'e.g. 18400',
          icon: Icons.savings_rounded,
          dark: true,
          controller: _titheController,
        ),
        const SizedBox(height: 14),
        TpmField(
          label: 'Souls won',
          hint: 'e.g. 12',
          icon: Icons.volunteer_activism_rounded,
          dark: true,
          controller: _soulsController,
        ),
        const SizedBox(height: 14),
        TpmField(
          label: 'First-time visitors',
          hint: 'e.g. 9',
          icon: Icons.person_add_rounded,
          dark: true,
          controller: _visitorsController,
        ),
        const SizedBox(height: 14),
        TpmField(
          label: 'Notes',
          hint: 'Highlights, testimonies, needs…',
          dark: true,
          maxLines: 4,
          controller: _notesController,
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
        const SizedBox(height: 20),
        TpmButton.gold(
          label: switch (_status) {
            SyncStatus.synced => 'Submitted',
            SyncStatus.syncing => 'Submitting…',
            _ => 'Submit report',
          },
          icon: switch (_status) {
            SyncStatus.synced => Icons.check_circle_rounded,
            SyncStatus.syncing => Icons.sync_rounded,
            _ => Icons.send_rounded,
          },
          onPressed: _status == SyncStatus.syncing ? null : _submit,
        ),
      ],
    );

    if (widget.embedded) return body;
    return Scaffold(
      backgroundColor: TpmColors.night,
      body: SafeArea(child: body),
    );
  }
}

class _SyncBanner extends StatelessWidget {
  const _SyncBanner({required this.status, required this.queuedCount});

  final SyncStatus status;
  final int queuedCount;

  @override
  Widget build(BuildContext context) {
    final (title, note, icon, color) = switch (status) {
      SyncStatus.idle => (
        'Ready to submit',
        '',
        Icons.cloud_rounded,
        TpmColors.success,
      ),
      SyncStatus.queued => (
        queuedCount > 1
            ? '$queuedCount reports queued — will sync when back online'
            : 'Queued — will sync when back online',
        'saved on device',
        Icons.schedule_rounded,
        TpmColors.warning,
      ),
      SyncStatus.syncing => (
        'Syncing to the office…',
        'sending',
        Icons.sync_rounded,
        TpmColors.portalGold,
      ),
      SyncStatus.synced => (
        'Synced — report received',
        'just now',
        Icons.check_circle_rounded,
        TpmColors.success,
      ),
    };

    final neutral = status == SyncStatus.idle;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: neutral
            ? Colors.white.withValues(alpha: 0.03)
            : color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: neutral
              ? Colors.white.withValues(alpha: 0.08)
              : color.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: TpmText.body(
                12.5,
                color: TpmColors.portalInk,
                weight: FontWeight.w600,
              ),
            ),
          ),
          if (note.isNotEmpty)
            Text(
              note,
              style: TpmText.body(
                10.5,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
        ],
      ),
    );
  }
}
