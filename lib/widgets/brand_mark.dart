import 'package:flutter/material.dart';

import '../core/theme.dart';

/// The Izlan mark (izlan-logo/mark.svg — a compass ring with a two-tone needle
/// on a 48×48 grid). The north needle is always amber; the ring and the south
/// needle take [color] (defaults to the ink color so it reads in both themes).
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 60, this.color});

  final double size;

  /// Ring and south needle; defaults to the text color.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _MarkPainter(
        color ?? context.colors.ink,
        context.colors.brand,
        context.colors.surfaceCard,
      ),
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
  _MarkPainter(this.color, this.accent, this.hub);

  final Color color;
  final Color accent;
  final Color hub;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 48, size.height / 48);
    final ring = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6;
    canvas.drawCircle(const Offset(24, 24), 18, ring);
    canvas.drawPath(
      Path()
        ..moveTo(24, 9)
        ..lineTo(28.2, 24)
        ..lineTo(19.8, 24)
        ..close(),
      Paint()..color = accent,
    );
    canvas.drawPath(
      Path()
        ..moveTo(24, 39)
        ..lineTo(19.8, 24)
        ..lineTo(28.2, 24)
        ..close(),
      Paint()..color = color,
    );
    canvas.drawCircle(const Offset(24, 24), 2.3, Paint()..color = hub);
    canvas.drawCircle(
      const Offset(24, 24),
      2.3,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1,
    );
  }

  @override
  bool shouldRepaint(_MarkPainter old) =>
      old.color != color || old.accent != accent || old.hub != hub;
}
