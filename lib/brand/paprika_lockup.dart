import 'package:flutter/material.dart';

import 'paprika_mark.dart';
import 'paprika_wordmark.dart';

/// Combined mark + wordmark lockup.
///
/// Mirrors design-system.jsx PaprikaLockup.
class PaprikaLockup extends StatelessWidget {
  const PaprikaLockup({super.key, this.size = 28});

  final double size;

  @override
Widget build(BuildContext context) {
  final gap = (size * 0.4).roundToDouble();
  final markSize = (size * 2.0).roundToDouble();

  return Row(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      // Kotak orange
      Container(
        width: markSize,
        height: markSize,
        decoration: BoxDecoration(
          color: const Color(0xFFF04058),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: PaprikaMark(
            size: markSize * 0.55,
            tile: false,
            foreground: Colors.white,
          ),
        ),
      ),

      SizedBox(width: gap),

      // Text hitam
      PaprikaWordmark(
        size: size,
        color: Colors.black,
      ),
    ],
  );
}
}
