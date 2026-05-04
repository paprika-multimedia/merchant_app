import 'package:freezed_annotation/freezed_annotation.dart';

import 'payer.dart';

part 'transaction.freezed.dart';
part 'transaction.g.dart';

/// Transaction status — mirrors Spec.md §2.3 status semantics.
enum TransactionStatus {
  pending,
  paid,
  expired,
  cancelled,
  failed,
  refunded,
}

/// Transaction type — mirrors Spec.md §2.3.
enum TransactionType {
  qris,
  link,
  cpm,
}

/// Transaction resource — mirrors Spec.md §2.3 verbatim.
@freezed
abstract class Transaction with _$Transaction {
  const factory Transaction({
    required String id,
    @JsonKey(name: 'merchant_id') required String merchantId,
    required TransactionType type,
    required String title,
    required String ref,
    required int amount,
    required TransactionStatus status,
    String? customer,
    String? note,
    @JsonKey(name: 'invoice_number') String? invoiceNumber,
    @JsonKey(name: 'link_url') String? linkUrl,
    /// Payer details for qris-type paid transactions.
    Payer? payer,
    /// CPM block — present only for type=cpm.
    CpmInfo? cpm,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'paid_at') String? paidAt,
    @JsonKey(name: 'expires_at') String? expiresAt,
  }) = _Transaction;

  factory Transaction.fromJson(Map<String, dynamic> json) =>
      _$TransactionFromJson(json);
}
