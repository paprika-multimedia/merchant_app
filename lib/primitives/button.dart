import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// Button variants mirroring design-system.jsx Button variants.
enum AppButtonVariant { primary, secondary, ghost, soft, danger }

/// Button sizes from design-system.jsx.
enum AppButtonSize { sm, md, lg }

/// Paprika button primitive — mirrors design-system.jsx Button.
///
/// All colors and radii from [AppTokens].
/// Includes 0.97-scale press animation and outer drop shadow on primary.
class AppButton extends StatefulWidget {
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
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final (h, px, fs, r) = switch (widget.size) {
      AppButtonSize.sm => (36.0, 14.0, 14.0, AppTokens.radiusSm),
      AppButtonSize.md => (48.0, 18.0, 15.0, AppTokens.radiusMd),
      AppButtonSize.lg => (56.0, 22.0, 16.0, AppTokens.radiusLg),
    };

    final (bg, fg, border) = switch (widget.variant) {
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
          AppTokens.danger.withValues(alpha: 0.13),
        ),
    };

    final isPrimary = widget.variant == AppButtonVariant.primary;

    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.leading != null) ...[widget.leading!, const SizedBox(width: 8)],
        Text(
          widget.label,
          style: TextStyle(
            fontFamily: AppTokens.fontDisplay,
            fontWeight: FontWeight.w600,
            fontSize: fs,
            letterSpacing: -0.1,
            color: widget.disabled ? fg.withValues(alpha: 0.4) : fg,
          ),
        ),
        if (widget.trailing != null) ...[const SizedBox(width: 8), widget.trailing!],
      ],
    );

    if (widget.block) {
      content = SizedBox(
        width: double.infinity,
        child: Center(child: content),
      );
    }

    // Build outer drop shadow for primary variant (mirrors JSX `0 1px 2px rgba(26,15,12,0.08)`)
    final List<BoxShadow> shadows = isPrimary
        ? const [
            BoxShadow(
              color: Color(0x141A0F0C),
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ]
        : const [];

    // Inner highlight: top 1px white border approximating `inset 0 1px 0 rgba(255,255,255,0.12)`
    // Inner depression: bottom 1px dark border approximating `inset 0 -1px 0 rgba(0,0,0,0.15)`
    final Border? innerBorder = isPrimary
        ? const Border(
            top: BorderSide(color: Color(0x1FFFFFFF), width: 1),
            bottom: BorderSide(color: Color(0x261A0F0C), width: 1),
            left: BorderSide.none,
            right: BorderSide.none,
          )
        : null;

    Widget decorated = Stack(
      children: [
        // Base container
        Container(
          height: h,
          padding: EdgeInsets.symmetric(horizontal: px),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(r),
            border: border != null
                ? Border.all(color: border, width: 1)
                : null,
            boxShadow: shadows,
          ),
          child: content,
        ),
        // Inner highlight/depression overlay (primary only)
        if (isPrimary)
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(r),
                  border: innerBorder,
                ),
              ),
            ),
          ),
      ],
    );

    return Semantics(
      label: widget.semanticsLabel ?? widget.label,
      button: true,
      enabled: !widget.disabled,
      child: GestureDetector(
        onTapDown: widget.disabled
            ? null
            : (_) => setState(() => _pressed = true),
        onTapUp: widget.disabled
            ? null
            : (_) {
                setState(() => _pressed = false);
                widget.onPressed?.call();
              },
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedOpacity(
          opacity: widget.disabled ? 0.4 : 1.0,
          duration: const Duration(milliseconds: 120),
          child: AnimatedScale(
            scale: _pressed && !widget.disabled ? 0.97 : 1.0,
            duration: const Duration(milliseconds: 80),
            curve: Curves.easeOut,
            child: decorated,
          ),
        ),
      ),
    );
  }
}
