import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:kid_matix/core/quiz/domain_registry.dart';
import 'package:kid_matix/core/quiz/learning_domain.dart';
import 'package:kid_matix/core/services/word_audio_service.dart';
import 'package:kid_matix/features/math_word/domain/services/math_word_domain.dart';
import 'package:kid_matix/features/math_word/injection.dart';
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
        <String>['multiplication', 'numbers', 'math_words'],
      );
      expect(inputLocator<WordAudioService>().languages, contains('wo'));
    },
  );
}
