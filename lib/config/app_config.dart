/// App-wide compile-time configuration.
///
/// Values are injected via `--dart-define` at build time.
/// Do NOT hard-code URLs or environment-specific values here.
class AppConfig {
  AppConfig._();

  /// Base URL for the REST API. Defaults to local mock server.
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080/v1',
  );

  /// WebSocket stream URL. Defaults to local mock server.
  static const wsUrl = String.fromEnvironment(
    'WS_URL',
    defaultValue: 'ws://localhost:8080/v1/stream',
  );
}
