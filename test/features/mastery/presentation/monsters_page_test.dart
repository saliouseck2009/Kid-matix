import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/widgets/little_monster.dart';
import 'package:kid_matix/features/mastery/domain/entities/item_progress_entity.dart';
import 'package:kid_matix/features/mastery/domain/repositories/item_progress_repository.dart';

import '../../../helpers/pump_localized.dart';
import '../../../helpers/test_mastery_pages.dart';

ItemProgressEntity _progress(String itemKey, int box, {int missed = 2}) {
  return ItemProgressEntity(
    profileId: 'p1',
    domainId: 'multiplication',
    itemKey: itemKey,
    presentationCount: 6,
    correctCount: 6 - missed,
    lastAnswerTimes: const <Duration>[Duration(seconds: 3)],
    box: box,
  );
}

/// Repository whose reads fail.
final class _FailingRepository implements ItemProgressRepository {
  @override
  Future<DataState<List<ItemProgressEntity>>> getProgress({
    required String profileId,
    required String domainId,
  }) async {
    return const DataFailed<List<ItemProgressEntity>>(CacheException());
  }

  @override
  Future<DataState<ItemProgressEntity>> getItemProgress({
    required String profileId,
    required String domainId,
    required String itemKey,
  }) async {
    return const DataFailed<ItemProgressEntity>(CacheException());
  }

  @override
  Future<DataState<void>> saveProgress({
    required ItemProgressEntity progress,
  }) async {
    return const DataFailed<void>(CacheException());
  }

  @override
  Stream<void> watchChanges() => const Stream<void>.empty();
}

void main() {
  group('MonstersPage', () {
    late List<String> calls;

    Future<void> pumpPage(
      WidgetTester tester,
      ItemProgressRepository repository,
    ) async {
      calls = <String>[];
      await pumpLocalized(
        tester,
        buildTestMasteryPages(repository: repository).buildMonstersPage(
          profileId: 'p1',
          huntQuestionCount: 10,
          onBack: () => calls.add('back'),
          onHunt: () => calls.add('hunt'),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('shows the monsters, the toughest first, and hunts them', (
      WidgetTester tester,
    ) async {
      // Arrange
      final SemanticsHandle handle = tester.ensureSemantics();
      await pumpPage(
        tester,
        InMemoryItemProgressRepository(<ItemProgressEntity>[
          _progress('mul:8x4', 3),
          _progress('mul:7x8', 1),
          _progress('mul:6x9', 2),
          _progress('mul:5x5', 1, missed: 1),
        ]),
      );
      // Act
      await tester.tap(find.text('Lancer la chasse'));
      // Assert
      expect(find.text('Mes monstres'), findsOneWidget);
      expect(find.text('10 questions'), findsOneWidget);
      expect(find.byType(LittleMonster), findsNWidgets(3));
      expect(
        tester.getTopLeft(find.text('7 × 8')).dy,
        lessThan(tester.getTopLeft(find.text('6 × 9')).dy),
      );
      expect(
        tester.getTopLeft(find.text('6 × 9')).dy,
        lessThan(tester.getTopLeft(find.text('8 × 4')).dy),
      );
      expect(find.text('Très coriace'), findsOneWidget);
      expect(find.text('Coriace'), findsOneWidget);
      expect(find.text('Presque apprivoisé'), findsOneWidget);
      expect(find.text('5 × 5'), findsNothing);
      expect(
        find.bySemanticsLabel('Monstre 7 fois 8, Très coriace'),
        findsOneWidget,
      );
      expect(find.text('Apprivoisés'), findsNothing);
      expect(calls, <String>['hunt']);
      handle.dispose();
    });
    testWidgets('collects the tamed monsters', (WidgetTester tester) async {
      // Arrange
      final SemanticsHandle handle = tester.ensureSemantics();
      final InMemoryItemProgressRepository inputRepository =
          InMemoryItemProgressRepository(<ItemProgressEntity>[
            _progress('mul:7x8', 3),
            _progress('mul:6x7', 4),
            _progress('mul:9x3', 5),
          ]);
      await pumpPage(tester, inputRepository);
      // Act
      await inputRepository.saveProgress(progress: _progress('mul:7x8', 4));
      await tester.pumpAndSettle();
      // Assert
      expect(find.text('Apprivoisés'), findsOneWidget);
      expect(find.text('3 monstres'), findsOneWidget);
      expect(find.text('6 × 7'), findsOneWidget);
      expect(find.text('9 × 3'), findsOneWidget);
      expect(find.text('7 × 8'), findsOneWidget);
      expect(
        find.bySemanticsLabel('Monstre 7 fois 8, apprivoisé'),
        findsOneWidget,
      );
      expect(find.text('Lancer la chasse'), findsNothing);
      handle.dispose();
    });
    testWidgets('encourages the player without monsters and goes back', (
      WidgetTester tester,
    ) async {
      // Arrange
      await pumpPage(tester, InMemoryItemProgressRepository());
      // Act
      await tester.tap(find.byTooltip('Retour'));
      // Assert
      expect(
        find.text(
          'Aucun monstre en vue, bravo ! Un calcul raté deux fois '
          'deviendra un petit monstre à apprivoiser.',
        ),
        findsOneWidget,
      );
      expect(find.text('Lancer la chasse'), findsNothing);
      expect(calls, <String>['back']);
    });
    testWidgets('says when the monsters cannot be read', (
      WidgetTester tester,
    ) async {
      // Act
      await pumpPage(tester, _FailingRepository());
      // Assert
      expect(
        find.text("Oups, on n'a pas pu lire ou enregistrer tes données."),
        findsOneWidget,
      );
    });
  });

  group('LittleMonster', () {
    test('keeps the same color for the same fact', () {
      // Act
      final int actualFirst = LittleMonster.variantOf('mul:7x8');
      final int actualSecond = LittleMonster.variantOf('mul:7x8');
      // Assert
      expect(actualFirst, actualSecond);
      expect(actualFirst, isNonNegative);
      expect(LittleMonster.variantOf('mul:8x7'), isNot(actualFirst));
    });
    test('repaints only when its color or mood changes', () {
      // Arrange
      final LittleMonsterPainter inputPainter = LittleMonsterPainter(
        body: LittleMonsterPainter.bodyColors.first,
        isTamed: false,
      );
      // Act & Assert
      expect(
        inputPainter.shouldRepaint(
          LittleMonsterPainter(
            body: LittleMonsterPainter.bodyColors.first,
            isTamed: false,
          ),
        ),
        isFalse,
      );
      expect(
        inputPainter.shouldRepaint(
          LittleMonsterPainter(
            body: LittleMonsterPainter.bodyColors.first,
            isTamed: true,
          ),
        ),
        isTrue,
      );
    });
  });
}
