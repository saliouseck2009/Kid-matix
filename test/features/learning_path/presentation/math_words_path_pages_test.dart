import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/entities/help_audio.dart';
import 'package:kid_matix/core/widgets/help_audio_button.dart';
import 'package:kid_matix/core/widgets/monster_family.dart';
import 'package:kid_matix/core/widgets/word_audio_scope.dart';
import 'package:kid_matix/features/learning_path/presentation/learning_path_pages.dart';

import '../../../helpers/fake_word_audio_service.dart';
import '../../../helpers/in_memory_local_storage.dart';
import '../../../helpers/pump_localized.dart';
import '../../../helpers/test_path_pages.dart';

/// The path of the math words on the map and on the Discovery page.
void main() {
  late InMemoryLocalStorage storage;
  late LearningPathPages pages;

  setUp(() {
    storage = InMemoryLocalStorage();
    pages = buildTestPathPages(storage: storage);
  });

  Future<void> pumpPage(WidgetTester tester, Widget page) async {
    tester.view.physicalSize = const Size(1170, 2532);
    addTearDown(tester.view.reset);
    await pumpLocalized(tester, page);
    await tester.pumpAndSettle();
  }

  testWidgets('offers the math words after the numbers, one node per family', (
    WidgetTester tester,
  ) async {
    // Arrange
    await pumpPage(
      tester,
      pages.buildLearningPathPage(
        profileId: 'p1',
        onOpenTable: (_) {},
        onPlay: (_) {},
      ),
    );
    expect(find.text('Mots des maths'), findsOneWidget);
    // Act
    await tester.tap(find.text('Mots des maths'));
    await tester.pumpAndSettle();
    // Assert
    expect(await storage.readString(key: 'path_domain.p1'), 'math_words');
    expect(
      find.bySemanticsLabel(RegExp('^Ajouter, en cours')),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('Enlever, verrouillée'), findsOneWidget);
    expect(find.bySemanticsLabel('Comparer, verrouillée'), findsOneWidget);
  });

  testWidgets('shows the words and the tip of a family at Discovery', (
    WidgetTester tester,
  ) async {
    // Act
    await pumpPage(
      tester,
      pages.buildDiscoveryPage(unitKey: 'word:remove', onClose: () {}),
    );
    // Assert
    expect(find.text('Enlever'), findsOneWidget);
    for (final String word in <String>['enlever', 'il reste', 'perdre']) {
      expect(find.text(word), findsOneWidget, reason: word);
    }
    expect(find.textContaining('il en reste moins'), findsOneWidget);
    expect(find.byType(HelpAudioButton), findsWidgets);
    expect(find.byIcon(Icons.volume_up_rounded), findsNothing);
  });

  testWidgets('offers the recording of each word that has one', (
    WidgetTester tester,
  ) async {
    // Arrange
    final FakeWordAudioService audio = FakeWordAudioService(
      recorded: <String>{'il_reste', 'perdre'},
    );
    await pumpPage(
      tester,
      WordAudioScope(
        audio: audio,
        child: HelpAudioLanguageScope(
          language: HelpAudio.defaultLanguage,
          child: pages.buildDiscoveryPage(
            unitKey: 'word:remove',
            onClose: () {},
          ),
        ),
      ),
    );
    // Assert
    expect(find.byIcon(Icons.volume_up_rounded), findsNWidgets(2));
    // Act
    await tester.tap(find.byIcon(Icons.volume_up_rounded).first);
    await tester.pump();
    // Assert
    expect(audio.played, <String>['wo:il_reste:explanation']);
  });

  test('gives the words their own monsters, after the other families', () {
    // Assert
    expect(MonsterFamily.of('math_words'), MonsterFamily.bubble);
  });
}
