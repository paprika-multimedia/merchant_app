# Paprika Merchant App (Flutter)

> Production mobile app for iOS + Android. Merchants receive payments via Dynamic QRIS, Payment Link, and Scan QRIS (CPM).

---

## Requirements

- **Flutter SDK:** 3.24.0 or newer (Dart 3.5+)
- **Xcode:** 15.4+ for iOS builds
- **Android Studio / SDK:** API 34+, JDK 17
- **Firebase project:** required for push notifications only — see [Firebase Setup](#firebase-setup) below. Not needed for simulator-mode development.

---

## Quick Start

```bash
# Install dependencies
flutter pub get

# Run code generation (models)
dart run build_runner build --delete-conflicting-outputs

# Run against local backend simulator (no Firebase needed)
flutter run --dart-define=API_BASE_URL=http://localhost:8080/v1 \
            --dart-define=WS_URL=ws://localhost:8080/v1/stream \
            --dart-define=ENABLE_FIREBASE=false
```

---

## Firebase Setup

Firebase is required only for **push notifications**. When developing against the local backend simulator you can skip it entirely by passing `--dart-define=ENABLE_FIREBASE=false` (shown above). The app will boot and all features work — you just won't receive push notifications.

### When you're ready to enable Firebase

**Android:**
1. Create a Firebase project at <https://console.firebase.google.com>
2. Add an Android app with package name `com.paprika.paprika_merchant`
3. Download `google-services.json` and place it at `android/app/google-services.json`
4. Add the Google Services Gradle plugin to `android/app/build.gradle.kts`:
   ```kotlin
   plugins {
       // existing plugins …
       id("com.google.gms.google-services")
   }
   ```
5. Declare the plugin version in `android/settings.gradle.kts`:
   ```kotlin
   plugins {
       // existing plugins …
       id("com.google.gms.google-services") version "4.4.2" apply false
   }
   ```
6. See `android/app/google-services.json.example` for the expected file shape.

**iOS:**
1. Add an iOS app in the same Firebase project (bundle ID `com.paprika.paprikaMerchant`)
2. Download `GoogleService-Info.plist` and add it to the Xcode Runner target (not just the project)
3. Confirm it appears under Runner → Build Phases → Copy Bundle Resources

**Both platforms:**
- Run without `--dart-define=ENABLE_FIREBASE=false` (or set it to `true` explicitly)
- The `ENABLE_FIREBASE` flag defaults to `true`, so production builds require no extra flag

### ENABLE_FIREBASE compile-time flag

| Flag value | Behaviour |
|------------|-----------|
| `--dart-define=ENABLE_FIREBASE=false` | Firebase init is skipped entirely; push notifications disabled |
| `--dart-define=ENABLE_FIREBASE=true` (or omitted) | Firebase init runs; failures are non-fatal with a debug log |

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
- **App crashes on startup with Firebase error** — either add the config files (see [Firebase Setup](#firebase-setup)) or pass `--dart-define=ENABLE_FIREBASE=false` to skip Firebase entirely.
- **iOS build can't find Firebase** — make sure `GoogleService-Info.plist` is added to the Runner target (not just the project) in Xcode.
- **Push notifications not arriving on Android** — confirm `google-services.json` is in `android/app/` and the `com.google.gms.google-services` Gradle plugin is applied.
- **WebSocket auth fails immediately** — check that the token is sent in the **first frame**, never as a `?token=` query param (Spec.md §5).
