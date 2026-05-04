import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/tokens.dart';

// ─── Paprika custom icon set ────────────────────────────────────────────────
//
// Each icon is a StatelessWidget that paints SVG-style strokes via CustomPaint.
// Defaults: strokeWidth 1.8, strokeCap round, strokeJoin round,
//           color from IconTheme (falls back to AppTokens.ink),
//           size from IconTheme (falls back to 20).
//
// Callers can override via constructor params or by wrapping in IconTheme.
// Paths match design-system.jsx Icon object (viewBox 0 0 24 24).

// ─── Helper ─────────────────────────────────────────────────────────────────

Paint _stroke(Color color, double sw) => Paint()
  ..color = color
  ..style = PaintingStyle.stroke
  ..strokeWidth = sw
  ..strokeCap = StrokeCap.round
  ..strokeJoin = StrokeJoin.round;

Paint _fill(Color color) => Paint()
  ..color = color
  ..style = PaintingStyle.fill;

// Scale a point from 24×24 viewBox to actual size.
Offset _p(double x, double y, double s) => Offset(x * s / 24, y * s / 24);

double _s(double x, double s) => x * s / 24;

// ─── Base painter ────────────────────────────────────────────────────────────

abstract class _IconPainter extends CustomPainter {
  const _IconPainter(this.color, this.strokeWidth);

  final Color color;
  final double strokeWidth;

  @override
  bool shouldRepaint(covariant _IconPainter old) =>
      old.color != color || old.strokeWidth != strokeWidth;
}

// ─── Base widget ─────────────────────────────────────────────────────────────

abstract class _PaprikaIcon extends StatelessWidget {
  const _PaprikaIcon({super.key, this.size, this.color});

  final double? size;
  final Color? color;

  CustomPainter painter(Color c, double sw, double s);

  @override
  Widget build(BuildContext context) {
    final iconTheme = IconTheme.of(context);
    final effectiveSize = size ?? iconTheme.size ?? 20;
    final effectiveColor = color ?? iconTheme.color ?? AppTokens.ink;
    return SizedBox(
      width: effectiveSize,
      height: effectiveSize,
      child: CustomPaint(
        painter: painter(effectiveColor, 1.8, effectiveSize),
      ),
    );
  }
}

// ─── Home ────────────────────────────────────────────────────────────────────
// <path d="M3 11l9-8 9 8v10a1 1 0 0 1-1 1h-5v-7h-6v7H4a1 1 0 0 1-1-1V11z"/>

class _HomePainter extends _IconPainter {
  const _HomePainter(super.color, super.strokeWidth, this.s);
  final double s;

  @override
  void paint(Canvas canvas, Size size) {
    final p = _stroke(color, strokeWidth);
    final path = Path()
      ..moveTo(_s(3, s), _s(11, s))
      ..lineTo(_s(12, s), _s(3, s))
      ..lineTo(_s(21, s), _s(11, s))
      ..lineTo(_s(21, s), _s(21, s))
      ..conicTo(_s(21, s), _s(22, s), _s(20, s), _s(22, s), 1)
      ..lineTo(_s(15, s), _s(22, s))
      ..lineTo(_s(15, s), _s(15, s))
      ..lineTo(_s(9, s), _s(15, s))
      ..lineTo(_s(9, s), _s(22, s))
      ..lineTo(_s(4, s), _s(22, s))
      ..conicTo(_s(3, s), _s(22, s), _s(3, s), _s(21, s), 1)
      ..close();
    canvas.drawPath(path, p);
  }
}

class HomeIcon extends _PaprikaIcon {
  const HomeIcon({super.key, super.size, super.color});
  @override
  CustomPainter painter(Color c, double sw, double s) =>
      _HomePainter(c, sw, s);
}

// ─── Plus ────────────────────────────────────────────────────────────────────
// <path d="M12 5v14M5 12h14"/>

class _PlusPainter extends _IconPainter {
  const _PlusPainter(super.color, super.strokeWidth, this.s);
  final double s;

  @override
  void paint(Canvas canvas, Size size) {
    final p = _stroke(color, strokeWidth * 1.1);
    canvas.drawLine(_p(12, 5, s), _p(12, 19, s), p);
    canvas.drawLine(_p(5, 12, s), _p(19, 12, s), p);
  }
}

class PlusIcon extends _PaprikaIcon {
  const PlusIcon({super.key, super.size, super.color});
  @override
  CustomPainter painter(Color c, double sw, double s) =>
      _PlusPainter(c, sw, s);
}

// ─── Back ────────────────────────────────────────────────────────────────────
// <path d="M15 6l-6 6 6 6"/>

class _BackPainter extends _IconPainter {
  const _BackPainter(super.color, super.strokeWidth, this.s);
  final double s;

