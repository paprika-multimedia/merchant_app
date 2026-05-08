import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'l10n/app_localizations.dart';
import 'router/routes.dart';
import 'state/active_merchant.dart';
import 'state/session.dart';
import 'state/ws_state.dart';
import 'theme/tokens.dart';

/// Root of the Paprika Merchant App widget tree.
///
/// Wires routing, theming, and locale together.
/// Locale is driven by [localeProvider] (persisted to secure storage).
class PaprikaApp extends ConsumerWidget {
  const PaprikaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final localeCode = ref.watch(localeProvider);
    final locale = Locale(localeCode);

    // Bootstrap side-effect providers exactly once. Without these reads the
    // notifiers would never run their build() — the WS client would stay
    // disconnected and persisted active-merchant would never restore.
    ref.watch(_appBootstrapProvider);
    ref.watch(wsStateProvider);

    return MaterialApp.router(
      title: 'Paprika',
      debugShowCheckedModeBanner: false,
      routerConfig: router,

      // ─── Localisation ───────────────────────────────────────────────────────
      locale: locale,
      supportedLocales: AppL10n.supportedLocales,
      localizationsDelegates: const [
        AppL10n.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // ─── Theme ──────────────────────────────────────────────────────────────
      theme: _buildTheme(),
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppTokens.accent,
        surface: AppTokens.surface,
      ),
      scaffoldBackgroundColor: AppTokens.bg,
      fontFamily: AppTokens.fontDisplay,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppTokens.bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: AppTokens.ink),
        titleTextStyle: TextStyle(
          fontFamily: AppTokens.fontDisplay,
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppTokens.ink,
        ),
      ),
      extensions: const [AppTokens()],
    );
  }
}

/// One-shot startup work that doesn't fit in `main()` (because it depends on
/// the ProviderScope) and shouldn't gate the first frame. Currently restores
/// the persisted active merchant. Add other one-shot init here.
final _appBootstrapProvider = FutureProvider<void>((ref) async {
  await ref.read(activeMerchantIdProvider.notifier).restore();
});
