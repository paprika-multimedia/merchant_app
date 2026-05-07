import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../theme/tokens.dart';

/// Shared QR scanner viewfinder overlay.
///
/// Renders centered square reticle with corner brackets and animated scanline.
/// Matches paprika-scan animation from Handoff §7: 1600ms loop, translateY.
class ScannerOverlay extends StatelessWidget {
  const ScannerOverlay({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  static const double _reticleSize = 260;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Dark scrim around reticle
        ColorFiltered(
          colorFilter: const ColorFilter.mode(
            Color(0x88000000),
            BlendMode.srcOut,
          ),
          child: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Colors.black,
                  backgroundBlendMode: BlendMode.dstOut,
                ),
              ),
              Center(
                child: Container(
                  width: _reticleSize,
                  height: _reticleSize,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Corner brackets
        Center(
          child: SizedBox(
            width: _reticleSize,
            height: _reticleSize,
            child: const _CornerBrackets(),
          ),
        ),

        // Animated scanline
        Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: _reticleSize,
              height: _reticleSize,
              child: _ScanLine(),
            ),
          ),
        ),

        // Title + subtitle
        Positioned(
          top: MediaQuery.of(context).size.height / 2 - _reticleSize / 2 - 80,
          left: 0,
          right: 0,
          child: Column(
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: AppTokens.fontDisplay,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontFamily: AppTokens.fontDisplay,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CornerBrackets extends StatelessWidget {
  const _CornerBrackets();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _CornerPainter());
  }
}

class _CornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTokens.accent
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const len = 24.0;
    final r = 8.0;

    // Top-left
    canvas.drawPath(
      Path()
        ..moveTo(0, len)
        ..lineTo(0, r)
        ..arcToPoint(Offset(r, 0), radius: Radius.circular(r))
        ..lineTo(len, 0),
      paint,
    );
    // Top-right
    canvas.drawPath(
      Path()
        ..moveTo(size.width - len, 0)
        ..lineTo(size.width - r, 0)
        ..arcToPoint(Offset(size.width, r), radius: Radius.circular(r))
        ..lineTo(size.width, len),
      paint,
    );
    // Bottom-left
    canvas.drawPath(
      Path()
        ..moveTo(0, size.height - len)
        ..lineTo(0, size.height - r)
        ..arcToPoint(Offset(r, size.height), radius: Radius.circular(r))
        ..lineTo(len, size.height),
      paint,
    );
    // Bottom-right
    canvas.drawPath(
      Path()
        ..moveTo(size.width - len, size.height)
        ..lineTo(size.width - r, size.height)
        ..arcToPoint(
          Offset(size.width, size.height - r),
          radius: Radius.circular(r),
        )
        ..lineTo(size.width, size.height - len),
      paint,
    );
  }

  @override
  bool shouldRepaint(_CornerPainter old) => false;
}

class _ScanLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Scanline lives inside the 260x260 reticle. Use a small inset so the
    // glow doesn't bleed past the corner brackets, and bounce between the
    // top and bottom rather than snapping back from the bottom.
    const travel = ScannerOverlay._reticleSize - 8;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Align(
        alignment: Alignment.topCenter,
        child:
            Container(
                  height: 2,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Colors.transparent,
                        AppTokens.accent,
                        Colors.transparent,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTokens.accent.withValues(alpha: 0.55),
                        blurRadius: 14,
                      ),
                    ],
                  ),
                )
                .animate(onPlay: (c) => c.repeat())
                .moveY(
                  begin: 4,
                  end: travel,
                  duration: 1400.ms,
                  curve: Curves.easeInOut,
                )
                .then()
                .moveY(
                  begin: travel,
                  end: 4,
                  duration: 1400.ms,
                  curve: Curves.easeInOut,
                ),
      ),
    );
  }
}
