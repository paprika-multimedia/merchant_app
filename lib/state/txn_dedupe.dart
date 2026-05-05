import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tracks transaction IDs already handled to prevent double-announcing.
///
/// A `transaction.paid` can arrive via both WebSocket and silent push for the
/// same `txn.id`. The second arrival is a no-op. Reset on logout.
class TxnDedupeNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => {};

  /// Returns true if this txnId has NOT been seen before (and marks it).
  bool markIfNew(String txnId) {
    if (state.contains(txnId)) return false;
    state = {...state, txnId};
    return true;
  }

  /// Clears all deduplication state (called on logout).
  void reset() => state = {};
}

final txnDedupeProvider = NotifierProvider<TxnDedupeNotifier, Set<String>>(
  TxnDedupeNotifier.new,
);
