import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/features/speech/data/datasources/flutter_tts_engine.dart';
import 'package:kid_matix/features/speech/domain/services/speech_voices_unknown_exception.dart';

const MethodChannel _channel = MethodChannel('flutter_tts');

/// A voice as the Android plugin lists it.
Map<String, String> _voice(
  String name,
  String locale, {
  bool needsNetwork = false,
  String features = '',
  String quality = 'normal',
}) {
  return <String, String>{
    'name': name,
    'locale': locale,
    'quality': quality,
    'latency': 'normal',
    'network_required': needsNetwork ? '1' : '0',
    'features': features,
  };
}

/// Fake `flutter_tts` plugin: records the calls of the engine, lists the
/// voices of the phone, and can send the events the platform sends.
final class _FakeTtsPlugin {
  _FakeTtsPlugin(this._messenger);

  final TestDefaultBinaryMessenger _messenger;
  final List<MethodCall> calls = <MethodCall>[];
  List<Map<String, String>> voices = <Map<String, String>>[
    _voice('fr-fr-x-frd-local', 'fr-FR'),
  ];
  Set<String> availableLocales = <String>{'fr-FR'};
  Object speakResult = 1;
  Object setVoiceResult = 1;

  /// Whether `getVoices` answers `null`, as the plugin does while the
  /// speech service of the phone is disconnected.
  bool voicesAreUnknown = false;

  List<String> methods() {
    return <String>[for (final MethodCall call in calls) call.method];
  }

  Object? argumentsOf(String method) {
    return calls
        .lastWhere((MethodCall call) => call.method == method)
        .arguments;
  }

  /// Texts of the `speak` calls: the plugin sends a map on Android and the
  /// text alone elsewhere, such as on the machine running the tests.
  List<String?> spokenTexts() {
    return <String?>[
      for (final MethodCall call in calls)
        if (call.method == 'speak')
          call.arguments is Map<Object?, Object?>
              ? (call.arguments as Map<Object?, Object?>)['text'] as String?
              : call.arguments as String?,
    ];
  }

  void install() => _messenger.setMockMethodCallHandler(_channel, _handle);

  void uninstall() => _messenger.setMockMethodCallHandler(_channel, null);

  Future<Object?> _handle(MethodCall call) async {
    calls.add(call);
    return switch (call.method) {
      'getVoices' => voicesAreUnknown ? null : voices,
      'isLanguageAvailable' => availableLocales.contains(call.arguments),
      'setVoice' => setVoiceResult,
      'speak' => speakResult,
      _ => 1,
    };
  }

