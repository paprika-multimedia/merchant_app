import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

import '../../config/app_config.dart';
import '../../storage/secure_storage.dart';
import 'events.dart';

/// WebSocket client implementing the Paprika auth-frame protocol.
///
/// Protocol (Spec §5.1):
/// 1. Connect to [AppConfig.wsUrl] — NO token in URL.
/// 2. Send `{ "type": "auth", "token": "<session_token>" }` as first frame.
/// 3. Await { "type": "auth.ok" } — anything else → close + retry.
/// 4. Listen for events; reset 25s heartbeat watchdog on every frame.
/// 5. On disconnect: backoff 1s → 30s capped, repeat from step 1.
/// 6. On reconnect: caller is notified via [onReconnect] to re-fetch resources.
class WsStreamClient {
  WsStreamClient({
    required SecureStorage storage,
    required void Function(WsEvent event) onEvent,
    required void Function() onReconnect,
    required void Function() onForceLogout,
  })  : _storage = storage,
        _onEvent = onEvent,
        _onReconnect = onReconnect,
        _onForceLogout = onForceLogout;

  final SecureStorage _storage;
  final void Function(WsEvent event) _onEvent;
  final void Function() _onReconnect;
  final void Function() _onForceLogout;

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _sub;
  Timer? _watchdog;
  bool _running = false;
  bool _authenticated = false;
  int _backoffSeconds = 1;

  static const _heartbeatTimeout = Duration(seconds: 30);
  static const _maxBackoff = 30;

  /// Start the WebSocket connection and reconnect loop.
  void start() {
    if (_running) return;
    _running = true;
    _connect();
  }

  /// Stop the client permanently (e.g., on logout).
  void stop() {
    _running = false;
    _cleanup();
  }

  void _connect() async {
    if (!_running) return;

    final token = await _storage.read(SecureStorage.keySessionToken);
    if (token == null) {
      // Not authenticated — retry after backoff
      _scheduleReconnect();
      return;
    }

    try {
      // URL MUST NOT contain token (Spec §5.1)
      _channel = WebSocketChannel.connect(Uri.parse(AppConfig.wsUrl));
      await _channel!.ready;
    } catch (e) {
      _scheduleReconnect();
      return;
    }

    // Send auth frame as first message
    _channel!.sink.add(
      jsonEncode({'type': 'auth', 'token': token}),
    );

    _authenticated = false;

    _sub = _channel!.stream.listen(
      _handleMessage,
      onDone: _onDisconnect,
      onError: (_) => _onDisconnect(),
      cancelOnError: false,
    );
  }

  void _handleMessage(dynamic raw) {
    // Reset watchdog on every frame (Spec §5.1)
    _resetWatchdog();

    Map<String, dynamic> json;
    try {
      json = jsonDecode(raw as String) as Map<String, dynamic>;
    } catch (_) {
      return;
    }

    if (!_authenticated) {
      if (json['type'] == 'auth.ok') {
        _authenticated = true;
        _backoffSeconds = 1; // reset backoff on successful auth
      } else {
        // Auth failed — close and retry
        _cleanup();
        _scheduleReconnect();
      }
      return;
    }

    final event = parseWsEvent(json);
    if (event is WsDeviceLoggedOutEvent) {
      _onForceLogout();
      stop();
      return;
    }
    _onEvent(event);
  }

  void _resetWatchdog() {
    _watchdog?.cancel();
    _watchdog = Timer(_heartbeatTimeout, _onDisconnect);
  }

  void _onDisconnect() {
    if (!_running) return;
    _cleanup();
    _onReconnect();
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (!_running) return;
    Future.delayed(Duration(seconds: _backoffSeconds), _connect);
    // Exponential backoff capped at _maxBackoff seconds
    _backoffSeconds = (_backoffSeconds * 2).clamp(1, _maxBackoff);
  }

  void _cleanup() {
    _watchdog?.cancel();
    _watchdog = null;
    _sub?.cancel();
    _sub = null;
    try {
      _channel?.sink.close();
    } catch (_) {}
    _channel = null;
    _authenticated = false;
  }
}
