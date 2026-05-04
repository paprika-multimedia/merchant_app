# Flutter App — File Index

> **Purpose:** Quick-lookup map so agents can grab the right file without searching.
> If the file you need isn't listed here, then search the codebase manually.

---

## Project Root

| Path | Responsibility |
|------|---------------|
| `README.md` | Project setup, run commands, quick orientation |
| `pubspec.yaml` | Dependencies, assets, fonts |
| `l10n.yaml` | gen_l10n configuration |
| `docs/` | All project-specific documentation |

---

## Configuration & Entry

| Path | Responsibility |
|------|---------------|
| `lib/main.dart` | App entry point, ProviderScope |
| `lib/app.dart` | MaterialApp.router, locale, theme |
| `lib/config/app_config.dart` | API_BASE_URL, WS_URL (from --dart-define) |

---

## Theme & Brand

| Path | Responsibility |
|------|---------------|
| `lib/theme/tokens.dart` | ALL color/spacing/radius tokens (mirrors T.* from JSX) |
| `lib/theme/paprika_theme.dart` | ThemeData + ThemeExtension wrapper |
| `lib/brand/paprika_mark.dart` | Brand mark widget (SVG artwork) |
| `lib/brand/paprika_wordmark.dart` | Wordmark widget (SVG artwork) |
| `lib/brand/paprika_lockup.dart` | Mark + wordmark combined |

---

## Primitives (Shared UI Components)

| Path | Responsibility |
|------|---------------|
| `lib/primitives/button.dart` | Primary/secondary/ghost buttons |
| `lib/primitives/card.dart` | Card container |
| `lib/primitives/chip.dart` | Status chips with leading symbol |
| `lib/primitives/field.dart` | Text input field |
| `lib/primitives/keypad.dart` | Custom 3×4 numeric keypad (no OS keyboard) |
| `lib/primitives/code_input.dart` | 20-char code input (5-5-5-5 display) |
| `lib/primitives/merchant_avatar.dart` | Merchant avatar with initials/icon |
| `lib/primitives/icons.dart` | App icon set |

---

## Networking

| Path | Responsibility |
|------|---------------|
| `lib/net/dio_client.dart` | Dio singleton + interceptor chain setup |
| `lib/net/interceptors/auth.dart` | Bearer token + 401 single-flight refresh |
| `lib/net/interceptors/accept_language.dart` | Accept-Language header on every request |
| `lib/net/interceptors/idempotency.dart` | Idempotency-Key from request extras |
| `lib/net/interceptors/client_version.dart` | X-Client-Version header |
| `lib/net/api/sessions_api.dart` | /sessions endpoints |
| `lib/net/api/merchants_api.dart` | /merchants endpoints |
| `lib/net/api/transactions_api.dart` | /transactions endpoints |
| `lib/net/ws/stream_client.dart` | WebSocket: auth-frame, reconnect, backoff |
| `lib/net/ws/events.dart` | Typed event payloads |

---

## Services

| Path | Responsibility |
|------|---------------|
| `lib/services/payment_announcer.dart` | TTS spoken amount on payment received |
| `lib/services/number_to_words.dart` | IDR amount → spoken words (id + en) |

---

## State Management

| Path | Responsibility |
|------|---------------|
| `lib/state/session.dart` | Session provider (token, auth state) |
| `lib/state/active_merchant.dart` | Currently selected merchant |
| `lib/state/recent_amounts.dart` | Per-merchant recent amount presets |
| `lib/state/ws_state.dart` | WebSocket connection state |
| `lib/state/txn_dedupe.dart` | Set<txnId> to dedupe WS + push events |

---

## Storage

| Path | Responsibility |
|------|---------------|
| `lib/storage/secure_storage.dart` | flutter_secure_storage wrapper |

---

## Models

| Path | Responsibility |
|------|---------------|
| `lib/models/company.dart` | Company model (mirrors Spec §2.1) |
| `lib/models/merchant.dart` | Merchant + MerchantCapabilities (Spec §2.2) |
| `lib/models/transaction.dart` | Transaction model (Spec §2.3) |
| `lib/models/payer.dart` | Payer model (CPM only, strip payer_name) |

---

## Routing

| Path | Responsibility |
|------|---------------|
| `lib/router/routes.dart` | go_router config, all 11 routes |

---

## Features (One Folder Per Screen)

The 11 production screens map to feature folders below, grouped by flow per `Handoff.md` §1. Onboarding has 5 routes because `ScreenCode` is reused for both company-code and merchant-code entry as separate routes.

### Onboarding (5 screens)

| Path | Screens |
|------|---------|
| `lib/features/onboarding/` | Welcome, Scan Company QR, Scan Merchant QR, Enter Company Code, Enter Merchant Code |

### Dashboards (3 screens)

| Path | Screens |
|------|---------|
| `lib/features/dashboard_company/` | Company dashboard |
| `lib/features/dashboard_merchant/` | Merchant dashboard |
| `lib/features/add_merchant/` | Add Merchant |

### Payment Actions (3 screens)

| Path | Screens |
|------|---------|
| `lib/features/dynamic_qris/` | Dynamic QRIS — amount → QR → paid |
| `lib/features/payment_link/` | Payment Link — amount → link → share → paid |
| `lib/features/scan_qris/` | Scan QRIS (CPM) — camera → confirm → paid |

### Bottom Sheets (not part of the 11 screens)

| Path | Responsibility |
|------|---------------|
| `lib/features/settings_sheet/` | Settings bottom sheet (language toggle) |
| `lib/features/remove_merchant_sheet/` | Remove merchant confirmation |

---

## Localization

| Path | Responsibility |
|------|---------------|
| `lib/l10n/app_id.arb` | Indonesian strings (default) |
| `lib/l10n/app_en.arb` | English strings |

---

## Assets

Shared brand assets are at the workspace root (`../../assets/`):

| Path (from workspace root) | Responsibility |
|----------------------------|---------------|
| `assets/paprika-icon.png` | Paprika icon (mark only) |
| `assets/paprika-logo.png` | Paprika logo (icon + name) |

Flutter app assets (inside `merchant_app/`):

| Path | Responsibility |
|------|---------------|
| `assets/fonts/Inter-Variable.ttf` | Inter font (bundled, no runtime fetch) |
| `assets/fonts/JetBrainsMono-Variable.ttf` | JetBrains Mono (bundled) |
| `assets/images/paprika-icon.png` | Copy of brand icon for Flutter bundling |
| `assets/images/paprika-logo.png` | Copy of brand logo for Flutter bundling |
| `assets/images/paprika-mark.svg` | Vector mark for scaling |
| `assets/images/paprika-wordmark.svg` | Vector wordmark |
| `assets/sounds/notification.wav` | Fallback sound when TTS unavailable |
