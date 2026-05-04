import '../../models/merchant.dart';
import '../../models/transaction.dart';

/// Typed WebSocket event payloads — mirrors Spec.md §5.3.
sealed class WsEvent {
  const WsEvent();
}

/// transaction.created / transaction.paid — full Transaction payload.
final class WsTxnEvent extends WsEvent {
  const WsTxnEvent({required this.event, required this.transaction});
  final String event;
  final Transaction transaction;
}

/// transaction.expired — minimal payload.
final class WsTxnExpiredEvent extends WsEvent {
  const WsTxnExpiredEvent({
    required this.id,
    required this.merchantId,
    required this.expiresAt,
  });
  final String id;
  final String merchantId;
  final String expiresAt;
}

/// transaction.cancelled / transaction.failed — minimal payload.
final class WsTxnStatusEvent extends WsEvent {
  const WsTxnStatusEvent({
    required this.event,
    required this.id,
    required this.merchantId,
    this.reason,
  });
  final String event;
  final String id;
  final String merchantId;
  final String? reason;
}

/// merchant.added / merchant.updated — full Merchant payload.
final class WsMerchantEvent extends WsEvent {
  const WsMerchantEvent({required this.event, required this.merchant});
  final String event;
  final Merchant merchant;
}

/// merchant.removed — id + name.
final class WsMerchantRemovedEvent extends WsEvent {
  const WsMerchantRemovedEvent({required this.id, required this.name});
  final String id;
  final String name;
}

/// device.logged_out — force logout from admin.
final class WsDeviceLoggedOutEvent extends WsEvent {
  const WsDeviceLoggedOutEvent({required this.deviceId, this.reason});
  final String deviceId;
  final String? reason;
}

/// Ping — server heartbeat, no payload needed.
final class WsPingEvent extends WsEvent {
  const WsPingEvent();
}

/// Unknown / unrecognized event — safe to ignore.
final class WsUnknownEvent extends WsEvent {
  const WsUnknownEvent(this.raw);
  final Map<String, dynamic> raw;
}

/// Parses a raw JSON map into a typed [WsEvent].
WsEvent parseWsEvent(Map<String, dynamic> json) {
  final event = json['event'] as String?;
  final data = json['data'];

  switch (event) {
    case 'transaction.created':
    case 'transaction.paid':
      return WsTxnEvent(
        event: event!,
        transaction: Transaction.fromJson(data as Map<String, dynamic>),
      );
    case 'transaction.expired':
      final d = data as Map<String, dynamic>;
      return WsTxnExpiredEvent(
        id: d['id'] as String,
        merchantId: d['merchant_id'] as String,
        expiresAt: d['expires_at'] as String,
      );
    case 'transaction.cancelled':
    case 'transaction.failed':
      final d = data as Map<String, dynamic>;
      return WsTxnStatusEvent(
        event: event!,
        id: d['id'] as String,
        merchantId: d['merchant_id'] as String,
        reason: d['reason'] as String?,
      );
    case 'merchant.added':
    case 'merchant.updated':
      return WsMerchantEvent(
        event: event!,
        merchant: Merchant.fromJson(data as Map<String, dynamic>),
      );
    case 'merchant.removed':
      final d = data as Map<String, dynamic>;
      return WsMerchantRemovedEvent(
        id: d['id'] as String,
        name: d['name'] as String,
      );
    case 'device.logged_out':
      final d = data as Map<String, dynamic>;
      return WsDeviceLoggedOutEvent(
        deviceId: d['device_id'] as String,
        reason: d['reason'] as String?,
      );
    case 'ping':
      return const WsPingEvent();
    default:
      return WsUnknownEvent(json);
  }
}
