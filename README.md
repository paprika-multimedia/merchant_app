# Paprika Merchant App (Flutter)

> Production mobile app for iOS + Android. Merchants receive payments via Dynamic QRIS, Payment Link, and Scan QRIS (CPM).

---

## Requirements

- **Flutter SDK:** 3.24.0 or newer (Dart 3.5+)
- **Xcode:** 15.4+ for iOS builds
- **Android Studio / SDK:** API 34+, JDK 17
- **Firebase project:** required for push notifications — drop `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) into the platform folders before running. See `docs/flutter-guide.md` for FCM wiring.

---

## Quick Start

```bash
# Install dependencies
flutter pub get

# Run code generation (models)
dart run build_runner build --delete-conflicting-outputs

# Run against local backend simulator
flutter run --dart-define=API_BASE_URL=http://localhost:8080/v1 \
            --dart-define=WS_URL=ws://localhost:8080/v1/stream
```

---

## Documentation

| File | Responsibility |
|------|---------------|
| `docs/file-index.md` | Quick file lookup — find any file by responsibility |
| `docs/coding-standards.md` | Dart-specific coding rules and conventions |
| `docs/flutter-guide.md` | Architecture, patterns, packages, implementation details |

Also read the shared standards at `../docs/coding-standards.md`.

---

## Tech Stack

- **Flutter** (iOS + Android)
- **Riverpod** — state management
- **go_router** — routing (11 routes)
- **Dio** — HTTP with interceptor chain
- **freezed + json_serializable** — immutable models
- **flutter_secure_storage** — secure local storage
- **mobile_scanner** — QR scanning
- **qr_flutter** — QR rendering
- **flutter_tts** — payment amount announcements
- **web_socket_channel** — realtime events

---

## Project Structure

```
lib/
  main.dart              → Entry point
  app.dart               → MaterialApp.router
  config/                → Compile-time configuration
  l10n/                  → ARB localization files (id + en)
  theme/                 → Design tokens + ThemeData
  brand/                 → Brand artwork widgets
  primitives/            → Shared UI components
  net/                   → Dio, interceptors, API clients, WebSocket
  services/              → Payment announcer, number-to-words
  state/                 → Riverpod providers
  storage/               → Secure storage wrapper
  models/                → Data models (freezed)
  router/                → go_router routes
  features/              → One folder per screen/flow
```

---

## Key Commands

```bash
# Run tests
flutter test

# Run with staging backend
flutter run --dart-define=API_BASE_URL=https://api-staging.paprika.co.id/v1 \
            --dart-define=WS_URL=wss://api-staging.paprika.co.id/v1/stream

# Generate app icons
dart run flutter_launcher_icons

# Generate splash screen
dart run flutter_native_splash:create

# Release build — Android (App Bundle for Play Store)
flutter build appbundle --release \
  --dart-define=API_BASE_URL=https://api.paprika.co.id/v1 \
  --dart-define=WS_URL=wss://api.paprika.co.id/v1/stream

# Release build — iOS (archive in Xcode after this)
flutter build ipa --release \
  --dart-define=API_BASE_URL=https://api.paprika.co.id/v1 \
  --dart-define=WS_URL=wss://api.paprika.co.id/v1/stream
```

---

## Troubleshooting

- **Code-gen fails with "Bad state: …"** — run `dart run build_runner build --delete-conflicting-outputs` to wipe stale generated files.
- **iOS build can't find Firebase** — make sure `GoogleService-Info.plist` is added to the Runner target (not just the project) in Xcode.
- **Push notifications not arriving on Android** — confirm `google-services.json` is in `android/app/` and the Gradle plugin is applied.
- **WebSocket auth fails immediately** — check that the token is sent in the **first frame**, never as a `?token=` query param (Spec.md §5).
