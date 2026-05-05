import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// Custom 3×4 numeric keypad for amount entry.
///
/// Suppresses the OS keyboard — all amount entry uses this widget.
/// Hard rule: never use a TextField on amount-entry screens.
class AmountKeypad extends StatelessWidget {
  const AmountKeypad({
    super.key,
    required this.onDigit,
    required this.onBackspace,
    required this.onTripleZero,
  });

  /// Called with the digit character ('0'–'9').
  final void Function(String digit) onDigit;

  /// Called when the backspace key is tapped.
  final VoidCallback onBackspace;

  /// Called when '000' key is tapped.
  final VoidCallback onTripleZero;

  static const _keys = [
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '000',
    '0',
    '⌫',
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 2.2,
      mainAxisSpacing: AppTokens.sp4,
      crossAxisSpacing: AppTokens.sp4,
      children: _keys
          .map(
            (key) => _KeypadButton(
              label: key,
              onTap: () {
                if (key == '⌫') {
                  onBackspace();
                } else if (key == '000') {
                  onTripleZero();
                } else {
                  onDigit(key);
                }
              },
            ),
          )
          .toList(),
    );
  }
}

class _KeypadButton extends StatelessWidget {
  const _KeypadButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isBackspace = label == '⌫';
    return Semantics(
      button: true,
      label: isBackspace ? 'Backspace' : label,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: AppTokens.surfaceAlt,
            borderRadius: BorderRadius.circular(AppTokens.radiusSm),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontFamily: AppTokens.fontDisplay,
              fontSize: isBackspace ? 20 : 22,
              fontWeight: FontWeight.w500,
              color: AppTokens.ink,
            ),
          ),
        ),
      ),
    );
  }
}