  @override
  void paint(Canvas canvas, Size size) {
    final p = _stroke(color, strokeWidth * 1.1);
    final path = Path()
      ..moveTo(_s(15, s), _s(6, s))
      ..lineTo(_s(9, s), _s(12, s))
      ..lineTo(_s(15, s), _s(18, s));
    canvas.drawPath(path, p);
  }
}

class BackIcon extends _PaprikaIcon {
  const BackIcon({super.key, super.size, super.color});
  @override
  CustomPainter painter(Color c, double sw, double s) =>
      _BackPainter(c, sw, s);
}

// ─── Close ───────────────────────────────────────────────────────────────────
// <path d="M6 6l12 12M18 6L6 18"/>

class _ClosePainter extends _IconPainter {
  const _ClosePainter(super.color, super.strokeWidth, this.s);
  final double s;

  @override
  void paint(Canvas canvas, Size size) {
    final p = _stroke(color, strokeWidth * 1.1);
    canvas.drawLine(_p(6, 6, s), _p(18, 18, s), p);
    canvas.drawLine(_p(18, 6, s), _p(6, 18, s), p);
  }
}

class CloseIcon extends _PaprikaIcon {
  const CloseIcon({super.key, super.size, super.color});
  @override
  CustomPainter painter(Color c, double sw, double s) =>
      _ClosePainter(c, sw, s);
}

// ─── More (three dots) ───────────────────────────────────────────────────────
// fill circles at cx5/12/19 cy12 r1.8

class _MorePainter extends _IconPainter {
  const _MorePainter(super.color, super.strokeWidth, this.s);
  final double s;

  @override
  void paint(Canvas canvas, Size sz) {
    final p = _fill(color);
    final r = _s(1.8, s);
    for (final cx in [5.0, 12.0, 19.0]) {
      canvas.drawCircle(_p(cx, 12, s), r, p);
    }
  }
}

class MoreIcon extends _PaprikaIcon {
  const MoreIcon({super.key, super.size, super.color});
  @override
  CustomPainter painter(Color c, double sw, double s) =>
      _MorePainter(c, sw, s);
}

// ─── Bell ────────────────────────────────────────────────────────────────────
// <path d="M6 8a6 6 0 0 1 12 0c0 4 2 6 2 6H4s2-2 2-6zM10 20a2 2 0 0 0 4 0"/>

class _BellPainter extends _IconPainter {
  const _BellPainter(super.color, super.strokeWidth, this.s);
  final double s;

  @override
  void paint(Canvas canvas, Size size) {
    final p = _stroke(color, strokeWidth);
    // Body — approximated from the SVG path
    final body = Path()
      ..moveTo(_s(6, s), _s(8, s))
      ..cubicTo(_s(6, s), _s(4.686, s), _s(8.686, s), _s(2, s), _s(12, s),
          _s(2, s))
      ..cubicTo(_s(15.314, s), _s(2, s), _s(18, s), _s(4.686, s), _s(18, s),
          _s(8, s))
      ..cubicTo(_s(18, s), _s(12, s), _s(20, s), _s(14, s), _s(20, s),
          _s(14, s))
      ..lineTo(_s(4, s), _s(14, s))
      ..cubicTo(_s(4, s), _s(14, s), _s(6, s), _s(12, s), _s(6, s), _s(8, s))
      ..close();
    canvas.drawPath(body, p);
    // Clapper arc
    final clapper = Path()
      ..moveTo(_s(10, s), _s(20, s))
      ..cubicTo(_s(10, s), _s(21.1, s), _s(10.9, s), _s(22, s), _s(12, s),
          _s(22, s))
      ..cubicTo(_s(13.1, s), _s(22, s), _s(14, s), _s(21.1, s), _s(14, s),
          _s(20, s));
    canvas.drawPath(clapper, p);
  }
}

class BellIcon extends _PaprikaIcon {
  const BellIcon({super.key, super.size, super.color});
  @override
  CustomPainter painter(Color c, double sw, double s) =>
      _BellPainter(c, sw, s);
}

// ─── QR ──────────────────────────────────────────────────────────────────────
// Three corner squares + bottom-right detail path

class _QrPainter extends _IconPainter {
  const _QrPainter(super.color, super.strokeWidth, this.s);
  final double s;

  @override
  void paint(Canvas canvas, Size size) {
    final p = _stroke(color, strokeWidth);
    final rr = RRect.fromRectAndRadius;
    // top-left square 3,3,7,7 rx1
    canvas.drawRRect(
        rr(Rect.fromLTWH(_s(3, s), _s(3, s), _s(7, s), _s(7, s)),
            Radius.circular(_s(1, s))),
        p);
    // top-right square 14,3,7,7 rx1
    canvas.drawRRect(
        rr(Rect.fromLTWH(_s(14, s), _s(3, s), _s(7, s), _s(7, s)),
            Radius.circular(_s(1, s))),
        p);
    // bottom-left square 3,14,7,7 rx1
    canvas.drawRRect(
        rr(Rect.fromLTWH(_s(3, s), _s(14, s), _s(7, s), _s(7, s)),
            Radius.circular(_s(1, s))),
        p);
    // bottom-right detail: M14 14h3v3M14 21h3M20 14v7M17 17h4
    final d = Path()
      ..moveTo(_s(14, s), _s(14, s))
      ..lineTo(_s(17, s), _s(14, s))
      ..lineTo(_s(17, s), _s(17, s));
    canvas.drawPath(d, p);
    canvas.drawLine(_p(14, 21, s), _p(17, 21, s), p);
    canvas.drawLine(_p(20, 14, s), _p(20, 21, s), p);
    canvas.drawLine(_p(17, 17, s), _p(21, 17, s), p);
  }
}

