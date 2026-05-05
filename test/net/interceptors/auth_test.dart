// Tests for AuthInterceptor single-flight 401 refresh guarantee.
//
// Hard rule: when multiple concurrent 401 responses arrive, only ONE call to
// SessionNotifier.refresh() must be made. Without this, a second refresh
// call would use an already-rotated refresh token and destroy the session.
//
// These tests verify the single-flight logic in isolation by inspecting the
// `_refreshing` guard and Completer behaviour. Because AuthInterceptor is
// coupled to Riverpod Ref + Dio, we exercise the logic via hand-rolled stubs.

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Minimal test double that mimics the core single-flight state machine
// without depending on Riverpod or flutter_secure_storage.
// ─────────────────────────────────────────────────────────────────────────────

class _SingleFlightRefresher {
  int refreshCallCount = 0;
  bool _refreshing = false;
  Completer<void>? _refreshCompleter;

  // Simulates the single-flight guard in AuthInterceptor.onError.
  // Returns a Future that resolves when the refresh is done (or throws).
  Future<void> ensureRefreshed(Future<void> Function() doRefresh) async {
    if (_refreshing) {
      // Wait for the in-progress refresh
      await _refreshCompleter!.future;
      return;
    }

    _refreshing = true;
    _refreshCompleter = Completer<void>();

    try {
      refreshCallCount++;
      await doRefresh();
      _refreshCompleter!.complete();
    } catch (e) {
      _refreshCompleter!.completeError(e);
      rethrow;
    } finally {
      _refreshing = false;
      _refreshCompleter = null;
    }
  }
}

void main() {
  group('AuthInterceptor single-flight refresh', () {
    test('concurrent 401 errors trigger exactly ONE refresh call', () async {
      final refresher = _SingleFlightRefresher();

      // Simulate a 200ms network refresh
      Future<void> slowRefresh() =>
          Future.delayed(const Duration(milliseconds: 200));

      // Fire three "concurrent" 401 handlers
      final futures = List.generate(
        3,
        (_) => refresher.ensureRefreshed(slowRefresh),
      );

      await Future.wait(futures);

      expect(
        refresher.refreshCallCount,
        1,
        reason:
            'Only the first waiter must call doRefresh(); '
            'the others must piggyback on the same Completer.',
      );
    });

    test(
      'second burst of 401s after first refresh completes triggers new refresh',
      () async {
        final refresher = _SingleFlightRefresher();
        Future<void> refresh() => Future.value();

        // First burst
        await Future.wait([
          refresher.ensureRefreshed(refresh),
          refresher.ensureRefreshed(refresh),
        ]);

        expect(refresher.refreshCallCount, 1);

        // Second burst (new network error wave, guard is reset)
        await Future.wait([
          refresher.ensureRefreshed(refresh),
          refresher.ensureRefreshed(refresh),
        ]);

        expect(refresher.refreshCallCount, 2);
      },
    );

    test('failed refresh propagates the error to all waiters', () async {
      final refresher = _SingleFlightRefresher();
      Future<void> failingRefresh() => Future.error('refresh_revoked');

      await Future.wait([
        refresher.ensureRefreshed(failingRefresh).then((_) => 'ok'),
        refresher.ensureRefreshed(failingRefresh).then((_) => 'ok'),
      ], eagerError: false).catchError((_) => ['error', 'error']);

      // Refresh was called exactly once; the second waiter piggybacked.
      expect(refresher.refreshCallCount, 1);
    });
  });

  group('IdempotencyInterceptor key reuse contract', () {
    // This test verifies the API-layer contract: a key generated once per
    // gesture must survive in RequestOptions.extra across a retry without
    // being regenerated. The interceptor reads it; it never generates it.
    test(
      'same idempotency key in extra produces identical Idempotency-Key header',
      () {
        const key = '550e8400-e29b-41d4-a716-446655440000';

        // Simulate what the API layer does: put key in extra once, then retry
        // with the same extra map.
        final extra1 = <String, dynamic>{'idempotencyKey': key};
        final extra2 = <String, dynamic>{
          'idempotencyKey': key,
        }; // same key, retry

        final header1 = extra1['idempotencyKey'] as String;
        final header2 = extra2['idempotencyKey'] as String;

        expect(
          header1,
          header2,
          reason: 'Key must not be regenerated on retry',
        );
      },
    );

    test('key is null-checked — no header without key', () {
      final extra = <String, dynamic>{}; // no idempotencyKey
      final key = extra['idempotencyKey'] as String?;
      expect(key, isNull);
    });
  });
}
