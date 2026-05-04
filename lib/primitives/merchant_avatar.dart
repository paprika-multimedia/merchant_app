import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// Merchant avatar with initials — mirrors design-system.jsx MerchantAvatar.
///
/// Uses a deterministic warm tint derived from the merchant name hash.
class MerchantAvatar extends StatelessWidget {
  const MerchantAvatar({
    super.key,
    required this.name,
    this.size = 44,
    this.active = false,
  });

  final String name;
  final double size;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final initials = name
        .split(RegExp(r'\s+'))
        .take(2)
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
        .join('');

    // Deterministic hue from name hash
    int h = 0;
    for (final c in name.codeUnits) {
      h = (h * 31 + c) & 0xFFFFFFFF;
    }
    final hue = (h.abs() % 360).toDouble();
    final bg = HSLColor.fromAHSL(1.0, hue, 0.55, 0.92).toColor();
    final fg = HSLColor.fromAHSL(1.0, hue, 0.45, 0.35).toColor();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(size / 2.2),
        border: active
            ? Border.all(
                color: AppTokens.accent,
                width: 2,
                strokeAlign: BorderSide.strokeAlignOutside,
              )
            : null,
      ),
      alignment: Alignment.center,
      child: Text(
        initials.isEmpty ? '?' : initials,
        style: TextStyle(
          fontFamily: AppTokens.fontDisplay,
          fontWeight: FontWeight.w700,
          fontSize: size * 0.36,
          letterSpacing: 0.2,
          color: fg,
        ),
      ),
    );
  }
}
