import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// Card container — mirrors design-system.jsx Card.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = AppTokens.sp16,
    this.onTap,
    this.color,
  });

  final Widget child;
  final double padding;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          color: color ?? AppTokens.surface,
          borderRadius: BorderRadius.circular(AppTokens.radius2xl),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A1A0F0C),
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
            BoxShadow(
              color: Color(0x0D1A0F0C),
              spreadRadius: 0,
              blurRadius: 0,
              offset: Offset(0, 0),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}