class QrIcon extends _PaprikaIcon {
  const QrIcon({super.key, super.size, super.color});
  @override
  CustomPainter painter(Color c, double sw, double s) => _QrPainter(c, sw, s);
}

// ─── Link ────────────────────────────────────────────────────────────────────
// Two interlocking arcs

class _LinkPainter extends _IconPainter {
  const _LinkPainter(super.color, super.strokeWidth, this.s);
  final double s;

  @override
  void paint(Canvas canvas, Size size) {
    final p = _stroke(color, strokeWidth);
    // M10 14a4 4 0 0 0 5.66 0l3-3a4 4 0 1 0-5.66-5.66l-1.5 1.5
    final top = Path()
      ..moveTo(_s(10, s), _s(14, s))
      ..cubicTo(_s(10, s), _s(14, s), _s(12, s), _s(16, s), _s(15.66, s),
          _s(14, s))
      ..lineTo(_s(18.66, s), _s(11, s))
      ..cubicTo(_s(20.3, s), _s(9.37, s), _s(20.3, s), _s(6.63, s),
          _s(18.66, s), _s(5, s))
      ..cubicTo(_s(17.03, s), _s(3.37, s), _s(14.3, s), _s(3.37, s),
          _s(12.66, s), _s(5, s))
      ..lineTo(_s(11.16, s), _s(6.5, s));
    canvas.drawPath(top, p);
    // M14 10a4 4 0 0 0-5.66 0l-3 3a4 4 0 1 0 5.66 5.66l1.5-1.5
    final bot = Path()
      ..moveTo(_s(14, s), _s(10, s))
      ..cubicTo(_s(14, s), _s(10, s), _s(12, s), _s(8, s), _s(8.34, s),
          _s(10, s))
      ..lineTo(_s(5.34, s), _s(13, s))
      ..cubicTo(_s(3.7, s), _s(14.63, s), _s(3.7, s), _s(17.37, s),
          _s(5.34, s), _s(19, s))
      ..cubicTo(_s(6.97, s), _s(20.63, s), _s(9.7, s), _s(20.63, s),
          _s(11.34, s), _s(19, s))
      ..lineTo(_s(12.84, s), _s(17.5, s));
    canvas.drawPath(bot, p);
  }
}

class LinkIcon extends _PaprikaIcon {
  const LinkIcon({super.key, super.size, super.color});
  @override
  CustomPainter painter(Color c, double sw, double s) =>
      _LinkPainter(c, sw, s);
}

// ─── Store ───────────────────────────────────────────────────────────────────
// storefront outline

class _StorePainter extends _IconPainter {
  const _StorePainter(super.color, super.strokeWidth, this.s);
  final double s;

  @override
  void paint(Canvas canvas, Size size) {
    final p = _stroke(color, strokeWidth);
    // M3 9l1.5-5h15L21 9
    canvas.drawLine(_p(3, 9, s), _p(4.5, 4, s), p);
    canvas.drawLine(_p(4.5, 4, s), _p(19.5, 4, s), p);
    canvas.drawLine(_p(19.5, 4, s), _p(21, 9, s), p);
    // M4 9v11h16V9
    canvas.drawLine(_p(4, 9, s), _p(4, 20, s), p);
    canvas.drawLine(_p(4, 20, s), _p(20, 20, s), p);
    canvas.drawLine(_p(20, 20, s), _p(20, 9, s), p);
    // Awning arc: M3 9a3 3 0 0 0 6 0 3 3 0 0 0 6 0 3 3 0 0 0 6 0
    final awning = Path()
      ..moveTo(_s(3, s), _s(9, s))
      ..arcToPoint(_p(9, 9, s),
          radius: Radius.circular(_s(3, s)), clockwise: false)
      ..arcToPoint(_p(15, 9, s),
          radius: Radius.circular(_s(3, s)), clockwise: false)
      ..arcToPoint(_p(21, 9, s),
          radius: Radius.circular(_s(3, s)), clockwise: false);
    canvas.drawPath(awning, p);
    // door: M10 20v-5h4v5
    canvas.drawLine(_p(10, 20, s), _p(10, 15, s), p);
    canvas.drawLine(_p(10, 15, s), _p(14, 15, s), p);
    canvas.drawLine(_p(14, 15, s), _p(14, 20, s), p);
  }
}

