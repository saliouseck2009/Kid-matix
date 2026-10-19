import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/widgets/word_audio_scope.dart';

import '../../../helpers/fake_word_audio_service.dart';
import '../../../helpers/pump_localized.dart';
import '../../../helpers/test_mastery_pages.dart';

/// « Mes mots »: a touched cell shows its word with the recorded help.
void main() {
  Future<FakeWordAudioService> pumpGrid(
    WidgetTester tester, {
    Set<String> recorded = const <String>{'il_reste'},
  }) async {
    final FakeWordAudioService audio = FakeWordAudioService(
      recorded: recorded,
    );
    await pumpLocalized(
      tester,
      Scaffold(
        body: SingleChildScrollView(
          child: WordAudioScope(
            audio: audio,
            child: HelpAudioLanguageScope(
              language: null,
              child: buildTestMasteryPages(
                repository: InMemoryItemProgressRepository(),
              ).buildGridCard(profileId: 'p1', domainId: 'math_words'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return audio;
  }

  testWidgets('shows the six families and plays the word touched', (
    WidgetTester tester,
  ) async {
    // Arrange
    final FakeWordAudioService audio = await pumpGrid(tester);
    expect(find.text('Mes mots'), findsOneWidget);
    expect(find.text('Écouter en wolof'), findsNothing);
    // Act
    await tester.tap(find.bySemanticsLabel(RegExp('^il reste')));
    await tester.pump();
    // Assert
    expect(find.text('il reste'), findsOneWidget);
    expect(find.text('Écouter en wolof'), findsOneWidget);
    // Act
    await tester.tap(find.text('Écouter en wolof'));
    await tester.pump();
    // Assert
    expect(audio.played, <String>['wo:il_reste:explanation']);
  });

  testWidgets('shows the word touched without a button when no file', (
    WidgetTester tester,
  ) async {
    // Arrange
    await pumpGrid(tester, recorded: const <String>{});
    // Act
    await tester.tap(find.bySemanticsLabel(RegExp('^il reste')));
    await tester.pump();
    // Assert
    expect(find.text('il reste'), findsOneWidget);
    expect(find.text('Écouter en wolof'), findsNothing);
  });

  testWidgets('leaves the cells of the tables alone', (
    WidgetTester tester,
  ) async {
    // Arrange
    await pumpLocalized(
      tester,
      Scaffold(
        body: SingleChildScrollView(
          child: buildTestMasteryPages(
            repository: InMemoryItemProgressRepository(),
          ).buildGridCard(profileId: 'p1', domainId: 'multiplication'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    // Act
    await tester.tap(find.bySemanticsLabel(RegExp('^5 fois 5')).first);
    await tester.pump();
    // Assert
    expect(find.text('Écouter en wolof'), findsNothing);
  });
}
