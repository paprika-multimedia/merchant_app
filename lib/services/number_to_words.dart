/// Converts an IDR integer amount to spoken words.
///
/// Follows the rules in flutter-guide.md §Payment Notification.
class NumberToWords {
  NumberToWords._();

  // ─── Indonesian ────────────────────────────────────────────────────────────

  static const _id = [
    '',
    'satu',
    'dua',
    'tiga',
    'empat',
    'lima',
    'enam',
    'tujuh',
    'delapan',
    'sembilan',
    'sepuluh',
    'sebelas',
  ];

  /// Converts [amount] to Indonesian words, appending "rupiah".
  static String toIndonesian(int amount) {
    if (amount <= 0) return '';
    return '${_convertId(amount)} rupiah';
  }

  static String _convertId(int n) {
    if (n == 0) return 'nol';
    if (n < 0) return 'minus ${_convertId(-n)}';
    if (n < 12) return _id[n];
    if (n < 20) return '${_id[n - 10]} belas';
    if (n < 100) {
      final tens = n ~/ 10;
      final unit = n % 10;
      return '${_id[tens]} puluh${unit > 0 ? ' ${_id[unit]}' : ''}';
    }
    if (n < 200) {
      final rem = n % 100;
      return 'seratus${rem > 0 ? ' ${_convertId(rem)}' : ''}';
    }
    if (n < 1000) {
      final hundreds = n ~/ 100;
      final rem = n % 100;
      return '${_id[hundreds]} ratus${rem > 0 ? ' ${_convertId(rem)}' : ''}';
    }
    if (n < 2000) {
      final rem = n % 1000;
      return 'seribu${rem > 0 ? ' ${_convertId(rem)}' : ''}';
    }
    if (n < 1000000) {
      final thousands = n ~/ 1000;
      final rem = n % 1000;
      return '${_convertId(thousands)} ribu${rem > 0 ? ' ${_convertId(rem)}' : ''}';
    }
    if (n < 1000000000) {
      final millions = n ~/ 1000000;
      final rem = n % 1000000;
      return '${_convertId(millions)} juta${rem > 0 ? ' ${_convertId(rem)}' : ''}';
    }
    final billions = n ~/ 1000000000;
    final rem = n % 1000000000;
    return '${_convertId(billions)} miliar${rem > 0 ? ' ${_convertId(rem)}' : ''}';
  }

  // ─── English ───────────────────────────────────────────────────────────────

  static const _en = [
    '',
    'one',
    'two',
    'three',
    'four',
    'five',
    'six',
    'seven',
    'eight',
    'nine',
    'ten',
    'eleven',
    'twelve',
    'thirteen',
    'fourteen',
    'fifteen',
    'sixteen',
    'seventeen',
    'eighteen',
    'nineteen',
  ];

  static const _enTens = [
    '',
    '',
    'twenty',
    'thirty',
    'forty',
    'fifty',
    'sixty',
    'seventy',
    'eighty',
    'ninety',
  ];

  /// Converts [amount] to English words, appending "rupiah".
  static String toEnglish(int amount) {
    if (amount <= 0) return '';
    return '${_convertEn(amount)} rupiah';
  }

  static String _convertEn(int n) {
    if (n == 0) return 'zero';
    if (n < 20) return _en[n];
    if (n < 100) {
      final tens = n ~/ 10;
      final unit = n % 10;
      return _enTens[tens] + (unit > 0 ? '-${_en[unit]}' : '');
    }
    if (n < 1000) {
      final hundreds = n ~/ 100;
      final rem = n % 100;
      return '${_en[hundreds]} hundred${rem > 0 ? ' ${_convertEn(rem)}' : ''}';
    }
    if (n < 1000000) {
      final thousands = n ~/ 1000;
      final rem = n % 1000;
      return '${_convertEn(thousands)} thousand${rem > 0 ? ' ${_convertEn(rem)}' : ''}';
    }
    if (n < 1000000000) {
      final millions = n ~/ 1000000;
      final rem = n % 1000000;
      return '${_convertEn(millions)} million${rem > 0 ? ' ${_convertEn(rem)}' : ''}';
    }
    final billions = n ~/ 1000000000;
    final rem = n % 1000000000;
    return '${_convertEn(billions)} billion${rem > 0 ? ' ${_convertEn(rem)}' : ''}';
  }

  /// Converts [amount] to spoken words for the given [locale] ('id' or 'en').
  static String toWords(int amount, String locale) {
    if (amount <= 0) return '';
    return locale == 'en' ? toEnglish(amount) : toIndonesian(amount);
  }
}
