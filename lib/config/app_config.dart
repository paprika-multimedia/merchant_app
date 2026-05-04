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

  /// Whether to initialize Firebase (push notifications).
  ///
  /// Set to `false` when developing against the local backend simulator
  /// without a Firebase project configured:
  ///
  ///   flutter run --dart-define=ENABLE_FIREBASE=false ...
  ///
  /// When false, `Firebase.initializeApp()` is never called and FCM
  /// token/topic calls are skipped. Push notifications will not work,
  /// but all other features function normally.
  ///
  /// Defaults to `true` so production builds require no extra flag.
  static const enableFirebase = bool.fromEnvironment(
    'ENABLE_FIREBASE',
    defaultValue: true,
  );
}
