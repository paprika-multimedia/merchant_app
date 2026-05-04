// Tests for the CodeInput character-cleaning logic.
//
// The TextInputFormatter inside CodeInput strips [^A-Z0-9], forces uppercase,
// and caps at 20 characters. These tests exercise that logic directly without
// needing a widget tree, mirroring the formatter's implementation.

import 'package:flutter_test/flutter_test.dart';

// ─── Extract the pure transform logic from CodeInput ─────────────────────────
// Mirrors the TextInputFormatter.withFunction callback in code_input.dart.

String _transform(String raw) {
  final cleaned = raw.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
  return cleaned.length > 20 ? cleaned.substring(0, 20) : cleaned;
}

void main() {
  group('CodeInput character cleaning', () {
    test('accepts uppercase alphanumerics unchanged', () {
      expect(_transform('ABC123'), 'ABC123');
    });

    test('uppercases lowercase letters', () {
      expect(_transform('abc'), 'ABC');
    });

    test('strips dashes (common in paste from display format)', () {
      expect(_transform('WK4F-82D1-XY9Z-AB3C'), 'WK4F82D1XY9ZAB3C');
    });

    test('strips spaces', () {
      expect(_transform('WK 4F 82'), 'WK4F82');
    });

    test('strips non-alphanumeric symbols', () {
      expect(_transform('A!B@C#1\$2%3'), 'ABC123');
    });

    test('preserves digits', () {
      expect(_transform('0123456789'), '0123456789');
    });

    test('caps at 20 characters', () {
      final long = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'; // 26 chars
      expect(_transform(long).length, 20);
    });

    test('caps at exactly 20 after stripping special chars', () {
      // After stripping dashes from a 25-char string that becomes 21 alphanumeric
      final pasted = 'ABCDE-FGHIJ-KLMNO-PQRST-U'; // 21 alphanum after strip
      final result = _transform(pasted);
      expect(result.length, 20);
    });

    test('empty input produces empty output', () {
      expect(_transform(''), '');
    });

    test('only special characters produces empty output', () {
      expect(_transform('---!!@'), '');
    });

    test('full 20-char code with dashes round-trips correctly', () {
      // Display format (what user copies from a printout) → raw storage format
      const display = 'WK4F8-2D1XY-9ZAB3-C7KP1';
      const expected = 'WK4F82D1XY9ZAB3C7KP1'; // 20 chars
      expect(_transform(display), expected);
    });
  });

  group('CodeInput 5-5-5-5 group display', () {
    // Tests the slot grouping logic independently.
    // Mirrors _SlotDisplay.build() logic.

    List<List<String>> buildGroups(String value) {
      final groups = <List<String>>[];
      for (int i = 0; i < 4; i++) {
        final group = <String>[];
        for (int j = 0; j < 5; j++) {
          final idx = i * 5 + j;
          group.add(idx < value.length ? value[idx] : '');
        }
        groups.add(group);
      }
      return groups;
    }

    test('empty value → all slots empty', () {
      final groups = buildGroups('');
      for (final g in groups) {
        expect(g, everyElement(''));
      }
    });

    test('3-char value fills first group partially', () {
      final groups = buildGroups('ABC');
      expect(groups[0], ['A', 'B', 'C', '', '']);
      expect(groups[1], everyElement(''));
    });

    test('5-char value fills first group completely', () {
      final groups = buildGroups('ABCDE');
      expect(groups[0], ['A', 'B', 'C', 'D', 'E']);
      expect(groups[1], everyElement(''));
    });

    test('6-char value spills into second group', () {
      final groups = buildGroups('ABCDEF');
      expect(groups[0], ['A', 'B', 'C', 'D', 'E']);
      expect(groups[1][0], 'F');
      expect(groups[1].sublist(1), everyElement(''));
    });

    test('20-char value fills all groups completely', () {
      const value = 'ABCDEFGHIJKLMNOPQRST'; // exactly 20
      final groups = buildGroups(value);
      expect(groups.expand((g) => g).toList().join(''), value);
      for (final g in groups) {
        expect(g.every((c) => c.isNotEmpty), isTrue);
      }
    });
  });
}
