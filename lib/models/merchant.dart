import 'package:freezed_annotation/freezed_annotation.dart';

part 'merchant.freezed.dart';
part 'merchant.g.dart';

/// Merchant capabilities — mirrors Spec.md §2.2.
///
/// Unknown keys are tolerated — the object is open-ended per spec.
@freezed
abstract class MerchantCapabilities with _$MerchantCapabilities {
  const factory MerchantCapabilities({
    @JsonKey(name: 'scan_cpm') @Default(false) bool scanCpm,
    @JsonKey(name: 'cpm_ceiling') int? cpmCeiling,
  }) = _MerchantCapabilities;

  factory MerchantCapabilities.fromJson(Map<String, dynamic> json) =>
      _$MerchantCapabilitiesFromJson(json);
}

/// Merchant resource — mirrors Spec.md §2.2 verbatim.
@freezed
abstract class Merchant with _$Merchant {
  const factory Merchant({
    required String id,
    @JsonKey(name: 'company_id') required String companyId,
    required String name,
    required String code,
    @JsonKey(name: 'qr_payload') required String qrPayload,
    @Default(MerchantCapabilities()) MerchantCapabilities capabilities,
    @JsonKey(name: 'today_total') @Default(0) int todayTotal,
    @JsonKey(name: 'today_count') @Default(0) int todayCount,
    @JsonKey(name: 'month_total') @Default(0) int monthTotal,
    @JsonKey(name: 'unread_count') @Default(0) int unreadCount,
    @JsonKey(name: 'last_transaction_amount') int? lastTransactionAmount,
    @JsonKey(name: 'last_transaction_at') String? lastTransactionAt,
    @JsonKey(name: 'created_at') required String createdAt,
  }) = _Merchant;

  factory Merchant.fromJson(Map<String, dynamic> json) =>
      _$MerchantFromJson(json);
}
