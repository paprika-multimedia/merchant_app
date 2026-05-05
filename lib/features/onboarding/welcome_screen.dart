import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../brand/paprika_lockup.dart';
import '../../primitives/button.dart';
import '../../primitives/icons.dart';
import '../../theme/tokens.dart';
import '../../l10n/app_localizations.dart';

/// Welcome screen — Handoff §4.1.
///
/// Layout (left-aligned): Lockup → 40px display tagline → hero illustration →
/// two CTAs (primary: Scan QR, secondary: Enter code).
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppL10n.of(context);

    return Scaffold(
      backgroundColor: AppTokens.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top content area: lockup + tagline + hero
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(28, 24, 28, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left-aligned lockup (size 26 matches JSX)
                    const PaprikaLockup(size: 26),
                    const SizedBox(height: 56),
                    // 40px display headline, left-aligned
                    Text(
                      t.welcomeTagline,
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                        fontFamily: AppTokens.fontDisplay,
                        fontSize: 40,
                        fontWeight: FontWeight.w700,
                        color: AppTokens.ink,
                        letterSpacing: -1.4,
                        height: 1.05,
                      ),
                    ),
                    // Hero illustration — fills remaining space
                    Expanded(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: _WelcomeHero(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Footer CTAs
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
              child: Column(
                children: [
                  AppButton(
                    label: t.welcomeScan,
                    variant: AppButtonVariant.primary,
                    size: AppButtonSize.lg,
                    block: true,
                    leading: const QrIcon(size: 18, color: Colors.white),
                    onPressed: () => context.push('/scan/company'),
                  ),
                  const SizedBox(height: 10),
                  AppButton(
                    label: t.welcomeCode,
                    variant: AppButtonVariant.secondary,
                    size: AppButtonSize.lg,
                    block: true,
                    leading: const KeyboardIcon(size: 18, color: AppTokens.ink),
                    onPressed: () => context.push('/code/company'),
                  ),
                  // Help row retained (not in JSX but useful contact copy)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Hero illustration — stacked QR cards + Paprika pill badge.
///
/// Captures the spirit of the JSX SVG illustration:
/// two layered rounded squares (suggesting QR cards) at slight rotations
/// with a small accent pill containing the Paprika mark on top.
class _WelcomeHero extends StatelessWidget {
  const _WelcomeHero();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      height: 240,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Back card — 192×192 rotated +6deg, right side (JSX: padding 16, FakeQR 160)
          Positioned(
            right: 0,
            top: 30,
            child: Transform.rotate(
              angle: 0.105, // ~6 degrees in radians
              child: Container(
                width: 192,
                height: 192,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTokens.surface,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1A1A0F0C),
                      blurRadius: 40,
                      offset: Offset(0, 20),
                    ),
                    BoxShadow(
                      color: Color(0x0F1A0F0C),
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: _FakeQr(size: 160, color: AppTokens.ink),
              ),
            ),
          ),
          // Front card — 152×152 rotated -4deg, left/bottom (JSX: padding 16, FakeQR 120)
          Positioned(
            left: 0,
            bottom: 10,
            child: Transform.rotate(
              angle: -0.070, // ~-4 degrees in radians
              child: Container(
                width: 152,
                height: 152,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTokens.surface,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1A1A0F0C),
                      blurRadius: 40,
                      offset: Offset(0, 20),
                    ),
                    BoxShadow(
                      color: Color(0x0F1A0F0C),
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: _FakeQr(size: 120, color: AppTokens.accent),
              ),
            ),
          ),
          // Paprika pill badge — top, overlapping cards
          Positioned(
            top: 4,
            left: 40,
            child: Container(
              height: 30,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppTokens.ink,
                borderRadius: BorderRadius.circular(999),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x401A0F0C),
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Accent dot
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppTokens.accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Paprika',
                    style: TextStyle(
                      fontFamily: AppTokens.fontDisplay,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Fake QR pattern — 25×25 grid matching JSX FakeQR.
///
/// Three 7×7 finder squares (top-left, top-right, bottom-left) each drawn as
/// a dark outer square, 5×5 white inner, 3×3 dark center.
/// Data cells use deterministic pseudo-random: filled when
/// `((row * 31 + col * 17) % 7) >= 3`.
class _FakeQr extends StatelessWidget {
  const _FakeQr({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _FakeQrPainter(color)),
    );
  }
}

class _FakeQrPainter extends CustomPainter {
  const _FakeQrPainter(this.color);
  final Color color;

  // Grid dimension matching JSX FakeQR
  static const int _grid = 25;
  // Finder square outer size in cells
  static const int _finderSize = 7;

  @override
  void paint(Canvas canvas, Size size) {
    final u = size.width / _grid; // module size

    final darkPaint = Paint()
      ..color = color.withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;

    final whitePaint = Paint()
      ..color = AppTokens.surface
      ..style = PaintingStyle.fill;

    // Three finder square top-left corners (in module coords)
    const finderOrigins = [(0, 0), (18, 0), (0, 18)];

    for (final (ox, oy) in finderOrigins) {
      // 7×7 dark outer
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(ox * u, oy * u, _finderSize * u, _finderSize * u),
          Radius.circular(u * 0.8),
        ),
        darkPaint,
      );
      // 5×5 white inner (1-cell inset)
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            (ox + 1) * u,
            (oy + 1) * u,
            5 * u,
            5 * u,
          ),
          Radius.circular(u * 0.4),
        ),
        whitePaint,
      );
      // 3×3 dark center (2-cell inset)
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            (ox + 2) * u,
            (oy + 2) * u,
            3 * u,
            3 * u,
          ),
          Radius.circular(u * 0.3),
        ),
        darkPaint,
      );
    }

    // Data region — skip finder zones, use deterministic pseudo-random
    for (int row = 0; row < _grid; row++) {
      for (int col = 0; col < _grid; col++) {
        if (_isFinderCell(col, row)) continue;
        // Deterministic fill: same formula as JSX
        if (((row * 31 + col * 17) % 7) >= 3) {
          canvas.drawRect(
            Rect.fromLTWH(
              col * u + u * 0.1,
              row * u + u * 0.1,
              u * 0.8,
              u * 0.8,
            ),
            darkPaint,
          );
        }
      }
    }
  }

  /// Returns true for cells that are inside a finder square region
  /// (including the 1-cell quiet zone around each finder).
  bool _isFinderCell(int col, int row) {
    // Top-left finder: cols 0-7, rows 0-7
    if (col <= 7 && row <= 7) return true;
    // Top-right finder: cols 17-24, rows 0-7
    if (col >= 17 && row <= 7) return true;
    // Bottom-left finder: cols 0-7, rows 17-24
    if (col <= 7 && row >= 17) return true;
    return false;
  }

  @override
  bool shouldRepaint(_FakeQrPainter old) => old.color != color;
}
