import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/widgets/listen_button.dart';
import 'package:kid_matix/core/widgets/read_aloud_button.dart';
import 'package:kid_matix/core/widgets/read_aloud_scope.dart';
import 'package:kid_matix/core/widgets/speech_bubble.dart';

import '../../helpers/fake_speech_service.dart';
import '../../helpers/pump_localized.dart';

void main() {
  late FakeSpeechService speech;

  setUp(() => speech = FakeSpeechService());

  Future<void> pumpScoped(
    WidgetTester tester,
    Widget child, {
    bool hasScope = true,
    Locale locale = const Locale('fr'),
  }) async {
    await pumpLocalized(
      tester,
      Scaffold(
        body: hasScope ? ReadAloudScope(speech: speech, child: child) : child,
      ),
      locale: locale,
    );
    await tester.pump();
  }

  group('ReadAloudButton', () {
    testWidgets('reads its text in the language of the interface', (
      WidgetTester tester,
    ) async {
      // Arrange
      await pumpScoped(
        tester,
        const ReadAloudButton(text: 'Pour la table de 5, compte de 5 en 5.'),
      );
      // Act
      await tester.tap(find.byType(ListenButton));
      await tester.pump();
      // Assert
      expect(speech.spoken, <String>['Pour la table de 5, compte de 5 en 5.']);
      expect(speech.languages, <String>['fr']);
    });
    testWidgets('speaks English in an English interface', (
      WidgetTester tester,
    ) async {
      // Arrange
      await pumpScoped(
        tester,
        const ReadAloudButton(text: 'Count by 5.'),
        locale: const Locale('en'),
      );
      // Act
      await tester.tap(find.byTooltip('Listen'));
      await tester.pump();
      // Assert
      expect(speech.languages, <String>['en']);
    });
    testWidgets('becomes a stop button while the voice speaks, then stops it', (
      WidgetTester tester,
    ) async {
      // Arrange
      await pumpScoped(tester, const ReadAloudButton(text: 'Compte.'));
      // Act
      await tester.tap(find.byTooltip('Écouter'));
      await tester.pump();
      // Assert
      expect(find.byIcon(Icons.stop_rounded), findsOneWidget);
      // Act
      await tester.tap(find.byTooltip('Arrêter la lecture'));
      await tester.pump();
      // Assert
      expect(speech.isSpeaking, isFalse);
      expect(find.byIcon(Icons.volume_up_rounded), findsOneWidget);
    });
    testWidgets('goes back to a speaker once the voice is done', (
      WidgetTester tester,
    ) async {
      // Arrange
      await pumpScoped(tester, const ReadAloudButton(text: 'Compte.'));
      await tester.tap(find.byTooltip('Écouter'));
      await tester.pump();
      // Act
      speech.finishReading();
      await tester.pump();
      // Assert
      expect(find.byIcon(Icons.volume_up_rounded), findsOneWidget);
    });
    testWidgets('shows nothing, and no message, without a voice', (
      WidgetTester tester,
    ) async {
      // Arrange
      speech.hasVoice = false;
      // Act
      await pumpScoped(tester, const ReadAloudButton(text: 'Compte.'));
      // Assert
      expect(find.byType(ListenButton), findsNothing);
      expect(find.byType(SnackBar), findsNothing);
    });
    testWidgets('shows nothing where no voice is wired', (
      WidgetTester tester,
    ) async {
      // Act
      await pumpScoped(
        tester,
        const ReadAloudButton(text: 'Compte.'),
        hasScope: false,
      );
      // Assert
      expect(find.byType(ListenButton), findsNothing);
    });
    testWidgets('stops the voice when its screen goes away', (
      WidgetTester tester,
    ) async {
      // Arrange
      await pumpScoped(tester, const ReadAloudButton(text: 'Compte.'));
      await tester.tap(find.byTooltip('Écouter'));
      await tester.pump();
      expect(speech.isSpeaking, isTrue);
      // Act
      await tester.pumpWidget(const SizedBox.shrink());
      // Assert
      expect(speech.isSpeaking, isFalse);
    });
  });

  group('SpeechBubble', () {
    testWidgets('is a plain bubble without a voice', (
      WidgetTester tester,
    ) async {
      // Act
      await pumpScoped(
        tester,
        const SpeechBubble(text: 'Pas grave, tu vas y arriver !'),
        hasScope: false,
      );
      // Assert
      expect(find.text('Pas grave, tu vas y arriver !'), findsOneWidget);
      expect(find.byIcon(Icons.volume_up_rounded), findsNothing);
    });
    testWidgets('reads the message of the mascot when tapped', (
      WidgetTester tester,
    ) async {
      // Arrange
      await pumpScoped(
        tester,
        const SpeechBubble(text: 'Pas grave, tu vas y arriver !'),
      );
      expect(find.byIcon(Icons.volume_up_rounded), findsOneWidget);
      // Act
      await tester.tap(find.text('Pas grave, tu vas y arriver !'));
      await tester.pump();
      // Assert
      expect(speech.spoken, <String>['Pas grave, tu vas y arriver !']);
      expect(find.byIcon(Icons.stop_rounded), findsOneWidget);
    });
    testWidgets('keeps a 48 dp target to tap', (WidgetTester tester) async {
      // Act
      await pumpScoped(tester, const SpeechBubble(text: 'Bravo !'));
      // Assert
      expect(
        tester.getSize(find.byType(SpeechBubble)).height,
        greaterThanOrEqualTo(48),
      );
    });
    testWidgets('shows no speaker when no voice is installed', (
      WidgetTester tester,
    ) async {
      // Arrange
      speech.hasVoice = false;
      // Act
      await pumpScoped(tester, const SpeechBubble(text: 'Bravo !'));
      // Assert
      expect(find.byIcon(Icons.volume_up_rounded), findsNothing);
      expect(find.text('Bravo !'), findsOneWidget);
    });
  });
}
