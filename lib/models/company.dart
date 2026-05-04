import 'package:freezed_annotation/freezed_annotation.dart';

part 'company.freezed.dart';
part 'company.g.dart';

/// Company resource — mirrors Spec.md §2.1 verbatim.
@freezed
abstract class Company with _$Company {
  const factory Company({
    required String id,
    required String name,
    required String code,
    @JsonKey(name: 'qr_payload') required String qrPayload,
    required String timezone,
    @JsonKey(name: 'created_at') required String createdAt,
  }) = _Company;

  factory Company.fromJson(Map<String, dynamic> json) =>
      _$CompanyFromJson(json);
}
