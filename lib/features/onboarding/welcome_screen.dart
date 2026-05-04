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
///
/// The "Don't have a code?" help row is retained (not in JSX but useful copy).
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
                    leading: const KeyboardIcon(
                        size: 18, color: AppTokens.ink),
                    onPressed: () => context.push('/code/company'),
                  ),
                  // Help row retained (not in JSX but useful contact copy)
                  const SizedBox(height: AppTokens.sp22),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        t.welcomeHelp,
                        style: const TextStyle(
                          fontFamily: AppTokens.fontDisplay,
                          fontSize: 13,
                          color: AppTokens.inkTertiary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () {}, // contact admin — placeholder
                        child: Text(
                          t.welcomeHelpCta,
                          style: const TextStyle(
                            fontFamily: AppTokens.fontDisplay,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTokens.accent,
                          ),
                        ),
                      ),
                    ],
                  ),
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
      width: 260,
      height: 240,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Back card — rotated +6deg, right side
          Positioned(
            right: 0,
            top: 30,
            child: Transform.rotate(
              angle: 0.105, // ~6 degrees in radians
              child: Container(
                width: 148,
                height: 148,
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
                child: _FakeQr(size: 116, color: AppTokens.ink),
              ),
            ),
          ),
          // Front card — rotated -4deg, left/bottom
          Positioned(
            left: 0,
            bottom: 10,
            child: Transform.rotate(
              angle: -0.070, // ~-4 degrees in radians
              child: Container(
                width: 112,
                height: 112,
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
                child: _FakeQr(size: 80, color: AppTokens.accent),
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

/// Simple fake QR pattern — 3×3 grid of corner squares + random inner blocks.
///
/// Pure Dart geometry, no image assets needed.
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

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;

    final s = size.width;
    final u = s / 7; // unit cell size

    // Three finder squares (corner QR markers)
    for (final (col, row) in [(0, 0), (4, 0), (0, 4)]) {
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(col * u, row * u, 3 * u, 3 * u),
        Radius.circular(u * 0.4),
      );
      canvas.drawRRect(rect, paint);
      // Inner white square
      final inner = RRect.fromRectAndRadius(
        Rect.fromLTWH(
            col * u + u * 0.4, row * u + u * 0.4, 3 * u - u * 0.8, 3 * u - u * 0.8),
        Radius.circular(u * 0.2),
      );
      canvas.drawRRect(inner, Paint()..color = AppTokens.surface..style = PaintingStyle.fill);
      // Center dot
      final center = Rect.fromLTWH(
          col * u + u, row * u + u, u, u);
      canvas.drawRRect(
        RRect.fromRectAndRadius(center, Radius.circular(u * 0.15)),
        paint,
      );
    }

    // Data cells — a few fixed blocks to look like QR data
    final dataCells = [
      (3, 0), (4, 1), (6, 0), (5, 2), (6, 2),
      (3, 3), (4, 3), (5, 3), (6, 3),
      (3, 4), (5, 4),
      (4, 5), (6, 5),
      (3, 6), (5, 6), (6, 6),
    ];
    for (final (col, row) in dataCells) {
      canvas.drawRect(
        Rect.fromLTWH(col * u + u * 0.1, row * u + u * 0.1, u * 0.8, u * 0.8),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_FakeQrPainter old) => old.color != color;
}
