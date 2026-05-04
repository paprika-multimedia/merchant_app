import 'package:flutter_test/flutter_test.dart';
import 'package:paprika_merchant/services/number_to_words.dart';

void main() {
  group('NumberToWords.toIndonesian', () {
    test('returns empty string for zero', () {
      expect(NumberToWords.toIndonesian(0), '');
    });

    test('returns empty string for negative', () {
      expect(NumberToWords.toIndonesian(-1), '');
    });

    test('single digit', () {
      expect(NumberToWords.toIndonesian(5), 'lima rupiah');
    });

    test('teens — eleven uses sebelas', () {
      expect(NumberToWords.toIndonesian(11), 'sebelas rupiah');
    });

    test('teens — 15 is lima belas', () {
      expect(NumberToWords.toIndonesian(15), 'lima belas rupiah');
    });

    test('tens', () {
      expect(NumberToWords.toIndonesian(20), 'dua puluh rupiah');
    });

    test('tens + unit', () {
      expect(NumberToWords.toIndonesian(23), 'dua puluh tiga rupiah');
    });

    test('100 is seratus', () {
      expect(NumberToWords.toIndonesian(100), 'seratus rupiah');
    });

    test('100-range', () {
      expect(NumberToWords.toIndonesian(150), 'seratus lima puluh rupiah');
    });

    test('hundreds', () {
      expect(NumberToWords.toIndonesian(300), 'tiga ratus rupiah');
    });

    test('1000 is seribu', () {
      expect(NumberToWords.toIndonesian(1000), 'seribu rupiah');
    });

    test('1000-range', () {
      expect(NumberToWords.toIndonesian(1500), 'seribu lima ratus rupiah');
    });

    test('thousands', () {
      expect(NumberToWords.toIndonesian(5000), 'lima ribu rupiah');
    });

    test('50000', () {
      expect(NumberToWords.toIndonesian(50000), 'lima puluh ribu rupiah');
    });

    test('100000', () {
      expect(NumberToWords.toIndonesian(100000), 'seratus ribu rupiah');
    });

    test('1000000 — juta', () {
      expect(NumberToWords.toIndonesian(1000000), 'satu juta rupiah');
    });

    test('1250000 — juta + ratus + ribu', () {
      expect(
        NumberToWords.toIndonesian(1250000),
        'satu juta dua ratus lima puluh ribu rupiah',
      );
    });

    test('1000000000 — miliar', () {
      expect(NumberToWords.toIndonesian(1000000000), 'satu miliar rupiah');
    });
  });

  group('NumberToWords.toEnglish', () {
    test('returns empty for zero', () {
      expect(NumberToWords.toEnglish(0), '');
    });

    test('single digit', () {
      expect(NumberToWords.toEnglish(7), 'seven rupiah');
    });

    test('teen', () {
      expect(NumberToWords.toEnglish(13), 'thirteen rupiah');
    });

    test('tens + unit with hyphen', () {
      expect(NumberToWords.toEnglish(42), 'forty-two rupiah');
    });

    test('hundreds', () {
      expect(NumberToWords.toEnglish(200), 'two hundred rupiah');
    });

    test('thousands', () {
      expect(NumberToWords.toEnglish(50000), 'fifty thousand rupiah');
    });

    test('millions', () {
      expect(NumberToWords.toEnglish(1000000), 'one million rupiah');
    });

    test('billions', () {
      expect(NumberToWords.toEnglish(2000000000), 'two billion rupiah');
    });
  });

  group('NumberToWords.toWords dispatcher', () {
    test('id locale → Indonesian', () {
      expect(NumberToWords.toWords(50000, 'id'), 'lima puluh ribu rupiah');
    });

    test('en locale → English', () {
      expect(NumberToWords.toWords(50000, 'en'), 'fifty thousand rupiah');
    });

    test('unknown locale falls through to Indonesian', () {
      // any unrecognised locale uses Indonesian per toWords() implementation
      expect(NumberToWords.toWords(1000, 'fr'), 'seribu rupiah');
    });

    test('zero returns empty regardless of locale', () {
      expect(NumberToWords.toWords(0, 'id'), '');
      expect(NumberToWords.toWords(0, 'en'), '');
    });
  });
}
