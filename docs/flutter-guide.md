# Flutter App — Architecture & Implementation Guide

> **For:** agents and developers building this Flutter app.
> **Prereqs:** Read `coding-standards.md` first, then the external `Flutter-Implementation.md` in `Paprika Merchant App_v1.3/`.

---

## Architecture Decisions (Locked In)

These are decided. Do not substitute alternatives without explicit approval.

| Concern | Choice | Why |
|---------|--------|-----|
| State management | Riverpod | Scoped providers fit company → merchant tree; less ceremony than Bloc |
| Routing | go_router | 11 routes, simple; persists last route for cold-start resume |
| HTTP | Dio | Interceptor chain (auth, language, idempotency, version) pays for itself |
| Models | freezed + json_serializable | Immutable; union types for nested Spec models |
| Async UI | Riverpod AsyncValue | Built-in loading/error/data states |
| Local storage | flutter_secure_storage | Tokens, refresh tokens, locale, recent amounts |
| QR scanning | mobile_scanner | Maintained successor to abandoned qr_code_scanner |
| QR rendering | qr_flutter | Server constructs payload; mobile renders as-is |
| WebSocket | web_socket_channel | Auth-frame protocol, reconnect with backoff |
| i18n | flutter_localizations + gen_l10n | ARB files, compile-time safety |
| Fonts | Bundled Inter + JetBrains Mono | No runtime fetch; airplane mode must work |
| TTS | flutter_tts + audio_session | Payment amount announcements |

---

## Critical Implementation Patterns

### Interceptor Stack (Dio)

Order matters. Must be added in this sequence:

1. **AcceptLanguageInterceptor** — read locale, attach `Accept-Language: id|en`
2. **AuthInterceptor** — attach Bearer token; on 401, single-flight refresh via `Completer` so concurrent 401s trigger only ONE refresh call
3. **IdempotencyInterceptor** — read key from `RequestOptions.extra['idempotencyKey']`, attach as header
4. **ClientVersionInterceptor** — attach `X-Client-Version` from package_info_plus

### Auth Refresh Single-Flight Lock

When multiple concurrent requests hit 401:
- Only ONE refresh token call is made
- All other 401'd requests wait for that single refresh to complete
- Then they replay with the new token
- Without this, concurrent 401s race the refresh-token rotation — the second refresh self-destructs the session (Spec §3.1.1: "used twice → revoked")

### Idempotency Key Lifecycle

The key is **per user intent**, not per HTTP request:
- Generate UUID at gesture start (e.g., "Generate QR" tapped)
- Same key is sent on retries of the same gesture
- Discard on success
- New key only on a fresh user action
- `POST /merchants/:id/scan` returns `400 idempotency_required` if the header is missing — treat as a coding bug

### WebSocket Lifecycle

```
1. Connect to WS_URL (no token in URL!)
2. Send { "type": "auth", "token": "<session_token>" } as first frame
3. Await { "type": "auth.ok" } — anything else → close + log
4. Listen for events; reset 25s heartbeat watchdog on every frame
5. On disconnect: backoff 1s → 30s capped, repeat from step 1
6. On reconnect: re-fetch whatever resource is currently on screen
```

WS is best-effort signalling, not a reliable queue. Dedupe with push notifications using an in-memory `Set<txnId>`.

### Capability Gating

- Hide Scan QRIS tile when `merchant.capabilities.scan_cpm == false`
- Re-render on `merchant.updated` WebSocket event
- Direct route to `/scan-cpm` must bounce back when capability is off
- Always handle `403 capability_disabled` response — show toast, return to dashboard

### Payment Notification — Spoken Amount (TTS)

When the app receives a payment notification (`transaction.paid` via push or WebSocket), it MUST play an audio announcement that speaks the received amount aloud. This is the merchant's primary feedback that money arrived — many merchants don't look at their phone screen while serving customers.

**Behavior:**

- Trigger: any `transaction.paid` event (from push notification OR WebSocket), after deduplication
- Output: text-to-speech reads the amount in the current app locale
  - Indonesian example: "Lima puluh ribu rupiah" (for Rp 50,000)
  - English example: "Fifty thousand rupiah" (for Rp 50,000)
- The speech MUST play even when the app is in the background (push notification trigger)
- The speech MUST play even if the device is in silent/vibrate mode — use the alarm/notification audio channel, not the media channel
- If multiple payments arrive in rapid succession, queue them — do not overlap or skip

**Implementation guidance:**

