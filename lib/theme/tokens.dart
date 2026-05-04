import 'package:flutter/material.dart';

/// Design tokens mirroring T.* from design-system.jsx.
///
/// All color/spacing/radius values used in the app must come from here.
/// No `Color(0xFF...)` literals outside this file.
class AppTokens extends ThemeExtension<AppTokens> {
  const AppTokens();

  // ─── Surfaces ──────────────────────────────────────────────────────────────
  static const Color bg = Color(0xFFFAF7F4);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceAlt = Color(0xFFF2EEE9);
  static const Color border = Color(0x141A0F0C); // rgba(26,15,12,0.08)
  static const Color borderStrong = Color(0x241A0F0C); // rgba(26,15,12,0.14)

  // ─── Ink ───────────────────────────────────────────────────────────────────
  static const Color ink = Color(0xFF1A0B0E);
  static const Color inkSecondary = Color(0x9E1A0F0C); // rgba(26,15,12,0.62)
  static const Color inkTertiary = Color(0x6B1A0F0C); // rgba(26,15,12,0.42)
  static const Color inkDisabled = Color(0x3D1A0F0C); // rgba(26,15,12,0.24)

  // ─── Accent (paprika) ──────────────────────────────────────────────────────
  static const Color accent = Color(0xFFF04058);
  static const Color accentStrong = Color(0xFFD9304A);
  static const Color accentDeep = Color(0xFFA8243A);
  static const Color accentSoft = Color(0xFFFFE2E5);
  static const Color accentWash = Color(0xFFFFF3F4);
  static const Color accentInk = Color(0xFF1A0B0E);

  // ─── Status ────────────────────────────────────────────────────────────────
  // oklch(0.62 0.14 155) ≈ #2DA070
  static const Color success = Color(0xFF2DA070);
  // oklch(0.95 0.04 155) ≈ #E8F7F1
  static const Color successSoft = Color(0xFFE8F7F1);
  // oklch(0.72 0.14 75) ≈ #C39438
  static const Color warning = Color(0xFFC39438);
  // oklch(0.95 0.04 75) ≈ #FDF6DC
  static const Color warningSoft = Color(0xFFFDF6DC);
  // oklch(0.58 0.19 25) ≈ #D94040
  static const Color danger = Color(0xFFD94040);
  // oklch(0.95 0.04 25) ≈ #FDE8E8
  static const Color dangerSoft = Color(0xFFFDE8E8);

  // ─── Corner radii (from Handoff §3.5) ─────────────────────────────────────
  static const double radiusXs = 10;
  static const double radiusSm = 12;
  static const double radiusMd = 14;
  static const double radiusLg = 16;
  static const double radiusXl = 18;
  static const double radius2xl = 20;

  // ─── Spacing scale (from Handoff §3.5) ────────────────────────────────────
  static const double sp4 = 4;
  static const double sp6 = 6;
  static const double sp8 = 8;
  static const double sp10 = 10;
  static const double sp12 = 12;
  static const double sp14 = 14;
  static const double sp16 = 16;
  static const double sp18 = 18;
  static const double sp22 = 22;
  static const double sp28 = 28;

  // ─── Font families ─────────────────────────────────────────────────────────
  static const String fontDisplay = 'Inter';
  static const String fontMono = 'JetBrainsMono';

  // ─── ThemeExtension boilerplate ────────────────────────────────────────────
  @override
  AppTokens copyWith() => const AppTokens();

  @override
  AppTokens lerp(ThemeExtension<AppTokens>? other, double t) => const AppTokens();
}
