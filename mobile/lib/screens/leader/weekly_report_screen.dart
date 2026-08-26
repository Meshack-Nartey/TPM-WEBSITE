import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../models/models.dart';
import '../../theme/tpm_theme.dart';
import '../../widgets/common.dart';

/// The one screen that has to work with no signal.
///
/// Branch leaders fill this in on the way home from a service, often with
/// nothing but a bar of GPRS. So the form never blocks on the network: submit
/// while offline and the report is saved to the device and queued, then syncs
/// itself the moment the connection returns. The banner always states which of
/// those four states you are in, because a silently-queued report is worse than
/// no report at all.
class WeeklyReportScreen extends StatefulWidget {
  const WeeklyReportScreen({super.key, this.embedded = false});

  /// True when hosted by the portal shell's tab bar rather than pushed.
  final bool embedded;

  @override
  State<WeeklyReportScreen> createState() => _WeeklyReportScreenState();
}

class _WeeklyReportScreenState extends State<WeeklyReportScreen> {
  bool _offline = false;
  SyncStatus _status = SyncStatus.idle;

  void _toggleConnection() {
    final wasOffline = _offline;
    setState(() => _offline = !_offline);

    // Coming back online is what drains the queue.
    if (wasOffline && _status == SyncStatus.queued) {
      _startSync();
    }
  }

  void _submit() {
    if (_offline) {
      setState(() => _status = SyncStatus.queued);
    } else {
      _startSync();
    }
  }

  void _startSync() {
    setState(() => _status = SyncStatus.syncing);
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) setState(() => _status = SyncStatus.synced);
    });
  }

  @override
  Widget build(BuildContext context) {
    final body = ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
      children: [
        Row(
          children: [
            if (!widget.embedded) ...[
              CircleBackButton(dark: true, onTap: () => Navigator.of(context).pop()),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Eyebrow('Kumasi Central', color: TpmColors.portalGold, size: 10),
                  const SizedBox(height: 3),
                  Text(
                    'Weekly Report',
                    style: TpmText.display(24, color: TpmColors.portalInk),
                  ),
                ],
              ),
            ),
            _ConnectionToggle(offline: _offline, onTap: _toggleConnection),
          ],
        ),
        const SizedBox(height: 16),
        _SyncBanner(status: _status, offline: _offline),
        const SizedBox(height: 16),
        for (final field in MockData.reportFields) ...[
          TpmField(
            label: field.label,
            hint: field.hint,
            icon: field.icon,
            dark: true,
          ),
          const SizedBox(height: 14),
        ],
        const TpmField(
          label: 'Notes',
          hint: 'Highlights, testimonies, needs…',
          dark: true,
          maxLines: 4,
        ),
        const SizedBox(height: 20),
        TpmButton.gold(
          label: switch (_status) {
            SyncStatus.synced => 'Submitted',
            _ => _offline ? 'Save & queue report' : 'Submit report',
          },
          icon: switch (_status) {
            SyncStatus.synced => Icons.check_circle_rounded,
            _ => _offline ? Icons.schedule_rounded : Icons.send_rounded,
          },
          onPressed: _status == SyncStatus.syncing ? null : _submit,
        ),
      ],
    );

    if (widget.embedded) return body;
    return Scaffold(backgroundColor: TpmColors.night, body: SafeArea(child: body));
  }
}

class _ConnectionToggle extends StatelessWidget {
  const _ConnectionToggle({required this.offline, required this.onTap});

  final bool offline;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = offline ? TpmColors.warning : TpmColors.success;
    return GestureDetector(
      onTap: onTap,
      child: Pill(
        offline ? 'Offline' : 'Online',
        icon: offline ? Icons.airplanemode_active_rounded : Icons.wifi_rounded,
        foreground: fg,
        background: fg.withValues(alpha: 0.1),
        borderColor: fg.withValues(alpha: 0.3),
        uppercase: false,
        fontSize: 10.5,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      ),
    );
  }
}

class _SyncBanner extends StatelessWidget {
  const _SyncBanner({required this.status, required this.offline});

  final SyncStatus status;
  final bool offline;

  @override
  Widget build(BuildContext context) {
    final (title, note, icon, color) = switch (status) {
      SyncStatus.idle => (
          offline ? 'Offline — you can still fill this in' : 'Online — ready to submit',
          '',
          offline ? Icons.cloud_off_rounded : Icons.cloud_rounded,
          offline ? TpmColors.warning : TpmColors.success,
        ),
      SyncStatus.queued => (
          'Queued — will sync when back online',
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
              style: TpmText.body(10.5, color: Colors.white.withValues(alpha: 0.5)),
            ),
        ],
      ),
    );
  }
}
