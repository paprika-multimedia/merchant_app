import 'package:flutter/material.dart';

import 'tokens.dart';

/// ThemeData configured with Paprika design tokens.
class PaprikaTheme {
  PaprikaTheme._();

  /// The app's light theme. Pass to [MaterialApp.theme].
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppTokens.accent,
        surface: AppTokens.surface,
      ),
      scaffoldBackgroundColor: AppTokens.bg,
      fontFamily: AppTokens.fontDisplay,
      extensions: const [AppTokens()],
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
    );
  }
}
