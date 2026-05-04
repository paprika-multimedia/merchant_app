import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/merchant.dart';
import 'session.dart';

/// Tracks the currently-selected merchant ID.
///
/// Persisted to SharedPreferences (non-sensitive — it's just a route param).
class ActiveMerchantNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  /// Sets the active merchant by ID and persists it.
  Future<void> setActive(String? merchantId) async {
    state = merchantId;
    final prefs = await SharedPreferences.getInstance();
    if (merchantId == null) {
      await prefs.remove('paprika-active-merchant');
    } else {
      await prefs.setString('paprika-active-merchant', merchantId);
    }
  }

  /// Restores persisted active merchant on cold start.
  Future<void> restore() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getString('paprika-active-merchant');
  }
}

final activeMerchantIdProvider =
    NotifierProvider<ActiveMerchantNotifier, String?>(
  ActiveMerchantNotifier.new,
);

/// Convenience provider that resolves the active merchant object from session.
final activeMerchantProvider = Provider<Merchant?>((ref) {
  final merchantId = ref.watch(activeMerchantIdProvider);
  final session = ref.watch(sessionProvider).valueOrNull;
  if (merchantId == null || session == null) return null;
  try {
    return session.merchants.firstWhere((m) => m.id == merchantId);
  } catch (_) {
    return null;
  }
});
