import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/widgets/word_audio_scope.dart';
import 'package:kid_matix/core/widgets/word_picture/word_picture_view.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/quiz_help_card.dart';

import '../../../helpers/fake_word_audio_service.dart';
import '../../../helpers/pump_localized.dart';
import '../../math_word/helpers/math_word_fixtures.dart';

/// The help card of a word missed twice: the family, the drawing and the
/// recorded help.
void main() {
  testWidgets('shows the words of the family, the drawing and the Wolof', (
    WidgetTester tester,
  ) async {
    // Arrange
    tester.view.physicalSize = const Size(1170, 2532);
    addTearDown(tester.view.reset);
    final FakeWordAudioService audio = FakeWordAudioService(
      recorded: <String>{'il_reste'},
    );
    final help = buildMathWordDomain().helpOf(
      loadMathWordCatalog().wordOf('il_reste')!,
    );
    // Act
    await pumpLocalized(
      tester,
      Scaffold(
        body: WordAudioScope(
          audio: audio,
          child: HelpAudioLanguageScope(
            language: 'wo',
            child: QuizHelpCard(help: help, unitName: 'Enlever'),
          ),
        ),
      ),
    );
    // Assert
    expect(find.text('il reste'), findsOneWidget);
    expect(find.text('perdre'), findsOneWidget);
    expect(find.byType(WordPictureView), findsOneWidget);
    expect(find.text('Écouter en wolof'), findsOneWidget);
    // Act
    await tester.tap(find.text('Écouter en wolof'));
    await tester.pump();
    // Assert
    expect(audio.played, <String>['wo:il_reste:explanation']);
  });
}
