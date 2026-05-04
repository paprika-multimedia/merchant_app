import 'package:flutter_test/flutter_test.dart';
import 'package:paprika_merchant/config/app_config.dart';

/// Tests for compile-time AppConfig values.
///
/// Note: dart-define values are baked in at compile time. The tests below
/// verify the defaults (no --dart-define flags passed), which is what
/// `flutter test` uses when run without extra defines.
void main() {
  group('AppConfig defaults', () {
    test('apiBaseUrl defaults to local simulator', () {
      // Default when API_BASE_URL is not set
      expect(AppConfig.apiBaseUrl, 'http://localhost:8080/v1');
    });

    test('wsUrl defaults to local simulator', () {
      // Default when WS_URL is not set
      expect(AppConfig.wsUrl, 'ws://localhost:8080/v1/stream');
    });

    test('enableFirebase defaults to true', () {
      // Default when ENABLE_FIREBASE is not set — production builds always
      // have Firebase enabled unless the flag is explicitly passed.
      expect(AppConfig.enableFirebase, isTrue);
    });

    test('apiBaseUrl is a non-empty string', () {
      expect(AppConfig.apiBaseUrl, isNotEmpty);
    });

    test('wsUrl starts with ws:// or wss://', () {
      final url = AppConfig.wsUrl;
      expect(
        url.startsWith('ws://') || url.startsWith('wss://'),
        isTrue,
        reason: 'WS URL must use ws:// or wss:// scheme, got: $url',
      );
    });
  });
}
