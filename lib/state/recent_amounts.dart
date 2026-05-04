import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../net/dio_client.dart';
import '../storage/secure_storage.dart';

/// Per-merchant, per-flow recent amounts (Handoff §4.7–§4.9).
///
/// Storage key: `paprika-recent-amounts:<merchant_id>:<flow>`
/// where flow is one of: 'qris', 'link', 'cpm'.
///
/// Falls back to flow-specific defaults when list is empty.
class RecentAmountsNotifier extends FamilyNotifier<List<int>, (String, String)> {
  static const _maxItems = 5;

  static const _defaults = {
    'qris': [5000, 10000, 25000, 50000, 100000],
    'link': [50000, 100000, 250000, 500000, 850000],
    'cpm': [5000, 10000, 25000, 50000, 100000],
  };

  @override
  List<int> build((String, String) arg) {
    // Load asynchronously; initial state is defaults
    _load();
    final (_, flow) = arg;
    return _defaults[flow] ?? [5000, 10000, 25000, 50000, 100000];
  }

  Future<void> _load() async {
    final storage = ref.read(secureStorageProvider);
    final (merchantId, flow) = arg;
    final key = SecureStorage.recentAmountsKey(merchantId, flow);
    final raw = await storage.read(key);
    if (raw != null) {
      try {
        final list = (jsonDecode(raw) as List<dynamic>)
            .map((e) => e as int)
            .toList();
        if (list.isNotEmpty) {
          state = list;
        }
      } catch (_) {}
    }
  }

  /// Records a successful payment amount, pushing it to the front.
  Future<void> push(int amount) async {
    final updated = [
      amount,
      ...state.where((a) => a != amount),
    ].take(_maxItems).toList();
    state = updated;

    final storage = ref.read(secureStorageProvider);
    final (merchantId, flow) = arg;
    await storage.write(
      SecureStorage.recentAmountsKey(merchantId, flow),
      jsonEncode(updated),
    );
  }
}

final recentAmountsProvider = NotifierProvider.family<
    RecentAmountsNotifier,
    List<int>,
    (String, String)>(RecentAmountsNotifier.new);
