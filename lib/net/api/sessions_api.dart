import 'package:dio/dio.dart';

import '../../models/company.dart';
import '../../models/merchant.dart';

/// Response shape for POST /sessions/claim — Spec §3.1.
class ClaimSessionResponse {
  const ClaimSessionResponse({
    required this.sessionToken,
    required this.refreshToken,
    required this.deviceId,
    required this.company,
    required this.merchants,
  });

  final String sessionToken;
  final String refreshToken;
  final String deviceId;
  final Company company;
  final List<Merchant> merchants;

  factory ClaimSessionResponse.fromJson(Map<String, dynamic> json) {
    return ClaimSessionResponse(
      sessionToken: json['session_token'] as String,
      refreshToken: json['refresh_token'] as String,
      deviceId: json['device_id'] as String,
      company: Company.fromJson(json['company'] as Map<String, dynamic>),
      merchants: (json['merchants'] as List<dynamic>)
          .map((j) => Merchant.fromJson(j as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Response shape for POST /sessions/refresh — Spec §3.1.1.
class RefreshSessionResponse {
  const RefreshSessionResponse({
    required this.sessionToken,
    required this.refreshToken,
  });

  final String sessionToken;
  final String refreshToken;

  factory RefreshSessionResponse.fromJson(Map<String, dynamic> json) {
    return RefreshSessionResponse(
      sessionToken: json['session_token'] as String,
      refreshToken: json['refresh_token'] as String,
    );
  }
}

/// API client for /sessions endpoints — Spec §3.
///
/// All path strings live here. Never put them in providers or widgets.
class SessionsApi {
  SessionsApi(this._dio);

  final Dio _dio;

  /// POST /sessions/claim — authenticate with a company code.
  Future<ClaimSessionResponse> claim({
    required String companyCode,
    required String platform,
    required String model,
    String? pushToken,
  }) async {
    final r = await _dio.post<Map<String, dynamic>>(
      '/sessions/claim',
      data: {
        'company_code': companyCode,
        'device': {
          'platform': platform,
          'model': model,
          if (pushToken != null) 'push_token': pushToken, // ignore: use_null_aware_elements
        },
      },
    );
    return ClaimSessionResponse.fromJson(r.data!);
  }

  /// POST /sessions/refresh — rotate tokens.
  Future<RefreshSessionResponse> refresh(String refreshToken) async {
    final r = await _dio.post<Map<String, dynamic>>(
      '/sessions/refresh',
      data: {'refresh_token': refreshToken},
    );
    return RefreshSessionResponse.fromJson(r.data!);
  }

  /// POST /sessions/logout — revoke tokens and unregister push.
  Future<void> logout() async {
    await _dio.post<void>('/sessions/logout');
  }
}
