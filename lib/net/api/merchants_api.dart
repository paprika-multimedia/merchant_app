import 'package:dio/dio.dart';

import '../../models/merchant.dart';
import '../../models/transaction.dart';

/// API client for /merchants endpoints — Spec §4.2.
///
/// All path strings live here. Never put them in providers or widgets.
class MerchantsApi {
  MerchantsApi(this._dio);

  final Dio _dio;

  /// GET /merchants — list all merchants for the current company.
  Future<List<Merchant>> list() async {
    final r = await _dio.get<List<dynamic>>('/merchants');
    return (r.data ?? [])
        .map((j) => Merchant.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  /// GET /merchants/:id — fetch a single merchant.
  Future<Merchant> get(String merchantId) async {
    final r =
        await _dio.get<Map<String, dynamic>>('/merchants/$merchantId');
    return Merchant.fromJson(r.data!);
  }

  /// POST /merchants/claim — claim a merchant via code.
  ///
  /// Returns the merchant (201 Created or 200 OK if already claimed).
  Future<Merchant> claim(
    String merchantCode, {
    required String idempotencyKey,
  }) async {
    final r = await _dio.post<Map<String, dynamic>>(
      '/merchants/claim',
      data: {'merchant_code': merchantCode},
      options: Options(extra: {'idempotencyKey': idempotencyKey}),
    );
    return Merchant.fromJson(r.data!);
  }

  /// POST /merchants/:id/seen — reset unread_count for a merchant.
  Future<void> markSeen(String merchantId) async {
    await _dio.post<void>('/merchants/$merchantId/seen');
  }

  /// DELETE /merchants/:id — remove merchant from company.
  ///
  /// [confirmName] must match the merchant name (Spec §4.2.2).
  Future<void> remove(
    String merchantId, {
    required String confirmName,
  }) async {
    await _dio.delete<void>(
      '/merchants/$merchantId',
      data: {'confirm_name': confirmName},
    );
  }

  /// GET /merchants/:id/transactions — list transactions for a merchant.
  Future<List<Transaction>> listTransactions(
    String merchantId, {
    String? cursor,
    int limit = 20,
    String? status,
    String? type,
  }) async {
    final r = await _dio.get<Map<String, dynamic>>(
      '/merchants/$merchantId/transactions',
      queryParameters: {
        if (cursor != null) 'cursor': cursor,
        'limit': limit,
        if (status != null) 'status': status,
        if (type != null) 'type': type,
      },
    );
    final data = r.data!['data'] as List<dynamic>;
    return data
        .map((j) => Transaction.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  /// POST /merchants/:id/qris — create a Dynamic QRIS transaction.
  Future<Map<String, dynamic>> createQris(
    String merchantId, {
    required int amount,
    String? note,
    required String idempotencyKey,
  }) async {
    final r = await _dio.post<Map<String, dynamic>>(
      '/merchants/$merchantId/qris',
      data: {
        'amount': amount,
        if (note != null && note.isNotEmpty) 'note': note,
      },
      options: Options(extra: {'idempotencyKey': idempotencyKey}),
    );
    return r.data!;
  }

  /// POST /merchants/:id/links — create a Payment Link transaction.
  Future<Map<String, dynamic>> createLink(
    String merchantId, {
    required String title,
    required int amount,
    String? customer,
    String? invoiceNumber,
    required String idempotencyKey,
  }) async {
    final r = await _dio.post<Map<String, dynamic>>(
      '/merchants/$merchantId/links',
      data: {
        'title': title,
        'amount': amount,
        if (customer != null && customer.isNotEmpty) 'customer': customer,
        if (invoiceNumber != null && invoiceNumber.isNotEmpty)
          'invoice_number': invoiceNumber,
      },
      options: Options(extra: {'idempotencyKey': idempotencyKey}),
    );
    return r.data!;
  }

  /// POST /merchants/:id/scan — execute a CPM charge.
  ///
  /// Idempotency-Key is REQUIRED for this endpoint (Spec §8).
  Future<Map<String, dynamic>> scan(
    String merchantId, {
    required String qrPayload,
    required int amount,
    required String idempotencyKey,
  }) async {
    final r = await _dio.post<Map<String, dynamic>>(
      '/merchants/$merchantId/scan',
      data: {
        'qr_payload': qrPayload,
        'amount': amount,
      },
      options: Options(extra: {'idempotencyKey': idempotencyKey}),
    );
    return r.data!;
  }
}