class StoreIcon extends _PaprikaIcon {
  const StoreIcon({super.key, super.size, super.color});
  @override
  CustomPainter painter(Color c, double sw, double s) =>
      _StorePainter(c, sw, s);
}

// ─── Camera ──────────────────────────────────────────────────────────────────
// <path d="M3 8h4l2-3h6l2 3h4v11H3z"/> <circle cx="12" cy="13" r="4"/>

class _CameraPainter extends _IconPainter {
  const _CameraPainter(super.color, super.strokeWidth, this.s);
  final double s;

  @override
  void paint(Canvas canvas, Size size) {
    final p = _stroke(color, strokeWidth);
    final body = Path()
      ..moveTo(_s(3, s), _s(8, s))
      ..lineTo(_s(7, s), _s(8, s))
      ..lineTo(_s(9, s), _s(5, s))
      ..lineTo(_s(15, s), _s(5, s))
      ..lineTo(_s(17, s), _s(8, s))
      ..lineTo(_s(21, s), _s(8, s))
      ..lineTo(_s(21, s), _s(19, s))
      ..lineTo(_s(3, s), _s(19, s))
      ..close();
    canvas.drawPath(body, p);
    canvas.drawCircle(_p(12, 13, s), _s(4, s), p);
  }
}

class CameraIcon extends _PaprikaIcon {
  const CameraIcon({super.key, super.size, super.color});
  @override
  CustomPainter painter(Color c, double sw, double s) =>
      _CameraPainter(c, sw, s);
}

// ─── Keyboard ─────────────────────────────────────────────────────────────────
// <rect x="3" y="6" width="18" height="12" rx="2"/>
// <path d="M7 10h0M11 10h0M15 10h0M7 14h10"/>

class _KeyboardPainter extends _IconPainter {
  const _KeyboardPainter(super.color, super.strokeWidth, this.s);
  final double s;

  @override
  void paint(Canvas canvas, Size size) {
    final p = _stroke(color, strokeWidth);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(_s(3, s), _s(6, s), _s(18, s), _s(12, s)),
            Radius.circular(_s(2, s))),
        p);
    // Three key dots (h0 means just a dot — draw as small circle)
    final dot = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final r = strokeWidth * 0.7;
    for (final cx in [7.0, 11.0, 15.0]) {
      canvas.drawCircle(_p(cx, 10, s), r, dot);
    }
    // Space bar
    canvas.drawLine(_p(7, 14, s), _p(17, 14, s), p);
  }
}

class KeyboardIcon extends _PaprikaIcon {
  const KeyboardIcon({super.key, super.size, super.color});
  @override
  CustomPainter painter(Color c, double sw, double s) =>
      _KeyboardPainter(c, sw, s);
}

// ─── Check ───────────────────────────────────────────────────────────────────
// <path d="M4 12l5 5L20 6"/>

class _CheckPainter extends _IconPainter {
  const _CheckPainter(super.color, super.strokeWidth, this.s);
  final double s;

  @override
  void paint(Canvas canvas, Size size) {
    final p = _stroke(color, strokeWidth * 1.2);
    final path = Path()
      ..moveTo(_s(4, s), _s(12, s))
      ..lineTo(_s(9, s), _s(17, s))
      ..lineTo(_s(20, s), _s(6, s));
    canvas.drawPath(path, p);
  }
}

class CheckIcon extends _PaprikaIcon {
  const CheckIcon({super.key, super.size, super.color});
  @override
  CustomPainter painter(Color c, double sw, double s) =>
      _CheckPainter(c, sw, s);
}

// ─── Copy ────────────────────────────────────────────────────────────────────
// <rect x="8" y="8" width="12" height="12" rx="2"/>
// <path d="M16 8V5a1 1 0 0 0-1-1H5a1 1 0 0 0-1 1v10a1 1 0 0 0 1 1h3"/>

class _CopyPainter extends _IconPainter {
  const _CopyPainter(super.color, super.strokeWidth, this.s);
  final double s;

  @override
  void paint(Canvas canvas, Size size) {
    final p = _stroke(color, strokeWidth);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(_s(8, s), _s(8, s), _s(12, s), _s(12, s)),
            Radius.circular(_s(2, s))),
        p);
    final path = Path()
      ..moveTo(_s(16, s), _s(8, s))
      ..lineTo(_s(16, s), _s(5, s))
      ..conicTo(_s(16, s), _s(4, s), _s(15, s), _s(4, s), 1)
      ..lineTo(_s(5, s), _s(4, s))
      ..conicTo(_s(4, s), _s(4, s), _s(4, s), _s(5, s), 1)
      ..lineTo(_s(4, s), _s(15, s))
      ..conicTo(_s(4, s), _s(16, s), _s(5, s), _s(16, s), 1)
      ..lineTo(_s(8, s), _s(16, s));
    canvas.drawPath(path, p);
  }
}

