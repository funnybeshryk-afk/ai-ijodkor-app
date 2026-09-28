import 'package:flutter/material.dart';

import '../core/theme.dart';

/// The AI Ijodkor mark (brand book: ijodkor-mark.svg — cap, book arc, tassel
/// and spark on a 40×40 grid), drawn in one of its three official colors.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 60, this.color});

  final double size;

  /// Defaults to brand-500 (the primary mark).
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _MarkPainter(color ?? context.colors.brand),
    );
  }
}

/// The mark inside its badge: radius-lg, white card fill, border — the
/// only way the logo is placed in the UI (brand book «Logotip»).
class LogoBadge extends StatelessWidget {
  const LogoBadge({super.key, this.size = 88, this.semanticLabel});

  final double size;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      label: semanticLabel,
      image: true,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: colors.surfaceCard,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: colors.border),
        ),
        alignment: Alignment.center,
        child: BrandMark(size: size * 0.68),
      ),
    );
  }
}

class _MarkPainter extends CustomPainter {
  _MarkPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 40, size.height / 40);
    final fill = Paint()..color = color;
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.1
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Cap: M20 5 34 12.5 20 20 6 12.5Z
    canvas.drawPath(
      Path()
        ..moveTo(20, 5)
        ..lineTo(34, 12.5)
        ..lineTo(20, 20)
        ..lineTo(6, 12.5)
        ..close(),
      fill,
    );
    // Book arc: M11.5 16v7c0 2.8 4 5 8.5 5s8.5-2.2 8.5-5v-7
    canvas.drawPath(
      Path()
        ..moveTo(11.5, 16)
        ..lineTo(11.5, 23)
        ..cubicTo(11.5, 25.8, 15.5, 28, 20, 28)
        ..cubicTo(24.5, 28, 28.5, 25.8, 28.5, 23)
        ..lineTo(28.5, 16),
      stroke,
    );
    // Tassel: M34 12.5v7.5 and a dot at (34, 22).
    canvas.drawLine(const Offset(34, 12.5), const Offset(34, 20), stroke);
    canvas.drawCircle(const Offset(34, 22), 1.7, fill);
    // Spark: M28 26.5l1 2.3 2.3 1-2.3 1-1 2.3-1-2.3-2.3-1 2.3-1Z
    canvas.drawPath(
      Path()
        ..moveTo(28, 26.5)
        ..lineTo(29, 28.8)
        ..lineTo(31.3, 29.8)
        ..lineTo(29, 30.8)
        ..lineTo(28, 33.1)
        ..lineTo(27, 30.8)
        ..lineTo(24.7, 29.8)
        ..lineTo(27, 28.8)
        ..close(),
      fill,
    );
  }

  @override
  bool shouldRepaint(_MarkPainter old) => old.color != color;
}
