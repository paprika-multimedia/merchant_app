import 'package:dio/dio.dart';

/// Reads an idempotency key from `RequestOptions.extra['idempotencyKey']`
/// and attaches it as the `Idempotency-Key` header.
///
/// The call site is responsible for generating and placing the key in extras.
/// This interceptor only lifts it to the header — it never generates keys.
class IdempotencyInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final key = options.extra['idempotencyKey'] as String?;
    if (key != null && key.isNotEmpty) {
      options.headers['Idempotency-Key'] = key;
    }
    handler.next(options);
  }
}
