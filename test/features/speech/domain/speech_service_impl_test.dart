import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/features/speech/domain/services/speech_service_impl.dart';
import 'package:kid_matix/features/speech/domain/services/text_to_speech_engine.dart';

/// [TextToSpeechEngine] whose answers and failures the test sets.
final class _FakeEngine implements TextToSpeechEngine {
  bool hasInstalledVoice = true;
  bool fails = false;
  bool keepsSpeaking = false;
  bool neverAnswersVoiceCheck = false;
  bool neverStops = false;
  final List<String> spoken = <String>[];
  final List<String> languages = <String>[];
  int stopCount = 0;

  @override
  Future<bool> hasVoice({required String languageCode}) async {
    if (fails) throw Exception('engine down');
    if (neverAnswersVoiceCheck) await Completer<void>().future;
    return hasInstalledVoice;
  }

  @override
  Future<void> speak({
    required String text,
    required String languageCode,
  }) async {
    if (fails) throw Exception('engine down');
    spoken.add(text);
    languages.add(languageCode);
    if (keepsSpeaking) await Completer<void>().future;
  }

  @override
  Future<void> stop() async {
    if (fails) throw Exception('engine down');
    stopCount++;
    if (neverStops) await Completer<void>().future;
  }
}

void main() {
  late _FakeEngine engine;
  late SpeechServiceImpl service;

  setUp(() {
    engine = _FakeEngine();
    service = SpeechServiceImpl(engine: engine);
  });

  group('SpeechServiceImpl.isAvailable', () {
    test('answers yes when the engine has a voice', () async {
      // Act
      final bool actualResult = await service.isAvailable(languageCode: 'fr');
      // Assert
      expect(actualResult, isTrue);
    });
    test('answers no when no voice is installed', () async {
      // Arrange
      engine.hasInstalledVoice = false;
      // Act
      final bool actualResult = await service.isAvailable(languageCode: 'fr');
      // Assert
      expect(actualResult, isFalse);
    });
    test('answers no, without failing, when the engine breaks', () async {
      // Arrange
      engine.fails = true;
      // Act
      final bool actualResult = await service.isAvailable(languageCode: 'fr');
      // Assert
      expect(actualResult, isFalse);
    });
  });

  group('SpeechServiceImpl.isAvailable when the engine hangs', () {
    testWidgets('answers no after the time given to the engine', (
      WidgetTester tester,
    ) async {
      // Arrange
      engine.neverAnswersVoiceCheck = true;
      bool? actualResult;
      unawaited(
        service
            .isAvailable(languageCode: 'fr')
            .then((bool result) => actualResult = result),
      );
      await tester.pump();
      expect(actualResult, isNull);
      // Act
      await tester.pump(SpeechServiceImpl.availabilityTimeout);
      // Assert
      expect(actualResult, isFalse);
    });
  });

  group('SpeechServiceImpl.speak', () {
    test('reads the text in the language asked', () async {
      // Act
      await service.speak(text: '5 fois 7 égale combien', languageCode: 'fr');
      // Assert
      expect(engine.spoken, <String>['5 fois 7 égale combien']);
      expect(engine.languages, <String>['fr']);
    });
    test('reads nothing for a blank text', () async {
      // Act
      await service.speak(text: '  ', languageCode: 'fr');
      // Assert
      expect(engine.spoken, isEmpty);
    });
    test('does not throw when the engine breaks', () async {
      // Arrange
      engine.fails = true;
      // Act
      final Future<void> actualReading = service.speak(
        text: '5 fois 7',
        languageCode: 'fr',
      );
      // Assert
      await expectLater(actualReading, completes);
    });
    testWidgets('cuts a voice that never says it is done', (
      WidgetTester tester,
    ) async {
      // Arrange
      engine.keepsSpeaking = true;
      const String inputText = '5 fois 7 égale combien';
      bool isDone = false;
      unawaited(
        service
            .speak(text: inputText, languageCode: 'fr')
            .then((_) => isDone = true),
      );
      await tester.pump();
      expect(isDone, isFalse);
      // Act
      await tester.pump(SpeechServiceImpl.readingTimeOf(inputText));
      // Assert
      expect(isDone, isTrue);
      expect(engine.stopCount, 1);
    });
    test('gives a longer text more time', () {
      // Arrange
      const String inputShort = '5 fois 7';
      const String inputLong = 'Ce calcul est-il juste ? 6 fois 7 égale 48';
      // Act
      final Duration actualShort = SpeechServiceImpl.readingTimeOf(inputShort);
      final Duration actualLong = SpeechServiceImpl.readingTimeOf(inputLong);
      // Assert
      expect(actualLong, greaterThan(actualShort));
      expect(actualShort, greaterThan(SpeechServiceImpl.baseReadingTime));
    });
  });

  group('SpeechServiceImpl when the engine never answers a stop', () {
    testWidgets('leaves a stop behind after the time given', (
      WidgetTester tester,
    ) async {
      // Arrange
      engine.neverStops = true;
      bool isDone = false;
      unawaited(service.stop().then((_) => isDone = true));
      await tester.pump();
      expect(isDone, isFalse);
      // Act
      await tester.pump(SpeechServiceImpl.stopTimeout);
      // Assert
      expect(isDone, isTrue);
    });
    testWidgets('still ends a reading after the time of its text', (
      WidgetTester tester,
    ) async {
      // Arrange
      engine
        ..keepsSpeaking = true
        ..neverStops = true;
      const String inputText = '5 fois 7 égale combien';
      bool isDone = false;
      unawaited(
        service
            .speak(text: inputText, languageCode: 'fr')
            .then((_) => isDone = true),
      );
      await tester.pump();
      // Act: the reading is cut, with no wait for the engine.
      await tester.pump(SpeechServiceImpl.readingTimeOf(inputText));
      // Assert
      expect(isDone, isTrue);
      expect(engine.stopCount, 1);
      // The stop left behind gives up on its own.
      await tester.pump(SpeechServiceImpl.stopTimeout);
    });
  });

  group('SpeechServiceImpl.stop', () {
    test('stops the engine', () async {
      // Act
      await service.stop();
      // Assert
      expect(engine.stopCount, 1);
    });
    test('does not throw when the engine breaks', () async {
      // Arrange
      engine.fails = true;
      // Act
      final Future<void> actualStop = service.stop();
      // Assert
      await expectLater(actualStop, completes);
    });
  });
}
