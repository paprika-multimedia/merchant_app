import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/session.dart';
import '../../storage/secure_storage.dart';

/// Attaches `Authorization: Bearer <session_token>` and handles 401 refresh.
///
/// SINGLE-FLIGHT guarantee: concurrent 401 responses all wait on the same
/// [Completer] so only one `/sessions/refresh` call is made. Without this,
/// a second refresh request uses a rotated (already-revoked) refresh token
/// and destroys the session (Spec §3.1.1).
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._dio, this._ref, this._storage);

  final Dio _dio;
  final Ref _ref;
  final SecureStorage _storage;

  // Single-flight state
  bool _refreshing = false;
  Completer<void>? _refreshCompleter;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.read(SecureStorage.keySessionToken);
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401) {
      handler.next(err);
      return;
    }

    final errorCode = _extractErrorCode(err.response);
    // refresh_revoked → cannot recover, force logout
    if (errorCode == 'refresh_revoked') {
      await _ref.read(sessionProvider.notifier).forceLogout();
      handler.next(err);
      return;
    }

    // Attempt a single-flight refresh
    if (_refreshing) {
      // Another request is already refreshing — wait for it. If the in-flight
      // refresh fails it calls completeError, which would otherwise rethrow
      // out of onError and leave Dio's handler pipeline in an inconsistent
      // state — so propagate the original 401 instead.
      try {
        await _refreshCompleter!.future;
      } catch (_) {
        handler.next(err);
        return;
      }
      // Replay original request with new token
      final retried = await _retry(err.requestOptions);
      if (retried != null) {
        handler.resolve(retried);
      } else {
        handler.next(err);
      }
      return;
    }

    _refreshing = true;
    _refreshCompleter = Completer<void>();

    try {
      await _ref.read(sessionProvider.notifier).refresh();
      _refreshCompleter!.complete();
    } catch (e) {
      _refreshCompleter!.completeError(e);
      await _ref.read(sessionProvider.notifier).forceLogout();
      handler.next(err);
      return;
    } finally {
      _refreshing = false;
      _refreshCompleter = null;
    }

    // Replay original request
    final retried = await _retry(err.requestOptions);
    if (retried != null) {
      handler.resolve(retried);
    } else {
      handler.next(err);
    }
  }

  Future<Response?> _retry(RequestOptions original) async {
    try {
      final token = await _storage.read(SecureStorage.keySessionToken);
      final opts = Options(
        method: original.method,
        headers: {
          ...original.headers,
          if (token != null) 'Authorization': 'Bearer $token',
        },
        extra: original.extra,
      );
      return await _dio.request<dynamic>(
        original.path,
        data: original.data,
        queryParameters: original.queryParameters,
        options: opts,
      );
    } catch (_) {
      return null;
    }
  }

  String? _extractErrorCode(Response? response) {
    try {
      return (response?.data as Map<String, dynamic>?)?['error'] as String?;
    } catch (_) {
      return null;
    }
  }
}