  /// Sends the event [name] the way the platform side does.
  Future<void> emit(String name, [Object? arguments]) async {
    await _messenger.handlePlatformMessage(
      _channel.name,
      _channel.codec.encodeMethodCall(MethodCall(name, arguments)),
      (ByteData? _) {},
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _FakeTtsPlugin plugin;

  setUp(() {
    plugin = _FakeTtsPlugin(
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger,
    )..install();
  });

  tearDown(() => plugin.uninstall());

  FlutterTtsEngine androidEngine() =>
      FlutterTtsEngine(platform: TargetPlatform.android);

  group('FlutterTtsEngine.hasVoice on Android', () {
    test('finds an installed voice of the language', () async {
      // Act
      final bool actualResult = await androidEngine().hasVoice(
        languageCode: 'fr',
      );
      // Assert
      expect(actualResult, isTrue);
      expect(plugin.methods(), contains('getVoices'));
    });
    test('ignores a voice that needs a network', () async {
      // Arrange
      plugin.voices = <Map<String, String>>[
        _voice('fr-fr-x-frd-network', 'fr-FR', needsNetwork: true),
      ];
      // Act
      final bool actualResult = await androidEngine().hasVoice(
        languageCode: 'fr',
      );
      // Assert
      expect(actualResult, isFalse);
    });
    test('ignores a voice whose data is not installed', () async {
      // Arrange
      plugin.voices = <Map<String, String>>[
        _voice('fr-fr-x-frd-local', 'fr-FR', features: 'notInstalled'),
      ];
      // Act
      final bool actualResult = await androidEngine().hasVoice(
        languageCode: 'fr',
      );
      // Assert
      expect(actualResult, isFalse);
    });
    test('finds no voice when none of the language is there', () async {
      // Arrange
      plugin.voices = <Map<String, String>>[_voice('en-us', 'en-US')];
      // Act
      final bool actualResult = await androidEngine().hasVoice(
        languageCode: 'fr',
      );
      // Assert
      expect(actualResult, isFalse);
    });
    test('finds no voice for a language the app does not speak', () async {
      // Act
      final bool actualResult = await androidEngine().hasVoice(
        languageCode: 'wo',
      );
      // Assert
      expect(actualResult, isFalse);
    });
    test('finds no voice when the plugin lists none', () async {
      // Arrange
      plugin.voices = <Map<String, String>>[];
      // Act
      final bool actualResult = await androidEngine().hasVoice(
        languageCode: 'fr',
      );
      // Assert
      expect(actualResult, isFalse);
    });
  });

  group('FlutterTtsEngine.hasVoice while the service is disconnected', () {
    test('throws instead of saying there is no voice', () async {
      // Arrange
      plugin.voicesAreUnknown = true;
      // Act & Assert
      await expectLater(
        androidEngine().hasVoice(languageCode: 'fr'),
        throwsA(isA<SpeechVoicesUnknownException>()),
      );
    });
    test('finds the voice once the service answers', () async {
      // Arrange
      final FlutterTtsEngine inputEngine = androidEngine();
      plugin.voicesAreUnknown = true;
      await expectLater(
        inputEngine.hasVoice(languageCode: 'fr'),
        throwsA(isA<SpeechVoicesUnknownException>()),
      );
      plugin.voicesAreUnknown = false;
      // Act
      final bool actualResult = await inputEngine.hasVoice(languageCode: 'fr');
      // Assert
      expect(actualResult, isTrue);
    });
  });

  group('FlutterTtsEngine.hasVoice on iOS', () {
    test('asks the system for the voices of the language', () async {
      // Arrange
      final FlutterTtsEngine inputEngine = FlutterTtsEngine(
        platform: TargetPlatform.iOS,
      );
      // Act
      final bool actualResult = await inputEngine.hasVoice(languageCode: 'fr');
      // Assert
      expect(actualResult, isTrue);
      expect(plugin.methods(), contains('isLanguageAvailable'));
      expect(plugin.methods(), isNot(contains('getVoices')));
    });
    test('does nothing to the audio before the first reading', () async {
      // Arrange
      final FlutterTtsEngine inputEngine = FlutterTtsEngine(
        platform: TargetPlatform.iOS,
      );
      // Act
      await inputEngine.hasVoice(languageCode: 'fr');
      // Assert: no category, no language, no voice chosen yet.
      expect(plugin.methods(), <String>['isLanguageAvailable']);
    });
  });

  group('FlutterTtsEngine.speak', () {
    test('uses the offline voice chosen, then waits for its end', () async {
      // Arrange
      plugin.voices = <Map<String, String>>[
        _voice(
          'fr-fr-x-network',
          'fr-FR',
          needsNetwork: true,
          quality: 'very high',
        ),
        _voice('fr-fr-x-frd-local', 'fr-FR'),
      ];
      final FlutterTtsEngine inputEngine = androidEngine();
      bool isDone = false;
      // Act
      final Future<void> actualReading = inputEngine
          .speak(text: '5 fois 7 égale combien', languageCode: 'fr')
          .then((_) => isDone = true);
      await pumpEventQueue();
      // Assert
      expect(plugin.argumentsOf('setVoice'), <String, String>{
        'name': 'fr-fr-x-frd-local',
        'locale': 'fr-FR',
      });
      expect(plugin.methods(), isNot(contains('setLanguage')));
      expect(plugin.spokenTexts(), <String?>['5 fois 7 égale combien']);
      expect(isDone, isFalse);
      await plugin.emit('speak.onStart');
      await plugin.emit('speak.onComplete');
      await actualReading;
      expect(isDone, isTrue);
    });
    test('prefers the better voice of the same locale', () async {
      // Arrange
      plugin.voices = <Map<String, String>>[
        _voice('normal', 'fr-FR'),
        _voice('best', 'fr-FR', quality: 'very high'),
      ];
      // Act
      unawaited(androidEngine().speak(text: 'Compte', languageCode: 'fr'));
      await pumpEventQueue();
      // Assert
      expect(
        (plugin.argumentsOf('setVoice')! as Map<Object?, Object?>)['name'],
        'best',
      );
    });
    test('prefers the first locale of the language, then any other', () async {
      // Arrange
      plugin.voices = <Map<String, String>>[
        _voice('senegal', 'fr-SN'),
        _voice('canada', 'fr-CA'),
      ];
      final FlutterTtsEngine inputEngine = androidEngine();
      // Act
      unawaited(inputEngine.speak(text: 'Compte', languageCode: 'fr'));
      await pumpEventQueue();
      // Assert: fr-CA comes before an unlisted locale.
      expect(
        (plugin.argumentsOf('setVoice')! as Map<Object?, Object?>)['name'],
        'canada',
      );
    });
    test('does not speak without a voice', () async {
      // Arrange
      plugin.voices = <Map<String, String>>[];
      // Act
      await androidEngine().speak(text: '5 fois 7', languageCode: 'fr');
      // Assert
      expect(plugin.methods(), isNot(contains('speak')));
    });
    test('does not speak when the engine refuses the voice', () async {
      // Arrange
      plugin.setVoiceResult = 0;
      // Act
      await androidEngine().speak(text: '5 fois 7', languageCode: 'fr');
      // Assert: no fall back on a voice the engine would choose.
      expect(plugin.methods(), isNot(contains('speak')));
      expect(plugin.methods(), isNot(contains('setLanguage')));
    });
    test('ends at once when the platform cannot start the voice', () async {
      // Arrange
      plugin.speakResult = 0;
      // Act
      final Future<void> actualReading = androidEngine().speak(
        text: '5 fois 7',
        languageCode: 'fr',
      );
      // Assert
      await expectLater(actualReading, completes);
    });
    test('ends when the voice reports an error', () async {
      // Arrange
      final Future<void> actualReading = androidEngine().speak(
        text: '5 fois 7',
        languageCode: 'fr',
      );
      await pumpEventQueue();
      await plugin.emit('speak.onStart');
      // Act
      await plugin.emit('speak.onError', 'Error from TextToSpeech');
      // Assert
      await expectLater(actualReading, completes);
    });
    test(
      'ignores an error that arrives before the utterance started',
      () async {
        // Arrange
        bool isDone = false;
        final Future<void> actualReading = androidEngine()
            .speak(text: '5 fois 7', languageCode: 'fr')
            .then((_) => isDone = true);
        await pumpEventQueue();
        // Act: the error of the utterance before this one, late.
        await plugin.emit('speak.onError', 'Error of the old utterance');
        await pumpEventQueue();
        // Assert
        expect(isDone, isFalse);
        await plugin.emit('speak.onStart');
        await plugin.emit('speak.onComplete');
        await actualReading;
        expect(isDone, isTrue);
      },
    );
    test('ends when the reading is stopped', () async {
      // Arrange
      final FlutterTtsEngine inputEngine = androidEngine();
      final Future<void> actualReading = inputEngine.speak(
        text: '5 fois 7',
        languageCode: 'fr',
      );
      await pumpEventQueue();
      await plugin.emit('speak.onStart');
      // Act
      final Future<void> stopping = inputEngine.stop();
      await pumpEventQueue();
      await plugin.emit('speak.onCancel');
      // Assert
      await stopping;
      await expectLater(actualReading, completes);
    });
    test('does not wait for ever for a voice that stops in silence', () async {
      // Arrange
      final FlutterTtsEngine inputEngine = androidEngine();
      final Future<void> actualReading = inputEngine.speak(
        text: '5 fois 7',
        languageCode: 'fr',
      );
      await pumpEventQueue();
      // Act
      await inputEngine.stop();
      // Assert
      await expectLater(actualReading, completes);
    });
    test('stops the reading in progress before a new one', () async {
      // Arrange
      final FlutterTtsEngine inputEngine = androidEngine();
      final Future<void> actualFirst = inputEngine.speak(
        text: 'première',
        languageCode: 'fr',
      );
      await pumpEventQueue();
      await plugin.emit('speak.onStart');
      // Act
      final Future<void> actualSecond = inputEngine.speak(
        text: 'seconde',
        languageCode: 'fr',
      );
      await pumpEventQueue();
      await plugin.emit('speak.onCancel');
      await pumpEventQueue();
      // Assert
      await expectLater(actualFirst, completes);
      expect(plugin.spokenTexts().last, 'seconde');
      await plugin.emit('speak.onStart');
      await plugin.emit('speak.onComplete');
      await expectLater(actualSecond, completes);
    });
  });

  group('FlutterTtsEngine with overlapping readings', () {
    test('lets only the newest of two simultaneous readings speak', () async {
      // Arrange
      final FlutterTtsEngine inputEngine = androidEngine();
      // Act: two questions in a row before the first got to speak.
      final Future<void> actualFirst = inputEngine.speak(
        text: 'première',
        languageCode: 'fr',
      );
      final Future<void> actualSecond = inputEngine.speak(
        text: 'seconde',
        languageCode: 'fr',
      );
      await pumpEventQueue();
      // Assert
      await expectLater(actualFirst, completes);
      expect(plugin.spokenTexts(), <String?>['seconde']);
      await plugin.emit('speak.onStart');
      await plugin.emit('speak.onComplete');
      await expectLater(actualSecond, completes);
    });
    testWidgets('does not let the end of the old utterance end the new one', (
      WidgetTester tester,
    ) async {
      // Arrange
      final FlutterTtsEngine inputEngine = androidEngine();
      unawaited(inputEngine.speak(text: 'première', languageCode: 'fr'));
      await tester.pump();
      await plugin.emit('speak.onStart');
      bool isSecondDone = false;
      final Future<void> actualSecond = inputEngine
          .speak(text: 'seconde', languageCode: 'fr')
          .then((_) => isSecondDone = true);
      // The old voice is slow to report that it stopped: the wait for it
      // runs out and the new utterance goes on.
      await tester.pump(
        FlutterTtsEngine.stopWaitTime + const Duration(milliseconds: 100),
      );
      expect(plugin.spokenTexts().last, 'seconde');
      // Act: the old utterance reports its cancel, late.
      await plugin.emit('speak.onCancel');
      await tester.pump();
      // Assert
      expect(isSecondDone, isFalse);
      await plugin.emit('speak.onStart');
      await plugin.emit('speak.onComplete');
      await actualSecond;
      expect(isSecondDone, isTrue);
    });
    test('ignores the events when no reading is in progress', () async {
      // Arrange
      final FlutterTtsEngine inputEngine = androidEngine();
      await inputEngine.hasVoice(languageCode: 'fr');
      // Act & Assert
      await plugin.emit('speak.onStart');
      await plugin.emit('speak.onComplete');
      await plugin.emit('speak.onCancel');
      final Future<void> actualReading = inputEngine.speak(
        text: 'seconde',
        languageCode: 'fr',
      );
      await pumpEventQueue();
      await plugin.emit('speak.onStart');
      await plugin.emit('speak.onComplete');
      await expectLater(actualReading, completes);
    });
    test('does not speak when it was stopped before it got going', () async {
      // Arrange
      final FlutterTtsEngine inputEngine = androidEngine();
      final Future<void> actualReading = inputEngine.speak(
        text: 'première',
        languageCode: 'fr',
      );
      // Act
      unawaited(inputEngine.stop());
      await pumpEventQueue();
      // Assert
      await expectLater(actualReading, completes);
      expect(plugin.methods(), isNot(contains('speak')));
    });
  });
}
