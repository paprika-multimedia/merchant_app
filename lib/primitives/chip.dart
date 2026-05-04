import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// Status chip tones.
enum ChipTone { neutral, accent, success, danger, warning }

/// Status chip size.
enum ChipSize { sm, md }

/// Paprika status chip — mirrors design-system.jsx Chip.
///
/// Never relies on color alone for status: always include a [leading] symbol.
class AppChip extends StatelessWidget {
  const AppChip({
    super.key,
    required this.label,
    this.leading,
    this.tone = ChipTone.neutral,
    this.size = ChipSize.sm,
  });

  final String label;
  final Widget? leading;
  final ChipTone tone;
  final ChipSize size;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (tone) {
      ChipTone.neutral => (AppTokens.surfaceAlt, AppTokens.inkSecondary),
      ChipTone.accent => (AppTokens.accentSoft, AppTokens.accentDeep),
      ChipTone.success => (AppTokens.successSoft, AppTokens.success),
      ChipTone.danger => (AppTokens.dangerSoft, AppTokens.danger),
      ChipTone.warning => (AppTokens.warningSoft, AppTokens.warning),
    };

    final (h, px, fs) = switch (size) {
      ChipSize.sm => (22.0, 8.0, 11.0),
      ChipSize.md => (28.0, 10.0, 13.0),
    };

    return Container(
      height: h,
      padding: EdgeInsets.symmetric(horizontal: px),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leading != null) ...[
            IconTheme(
              data: IconThemeData(color: fg, size: fs + 2),
              child: leading!,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontFamily: AppTokens.fontDisplay,
              fontWeight: FontWeight.w600,
              fontSize: fs,
              letterSpacing: 0.1,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}
