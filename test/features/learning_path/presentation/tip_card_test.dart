import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/widgets/listen_button.dart';
import 'package:kid_matix/core/widgets/read_aloud_scope.dart';
import 'package:kid_matix/features/learning_path/presentation/widgets/tip_card.dart';

import '../../../helpers/fake_speech_service.dart';
import '../../../helpers/pump_localized.dart';

void main() {
  const String inputTip =
      'Dans la table de 5, les résultats finissent par 0 ou 5.';

  group('TipCard', () {
    testWidgets('reads the tip of the table aloud', (
      WidgetTester tester,
    ) async {
      // Arrange
      final FakeSpeechService speech = FakeSpeechService();
      await pumpLocalized(
        tester,
        Scaffold(
          body: ReadAloudScope(
            speech: speech,
            child: const TipCard(tip: inputTip),
          ),
        ),
      );
      await tester.pump();
      // Act
      await tester.tap(find.byType(ListenButton));
      await tester.pump();
      // Assert
      expect(speech.spoken, <String>[inputTip]);
      expect(speech.languages, <String>['fr']);
    });
    testWidgets('offers no button, and no message, without a voice', (
      WidgetTester tester,
    ) async {
      // Arrange
      final FakeSpeechService speech = FakeSpeechService(hasVoice: false);
      await pumpLocalized(
        tester,
        Scaffold(
          body: ReadAloudScope(
            speech: speech,
            child: const TipCard(tip: inputTip),
          ),
        ),
      );
      await tester.pump();
      // Assert
      expect(find.byType(ListenButton), findsNothing);
      expect(find.text(inputTip), findsOneWidget);
    });
  });
}
