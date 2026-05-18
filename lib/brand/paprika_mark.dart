import 'package:flutter/material.dart';

/// Paprika brand mark using PNG asset.
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
    final image = Image.asset(
    'assets/images/paprika-icon.png',
    width: tile ? size * 0.72 : size,
    height: tile ? size * 0.72 : size,
    fit: BoxFit.contain,
    color: foreground,
    colorBlendMode: BlendMode.srcIn,
    );

    if (!tile) return image;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background ?? const Color(0xFFE65A2E),
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      alignment: Alignment.center,
      child: image,
    );
  }
}