class CopyIcon extends _PaprikaIcon {
  const CopyIcon({super.key, super.size, super.color});
  @override
  CustomPainter painter(Color c, double sw, double s) =>
      _CopyPainter(c, sw, s);
}

// ─── Share ───────────────────────────────────────────────────────────────────
// <path d="M12 3v13M7 8l5-5 5 5M5 14v5a1 1 0 0 0 1 1h12a1 1 0 0 0 1-1v-5"/>

class _SharePainter extends _IconPainter {
  const _SharePainter(super.color, super.strokeWidth, this.s);
  final double s;

  @override
  void paint(Canvas canvas, Size size) {
    final p = _stroke(color, strokeWidth);
    canvas.drawLine(_p(12, 3, s), _p(12, 16, s), p);
    final arrow = Path()
      ..moveTo(_s(7, s), _s(8, s))
      ..lineTo(_s(12, s), _s(3, s))
      ..lineTo(_s(17, s), _s(8, s));
    canvas.drawPath(arrow, p);
    final tray = Path()
      ..moveTo(_s(5, s), _s(14, s))
      ..lineTo(_s(5, s), _s(19, s))
      ..conicTo(_s(5, s), _s(20, s), _s(6, s), _s(20, s), 1)
      ..lineTo(_s(18, s), _s(20, s))
      ..conicTo(_s(19, s), _s(20, s), _s(19, s), _s(19, s), 1)
      ..lineTo(_s(19, s), _s(14, s));
    canvas.drawPath(tray, p);
  }
}

class ShareIcon extends _PaprikaIcon {
  const ShareIcon({super.key, super.size, super.color});
  @override
  CustomPainter painter(Color c, double sw, double s) =>
      _SharePainter(c, sw, s);
}

// ─── Print ───────────────────────────────────────────────────────────────────
// <path d="M6 9V3h12v6M6 18H4a1 1 0 0 1-1-1v-6a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2v6a1 1 0 0 1-1 1h-2"/>
// <rect x="6" y="14" width="12" height="7" rx="1"/>

class _PrintPainter extends _IconPainter {
  const _PrintPainter(super.color, super.strokeWidth, this.s);
  final double s;

  @override
  void paint(Canvas canvas, Size size) {
    final p = _stroke(color, strokeWidth);
    final top = Path()
      ..moveTo(_s(6, s), _s(9, s))
      ..lineTo(_s(6, s), _s(3, s))
      ..lineTo(_s(18, s), _s(3, s))
      ..lineTo(_s(18, s), _s(9, s));
    canvas.drawPath(top, p);
    final body = Path()
      ..moveTo(_s(6, s), _s(18, s))
      ..lineTo(_s(4, s), _s(18, s))
      ..conicTo(_s(3, s), _s(18, s), _s(3, s), _s(17, s), 1)
      ..lineTo(_s(3, s), _s(11, s))
      ..cubicTo(
          _s(3, s), _s(9.9, s), _s(3.9, s), _s(9, s), _s(5, s), _s(9, s))
      ..lineTo(_s(19, s), _s(9, s))
      ..cubicTo(
          _s(20.1, s), _s(9, s), _s(21, s), _s(9.9, s), _s(21, s), _s(11, s))
      ..lineTo(_s(21, s), _s(17, s))
      ..conicTo(_s(21, s), _s(18, s), _s(20, s), _s(18, s), 1)
      ..lineTo(_s(18, s), _s(18, s));
    canvas.drawPath(body, p);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(_s(6, s), _s(14, s), _s(12, s), _s(7, s)),
            Radius.circular(_s(1, s))),
        p);
  }
}

class PrintIcon extends _PaprikaIcon {
  const PrintIcon({super.key, super.size, super.color});
  @override
  CustomPainter painter(Color c, double sw, double s) =>
      _PrintPainter(c, sw, s);
}

// ─── ArrowUp ─────────────────────────────────────────────────────────────────
// <path d="M5 12l7-7 7 7M12 5v14"/>

class _ArrowUpPainter extends _IconPainter {
  const _ArrowUpPainter(super.color, super.strokeWidth, this.s);
  final double s;

  @override
  void paint(Canvas canvas, Size size) {
    final p = _stroke(color, strokeWidth * 1.1);
    final path = Path()
      ..moveTo(_s(5, s), _s(12, s))
      ..lineTo(_s(12, s), _s(5, s))
      ..lineTo(_s(19, s), _s(12, s));
    canvas.drawPath(path, p);
    canvas.drawLine(_p(12, 5, s), _p(12, 19, s), p);
  }
}

class ArrowUpIcon extends _PaprikaIcon {
  const ArrowUpIcon({super.key, super.size, super.color});
  @override
  CustomPainter painter(Color c, double sw, double s) =>
      _ArrowUpPainter(c, sw, s);
}

