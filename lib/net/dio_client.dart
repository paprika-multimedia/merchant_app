import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import '../storage/secure_storage.dart';
import 'interceptors/accept_language.dart';
import 'interceptors/auth.dart';
import 'interceptors/client_version.dart';
import 'interceptors/idempotency.dart';

/// Creates and configures the Dio singleton with the full interceptor chain.
///
/// Interceptor order (must not be changed — see flutter-guide.md §7):
/// 1. AcceptLanguageInterceptor
/// 2. AuthInterceptor
/// 3. IdempotencyInterceptor
/// 4. ClientVersionInterceptor
Future<Dio> createDioClient(Ref ref, SecureStorage storage) async {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  final versionInterceptor = await ClientVersionInterceptor.create();

  dio.interceptors.addAll([
    AcceptLanguageInterceptor(ref),
    AuthInterceptor(dio, ref, storage),
    IdempotencyInterceptor(),
    versionInterceptor,
  ]);

  return dio;
}

/// Riverpod provider for the configured Dio client.
final dioProvider = FutureProvider<Dio>((ref) async {
  final storage = ref.read(secureStorageProvider);
  return createDioClient(ref, storage);
});

/// Provider for SecureStorage — shared singleton.
final secureStorageProvider = Provider<SecureStorage>((ref) {
  return SecureStorage();
});
