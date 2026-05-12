import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/transaction.dart';
import '../net/ws/events.dart';
import '../net/ws/stream_client.dart';
import '../net/dio_client.dart';
import '../services/payment_announcer.dart';
import 'session.dart';
import 'txn_dedupe.dart';

/// WebSocket connection status.
enum WsStatus { disconnected, connecting, connected }

/// Aggregate WebSocket state — surfaces connection status plus the latest
/// event payloads that screens may want to react to (paid / expired /
/// cancelled / failed transactions, reconnects).
///
/// `eventSeq` increments on every dispatched event, even when the rest of
/// the fields are unchanged, so [Notifier]'s built-in equality check still
/// emits to listeners.
class WsState {
  const WsState({
    this.status = WsStatus.disconnected,
    this.lastPaidTxn,
    this.lastExpiredTxnId,
    this.lastCancelledTxnId,
    this.lastFailedTxnId,
    this.reconnectCount = 0,
    this.eventSeq = 0,
  });

  final WsStatus status;
  final Transaction? lastPaidTxn;
  final String? lastExpiredTxnId;
  final String? lastCancelledTxnId;
  final String? lastFailedTxnId;
  final int reconnectCount;
  final int eventSeq;

  WsState copyWith({
    WsStatus? status,
    Transaction? lastPaidTxn,
    String? lastExpiredTxnId,
    String? lastCancelledTxnId,
    String? lastFailedTxnId,
    int? reconnectCount,
    int? eventSeq,
  }) {
    return WsState(
      status: status ?? this.status,
      lastPaidTxn: lastPaidTxn ?? this.lastPaidTxn,
      lastExpiredTxnId: lastExpiredTxnId ?? this.lastExpiredTxnId,
      lastCancelledTxnId: lastCancelledTxnId ?? this.lastCancelledTxnId,
      lastFailedTxnId: lastFailedTxnId ?? this.lastFailedTxnId,
      reconnectCount: reconnectCount ?? this.reconnectCount,
      eventSeq: eventSeq ?? this.eventSeq,
    );
  }
}

/// Manages the WebSocket client lifecycle and event dispatch.
///
/// Starts the WS client when session is active and stops on logout.
class WsStateNotifier extends Notifier<WsState> {
  WsStreamClient? _client;
  int _eventSeq = 0;

 @override
  WsState build() {
    // Use listen() instead of watch() to avoid circular dependency.
    // We handle session changes in the listener callback, not during build.
    ref.listen(sessionProvider, (previous, next) {
      if (next.value != null) {
        _ensureStarted();
      } else {
        _stop();
      }
    });

    ref.onDispose(_stop);
    return const WsState();
  }

  void _ensureStarted() {
    if (_client != null) return;
    final storage = ref.read(secureStorageProvider);
    _client = WsStreamClient(
      storage: storage,
      onEvent: _handleEvent,
      onReconnect: _handleReconnect,
      onForceLogout: () => ref.read(sessionProvider.notifier).forceLogout(),
    );
    _client!.start();
    state = state.copyWith(status: WsStatus.connecting);
  }

  void _stop() {
    _client?.stop();
    _client = null;
    state = state.copyWith(status: WsStatus.disconnected);
  }

  void _handleEvent(WsEvent event) {
    _eventSeq++;
    switch (event) {
      case WsTxnEvent(:final event, :final transaction):
        if (event == 'transaction.paid') {
          final isNew = ref
              .read(txnDedupeProvider.notifier)
              .markIfNew(transaction.id);
          if (isNew) {
            state = state.copyWith(
              status: WsStatus.connected,
              lastPaidTxn: transaction,
              eventSeq: _eventSeq,
            );
            // TTS announcement — singleton init'd in main(); no-op if unavailable.
            final locale = ref.read(localeProvider);
            PaymentAnnouncer.instance.announce(transaction.amount, locale);
          } else {
            state = state.copyWith(
              status: WsStatus.connected,
              eventSeq: _eventSeq,
            );
          }
        } else {
          state = state.copyWith(
            status: WsStatus.connected,
            eventSeq: _eventSeq,
          );
        }
      case WsTxnExpiredEvent(:final id):
        state = state.copyWith(
          status: WsStatus.connected,
          lastExpiredTxnId: id,
          eventSeq: _eventSeq,
        );
      case WsTxnStatusEvent(:final event, :final id):
        if (event == 'transaction.cancelled') {
          state = state.copyWith(
            status: WsStatus.connected,
            lastCancelledTxnId: id,
            eventSeq: _eventSeq,
          );
        } else if (event == 'transaction.failed') {
          state = state.copyWith(
            status: WsStatus.connected,
            lastFailedTxnId: id,
            eventSeq: _eventSeq,
          );
        }
      case WsMerchantEvent(:final merchant):
        ref.read(sessionProvider.notifier).updateMerchant(merchant);
        state = state.copyWith(
          status: WsStatus.connected,
          eventSeq: _eventSeq,
        );
      case WsMerchantRemovedEvent(:final id):
        ref.read(sessionProvider.notifier).removeMerchant(id);
        state = state.copyWith(
          status: WsStatus.connected,
          eventSeq: _eventSeq,
        );
      case WsDeviceLoggedOutEvent():
        ref.read(sessionProvider.notifier).forceLogout();
      case WsPingEvent():
        state = state.copyWith(
          status: WsStatus.connected,
          eventSeq: _eventSeq,
        );
      default:
        break;
    }
  }

  void _handleReconnect() {
    _eventSeq++;
    state = state.copyWith(
      status: WsStatus.connecting,
      reconnectCount: state.reconnectCount + 1,
      eventSeq: _eventSeq,
    );
  }
}

final wsStateProvider = NotifierProvider<WsStateNotifier, WsState>(
  WsStateNotifier.new,
);
