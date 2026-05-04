import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// Paprika brand mark — outlined paprika silhouette with stem dot.
///
/// Mirrors design-system.jsx PaprikaMark.
/// tile=true: white stroke on coral tile (app icon style).
/// tile=false: mark drawn on transparent background in brand coral.
class PaprikaMark extends StatelessWidget {
  const PaprikaMark({
    super.key,
    this.size = 36,
    this.tile = true,
    this.foreground,
    this.background,
  });

  final double size;
  final bool tile;
  final Color? foreground;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    final strokeColor = tile
        ? (foreground ?? Colors.white)
        : (foreground ?? AppTokens.accent);
    final renderSize = tile ? size * 0.72 : size;
    final radius = (size * 0.28).roundToDouble();

    final mark = SizedBox(
      width: renderSize,
      height: renderSize,
      child: CustomPaint(
        painter: _PaprikaMarkPainter(strokeColor: strokeColor),
      ),
    );

    if (!tile) return mark;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background ?? AppTokens.accent,
        borderRadius: BorderRadius.circular(radius),
      ),
      alignment: Alignment.center,
      child: mark,
    );
  }
}

class _PaprikaMarkPainter extends CustomPainter {
  const _PaprikaMarkPainter({required this.strokeColor});

  final Color strokeColor;

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / 48;
    final scaleY = size.height / 48;

    canvas.scale(scaleX, scaleY);

    final paint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Stem dot
    final dotPaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(24, 6.5), 2.4, dotPaint);

    // Body — paprika/bell-pepper silhouette
    final path = Path()
      ..moveTo(24, 11)
      ..cubicTo(16, 11, 9.5, 17, 9.5, 26)
      ..cubicTo(9.5, 32, 12.6, 36.6, 15.5, 39.4)
      ..cubicTo(17.4, 41.2, 19.4, 41.6, 20.7, 39.6)
      ..cubicTo(21.5, 38.3, 22.4, 37.4, 24, 37.4)
      ..cubicTo(25.6, 37.4, 26.5, 38.3, 27.3, 39.6)
      ..cubicTo(28.6, 41.6, 30.6, 41.2, 32.5, 39.4)
      ..cubicTo(35.4, 36.6, 38.5, 32, 38.5, 26)
      ..cubicTo(38.5, 17, 32, 11, 24, 11)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_PaprikaMarkPainter old) =>
      old.strokeColor != strokeColor;
}