// ─── ArrowDown ───────────────────────────────────────────────────────────────
// <path d="M5 12l7 7 7-7M12 19V5"/>

class _ArrowDownPainter extends _IconPainter {
  const _ArrowDownPainter(super.color, super.strokeWidth, this.s);
  final double s;

  @override
  void paint(Canvas canvas, Size size) {
    final p = _stroke(color, strokeWidth * 1.1);
    final path = Path()
      ..moveTo(_s(5, s), _s(12, s))
      ..lineTo(_s(12, s), _s(19, s))
      ..lineTo(_s(19, s), _s(12, s));
    canvas.drawPath(path, p);
    canvas.drawLine(_p(12, 19, s), _p(12, 5, s), p);
  }
}

class ArrowDownIcon extends _PaprikaIcon {
  const ArrowDownIcon({super.key, super.size, super.color});
  @override
  CustomPainter painter(Color c, double sw, double s) =>
      _ArrowDownPainter(c, sw, s);
}

// ─── Trash ───────────────────────────────────────────────────────────────────
// <path d="M4 7h16M9 7V4h6v3M6 7l1 13h10l1-13M10 11v6M14 11v6"/>

class _TrashPainter extends _IconPainter {
  const _TrashPainter(super.color, super.strokeWidth, this.s);
  final double s;

  @override
  void paint(Canvas canvas, Size size) {
    final p = _stroke(color, strokeWidth);
    canvas.drawLine(_p(4, 7, s), _p(20, 7, s), p);
    final lid = Path()
      ..moveTo(_s(9, s), _s(7, s))
      ..lineTo(_s(9, s), _s(4, s))
      ..lineTo(_s(15, s), _s(4, s))
      ..lineTo(_s(15, s), _s(7, s));
    canvas.drawPath(lid, p);
    final body = Path()
      ..moveTo(_s(6, s), _s(7, s))
      ..lineTo(_s(7, s), _s(20, s))
      ..lineTo(_s(17, s), _s(20, s))
      ..lineTo(_s(18, s), _s(7, s));
    canvas.drawPath(body, p);
    canvas.drawLine(_p(10, 11, s), _p(10, 17, s), p);
    canvas.drawLine(_p(14, 11, s), _p(14, 17, s), p);
  }
}

class TrashIcon extends _PaprikaIcon {
  const TrashIcon({super.key, super.size, super.color});
  @override
  CustomPainter painter(Color c, double sw, double s) =>
      _TrashPainter(c, sw, s);
}

// ─── Info ────────────────────────────────────────────────────────────────────
// <circle cx="12" cy="12" r="9"/> <path d="M12 11v5M12 8v.01"/>

class _InfoPainter extends _IconPainter {
  const _InfoPainter(super.color, super.strokeWidth, this.s);
  final double s;

  @override
  void paint(Canvas canvas, Size size) {
    final p = _stroke(color, strokeWidth);
    canvas.drawCircle(_p(12, 12, s), _s(9, s), p);
    canvas.drawLine(_p(12, 11, s), _p(12, 16, s), p);
    // Dot at 12,8
    canvas.drawCircle(_p(12, 8, s), strokeWidth * 0.5, _fill(color));
  }
}

class InfoIcon extends _PaprikaIcon {
  const InfoIcon({super.key, super.size, super.color});
  @override
  CustomPainter painter(Color c, double sw, double s) =>
      _InfoPainter(c, sw, s);
}

// ─── Edit ────────────────────────────────────────────────────────────────────
// <path d="M4 20h4L20 8l-4-4L4 16v4z"/> <path d="M14 6l4 4"/>

class _EditPainter extends _IconPainter {
  const _EditPainter(super.color, super.strokeWidth, this.s);
  final double s;

  @override
  void paint(Canvas canvas, Size size) {
    final p = _stroke(color, strokeWidth);
    final pen = Path()
      ..moveTo(_s(4, s), _s(20, s))
      ..lineTo(_s(8, s), _s(20, s))
      ..lineTo(_s(20, s), _s(8, s))
      ..lineTo(_s(16, s), _s(4, s))
      ..lineTo(_s(4, s), _s(16, s))
      ..close();
    canvas.drawPath(pen, p);
    canvas.drawLine(_p(14, 6, s), _p(18, 10, s), p);
  }
}

class EditIcon extends _PaprikaIcon {
  const EditIcon({super.key, super.size, super.color});
  @override
  CustomPainter painter(Color c, double sw, double s) =>
      _EditPainter(c, sw, s);
}

// ─── Logout ──────────────────────────────────────────────────────────────────
// <path d="M10 4H6a2 2 0 0 0-2 2v12a2 2 0 0 0 2 2h4"/>
// <path d="M16 16l4-4-4-4"/> <path d="M20 12H10"/>

