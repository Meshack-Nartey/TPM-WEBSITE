import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../models/models.dart';
import '../../theme/tpm_theme.dart';
import '../../widgets/common.dart';

/// Where to find us. Directions, phone, email and WhatsApp are all one tap from
/// the branch card — WhatsApp especially, since that is how most branches
/// actually field questions.
class BranchesScreen extends StatelessWidget {
  const BranchesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TpmColors.canvas,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(top: 12, bottom: 24),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: ScreenTitle(
                eyebrow: 'Find us',
                title: 'Branches',
                titleSize: 24,
                onBack: () => Navigator.of(context).pop(),
              ),
            ),
            const SizedBox(height: 14),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 22),
              child: _MapPreview(),
            ),
            const SizedBox(height: 16),
            for (final branch in MockData.branches)
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 12),
                child: _BranchCard(branch: branch),
              ),
          ],
        ),
      ),
    );
  }
}

/// A stand-in for the real map. Deliberately styled as a preview rather than a
/// fake map, so nobody mistakes it for live tiles.
class _MapPreview extends StatelessWidget {
  const _MapPreview();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        height: 150,
        child: Stack(
          fit: StackFit.expand,
          children: [
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [TpmColors.tintBlue, Color(0xFFEFF6FF)],
                ),
              ),
            ),
            CustomPaint(painter: _GridPainter()),
            const Align(
              alignment: Alignment(-0.3, -0.2),
              child: Icon(Icons.map_rounded, color: TpmColors.navy, size: 26),
            ),
            const Align(
              alignment: Alignment(0.25, 0.15),
              child: Icon(Icons.location_on_rounded, color: TpmColors.gold, size: 26),
            ),
            Positioned(
              right: 12,
              bottom: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('Map preview', style: TpmText.body(10.5)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = TpmColors.navy.withValues(alpha: 0.08)
      ..strokeWidth = 1;
    const step = 26.0;
    for (var x = 0.0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = 0.0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BranchCard extends StatelessWidget {
  const _BranchCard({required this.branch});

  final Branch branch;

  @override
  Widget build(BuildContext context) {
    return TpmCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (branch.photo != null) ...[
                ClipOval(
                  child: Image.asset(
                    branch.photo!,
                    width: 36,
                    height: 36,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(child: Text(branch.name, style: TpmText.display(17))),
              const SizedBox(width: 8),
              Pill(
                branch.region,
                foreground: TpmColors.navy,
                background: TpmColors.tintIndigo,
                uppercase: false,
                fontSize: 10,
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 13, color: TpmColors.faint),
              const SizedBox(width: 4),
              Expanded(child: Text(branch.address, style: TpmText.body(12.2))),
            ],
          ),
          const SizedBox(height: 13),
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  label: 'Directions',
                  icon: Icons.directions_rounded,
                  background: TpmColors.navy,
                  foreground: Colors.white,
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 8),
              _IconAction(icon: Icons.phone_rounded, onTap: () {}),
              const SizedBox(width: 8),
              _IconAction(icon: Icons.email_rounded, onTap: () {}),
              const SizedBox(width: 8),
              _IconAction(
                icon: Icons.chat_rounded,
                foreground: TpmColors.green,
                background: const Color(0xFFF0FDF4),
                borderColor: TpmColors.tintGreen,
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.background,
    required this.foreground,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(11),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: foreground),
              const SizedBox(width: 6),
              Text(
                label,
                style: TpmText.body(11.5, color: foreground, weight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  const _IconAction({
    required this.icon,
    required this.onTap,
    this.foreground = TpmColors.navy,
    this.background = TpmColors.surface,
    this.borderColor = TpmColors.hairline,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color foreground;
  final Color background;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(11),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: borderColor),
          ),
          child: Icon(icon, size: 16, color: foreground),
        ),
      ),
    );
  }
}
