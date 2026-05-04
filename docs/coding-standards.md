# Flutter App — Dart Coding Standards

> **Applies to:** all Dart code in `merchant_app/`.
> **Read also:** `../../docs/coding-standards.md` for shared principles that apply to both projects.

---

## Dart-Specific Conventions

### Naming

```
Files:         snake_case.dart
Classes:       PascalCase
Variables:     camelCase
Constants:     camelCase (Dart convention, not SCREAMING_SNAKE)
Providers:     <name>Provider (e.g., sessionProvider, activeMerchantProvider)
API classes:   <Resource>Api (e.g., MerchantsApi, SessionsApi)
Models:        Singular noun matching Spec.md (Company, Merchant, Transaction)
Features:      snake_case folder matching the screen name
```

### File Organization

- One public class per file (private helpers in the same file are fine).
- Imports ordered: dart → flutter → packages → project-relative.
- No barrel files (`index.dart` re-exports). Import the file you need directly.

### Widget Rules

- Use `const` constructors on every widget that accepts only compile-time constants.
- Prefer `StatelessWidget` unless local mutable state is unavoidable.
- Extract widget subtrees into named widgets when they exceed ~50 lines.
- Widget file = one screen or one reusable component. Not both.

### Provider Rules

- One provider per file. File name = provider name in snake_case.
- Use `ref.watch` in build methods, `ref.read` in callbacks/event handlers.
- Use `.select` to watch only the field you need — avoids unnecessary rebuilds.
- Async operations → `AsyncNotifierProvider`. Sync state → `NotifierProvider`.
- Dispose resources in the provider's `ref.onDispose` callback.

### Model Rules

- Models mirror `Spec.md` §2 verbatim. Field names use `@JsonKey(name:)` for snake_case → camelCase.
- Always use `freezed` — no manual `==`, `hashCode`, `copyWith`.
- Never restructure the API shape on the client. UI-label mapping happens at render time.
- Tolerate unknown JSON keys (don't crash on new fields from the server).

### Error Handling

- Wrap all Dio calls in try-catch at the provider level, not in widgets.
- Map `DioException` to domain-specific error types if needed.
- `AsyncValue.error` surfaces to widgets — widgets show error state with retry.
- Never catch `Exception` silently. At minimum, log it.

### Performance

- `const` everywhere it compiles.
- `ListView.builder` for any list that could exceed 10 items.
- Avoid `setState` in favor of Riverpod providers (state survives hot reload).
- Image assets: use appropriate resolution variants (1x, 2x, 3x).
- Avoid `MediaQuery.of(context)` in deeply nested widgets — pass values down or use a provider.

### Testing

- Test files mirror source structure: `test/net/interceptors/auth_test.dart`.
- Use `mocktail` for mocking (not `mockito` — no code generation needed).
- Provider tests: use `ProviderContainer` directly, no widget harness needed.
- Widget tests: use `pumpWidget` with `ProviderScope.overrides` for dependencies.

### Documentation

- Every public class and method gets a `///` doc comment (one line is fine).
- Complex logic gets a `//` comment above the block explaining WHY.
- TODOs: `// TODO(name, 2026-05-04): description` — never naked TODOs.

---

## Hard Rules (Flutter-Specific)

These are non-negotiable. Violating any is a bug.

1. No `Color(0xFF...)` outside `lib/theme/tokens.dart`.
2. No hardcoded strings in widgets — all copy through `AppL10n.of(context).*`.
3. No API path strings outside `lib/net/api/*.dart` files.
4. No `TextField` on amount-entry screens — custom keypad only.
5. No `?token=` in WebSocket URLs — auth via first frame only.
6. No `cpm.payer_name` logged, cached, stored, or rendered anywhere.
7. No packages added without checking the approved list in `flutter-guide.md`.
8. No `SharedPreferences` for sensitive data — use `flutter_secure_storage`.
9. No direct `http://` or `https://` URLs — all from `AppConfig`.
10. No OS keyboard on CPM screen — camera-only, no manual entry fallback.