- Use `flutter_tts` for text-to-speech
- Convert integer IDR amount → spoken words using a number-to-words utility (write one for Indonesian and English)
- Indonesian number words: follow standard rules (ribu, juta, miliar) — e.g., 1,250,000 → "satu juta dua ratus lima puluh ribu rupiah"
- Audio session: configure to duck other audio, play over silent mode, use notification channel
- The TTS call should live in a dedicated service (`lib/services/payment_announcer.dart`), not in a widget
- On iOS: configure `AVAudioSession` category to `.playback` with `.duckOthers` option
- On Android: use `STREAM_NOTIFICATION` or `STREAM_ALARM` so it plays over silent mode
- Foreground: triggered by WebSocket `transaction.paid` event
- Background: triggered by FCM data message handler (`firebase_messaging` `onBackgroundMessage`)

**Number-to-words rules (Indonesian):**

```
0 → "nol"
1-11 → "satu", "dua", ..., "sepuluh", "sebelas"
12-19 → "[unit] belas" (e.g., 12 → "dua belas")
20-99 → "[tens] puluh [unit]" (e.g., 25 → "dua puluh lima")
100-199 → "seratus [remainder]"
200-999 → "[hundreds] ratus [remainder]"
1,000-1,999 → "seribu [remainder]"
2,000-999,999 → "[thousands] ribu [remainder]"
1,000,000+ → "[millions] juta [remainder]"
1,000,000,000+ → "[billions] miliar [remainder]"
```

Always append "rupiah" at the end.

**Edge cases:**

- Amount of 0 → do not announce (should not happen, but guard against it)
- Very large amounts → still speak fully, no abbreviation
- TTS engine unavailable → fall back to a short notification sound (bundled `.wav`), do not crash
- Deduplication: same `txnId` must not trigger two announcements (use the existing `Set<txnId>` dedupe in `txn_dedupe.dart`)

---

## i18n Rules

- Default locale: `id` (Indonesian). Fallback: `id` (NOT English).
- Mirror every key from `i18n.jsx` DICT into ARB files for both languages.
- Use `gen_l10n` with output class `AppL10n`.
- First launch: seed from `Platform.localeName` (`id-*` → `id`, else `en`), then persist to secure storage.
- Language toggle is in Settings sheet ONLY — no first-run language picker.
- Send `Accept-Language` on every authenticated call.
- Number/currency: use `intl` NumberFormat, not string concatenation.

---

## Security Checklist

- Session tokens in `flutter_secure_storage` only (not SharedPreferences)
- Keychain accessibility: `first_unlock_this_device` (no iCloud sync)
- `FLAG_SECURE` on payment-sensitive routes (Android)
- App-switcher blur on iOS for sensitive screens
- Camera permission strings localized in id + en
- No tokens in WebSocket URL query params
- No `cpm.payer_name` anywhere in client logs or state

---

## Testing Strategy

### What to Test (Mandatory)

- **Unit:** Auth interceptor single-flight (concurrent 401s → one refresh call); idempotency-key reuse across retries; WS reconnect re-fetches on-screen resource; capability 403 returns to dashboard; number-to-words conversion (Indonesian + English)
- **Widget:** Code input (paste-with-dashes, regex strip, length cap); custom amount keypad; remove-merchant confirm-name match
- **Integration:** Claim flow and CPM flow end-to-end against mock backend

### What to Skip

- Trivially-styled widgets — don't golden-test everything
- Don't golden every screen in both languages (diffs become noise)
- Skip testing obvious getters/setters

---

## Recommended Package Set

> Versions current as of May 2026. Use `flutter pub outdated` before upgrading any single line; bump in coordinated batches, not piecemeal.

```yaml
dependencies:
  # State, routing, HTTP
  flutter_riverpod: ^2.6.1
  go_router: ^14.6.2
  dio: ^5.7.0

  # Models & codegen
  freezed_annotation: ^2.4.4
  json_annotation: ^4.9.0

  # Storage
  flutter_secure_storage: ^9.2.2
  shared_preferences: ^2.3.3

  # Realtime + QR
  web_socket_channel: ^3.0.1
  mobile_scanner: ^5.2.3
  qr_flutter: ^4.1.0

  # Utilities
  uuid: ^4.5.1
  intl: ^0.19.0
  package_info_plus: ^8.1.1
  url_launcher: ^6.3.1
  flutter_svg: ^2.0.10
  flutter_animate: ^4.5.0

  # Push notifications (firebase_core is required by firebase_messaging)
  firebase_core: ^3.8.0
  firebase_messaging: ^15.1.5

  # Spoken-amount announcement
  flutter_tts: ^4.2.0
  audio_session: ^0.1.21

dev_dependencies:
  build_runner: ^2.4.13
  freezed: ^2.5.7
  json_serializable: ^6.9.0
  golden_toolkit: ^0.15.0
  mocktail: ^1.0.4
  flutter_launcher_icons: ^0.14.1
  flutter_native_splash: ^2.4.3
```

Do NOT add packages outside this list without justification.
