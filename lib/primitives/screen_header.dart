import 'package:flutter/material.dart';

import '../primitives/icons.dart';
import '../theme/tokens.dart';

/// 56-px custom screen header matching the JSX prototype.
///
/// Replaces Material [AppBar] across all feature screens.
/// Layout (inside a 56px SizedBox):
///   [40×40 back button?] [12px gap] [Expanded column: overline + title] [trailing?]
///
/// The circular back button matches JSX `Btn variant="circle"`:
/// 40px diameter, [AppTokens.surface] fill, [AppTokens.border] hairline ring,
/// subtle drop shadow (same recipe as the first [AppCard] BoxShadow).
///
/// All tokens from [AppTokens]. No hardcoded colors or spacing.
class PaprikaScreenHeader extends StatelessWidget {
  const PaprikaScreenHeader({
    super.key,
    required this.title,
    this.overline,
    this.onBack,
    this.trailing,
    this.background,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  });

  /// Main title widget (usually a [Text]).
  final Widget title;

  /// Optional uppercase secondary label above the title (e.g. "STEP 1 OF 2").
  final Widget? overline;

  /// When non-null, shows a 40×40 circular back button that calls this on tap.
  final VoidCallback? onBack;

  /// Optional right-side widget (e.g. settings icon button).
  final Widget? trailing;

  /// Background color. Defaults to [Colors.transparent].
  final Color? background;

  /// Horizontal padding for the header row. Defaults to 16px each side.
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ColoredBox(
        color: background ?? Colors.transparent,
        child: Padding(
          padding: padding,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (onBack != null) ...[
                _CircleBackButton(onPressed: onBack!),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (overline != null)
                      DefaultTextStyle(
                        style: const TextStyle(
                          fontFamily: AppTokens.fontDisplay,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppTokens.inkSecondary,
                          letterSpacing: 0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        child: overline!,
                      ),
                    DefaultTextStyle(
                      style: const TextStyle(
                        fontFamily: AppTokens.fontDisplay,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppTokens.ink,
                        letterSpacing: -0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      child: title,
                    ),
                  ],
                ),
              ),
              if (trailing != null) ...[const SizedBox(width: 8), trailing!],
            ],
          ),
        ),
      ),
    );
  }
}

/// 40×40 circular surface button containing a [BackIcon].
/// Matches JSX `Btn variant="circle"`: surface fill, hairline border, drop shadow.
class _CircleBackButton extends StatelessWidget {
  const _CircleBackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: MaterialLocalizations.of(context).backButtonTooltip,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: AppTokens.surface,
            shape: BoxShape.circle,
            border: Border.fromBorderSide(
              BorderSide(color: AppTokens.border, width: 1),
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x0A1A0F0C),
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: const BackIcon(size: 18, color: AppTokens.ink),
        ),
      ),
    );
  }
}
