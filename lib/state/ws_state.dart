import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/transaction.dart';
import '../net/ws/events.dart';
import '../net/ws/stream_client.dart';
import '../net/dio_client.dart';
import 'session.dart';
import 'txn_dedupe.dart';

/// WebSocket connection status.
enum WsStatus { disconnected, connecting, connected }

/// Manages the WebSocket client lifecycle and event dispatch.
///
/// Starts the WS client when session is active and stops on logout.
class WsStateNotifier extends Notifier<WsStatus> {
  WsStreamClient? _client;

  /// The most recently paid transaction (for TTS announcement).
  /// External listeners (e.g. PaymentAnnouncer) can watch via [paidTxnStream].
  Transaction? _latestPaidTxn;
  Transaction? get latestPaidTxn => _latestPaidTxn;

  /// Reconnect counter — increments every time WS reconnects.
  /// Screens watch this to trigger a re-fetch on reconnect.
  int _reconnectCount = 0;
  int get reconnectCount => _reconnectCount;

  @override
  WsStatus build() {
    // React to session changes
    final session = ref.watch(sessionProvider);
    if (session.valueOrNull != null) {
      _ensureStarted();
    } else {
      _stop();
    }

    ref.onDispose(_stop);
    return WsStatus.disconnected;
  }

  void _ensureStarted() {
    if (_client != null) return;
    final storage = ref.read(secureStorageProvider);
    _client = WsStreamClient(
      storage: storage,
      onEvent: _handleEvent,
      onReconnect: _handleReconnect,
      onForceLogout: () =>
          ref.read(sessionProvider.notifier).forceLogout(),
    );
    _client!.start();
    state = WsStatus.connecting;
  }

  void _stop() {
    _client?.stop();
    _client = null;
    state = WsStatus.disconnected;
  }

  void _handleEvent(WsEvent event) {
    state = WsStatus.connected;
    switch (event) {
      case WsTxnEvent(:final event, :final transaction):
        if (event == 'transaction.paid') {
          final isNew =
              ref.read(txnDedupeProvider.notifier).markIfNew(transaction.id);
          if (isNew) {
            _latestPaidTxn = transaction;
            // Re-notify listeners by triggering a state update
            // ignore: invalid_use_of_protected_member
            state = WsStatus.connected;
          }
        }
      case WsMerchantEvent(:final merchant):
        ref.read(sessionProvider.notifier).updateMerchant(merchant);
      case WsMerchantRemovedEvent(:final id):
        ref.read(sessionProvider.notifier).removeMerchant(id);
      case WsDeviceLoggedOutEvent():
        ref.read(sessionProvider.notifier).forceLogout();
      case WsPingEvent():
        state = WsStatus.connected;
      default:
        break;
    }
  }

  void _handleReconnect() {
    _reconnectCount++;
    state = WsStatus.connecting;
    // Screens that watch reconnectCount will re-fetch their resources
  }
}

final wsStateProvider =
    NotifierProvider<WsStateNotifier, WsStatus>(WsStateNotifier.new);
