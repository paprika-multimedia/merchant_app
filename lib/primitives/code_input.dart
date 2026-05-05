import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/tokens.dart';

/// 20-character code input displayed in 5-5-5-5 groups.
///
/// Strips non-[A-Z0-9] characters (including dashes from pastes).
/// Forces uppercase. Caps at 20 characters.
/// Uses an invisible TextField overlaid on a styled row of slot chars.
class CodeInput extends StatefulWidget {
  const CodeInput({
    super.key,
    required this.onChanged,
    this.initialValue = '',
    this.error,
    this.showCounter = true,
  });

  final ValueChanged<String> onChanged;
  final String initialValue;
  final String? error;

  /// Whether to render the `n / 20` counter below the input.
  /// Pass `false` when the parent renders the counter inline (M8).
  final bool showCounter;

  @override
  State<CodeInput> createState() => _CodeInputState();
}

class _CodeInputState extends State<CodeInput> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  String _value = '';

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
    _controller = TextEditingController(text: _value);
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleChange(String raw) {
    // Strip non-alphanumeric, force uppercase, cap at 20
    final cleaned = raw
        .toUpperCase()
        .replaceAll(RegExp(r'[^A-Z0-9]'), '')
        .substring(0, min(20, raw.length > 20 ? 20 : raw.length));

    // Re-strip after uppercase to handle edge cases
    final final_ = cleaned.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
    final clamped = final_.length > 20 ? final_.substring(0, 20) : final_;

    if (clamped != _value) {
      setState(() => _value = clamped);
      // Sync controller without rebuilding twice
      _controller.value = TextEditingValue(
        text: clamped,
        selection: TextSelection.collapsed(offset: clamped.length),
      );
      widget.onChanged(clamped);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            // Visual slot display
            _SlotDisplay(value: _value),
            // Invisible text field captures input
            Positioned.fill(
              child: Opacity(
                opacity: 0,
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  onChanged: _handleChange,
                  // visiblePassword keeps alphanumeric keyboard on iOS
                  // without autocorrect
                  keyboardType: TextInputType.visiblePassword,
                  textCapitalization: TextCapitalization.characters,
                  autocorrect: false,
                  enableSuggestions: false,
                  maxLength: 20,
                  inputFormatters: [
                    TextInputFormatter.withFunction((old, neu) {
                      final cleaned = neu.text.toUpperCase().replaceAll(
                        RegExp(r'[^A-Z0-9]'),
                        '',
                      );
                      final clamped = cleaned.length > 20
                          ? cleaned.substring(0, 20)
                          : cleaned;
                      return TextEditingValue(
                        text: clamped,
                        selection: TextSelection.collapsed(
                          offset: clamped.length,
                        ),
                      );
                    }),
                  ],
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    counterText: '',
                  ),
                ),
              ),
            ),
          ],
        ),
        if (widget.error != null) ...[
          const SizedBox(height: 6),
          Text(
            widget.error!,
            style: const TextStyle(
              fontFamily: AppTokens.fontDisplay,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppTokens.danger,
            ),
          ),
        ],
        if (widget.showCounter) ...[
          const SizedBox(height: 6),
          Text(
            '${_value.length} / 20',
            style: const TextStyle(
              fontFamily: AppTokens.fontDisplay,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppTokens.inkTertiary,
            ),
          ),
        ],
      ],
    );
  }
}

class _SlotDisplay extends StatelessWidget {
  const _SlotDisplay({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    // Display as 4 groups of 5, joined by dashes
    final groups = <List<String>>[];
    for (int i = 0; i < 4; i++) {
      final group = <String>[];
      for (int j = 0; j < 5; j++) {
        final idx = i * 5 + j;
        group.add(idx < value.length ? value[idx] : '');
      }
      groups.add(group);
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: AppTokens.surface,
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        border: Border.all(color: AppTokens.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (int g = 0; g < 4; g++) ...[
            if (g > 0)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  '-',
                  style: TextStyle(
                    fontFamily: AppTokens.fontMono,
                    fontSize: 18,
                    color: AppTokens.inkTertiary,
                    letterSpacing: 2,
                  ),
                ),
              ),
            Row(
              children: groups[g].map((char) {
                final isEmpty = char.isEmpty;
                return SizedBox(
                  width: 18,
                  child: Text(
                    isEmpty ? '·' : char,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppTokens.fontMono,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2,
                      color: isEmpty ? AppTokens.inkDisabled : AppTokens.ink,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
