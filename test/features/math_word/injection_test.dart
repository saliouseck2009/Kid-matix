import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:kid_matix/core/quiz/domain_registry.dart';
import 'package:kid_matix/core/quiz/learning_domain.dart';
import 'package:kid_matix/core/services/crash_reporter.dart';
import 'package:kid_matix/core/services/word_audio_service.dart';
import 'package:kid_matix/features/math_word/domain/services/math_word_domain.dart';
import 'package:kid_matix/features/math_word/injection.dart';
import 'package:kid_matix/features/addition/injection.dart';
import 'package:kid_matix/features/division/injection.dart';
import 'package:kid_matix/features/multiplication/injection.dart';
import 'package:kid_matix/features/number/injection.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'declares the math words after the numbers, with the audio packs',
    () async {
      // Arrange
      final GetIt inputLocator = GetIt.asNewInstance()
        ..registerLazySingleton<DomainRegistry>(DomainRegistry.new);
      registerMultiplicationFeature(inputLocator);
      registerNumbersFeature(inputLocator);
      registerAdditionFeature(inputLocator);
      registerDivisionFeature(inputLocator);
      // Act
      await registerMathWordFeature(inputLocator, bundle: rootBundle);
      // Assert
      final DomainRegistry actualRegistry = inputLocator<DomainRegistry>();
      expect(
        actualRegistry.find(MathWordDomain.domainId),
        isA<MathWordDomain>(),
      );
      expect(
        actualRegistry.domains.map((LearningDomain domain) => domain.id),
        <String>[
          'multiplication',
          'numbers',
          'addition',
          'division',
          'math_words',
        ],
      );
      // The Wolof pack is the default language and holds recordings (the
      // provisional machine-made ones until the owner's arrive).
      // A provisional pack is never the default of a child who never chose.
      expect(
        inputLocator<WordAudioService>().defaultLanguage,
        inputLocator<WordAudioService>().isProvisional('wo') ? isNull : 'wo',
      );
      expect(inputLocator<WordAudioService>().languages, <String>['wo']);
    },
  );

  test('leaves the domain out and reports a malformed asset', () async {
    // Arrange
    final _RecordingReporter reporter = _RecordingReporter();
    final GetIt inputLocator = GetIt.asNewInstance()
      ..registerLazySingleton<DomainRegistry>(DomainRegistry.new)
      ..registerSingleton<CrashReporter>(reporter);
    // Act
    await registerMathWordFeature(inputLocator, bundle: _BrokenBundle());
    // Assert
    expect(inputLocator<DomainRegistry>().domains, isEmpty);
    expect(reporter.errors, hasLength(1));
    expect(inputLocator<WordAudioService>().languages, isEmpty);
  });
}

final class _RecordingReporter implements CrashReporter {
  final List<Object> errors = <Object>[];

  @override
  void recordError(Object error, StackTrace stackTrace) => errors.add(error);
}

final class _BrokenBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    return ByteData.sublistView(Uint8List.fromList('{"words": 3}'.codeUnits));
  }
}