class _LogoutPainter extends _IconPainter {
  const _LogoutPainter(super.color, super.strokeWidth, this.s);
  final double s;

  @override
  void paint(Canvas canvas, Size size) {
    final p = _stroke(color, strokeWidth);
    final box = Path()
      ..moveTo(_s(10, s), _s(4, s))
      ..lineTo(_s(6, s), _s(4, s))
      ..cubicTo(
          _s(4.9, s), _s(4, s), _s(4, s), _s(4.9, s), _s(4, s), _s(6, s))
      ..lineTo(_s(4, s), _s(18, s))
      ..cubicTo(
          _s(4, s), _s(19.1, s), _s(4.9, s), _s(20, s), _s(6, s), _s(20, s))
      ..lineTo(_s(10, s), _s(20, s));
    canvas.drawPath(box, p);
    final arrow = Path()
      ..moveTo(_s(16, s), _s(16, s))
      ..lineTo(_s(20, s), _s(12, s))
      ..lineTo(_s(16, s), _s(8, s));
    canvas.drawPath(arrow, p);
    canvas.drawLine(_p(20, 12, s), _p(10, 12, s), p);
  }
}

class LogoutIcon extends _PaprikaIcon {
  const LogoutIcon({super.key, super.size, super.color});
  @override
  CustomPainter painter(Color c, double sw, double s) =>
      _LogoutPainter(c, sw, s);
}

// ─── Settings ────────────────────────────────────────────────────────────────
// Gear — simplified faithful equivalent of the JSX path

class _SettingsPainter extends _IconPainter {
  const _SettingsPainter(super.color, super.strokeWidth, this.s);
  final double s;

  @override
  void paint(Canvas canvas, Size size) {
    final p = _stroke(color, strokeWidth);
    canvas.drawCircle(_p(12, 12, s), _s(3, s), p);
    // Draw 8 gear teeth as short radial lines
    for (var i = 0; i < 8; i++) {
      final angle = i * math.pi / 4;
      final inner = _s(5.5, s);
      final outer = _s(7.5, s);
      final cx = _s(12, s);
      final cy = _s(12, s);
      canvas.drawLine(
        Offset(cx + inner * math.cos(angle), cy + inner * math.sin(angle)),
        Offset(cx + outer * math.cos(angle), cy + outer * math.sin(angle)),
        p,
      );
    }
    canvas.drawCircle(_p(12, 12, s), _s(7.5, s), _stroke(color, strokeWidth * 0.8));
  }
}

class SettingsIcon extends _PaprikaIcon {
  const SettingsIcon({super.key, super.size, super.color});
  @override
  CustomPainter painter(Color c, double sw, double s) =>
      _SettingsPainter(c, sw, s);
}

// ─── Activity ────────────────────────────────────────────────────────────────
// <path d="M3 12h4l3-8 4 16 3-8h4"/>

class _ActivityPainter extends _IconPainter {
  const _ActivityPainter(super.color, super.strokeWidth, this.s);
  final double s;

  @override
  void paint(Canvas canvas, Size size) {
    final p = _stroke(color, strokeWidth);
    final path = Path()
      ..moveTo(_s(3, s), _s(12, s))
      ..lineTo(_s(7, s), _s(12, s))
      ..lineTo(_s(10, s), _s(4, s))
      ..lineTo(_s(14, s), _s(20, s))
      ..lineTo(_s(17, s), _s(12, s))
      ..lineTo(_s(21, s), _s(12, s));
    canvas.drawPath(path, p);
  }
}

class ActivityIcon extends _PaprikaIcon {
  const ActivityIcon({super.key, super.size, super.color});
  @override
  CustomPainter painter(Color c, double sw, double s) =>
      _ActivityPainter(c, sw, s);
}

// ─── Chevron ─────────────────────────────────────────────────────────────────
// <path d="M9 6l6 6-6 6"/>

class _ChevronPainter extends _IconPainter {
  const _ChevronPainter(super.color, super.strokeWidth, this.s);
  final double s;

  @override
  void paint(Canvas canvas, Size size) {
    final p = _stroke(color, strokeWidth * 1.1);
    final path = Path()
      ..moveTo(_s(9, s), _s(6, s))
      ..lineTo(_s(15, s), _s(12, s))
      ..lineTo(_s(9, s), _s(18, s));
    canvas.drawPath(path, p);
  }
}

class ChevronIcon extends _PaprikaIcon {
  const ChevronIcon({super.key, super.size, super.color});
  @override
  CustomPainter painter(Color c, double sw, double s) =>
      _ChevronPainter(c, sw, s);
}

// ─── Flash ───────────────────────────────────────────────────────────────────
// <path d="M13 2L3 14h7l-1 8 10-12h-7l1-8z"/>

class _FlashPainter extends _IconPainter {
  const _FlashPainter(super.color, super.strokeWidth, this.s);
  final double s;

