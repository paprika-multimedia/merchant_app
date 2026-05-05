import 'package:dio/dio.dart';

import '../../models/transaction.dart';

/// API client for /transactions endpoints — Spec §4.3.
///
/// All path strings live here. Never put them in providers or widgets.
class TransactionsApi {
  TransactionsApi(this._dio);

  final Dio _dio;

  /// GET /transactions/:id — fetch a single transaction.
  ///
  /// Used after silent push to hydrate state (Spec §5.2).
  Future<Transaction> get(String txnId) async {
    final r = await _dio.get<Map<String, dynamic>>('/transactions/$txnId');
    return Transaction.fromJson(r.data!);
  }

  /// POST /transactions/:id/cancel — cancel a pending transaction.
  Future<Transaction> cancel(
    String txnId, {
    required String idempotencyKey,
  }) async {
    final r = await _dio.post<Map<String, dynamic>>(
      '/transactions/$txnId/cancel',
      options: Options(extra: {'idempotencyKey': idempotencyKey}),
    );
    return Transaction.fromJson(r.data!);
  }
}
