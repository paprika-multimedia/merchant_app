// Tests for IdempotencyInterceptor.
//
// The interceptor reads options.extra['idempotencyKey'] and attaches it
// as the Idempotency-Key header before forwarding the request.
// Crucially, it never generates the key itself — the call site does that
// once per gesture, reusing it on retry.

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paprika_merchant/net/interceptors/idempotency.dart';

void main() {
  group('IdempotencyInterceptor', () {
    late IdempotencyInterceptor interceptor;

    setUp(() => interceptor = IdempotencyInterceptor());

    /// Creates RequestOptions with or without an idempotency key in extra.
    RequestOptions makeOpts({String? key}) {
      final extra = <String, dynamic>{};
      if (key != null) extra['idempotencyKey'] = key;
      return RequestOptions(path: '/test', extra: extra);
    }

    /// Runs the interceptor and returns the resulting headers map.
    /// Uses a real RequestInterceptorHandler to avoid double-call issues.
    Map<String, dynamic> runInterceptor(RequestOptions opts) {
      // The interceptor mutates options.headers in-place before calling next.
      // We pass a real handler; the interceptor will call handler.next(opts).
      // We capture the options object to inspect headers after the fact.
      interceptor.onRequest(
        opts,
        RequestInterceptorHandler(),
      );
      return opts.headers;
    }

    test('attaches Idempotency-Key header when key is present in extra', () {
      final opts = makeOpts(key: 'my-uuid-key');
      final headers = runInterceptor(opts);
      expect(headers['Idempotency-Key'], 'my-uuid-key');
    });

    test('does NOT attach header when extra is missing idempotencyKey', () {
      final opts = makeOpts(key: null);
      final headers = runInterceptor(opts);
      expect(headers.containsKey('Idempotency-Key'), isFalse);
    });

    test('does NOT attach header when key is empty string', () {
      final opts = RequestOptions(
        path: '/test',
        extra: {'idempotencyKey': ''},
      );
      final headers = runInterceptor(opts);
      expect(headers.containsKey('Idempotency-Key'), isFalse);
    });

    test('key is passed through verbatim (UUID format)', () {
      const uuid = '550e8400-e29b-41d4-a716-446655440000';
      final opts = makeOpts(key: uuid);
      final headers = runInterceptor(opts);
      expect(headers['Idempotency-Key'], uuid);
    });

    group('idempotency key reuse on retry', () {
      test('same key in extra on second call produces same header', () {
        const key = 'retry-key-123';

        // First attempt — caller puts key in extra
        final opts1 = makeOpts(key: key);
        expect(runInterceptor(opts1)['Idempotency-Key'], key);

        // Retry — caller reuses the same key (gesture-level idempotency key
        // is discarded only on success, never on error/retry)
        final opts2 = makeOpts(key: key);
        expect(runInterceptor(opts2)['Idempotency-Key'], key);
      });

      test('different requests get different keys', () {
        // Two independent gestures → two different keys
        const key1 = 'gesture-1-key';
        const key2 = 'gesture-2-key';

        final opts1 = makeOpts(key: key1);
        final opts2 = makeOpts(key: key2);

        expect(runInterceptor(opts1)['Idempotency-Key'], key1);
        expect(runInterceptor(opts2)['Idempotency-Key'], key2);
        expect(key1, isNot(key2));
      });
    });
  });
}
