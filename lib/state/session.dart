import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/company.dart';
import '../models/merchant.dart';
import '../net/api/sessions_api.dart';
import '../net/dio_client.dart';
import '../storage/secure_storage.dart';

/// Persisted session data.
class SessionData {
  const SessionData({
    required this.company,
    required this.merchants,
    required this.deviceId,
  });

  final Company company;
  final List<Merchant> merchants;
  final String deviceId;
}

/// Session provider — manages auth state, login, logout, token refresh.
///
/// Use [AsyncValue.data] to access session, null when not logged in.
class SessionNotifier extends AsyncNotifier<SessionData?> {
  @override
  Future<SessionData?> build() async {
    final storage = ref.read(secureStorageProvider);
    final token = await storage.read(SecureStorage.keySessionToken);
    if (token == null) return null;
    // Logged in — session will be hydrated by the app's startup fetch
    return null; // Caller must call hydrate() after startup
  }

  /// Claims a company and establishes a session.
  Future<SessionData> claim({
    required String companyCode,
  }) async {
    state = const AsyncValue.loading();
    final storage = ref.read(secureStorageProvider);
    final dio = await ref.read(dioProvider.future);
    final api = SessionsApi(dio);

    try {
      final platform = Platform.isIOS ? 'ios' : 'android';
      final model = Platform.localHostname;
      final response = await api.claim(
        companyCode: companyCode,
        platform: platform,
        model: model,
      );

      await storage.write(
        SecureStorage.keySessionToken,
        response.sessionToken,
      );
      await storage.write(
        SecureStorage.keyRefreshToken,
        response.refreshToken,
      );
      await storage.write(SecureStorage.keyDeviceId, response.deviceId);

      final data = SessionData(
        company: response.company,
        merchants: response.merchants,
        deviceId: response.deviceId,
      );
      state = AsyncValue.data(data);
      return data;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Refreshes the session token using the stored refresh token.
  Future<void> refresh() async {
    final storage = ref.read(secureStorageProvider);
    final dio = await ref.read(dioProvider.future);
    final api = SessionsApi(dio);

    final refreshToken = await storage.read(SecureStorage.keyRefreshToken);
    if (refreshToken == null) {
      await forceLogout();
      return;
    }

    final response = await api.refresh(refreshToken);
    await storage.write(
      SecureStorage.keySessionToken,
      response.sessionToken,
    );
    await storage.write(
      SecureStorage.keyRefreshToken,
      response.refreshToken,
    );
  }

  /// Logs out the current session, clearing all tokens.
  Future<void> logout() async {
    try {
      final dio = await ref.read(dioProvider.future);
      await SessionsApi(dio).logout();
    } catch (_) {
      // Best-effort — clear local state regardless
    }
    await forceLogout();
  }

  /// Force-clears session state without calling the server.
  /// Used when refresh token is revoked or on admin force-logout.
  Future<void> forceLogout() async {
    final storage = ref.read(secureStorageProvider);
    await storage.deleteAll();
    state = const AsyncValue.data(null);
  }

  /// Updates the merchant list (e.g. after claiming a new merchant).
  void updateMerchants(List<Merchant> merchants) {
    final current = state.value;
    if (current == null) return;
    state = AsyncValue.data(SessionData(
      company: current.company,
      merchants: merchants,
      deviceId: current.deviceId,
    ));
  }

  /// Updates a single merchant in the list (e.g. on merchant.updated WS event).
  void updateMerchant(Merchant merchant) {
    final current = state.value;
    if (current == null) return;
    final updated = current.merchants.map((m) {
      return m.id == merchant.id ? merchant : m;
    }).toList();
    state = AsyncValue.data(SessionData(
      company: current.company,
      merchants: updated,
      deviceId: current.deviceId,
    ));
  }

  /// Removes a merchant from the list (e.g. on merchant.removed WS event).
  void removeMerchant(String merchantId) {
    final current = state.value;
    if (current == null) return;
    final updated =
        current.merchants.where((m) => m.id != merchantId).toList();
    state = AsyncValue.data(SessionData(
      company: current.company,
      merchants: updated,
      deviceId: current.deviceId,
    ));
  }
}

final sessionProvider =
    AsyncNotifierProvider<SessionNotifier, SessionData?>(SessionNotifier.new);

/// The current locale ('id' or 'en'), persisted to secure storage.
class LocaleNotifier extends Notifier<String> {
  @override
  String build() => 'id'; // default; hydrated in main()

  /// Switch locale and persist.
  Future<void> setLocale(String lang) async {
    assert(lang == 'id' || lang == 'en');
    state = lang;
    await ref.read(secureStorageProvider).write(SecureStorage.keyLang, lang);
  }
}

final localeProvider =
    NotifierProvider<LocaleNotifier, String>(LocaleNotifier.new);
