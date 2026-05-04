import 'package:freezed_annotation/freezed_annotation.dart';

part 'payer.freezed.dart';
part 'payer.g.dart';

/// Payer block for Dynamic QRIS transactions — mirrors Spec.md §2.3.
///
/// For CPM transactions the server intentionally omits payer_name on mobile
/// sessions. This model never stores or surfaces payer_name.
@freezed
class Payer with _$Payer {
  const factory Payer({
    /// Masked phone from issuer — optional, may be omitted by acquirer.
    @JsonKey(name: 'masked_phone') String? maskedPhone,
    /// Display-ready wallet/bank name.
    @JsonKey(name: 'issuer_name') String? issuerName,
  }) = _Payer;

  factory Payer.fromJson(Map<String, dynamic> json) => _$PayerFromJson(json);
}

/// CPM block for Scan QRIS transactions — mirrors Spec.md §2.3.
///
/// payer_name is intentionally absent: server strips it from mobile sessions.
@freezed
class CpmInfo with _$CpmInfo {
  const factory CpmInfo({
    /// Display-ready bank/wallet name.
    @JsonKey(name: 'issuer_name') required String issuerName,
    /// Masked account number.
    @JsonKey(name: 'masked_account') required String maskedAccount,
    // payer_name deliberately omitted — never store, never log, never render.
  }) = _CpmInfo;

  factory CpmInfo.fromJson(Map<String, dynamic> json) =>
      _$CpmInfoFromJson(json);
}
