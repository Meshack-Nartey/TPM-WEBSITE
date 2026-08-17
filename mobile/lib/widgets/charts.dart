import 'package:flutter/material.dart';

import '../theme/tpm_theme.dart';

/// Charts for the leader and administrator dashboards.
///
/// All four are single-series magnitude charts on the portal's near-black
/// surface, so none carries a legend — the card title names the series. Gold is
/// the only data colour; grid and axis furniture stay recessive, and values are
/// labelled selectively (the latest point, the peak) rather than on every mark.

/// Eight-week attendance. Area fill under a 2.5px gold line, with the most
/// recent point marked and directly labelled.
class AttendanceLineChart extends StatelessWidget {
  const AttendanceLineChart({
    super.key,
    required this.values,
    this.height = 110,
  });

  final List<int> values;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _LinePainter(
          values: values.map((v) => v.toDouble()).toList(),
          label: values.isEmpty ? '' : '${values.last}',
          labelStyle: TpmText.body(11, color: TpmColors.portalGold, weight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _LinePainter extends CustomPainter {
  _LinePainter({required this.values, required this.label, required this.labelStyle});

  final List<double> values;
  final String label;
  final TextStyle labelStyle;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;

    // Leave room on the right for the trailing value label.
    const labelGutter = 34.0;
    const topPad = 10.0;
    final plotWidth = size.width - labelGutter;
    final plotHeight = size.height - topPad;

    // Pad the range so the line never touches the top or bottom edge.
    final maxV = values.reduce((a, b) => a > b ? a : b);
    final minV = values.reduce((a, b) => a < b ? a : b);
    final span = (maxV - minV).abs() < 1 ? 1.0 : (maxV - minV);
    final lo = minV - span * 0.35;
    final hi = maxV + span * 0.2;

    double xFor(int i) => plotWidth * i / (values.length - 1);
    double yFor(double v) => topPad + plotHeight * (1 - (v - lo) / (hi - lo));

    // Recessive gridlines.
    final grid = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 1;
    for (var i = 1; i <= 3; i++) {
      final y = topPad + plotHeight * i / 4;
      canvas.drawLine(Offset(0, y), Offset(plotWidth, y), grid);
    }

    final points = [
      for (var i = 0; i < values.length; i++) Offset(xFor(i), yFor(values[i])),
    ];

    // Area fill, fading out toward the baseline.
    final area = Path()..moveTo(points.first.dx, points.first.dy);
    for (final p in points.skip(1)) {
      area.lineTo(p.dx, p.dy);
    }
    area
      ..lineTo(points.last.dx, size.height)
      ..lineTo(points.first.dx, size.height)
      ..close();

    canvas.drawPath(
      area,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            TpmColors.portalGold.withValues(alpha: 0.35),
            TpmColors.portalGold.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromLTWH(0, 0, plotWidth, size.height)),
    );

    // The line itself.
    final line = Path()..moveTo(points.first.dx, points.first.dy);
    for (final p in points.skip(1)) {
      line.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(
      line,
      Paint()
        ..color = TpmColors.portalGold
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Latest point: 8px marker with a 2px surface ring so it reads over the line.
    final last = points.last;
    canvas.drawCircle(last, 6, Paint()..color = TpmColors.nightSurface);
    canvas.drawCircle(last, 4, Paint()..color = TpmColors.portalGold);

    // Direct label for the latest value only.
    final tp = TextPainter(
      text: TextSpan(text: label, style: labelStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(last.dx + 9, last.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _LinePainter old) =>
      old.values != values || old.label != label;
}

/// Six weeks of tithe. Bars anchored to the baseline with 4px rounded ends and
/// a surface gap between them; the peak week carries a value label.
class TitheBarChart extends StatelessWidget {
  const TitheBarChart({
    super.key,
    required this.values,
    required this.labels,
    required this.axisMax,
    this.height = 96,
  });

  final List<double> values;
  final List<String> labels;
  final double axisMax;
  final double height;

  @override
  Widget build(BuildContext context) {
    final peak = values.isEmpty ? 0.0 : values.reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < values.length; i++) ...[
            if (i > 0) const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (values[i] == peak)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        values[i].toStringAsFixed(1),
                        style: TpmText.body(
                          9.5,
                          color: TpmColors.portalGold,
                          weight: FontWeight.w700,
                        ),
                      ),
                    ),
                  Flexible(
                    child: FractionallySizedBox(
                      heightFactor: (values[i] / axisMax).clamp(0.02, 1.0),
                      child: Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [TpmColors.portalGold, TpmColors.portalGoldDeep],
                          ),
                          borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    labels[i],
                    style: TpmText.body(9.5, color: Colors.white.withValues(alpha: 0.4)),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Ranked branches by attendance — horizontal magnitude bars, value at the end.
class BranchRankBar extends StatelessWidget {
  const BranchRankBar({
    super.key,
    required this.name,
    required this.value,
    required this.fraction,
  });

  final String name;
  final int value;
  final double fraction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            name,
            style: TpmText.body(14, color: TpmColors.portalInk, weight: FontWeight.w600),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 78,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: fraction.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: Colors.white.withValues(alpha: 0.06),
              valueColor: const AlwaysStoppedAnimation(TpmColors.portalGold),
            ),
          ),
        ),
        SizedBox(
          width: 46,
          child: Text(
            '$value',
            textAlign: TextAlign.right,
            style: TpmText.body(13, color: TpmColors.portalGold, weight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

/// One member's last six weeks. This is a status encoding, not a magnitude one,
/// so every bar carries a check or cross icon — never colour alone.
class AttendanceStrip extends StatelessWidget {
  const AttendanceStrip({super.key, required this.weeks, this.height = 80});

  final List<bool> weeks;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < weeks.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Flexible(
                    child: FractionallySizedBox(
                      heightFactor: weeks[i] ? 1.0 : 0.18,
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: weeks[i]
                              ? const LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    TpmColors.portalGold,
                                    TpmColors.portalGoldDeep,
                                  ],
                                )
                              : null,
                          color: weeks[i] ? null : Colors.white.withValues(alpha: 0.1),
                          borderRadius:
                              const BorderRadius.vertical(top: Radius.circular(4)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Icon(
                    weeks[i] ? Icons.check_rounded : Icons.close_rounded,
                    size: 11,
                    color: weeks[i]
                        ? TpmColors.success
                        : Colors.white.withValues(alpha: 0.3),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
