import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/features/quiz/domain/entities/read_aloud_mode.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/question_reading_cubit.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/question_reading_state.dart';

import '../../../helpers/fake_speech_service.dart';
import '../../../helpers/test_quiz_pages.dart';

void main() {
  late FakeSpeechService speech;

  QuestionReadingCubit buildCubit({
    bool readsByItself = false,
    String? contentLanguageCode,
    bool withVoiceUseCases = true,
  }) {
    return QuestionReadingCubit(
      useCases: withVoiceUseCases
          ? buildReadAloudUseCases(speech: speech, readsByItself: readsByItself)
          : null,
      profileId: 'p1',
      contentLanguageCode: contentLanguageCode,
    );
  }

  setUp(() => speech = FakeSpeechService());

  test('reads nothing and shows no button without use cases', () async {
    // Arrange
    final QuestionReadingCubit cubit = buildCubit(withVoiceUseCases: false);
    // Act
    await cubit.show(text: 'Combien ?', interfaceLanguageCode: 'fr');
    cubit.toggle();
    // Assert
    expect(cubit.state.canRead, isFalse);
    expect(speech.spoken, isEmpty);
    await cubit.close();
  });

  test('shows the button but waits for the tap when read on request', () async {
    // Arrange
    final QuestionReadingCubit cubit = buildCubit();
    // Act
    await cubit.show(text: 'Combien ?', interfaceLanguageCode: 'fr');
    // Assert
    expect(cubit.state.mode, ReadAloudMode.onRequest);
    expect(speech.spoken, isEmpty);
    // Act
    cubit.toggle();
    // Assert
    expect(speech.spoken, <String>['Combien ?']);
    expect(cubit.state.isSpeaking, isTrue);
    // Act
    cubit.toggle();
    // Assert
    expect(cubit.state.isSpeaking, isFalse);
    expect(speech.isSpeaking, isFalse);
    await cubit.close();
  });

  test('shows no button when the phone has no voice', () async {
    // Arrange
    speech = FakeSpeechService(hasVoice: false);
    final QuestionReadingCubit cubit = buildCubit(readsByItself: true);
    // Act
    await cubit.show(text: 'Combien ?', interfaceLanguageCode: 'fr');
    // Assert
    expect(cubit.state, const QuestionReadingState());
    expect(speech.spoken, isEmpty);
    await cubit.close();
  });

  test(
    'reads each new question by itself and stops the previous one',
    () async {
      // Arrange
      final QuestionReadingCubit cubit = buildCubit(readsByItself: true);
      // Act
      await cubit.show(text: 'Un', interfaceLanguageCode: 'fr');
      final bool wasSpeaking = speech.isSpeaking;
      await cubit.show(text: 'Deux', interfaceLanguageCode: 'fr');
      // Assert
      expect(wasSpeaking, isTrue);
      expect(speech.spoken, <String>['Un', 'Deux']);
      expect(speech.stopCount, greaterThan(0));
      await cubit.close();
    },
  );

  test('speaks the language of the domain, not of the interface', () async {
    // Arrange
    final QuestionReadingCubit cubit = buildCubit(
      readsByItself: true,
      contentLanguageCode: 'fr',
    );
    // Act
    await cubit.show(text: 'Combien ?', interfaceLanguageCode: 'en');
    // Assert
    expect(speech.languages, <String>['fr']);
    await cubit.close();
  });

  test('stops the voice when it is closed', () async {
    // Arrange
    final QuestionReadingCubit cubit = buildCubit(readsByItself: true);
    await cubit.show(text: 'Un', interfaceLanguageCode: 'fr');
    // Act
    await cubit.close();
    // Assert
    expect(speech.isSpeaking, isFalse);
  });
}
