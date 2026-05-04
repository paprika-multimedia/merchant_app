import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../net/dio_client.dart';

/// Per-merchant last-transaction amount (company dashboard row display).
///
/// Storage key: `paprika-last-tx-amount:<merchant_id>`
///
/// Defaults: if no stored value exists for a given merchantId, returns a
/// deterministic default from [_kDefaults] keyed by
/// `merchantId.hashCode.abs() % 5` — same merchant always maps to the same
/// default, no UI flicker. The default is NOT written to storage; only
/// amounts from real completed payments persist.
///
/// Usage:
///   ref.watch(lastTxAmountProvider('mch_123'))  → int
///   ref.read(lastTxAmountProvider('mch_123').notifier).setLast(amount)
class LastTxAmountNotifier extends Notifier<int> {
  LastTxAmountNotifier(this._merchantId);

  final String _merchantId;

  static const _kDefaults = [5000, 10000, 20000, 50000, 100000];

  static String _key(String merchantId) =>
      'paprika-last-tx-amount:$merchantId';

  int get _defaultAmount =>
      _kDefaults[_merchantId.hashCode.abs() % _kDefaults.length];

  @override
  int build() {
    _load();
    return _defaultAmount;
  }

  Future<void> _load() async {
    final storage = ref.read(secureStorageProvider);
    final raw = await storage.read(_key(_merchantId));
    if (raw != null) {
      final parsed = int.tryParse(raw);
      if (parsed != null && parsed > 0) {
        state = parsed;
      }
    }
  }

  /// Persists [amount] as the last transaction amount for this merchant.
  /// Call this immediately after a payment succeeds.
  Future<void> setLast(int amount) async {
    state = amount;
    final storage = ref.read(secureStorageProvider);
    await storage.write(_key(_merchantId), amount.toString());
  }
}

/// Family provider for per-merchant last-transaction amount.
///
/// Arg: merchantId (String).
final lastTxAmountProvider = NotifierProvider.family<
    LastTxAmountNotifier,
    int,
    String>((merchantId) => LastTxAmountNotifier(merchantId));
