import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/features/speech/data/datasources/flutter_tts_engine.dart';

const MethodChannel _channel = MethodChannel('flutter_tts');

/// Fake `flutter_tts` plugin: records the calls of the engine, knows which
/// voices are installed, and can send the events the platform sends.
final class _FakeTtsPlugin {
  _FakeTtsPlugin(this._messenger);

  final TestDefaultBinaryMessenger _messenger;
  final List<MethodCall> calls = <MethodCall>[];
  Set<String> installedLocales = <String>{'fr-FR'};
  Object speakResult = 1;

  List<String> methods() {
    return <String>[for (final MethodCall call in calls) call.method];
  }

  Object? argumentsOf(String method) {
    return calls
        .lastWhere((MethodCall call) => call.method == method)
        .arguments;
  }

  /// Text of the last `speak` call: the plugin sends a map on Android and
  /// the text alone elsewhere, such as on the machine running the tests.
  String? spokenText() {
    final Object? arguments = argumentsOf('speak');
    return arguments is Map<Object?, Object?>
        ? arguments['text'] as String?
        : arguments as String?;
  }

  void install() => _messenger.setMockMethodCallHandler(_channel, _handle);

  void uninstall() => _messenger.setMockMethodCallHandler(_channel, null);

  Future<Object?> _handle(MethodCall call) async {
    calls.add(call);
    return switch (call.method) {
      'isLanguageInstalled' ||
      'isLanguageAvailable' => installedLocales.contains(call.arguments),
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

  group('FlutterTtsEngine.hasVoice', () {
    test('finds an installed voice of the language on Android', () async {
      // Act
      final bool actualResult = await androidEngine().hasVoice(
        languageCode: 'fr',
      );
      // Assert
      expect(actualResult, isTrue);
      expect(plugin.methods(), contains('isLanguageInstalled'));
      expect(plugin.methods(), isNot(contains('isLanguageAvailable')));
    });
    test('tries the other voices of the language', () async {
      // Arrange
      plugin.installedLocales = <String>{'fr-CA'};
      // Act
      final bool actualResult = await androidEngine().hasVoice(
        languageCode: 'fr',
      );
      // Assert
      expect(actualResult, isTrue);
    });
    test('finds no voice when none of the language is installed', () async {
      // Arrange
      plugin.installedLocales = <String>{'en-US'};
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
    test('asks the system for the voices of the language on iOS', () async {
      // Arrange
      final FlutterTtsEngine inputEngine = FlutterTtsEngine(
        platform: TargetPlatform.iOS,
      );
      // Act
      final bool actualResult = await inputEngine.hasVoice(languageCode: 'fr');
      // Assert
      expect(actualResult, isTrue);
      expect(plugin.methods(), contains('isLanguageAvailable'));
      expect(plugin.methods(), isNot(contains('isLanguageInstalled')));
    });
  });

  group('FlutterTtsEngine.speak', () {
    test('reads the text in the voice found, then waits for its end', () async {
      // Arrange
      final FlutterTtsEngine inputEngine = androidEngine();
      bool isDone = false;
      // Act
      final Future<void> actualReading = inputEngine
          .speak(text: '5 fois 7 égale combien', languageCode: 'fr')
          .then((_) => isDone = true);
      await pumpEventQueue();
      // Assert
      expect(plugin.argumentsOf('setLanguage'), 'fr-FR');
      expect(plugin.spokenText(), '5 fois 7 égale combien');
      expect(isDone, isFalse);
      await plugin.emit('speak.onStart');
      await plugin.emit('speak.onComplete');
      await actualReading;
      expect(isDone, isTrue);
    });
    test('does not speak without a voice', () async {
      // Arrange
      plugin.installedLocales = <String>{};
      // Act
      await androidEngine().speak(text: '5 fois 7', languageCode: 'fr');
      // Assert
      expect(plugin.methods(), isNot(contains('speak')));
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
      // Act
      await plugin.emit('speak.onError', 'Error from TextToSpeech');
      // Assert
      await expectLater(actualReading, completes);
    });
    test('ends when the reading is stopped', () async {
      // Arrange
      final FlutterTtsEngine inputEngine = androidEngine();
      final Future<void> actualReading = inputEngine.speak(
        text: '5 fois 7',
        languageCode: 'fr',
      );
      await pumpEventQueue();
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
      expect(plugin.spokenText(), 'seconde');
      await plugin.emit('speak.onComplete');
      await expectLater(actualSecond, completes);
    });
  });
}
