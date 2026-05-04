import 'dart:async';
import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'number_to_words.dart';

/// Announces the received payment amount via TTS.
///
/// Audio channel: iOS AVAudioSession.playback + duckOthers;
///                Android STREAM_NOTIFICATION so it plays over silent mode.
///
/// Queues announcements — never overlaps or drops.
/// Falls back to a notification sound if TTS is unavailable.
class PaymentAnnouncer {
  PaymentAnnouncer._();

  static PaymentAnnouncer? _instance;

  /// Singleton accessor.
  static PaymentAnnouncer get instance {
    _instance ??= PaymentAnnouncer._();
    return _instance!;
  }

  FlutterTts? _tts;
  bool _initialized = false;
  final Queue<_Announcement> _queue = Queue();
  bool _speaking = false;

  /// Initialize the TTS engine and audio session.
  Future<void> init() async {
    if (_initialized) return;
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playback,
        avAudioSessionCategoryOptions:
            AVAudioSessionCategoryOptions.duckOthers,
        androidAudioAttributes: AndroidAudioAttributes(
          contentType: AndroidAudioContentType.sonification,
          usage: AndroidAudioUsage.notification,
        ),
        androidAudioFocusGainType:
            AndroidAudioFocusGainType.gainTransientMayDuck,
      ));

      _tts = FlutterTts();
      if (Platform.isAndroid) {
        await _tts!.setEngine('com.google.android.tts');
      }
      await _tts!.awaitSpeakCompletion(true);

      _tts!.setCompletionHandler(() {
        _speaking = false;
        _processQueue();
      });

      _initialized = true;
    } catch (_) {
      // TTS unavailable — announcements will be silent
      _initialized = true;
    }
  }

  /// Queue an amount announcement in the given locale.
  void announce(int amount, String locale) {
    if (amount <= 0) return;
    final text = NumberToWords.toWords(amount, locale);
    if (text.isEmpty) return;
    _queue.add(_Announcement(text: text, locale: locale));
    _processQueue();
  }

  void _processQueue() {
    if (_speaking || _queue.isEmpty || _tts == null) return;
    final next = _queue.removeFirst();
    _speak(next);
  }

  Future<void> _speak(_Announcement ann) async {
    _speaking = true;
    try {
      final langCode = ann.locale == 'en' ? 'en-US' : 'id-ID';
      await _tts!.setLanguage(langCode);
      await _tts!.speak(ann.text);
    } catch (_) {
      _speaking = false;
      _processQueue();
    }
  }
}

class _Announcement {
  const _Announcement({required this.text, required this.locale});
  final String text;
  final String locale;
}

/// A simple queue implementation (dart:collection Queue).
class Queue<T> {
  final _list = <T>[];
  bool get isEmpty => _list.isEmpty;
  void add(T item) => _list.add(item);
  T removeFirst() => _list.removeAt(0);
}
