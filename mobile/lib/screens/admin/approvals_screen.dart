import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../models/models.dart';
import '../../theme/tpm_theme.dart';
import '../../widgets/common.dart';

/// The other end of "Request to update details" on the member's profile.
///
/// Each card shows the change as old → new so the office can approve without
/// opening the member's full record, which is what makes the queue clearable in
/// one sitting.
class ApprovalsScreen extends StatefulWidget {
  const ApprovalsScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<ApprovalsScreen> createState() => _ApprovalsScreenState();
}

class _ApprovalsScreenState extends State<ApprovalsScreen> {
  late final List<ApprovalRequest> _pending = [...MockData.approvals];

  void _resolve(ApprovalRequest request, bool approved) {
    setState(() => _pending.remove(request));
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
  }

  @override
  Widget build(BuildContext context) {
    final body = ListView(
      padding: const EdgeInsets.only(top: 20, bottom: 24),
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
        if (_pending.isEmpty)
          const _QueueClear()
        else
          for (final request in _pending)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: _ApprovalCard(
                request: request,
                onApprove: () => _resolve(request, true),
                onReject: () => _resolve(request, false),
              ),
            ),
      ],
    );

    if (widget.embedded) return body;
    return Scaffold(backgroundColor: TpmColors.night, body: SafeArea(child: body));
  }
}

class _ApprovalCard extends StatelessWidget {
  const _ApprovalCard({
    required this.request,
    required this.onApprove,
    required this.onReject,
  });

  final ApprovalRequest request;
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.name,
                      style: TpmText.body(
                        14,
                        color: TpmColors.portalInk,
                        weight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      request.branch,
                      style: TpmText.body(
                        11.2,
                        color: Colors.white.withValues(alpha: 0.45),
                      ),
                    ),
                  ],
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
                  onPressed: onApprove,
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
                  onPressed: onReject,
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
