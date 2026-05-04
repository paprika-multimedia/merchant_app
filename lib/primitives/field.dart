import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/tokens.dart';

/// Text input field — mirrors design-system.jsx Field.
class AppField extends StatefulWidget {
  const AppField({
    super.key,
    this.label,
    this.placeholder,
    this.value,
    this.controller,
    this.onChanged,
    this.prefix,
    this.suffix,
    this.hint,
    this.error,
    this.readOnly = false,
    this.large = false,
    this.monospace = false,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.focusNode,
    this.autofocus = false,
    this.maxLength,
    this.maxLines = 1,
  });

  final String? label;
  final String? placeholder;
  /// External value — when set, the internal controller tracks this value.
  /// Only one of [value] or [controller] should be set.
  final String? value;
  /// External controller — takes precedence over [value] when both are set.
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final String? prefix;
  final String? suffix;
  final String? hint;
  final String? error;
  final bool readOnly;
  final bool large;
  final bool monospace;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final bool autofocus;
  final int? maxLength;
  final int? maxLines;

  @override
  State<AppField> createState() => _AppFieldState();
}

class _AppFieldState extends State<AppField> {
  bool _focused = false;
  // Internal controller — only created when [widget.controller] is null and
  // [widget.value] is non-null so we can own its lifecycle.
  TextEditingController? _internalController;

  TextEditingController? get _effectiveController =>
      widget.controller ?? _internalController;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null && widget.value != null) {
      _internalController = TextEditingController(text: widget.value);
    }
  }

  @override
  void didUpdateWidget(AppField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the caller controls via [value] (no external controller), sync only
    // when the value has changed to avoid cursor-jump on every keystroke.
    if (widget.controller == null && widget.value != null) {
      _internalController ??= TextEditingController(text: widget.value);
      if (widget.value != _internalController!.text) {
        _internalController!.text = widget.value!;
      }
    }
  }

  @override
  void dispose() {
    _internalController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isError = widget.error != null;
    final borderColor = isError
        ? AppTokens.danger
        : _focused
            ? AppTokens.accent
            : AppTokens.border;
    final borderWidth = _focused ? 2.0 : 1.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: const TextStyle(
              fontFamily: AppTokens.fontDisplay,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTokens.inkSecondary,
              letterSpacing: -0.1,
            ),
          ),
          const SizedBox(height: 6),
        ],
        AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          decoration: BoxDecoration(
            color: AppTokens.surface,
            borderRadius: BorderRadius.circular(AppTokens.radiusMd),
            border: Border.all(color: borderColor, width: borderWidth),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: AppTokens.sp14,
            vertical: widget.large ? 14 : 12,
          ),
          child: Row(
            children: [
              if (widget.prefix != null) ...[
                Text(
                  widget.prefix!,
                  style: TextStyle(
                    fontFamily: AppTokens.fontDisplay,
                    fontSize: widget.large ? 18 : 15,
                    fontWeight: FontWeight.w500,
                    color: AppTokens.inkTertiary,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Focus(
                  onFocusChange: (f) => setState(() => _focused = f),
                  child: TextField(
                    controller: _effectiveController,
                    onChanged: widget.onChanged,
                    readOnly: widget.readOnly,
                    focusNode: widget.focusNode,
                    autofocus: widget.autofocus,
                    keyboardType: widget.keyboardType,
                    textCapitalization: widget.textCapitalization,
                    inputFormatters: widget.inputFormatters,
                    maxLength: widget.maxLength,
                    maxLines: widget.maxLines,
                    minLines: 1,
                    decoration: InputDecoration(
                      hintText: widget.placeholder,
                      hintStyle: TextStyle(
                        color: AppTokens.inkDisabled,
                        fontFamily: widget.monospace
                            ? AppTokens.fontMono
                            : AppTokens.fontDisplay,
                        fontSize: widget.large ? 20 : 15,
                        fontWeight: widget.large
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      counterText: '',
                    ),
                    style: TextStyle(
                      fontFamily: widget.monospace
                          ? AppTokens.fontMono
                          : AppTokens.fontDisplay,
                      fontSize: widget.large ? 20 : 15,
                      fontWeight:
                          widget.large ? FontWeight.w600 : FontWeight.w500,
                      color: AppTokens.ink,
                      letterSpacing: widget.monospace ? 1.0 : -0.1,
                    ),
                  ),
                ),
              ),
              if (widget.suffix != null) ...[
                const SizedBox(width: 8),
                Text(
                  widget.suffix!,
                  style: const TextStyle(
                    color: AppTokens.inkTertiary,
                    fontFamily: AppTokens.fontDisplay,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (widget.hint != null || widget.error != null) ...[
          const SizedBox(height: 6),
          Text(
            widget.error ?? widget.hint!,
            style: TextStyle(
              fontFamily: AppTokens.fontDisplay,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isError ? AppTokens.danger : AppTokens.inkTertiary,
            ),
          ),
        ],
      ],
    );
  }
}
