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
    final markSize = (size * 1.45).roundToDouble();

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        PaprikaMark(size: markSize, tile: false),
        SizedBox(width: gap),
        PaprikaWordmark(size: size),
      ],
    );
  }
}
