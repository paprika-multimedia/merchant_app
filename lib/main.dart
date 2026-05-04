import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'services/payment_announcer.dart';
import 'state/session.dart';
import 'storage/secure_storage.dart';

/// Entry point — Paprika Merchant App.
///
/// Initialisation order (must be sequential, each can fail gracefully):
/// 1. Flutter engine binding
/// 2. Firebase (core, messaging)
/// 3. TTS / audio session via PaymentAnnouncer
/// 4. Locale hydration from secure storage → seed localeProvider
/// 5. Launch the widget tree with ProviderScope
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Firebase — failure here is non-fatal; push notifications simply won't work.
  await _initFirebase();

  // 3. TTS / audio session
  await PaymentAnnouncer.instance.init();

  // 4. Read persisted locale so it is available synchronously to localeProvider.
  final storage = SecureStorage();
  final savedLocale = await storage.read(SecureStorage.keyLang) ?? 'id';

  runApp(
    ProviderScope(
      overrides: [
        // Seed localeProvider with persisted value before the first build.
        // overrideWith receives the notifier factory; we return a subclass
        // whose build() returns the saved locale instead of the default 'id'.
        localeProvider.overrideWith(() => _SeedableLocaleNotifier(savedLocale)),
      ],
      child: const PaprikaApp(),
    ),
  );
}

/// A LocaleNotifier whose initial value is provided at construction time.
/// Used only in main() to hydrate from secure storage before first build.
class _SeedableLocaleNotifier extends LocaleNotifier {
  _SeedableLocaleNotifier(this._initial);

  final String _initial;

  @override
  String build() => _initial;
}

Future<void> _initFirebase() async {
  try {
    await Firebase.initializeApp();
  } catch (_) {
    // Not fatal — app runs without push in development or emulator
  }
}