  @override
  void paint(Canvas canvas, Size size) {
    final p = _stroke(color, strokeWidth);
    final path = Path()
      ..moveTo(_s(13, s), _s(2, s))
      ..lineTo(_s(3, s), _s(14, s))
      ..lineTo(_s(10, s), _s(14, s))
      ..lineTo(_s(9, s), _s(22, s))
      ..lineTo(_s(19, s), _s(10, s))
      ..lineTo(_s(12, s), _s(10, s))
      ..close();
    canvas.drawPath(path, p);
  }
}

class FlashIcon extends _PaprikaIcon {
  const FlashIcon({super.key, super.size, super.color});
  @override
  CustomPainter painter(Color c, double sw, double s) =>
      _FlashPainter(c, sw, s);
}

// ─── Gallery ─────────────────────────────────────────────────────────────────
// <rect x="3" y="3" width="18" height="18" rx="3"/>
// <circle cx="8.5" cy="8.5" r="1.5"/> <path d="M21 15l-5-5-9 9"/>

class _GalleryPainter extends _IconPainter {
  const _GalleryPainter(super.color, super.strokeWidth, this.s);
  final double s;

  @override
  void paint(Canvas canvas, Size size) {
    final p = _stroke(color, strokeWidth);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(_s(3, s), _s(3, s), _s(18, s), _s(18, s)),
            Radius.circular(_s(3, s))),
        p);
    canvas.drawCircle(_p(8.5, 8.5, s), _s(1.5, s), p);
    final mountain = Path()
      ..moveTo(_s(21, s), _s(15, s))
      ..lineTo(_s(16, s), _s(10, s))
      ..lineTo(_s(7, s), _s(19, s));
    canvas.drawPath(mountain, p);
  }
}

class GalleryIcon extends _PaprikaIcon {
  const GalleryIcon({super.key, super.size, super.color});
  @override
  CustomPainter painter(Color c, double sw, double s) =>
      _GalleryPainter(c, sw, s);
}

// ─── Namespace ───────────────────────────────────────────────────────────────
//
// Expose all icons through a single class for ergonomic access:
//   PaprikaIcons.back(size: 20, color: AppTokens.ink)

class PaprikaIcons {
  const PaprikaIcons._();

  static HomeIcon home({double? size, Color? color}) =>
      HomeIcon(size: size, color: color);
  static PlusIcon plus({double? size, Color? color}) =>
      PlusIcon(size: size, color: color);
  static BackIcon back({double? size, Color? color}) =>
      BackIcon(size: size, color: color);
  static CloseIcon close({double? size, Color? color}) =>
      CloseIcon(size: size, color: color);
  static MoreIcon more({double? size, Color? color}) =>
      MoreIcon(size: size, color: color);
  static BellIcon bell({double? size, Color? color}) =>
      BellIcon(size: size, color: color);
  static QrIcon qr({double? size, Color? color}) =>
      QrIcon(size: size, color: color);
  static LinkIcon link({double? size, Color? color}) =>
      LinkIcon(size: size, color: color);
  static StoreIcon store({double? size, Color? color}) =>
      StoreIcon(size: size, color: color);
  static CameraIcon camera({double? size, Color? color}) =>
      CameraIcon(size: size, color: color);
  static KeyboardIcon keyboard({double? size, Color? color}) =>
      KeyboardIcon(size: size, color: color);
  static CheckIcon check({double? size, Color? color}) =>
      CheckIcon(size: size, color: color);
  static CopyIcon copy({double? size, Color? color}) =>
      CopyIcon(size: size, color: color);
  static ShareIcon share({double? size, Color? color}) =>
      ShareIcon(size: size, color: color);
  static PrintIcon print({double? size, Color? color}) =>
      PrintIcon(size: size, color: color);
  static ArrowUpIcon arrowUp({double? size, Color? color}) =>
      ArrowUpIcon(size: size, color: color);
  static ArrowDownIcon arrowDown({double? size, Color? color}) =>
      ArrowDownIcon(size: size, color: color);
  static TrashIcon trash({double? size, Color? color}) =>
      TrashIcon(size: size, color: color);
  static InfoIcon info({double? size, Color? color}) =>
      InfoIcon(size: size, color: color);
  static EditIcon edit({double? size, Color? color}) =>
      EditIcon(size: size, color: color);
  static LogoutIcon logout({double? size, Color? color}) =>
      LogoutIcon(size: size, color: color);
  static SettingsIcon settings({double? size, Color? color}) =>
      SettingsIcon(size: size, color: color);
  static ActivityIcon activity({double? size, Color? color}) =>
      ActivityIcon(size: size, color: color);
  static ChevronIcon chevron({double? size, Color? color}) =>
      ChevronIcon(size: size, color: color);
  static FlashIcon flash({double? size, Color? color}) =>
      FlashIcon(size: size, color: color);
  static GalleryIcon gallery({double? size, Color? color}) =>
      GalleryIcon(size: size, color: color);
}
