import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/entities/help_audio.dart';
import 'package:kid_matix/core/entities/word_audio_kind.dart';
import 'package:kid_matix/core/widgets/help_audio_button.dart';
import 'package:kid_matix/core/widgets/word_audio_scope.dart';

import '../../helpers/fake_word_audio_service.dart';
import '../../helpers/pump_localized.dart';

/// The "Écouter en wolof" button: there only when a player chose a help
/// language and the recording exists.
void main() {
  late FakeWordAudioService audio;

  setUp(() {
    audio = FakeWordAudioService(
      recorded: <String>{'il_reste'},
      withExample: <String>{'il_reste'},
    );
  });

  Future<void> pumpButton(
    WidgetTester tester, {
    String wordKey = 'il_reste',
    WordAudioKind kind = WordAudioKind.explanation,
    String language = 'wo',
    bool hasScope = true,
    Locale locale = const Locale('fr'),
  }) async {
    Widget child = HelpAudioLanguageScope(
      language: language,
      child: Center(
        child: HelpAudioButton(wordKey: wordKey, kind: kind),
      ),
    );
    if (hasScope) child = WordAudioScope(audio: audio, child: child);
    await pumpLocalized(tester, child, locale: locale);
  }

  testWidgets('says Écouter en wolof and plays the explanation', (
    WidgetTester tester,
  ) async {
    // Arrange
    await pumpButton(tester);
    // Act
    await tester.tap(find.text('Écouter en wolof'));
    await tester.pump();
    // Assert
    expect(audio.played, <String>['wo:il_reste:explanation']);
  });

  testWidgets('plays the example when it is the example button', (
    WidgetTester tester,
  ) async {
    // Arrange
    await pumpButton(tester, kind: WordAudioKind.example);
    // Act
    await tester.tap(find.text('Exemple en wolof'));
    await tester.pump();
    // Assert
    expect(audio.played, <String>['wo:il_reste:example']);
  });

  testWidgets('is told in the language of the interface', (
    WidgetTester tester,
  ) async {
    // Act
    await pumpButton(tester, locale: const Locale('en'));
    // Assert
    expect(find.text('Listen in Wolof'), findsOneWidget);
  });

  testWidgets('is not there for a word with no recording', (
    WidgetTester tester,
  ) async {
    // Act
    await pumpButton(tester, wordKey: 'total');
    // Assert
    expect(find.byType(OutlinedButton), findsNothing);
  });

  testWidgets('is not there when the player chose no help', (
    WidgetTester tester,
  ) async {
    // Act
    await pumpButton(tester, language: HelpAudio.none);
    // Assert
    expect(find.byType(OutlinedButton), findsNothing);
  });

  testWidgets('is not there for a language with no pack', (
    WidgetTester tester,
  ) async {
    // Act
    await pumpButton(tester, language: 'xx');
    // Assert
    expect(find.byType(OutlinedButton), findsNothing);
  });

  testWidgets('is not there without the service', (WidgetTester tester) async {
    // Act
    await pumpButton(tester, hasScope: false);
    // Assert
    expect(find.byType(OutlinedButton), findsNothing);
  });

  testWidgets('shows a stop sign while it plays and stops on a second touch', (
    WidgetTester tester,
  ) async {
    // Arrange
    audio = FakeWordAudioService(
      recorded: <String>{'il_reste'},
      isInstant: false,
    );
    await pumpButton(tester);
    expect(find.byIcon(Icons.volume_up_rounded), findsOneWidget);
    // Act
    await tester.tap(find.text('Écouter en wolof'));
    await tester.pump();
    // Assert
    expect(find.byIcon(Icons.stop_rounded), findsOneWidget);
    // Act
    await tester.tap(find.text('Écouter en wolof'));
    await tester.pump();
    // Assert
    expect(audio.stopCount, 1);
    expect(find.byIcon(Icons.volume_up_rounded), findsOneWidget);
  });

  testWidgets('goes back to the speaker when the recording ends', (
    WidgetTester tester,
  ) async {
    // Arrange
    audio = FakeWordAudioService(
      recorded: <String>{'il_reste'},
      isInstant: false,
    );
    await pumpButton(tester);
    await tester.tap(find.text('Écouter en wolof'));
    await tester.pump();
    // Act
    audio.finishSound();
    await tester.pump();
    // Assert
    expect(find.byIcon(Icons.volume_up_rounded), findsOneWidget);
    expect(audio.stopCount, 0);
  });

  testWidgets('stops the sound when the screen goes away', (
    WidgetTester tester,
  ) async {
    // Arrange
    audio = FakeWordAudioService(
      recorded: <String>{'il_reste'},
      isInstant: false,
    );
    await pumpButton(tester);
    await tester.tap(find.text('Écouter en wolof'));
    await tester.pump();
    // Act
    await pumpLocalized(tester, const SizedBox.shrink());
    // Assert
    expect(audio.stopCount, 1);
  });
}
