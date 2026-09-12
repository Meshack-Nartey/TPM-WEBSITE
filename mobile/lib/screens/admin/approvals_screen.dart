import 'package:flutter/material.dart';

import '../../app/session.dart';
import '../../models/models.dart';
import '../../services/auth_api.dart';
import '../../services/profile_requests_api.dart';
import '../../theme/tpm_theme.dart';
import '../../widgets/common.dart';

/// The other end of "Request to update details" on the member's profile.
///
/// Each card shows the change as old → new so the office can approve without
/// opening the member's full record, which is what makes the queue clearable
/// in one sitting. Approving actually writes the change to the member's
/// profile server-side — this isn't just a status flag.
class ApprovalsScreen extends StatefulWidget {
  const ApprovalsScreen({
    super.key,
    this.embedded = false,
    this.fetchPending,
    this.decide,
  });

  final bool embedded;

  /// Overrides the real API calls — tests use these to exercise the
  /// queue/resolve behaviour without a live server.
  final Future<List<ApprovalRequest>> Function(String token)? fetchPending;
  final Future<void> Function(String token, String id, bool approve)? decide;

  @override
  State<ApprovalsScreen> createState() => _ApprovalsScreenState();
}

class _ApprovalsScreenState extends State<ApprovalsScreen> {
  bool _loaded = false;
  bool _loading = true;
  String? _error;
  List<ApprovalRequest> _pending = const [];

  /// Cards mid-flight to approve/reject — kept separate from removing them
  /// outright so a failure can put the card back instead of losing it.
  final Set<String> _resolving = {};

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
    if (token == null) {
      setState(() => _loading = false);
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final fetch =
          widget.fetchPending ??
          (t) => ProfileRequestsApi(token: t).fetchPending();
      final pending = await fetch(token);
      if (!mounted) return;
      setState(() {
        _pending = pending;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    }
  }

  Future<void> _resolve(ApprovalRequest request, bool approved) async {
    final token = AppSession.of(context).token;
    if (token == null) return;

    setState(() => _resolving.add(request.id));
    try {
      final decide =
          widget.decide ??
          (t, id, approve) =>
              ProfileRequestsApi(token: t).decide(id, approve: approve);
      await decide(token, request.id, approved);
      if (!mounted) return;
      setState(() {
        _pending = _pending.where((r) => r.id != request.id).toList();
        _resolving.remove(request.id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            approved
                ? '${request.field} change approved for ${request.name}'
                : '${request.field} change rejected for ${request.name}',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _resolving.remove(request.id));
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final body = RefreshIndicator(
      color: TpmColors.portalGold,
      backgroundColor: TpmColors.nightRaised,
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 20, bottom: 110),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Eyebrow(
                  'Pending · ${_pending.length}',
                  color: TpmColors.portalGold,
                  size: 10,
                ),
                const SizedBox(height: 3),
                Text(
                  'Approvals',
                  style: TpmText.display(24, color: TpmColors.portalInk),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: CircularProgressIndicator(color: TpmColors.portalGold),
              ),
            )
          else if (_error != null)
            _LoadError(message: _error!, onRetry: _load)
          else if (_pending.isEmpty)
            const _QueueClear()
          else
            for (final request in _pending)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: _ApprovalCard(
                  request: request,
                  busy: _resolving.contains(request.id),
                  onApprove: () => _resolve(request, true),
                  onReject: () => _resolve(request, false),
                ),
              ),
        ],
      ),
    );

    if (widget.embedded) return body;
    return Scaffold(
      backgroundColor: TpmColors.night,
      body: SafeArea(child: body),
    );
  }
}

class _ApprovalCard extends StatelessWidget {
  const _ApprovalCard({
    required this.request,
    required this.busy,
    required this.onApprove,
    required this.onReject,
  });

  final ApprovalRequest request;
  final bool busy;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    return PortalCard(
      radius: 16,
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              InitialsAvatar(
                initials: request.initials,
                color: request.avatarColor,
                size: 38,
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  request.name,
                  style: TpmText.body(
                    14,
                    color: TpmColors.portalInk,
                    weight: FontWeight.w600,
                  ),
                ),
              ),
              Pill(
                request.field,
                foreground: TpmColors.portalGold,
                background: TpmColors.portalGold.withValues(alpha: 0.12),
                uppercase: false,
                fontSize: 9.5,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
            decoration: BoxDecoration(
              color: TpmColors.nightRaised,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  request.oldValue,
                  style: TpmText.body(
                    12.5,
                    color: Colors.white.withValues(alpha: 0.4),
                  ).copyWith(decoration: TextDecoration.lineThrough),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    size: 12,
                    color: TpmColors.portalGold,
                  ),
                ),
                Text(
                  request.newValue,
                  style: TpmText.body(
                    12.5,
                    color: TpmColors.portalInk,
                    weight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TpmButton.gold(
                  label: 'Approve',
                  icon: Icons.check_rounded,
                  height: 44,
                  fontSize: 12.5,
                  radius: 11,
                  onPressed: busy ? null : onApprove,
                ),
              ),
              const SizedBox(width: 9),
              SizedBox(
                width: 92,
                child: TpmOutlineButton(
                  label: 'Reject',
                  height: 44,
                  radius: 11,
                  foreground: Colors.white.withValues(alpha: 0.7),
                  background: Colors.transparent,
                  borderColor: Colors.white.withValues(alpha: 0.15),
                  onPressed: busy ? null : onReject,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QueueClear extends StatelessWidget {
  const _QueueClear();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: PortalCard(
        padding: const EdgeInsets.symmetric(vertical: 34, horizontal: 20),
        child: Column(
          children: [
            IconTile(
              icon: Icons.check_circle_rounded,
              background: TpmColors.success.withValues(alpha: 0.12),
              foreground: TpmColors.success,
              size: 54,
              radius: 16,
              iconSize: 26,
            ),
            const SizedBox(height: 14),
            Text(
              'Nothing waiting',
              style: TpmText.body(
                14.5,
                color: TpmColors.portalInk,
                weight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Every profile change has been reviewed.',
              textAlign: TextAlign.center,
              style: TpmText.body(
                12.5,
                color: Colors.white.withValues(alpha: 0.45),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: PortalCard(
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
        child: Column(
          children: [
            IconTile(
              icon: Icons.wifi_off_rounded,
              background: TpmColors.portalGold.withValues(alpha: 0.1),
              foreground: TpmColors.portalGold,
              size: 54,
              radius: 16,
              iconSize: 24,
            ),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TpmText.body(
                13,
                color: TpmColors.portalInk,
                weight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 14),
            TpmOutlineButton(
              label: 'Retry',
              icon: Icons.refresh_rounded,
              foreground: TpmColors.portalInk,
              background: Colors.white.withValues(alpha: 0.06),
              borderColor: Colors.white.withValues(alpha: 0.15),
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
