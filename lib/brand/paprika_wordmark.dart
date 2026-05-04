import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// Paprika wordmark — "paprika" in brand coral.
///
/// Mirrors design-system.jsx PaprikaWordmark.
/// Renders the brand name text in brand coral using Inter.
/// Note: ideally this would be a bundled SVG; for now uses the Inter font
/// which is bundled as an asset. The actual SVG wordmark should be added
/// to assets/images/paprika-wordmark.svg and rendered via flutter_svg
/// when those assets are available.
class PaprikaWordmark extends StatelessWidget {
  const PaprikaWordmark({super.key, this.size = 28, this.color});

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      'paprika',
      style: TextStyle(
        fontFamily: AppTokens.fontDisplay,
        fontWeight: FontWeight.w800,
        fontSize: size,
        color: color ?? AppTokens.accent,
        letterSpacing: -1,
      ),
    );
  }
}
