import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/entities/mascot_accessory.dart';
import 'package:kid_matix/core/entities/mascot_look.dart';
import 'package:kid_matix/core/widgets/mascot_look_scope.dart';
import 'package:kid_matix/core/widgets/speech_bubble.dart';
import 'package:kid_matix/features/mascot/domain/entities/mascot_record.dart';
import 'package:kid_matix/features/mascot/presentation/mascot_pages.dart';

import '../../../helpers/pump_localized.dart';
import '../../../helpers/test_mascot_pages.dart';
import '../../../helpers/test_reward_pages.dart';
import '../helpers/mascot_fakes.dart';

void main() {
  late InMemoryMascotRepository repository;
  late FixedRewardService rewards;
  late FixedCrownService crowns;
  late MascotPages pages;

  setUp(() {
    repository = InMemoryMascotRepository();
    rewards = FixedRewardService(level: 6);
    crowns = FixedCrownService(crowns: 1);
    pages = buildTestMascotPages(
      repository: repository,
      rewards: rewards,
      crowns: crowns,
    );
  });

  Future<void> pumpInScope(WidgetTester tester, Widget child) async {
    tester.view.physicalSize = const Size(1170, 2532);
    addTearDown(tester.view.reset);
    await pumpLocalized(
      tester,
      pages.buildScope(profileId: 'p1', child: child),
    );
    await tester.pumpAndSettle();
  }

  group('Mascot widgets', () {
    testWidgets('the profile card shows the stage and the next one', (
      WidgetTester tester,
    ) async {
      // Arrange
      repository.records['p1'] = MascotRecord(
        name: 'Lim',
        worn: const <MascotAccessory>[],
        celebratedStage: 2,
      );
      bool isOpened = false;
      // Act
      await pumpInScope(
        tester,
        Scaffold(
          body: pages.buildProfileCard(onOpen: () => isOpened = true),
        ),
      );
      await tester.tap(find.text('Ta mascotte grandit'));
      // Assert
      expect(
        find.text('Stade 2 sur 5 · prochain au niveau 10'),
        findsOneWidget,
      );
      expect(isOpened, isTrue);
    });
    testWidgets('the mascot page dresses and renames the mascot', (
      WidgetTester tester,
    ) async {
      // Arrange
      await pumpInScope(tester, pages.buildMascotPage(onBack: () {}));
      // Act
      await tester.tap(find.text('Casquette'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Bouboule');
      await tester.tap(find.text('Changer le nom'));
      await tester.pumpAndSettle();
      // Assert
      expect(repository.records['p1']!.worn, <MascotAccessory>[
        MascotAccessory.cap,
      ]);
      expect(repository.records['p1']!.name, 'Bouboule');
      expect(
        find.bySemanticsLabel('Casquette, sur ta mascotte'),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel(
          'Chapeau de magicien, à débloquer. À la 6e couronne',
        ),
        findsOneWidget,
      );
      final BuildContext context = tester.element(find.byType(TextField));
      expect(
        MascotLookScope.of(context),
        MascotLook(
          stage: 2,
          accessories: const <MascotAccessory>{MascotAccessory.cap},
        ),
      );
    });
    testWidgets('the map mascot celebrates a new stage once', (
      WidgetTester tester,
    ) async {
      // Act
      await pumpInScope(
        tester,
        Scaffold(
          body: pages.buildMapMascot(
            bubble: const SpeechBubble(text: 'Bonjour'),
          ),
        ),
      );
      // Assert
      expect(find.text('Lim a grandi !'), findsOneWidget);
      expect(find.text('Stade 2 sur 5'), findsOneWidget);
      await tester.tap(find.text("Touche l'écran pour continuer"));
      await tester.pumpAndSettle();
      expect(find.text('Bonjour'), findsOneWidget);
      expect(repository.records['p1']!.celebratedStage, 2);
    });
    testWidgets('the map celebrates a stage reached before it showed', (
      WidgetTester tester,
    ) async {
      // Arrange: the mascot is read while the map is not shown.
      final ValueNotifier<bool> inputShowsMap = ValueNotifier<bool>(false);
      addTearDown(inputShowsMap.dispose);
      await pumpInScope(
        tester,
        Scaffold(
          body: ValueListenableBuilder<bool>(
            valueListenable: inputShowsMap,
            builder: (BuildContext context, bool showsMap, _) => showsMap
                ? pages.buildMapMascot(
                    bubble: const SpeechBubble(text: 'Bonjour'),
                  )
                : const SizedBox.shrink(),
          ),
        ),
      );
      expect(find.text('Lim a grandi\u00a0!'), findsNothing);
      // Act
      inputShowsMap.value = true;
      await tester.pumpAndSettle();
      // Assert
      expect(find.text('Lim a grandi\u00a0!'), findsOneWidget);
    });
    testWidgets('the mascot reminds the daily goal', (
      WidgetTester tester,
    ) async {
      // Act
      await pumpLocalized(
        tester,
        buildTestRewardPages(
          repository: InMemoryRewardRepository(xpEarned: 5),
        ).buildGoalReminder(profileId: 'p1'),
      );
      await tester.pumpAndSettle();
      // Assert
      expect(
        find.text('Encore 15 XP pour ton objectif du jour !'),
        findsOneWidget,
      );
    });
  });
}
