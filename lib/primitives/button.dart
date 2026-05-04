import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// Button variants mirroring design-system.jsx Button variants.
enum AppButtonVariant { primary, secondary, ghost, soft, danger }

/// Button sizes from design-system.jsx.
enum AppButtonSize { sm, md, lg }

/// Paprika button primitive — mirrors design-system.jsx Button.
///
/// All colors and radii from [AppTokens].
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.md,
    this.leading,
    this.trailing,
    this.block = false,
    this.disabled = false,
    this.semanticsLabel,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final Widget? leading;
  final Widget? trailing;
  final bool block;
  final bool disabled;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final (h, px, fs, r) = switch (size) {
      AppButtonSize.sm => (36.0, 14.0, 14.0, AppTokens.radiusSm),
      AppButtonSize.md => (48.0, 18.0, 15.0, AppTokens.radiusMd),
      AppButtonSize.lg => (56.0, 22.0, 16.0, AppTokens.radiusLg),
    };

    final (bg, fg, border) = switch (variant) {
      AppButtonVariant.primary => (
          AppTokens.accent,
          Colors.white,
          null,
        ),
      AppButtonVariant.secondary => (
          AppTokens.surface,
          AppTokens.ink,
          AppTokens.borderStrong,
        ),
      AppButtonVariant.ghost => (
          Colors.transparent,
          AppTokens.ink,
          null,
        ),
      AppButtonVariant.soft => (
          AppTokens.accentSoft,
          AppTokens.accentDeep,
          null,
        ),
      AppButtonVariant.danger => (
          AppTokens.dangerSoft,
          AppTokens.danger,
          AppTokens.danger.withOpacity(0.13),
        ),
    };

    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (leading != null) ...[leading!, const SizedBox(width: 8)],
        Text(
          label,
          style: TextStyle(
            fontFamily: AppTokens.fontDisplay,
            fontWeight: FontWeight.w600,
            fontSize: fs,
            letterSpacing: -0.1,
            color: disabled ? fg.withOpacity(0.4) : fg,
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 8), trailing!],
      ],
    );

    if (block) {
      content = SizedBox(
        width: double.infinity,
        child: Center(child: content),
      );
    }

    return Semantics(
      label: semanticsLabel ?? label,
      button: true,
      enabled: !disabled,
      child: GestureDetector(
        onTap: disabled ? null : onPressed,
        child: AnimatedOpacity(
          opacity: disabled ? 0.4 : 1.0,
          duration: const Duration(milliseconds: 120),
          child: Container(
            height: h,
            padding: EdgeInsets.symmetric(horizontal: px),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(r),
              border: border != null
                  ? Border.all(color: border, width: 1)
                  : null,
            ),
            child: content,
          ),
        ),
      ),
    );
  }
}
