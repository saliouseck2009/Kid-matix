import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/quiz/question_types/question_type_ids.dart';
import 'package:kid_matix/core/quiz/quiz_spec.dart';
import 'package:kid_matix/core/widgets/listen_button.dart';
import 'package:kid_matix/core/widgets/monster_family.dart';
import 'package:kid_matix/core/widgets/monster_painter.dart';
import 'package:kid_matix/core/widgets/read_aloud_scope.dart';
import 'package:kid_matix/features/learning_path/domain/entities/stage_kind.dart';
import 'package:kid_matix/features/learning_path/domain/entities/stage_progress_entity.dart';
import 'package:kid_matix/features/learning_path/domain/entities/stage_source.dart';
import 'package:kid_matix/features/learning_path/presentation/learning_path_pages.dart';

import '../../../helpers/fake_speech_service.dart';
import '../../../helpers/in_memory_local_storage.dart';
import '../../../helpers/pump_localized.dart';
import '../../../helpers/test_path_pages.dart';

StageProgressEntity _done(
  String domainId,
  String unitKey,
  StageKind stage, {
  int stars = 3,
}) {
  return StageProgressEntity(
    profileId: 'p1',
    domainId: domainId,
    unitKey: unitKey,
    stage: stage,
    bestStars: stars,
    bestScore: 10,
    completedAt: DateTime(2026, 10, 18),
  );
}

void main() {
  late InMemoryLocalStorage storage;
  late LearningPathPages pages;

  setUp(() {
    storage = InMemoryLocalStorage();
    pages = buildTestPathPages(
      storage: storage,
      repository: InMemoryStageProgressRepository(<StageProgressEntity>[
        _done('multiplication', 'mul:1', StageKind.discovery),
        _done('numbers', 'num:count10', StageKind.boss, stars: 2),
      ]),
    );
  });

  Future<void> pumpPage(WidgetTester tester, Widget page) async {
    tester.view.physicalSize = const Size(1170, 2532);
    addTearDown(tester.view.reset);
    await pumpLocalized(tester, page);
    await tester.pumpAndSettle();
  }

  Widget buildMap() {
    return pages.buildLearningPathPage(
      profileId: 'p1',
      onOpenTable: (_) {},
      onPlay: (_) {},
    );
  }

  group('the domain switch of the map', () {
    testWidgets('shows the multiplication first, then the numbers', (
      WidgetTester tester,
    ) async {
      // Arrange
      await pumpPage(tester, buildMap());
      expect(find.text('Multiplication'), findsOneWidget);
      expect(find.text('Nombres'), findsOneWidget);
      expect(find.bySemanticsLabel('Table de 1, en cours'), findsOneWidget);
      // Act
      await tester.tap(find.text('Nombres'));
      await tester.pumpAndSettle();
      // Assert
      expect(
        find.bySemanticsLabel(
          RegExp('^Compter jusqu\'à 10, terminée, 0 étoile'),
        ),
        findsNothing,
      );
      expect(
        find.bySemanticsLabel(RegExp("^Compter jusqu'à 10, en cours")),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel("Compter jusqu'à 20, verrouillée"),
        findsOneWidget,
      );
      expect(await storage.readString(key: 'path_domain.p1'), 'numbers');
    });
    testWidgets('opens on the domain the player chose last', (
      WidgetTester tester,
    ) async {
      // Arrange
      await storage.writeString(key: 'path_domain.p1', value: 'numbers');
      // Act
      await pumpPage(tester, buildMap());
      // Assert
      expect(
        find.bySemanticsLabel(RegExp("^Compter jusqu'à 10")),
        findsWidgets,
      );
      expect(find.bySemanticsLabel(RegExp('^Table de 1')), findsNothing);
    });
  });

  group('a unit of the numbers', () {
    testWidgets('names its stages as a lesson and shows it again', (
      WidgetTester tester,
    ) async {
      // Act
      await pumpPage(
        tester,
        pages.buildTableDetailPage(
          profileId: 'p1',
          unitKey: 'num:compare',
          onBack: () {},
          onPlay: (_) {},
          onShowTable: () {},
        ),
      );
      // Assert
      expect(find.text('Comparer'), findsOneWidget);
      expect(find.text('La leçon et son astuce'), findsOneWidget);
      expect(find.text('Bats le monstre de la leçon'), findsOneWidget);
      expect(find.text('Revoir la leçon'), findsOneWidget);
    });
    testWidgets('shows its items and its tip at the Discovery stage', (
      WidgetTester tester,
    ) async {
      // Act
      await pumpPage(
        tester,
        pages.buildDiscoveryPage(unitKey: 'num:tensones', onClose: () {}),
      );
      // Assert
      expect(find.text('Dizaines et unités'), findsOneWidget);
      expect(find.text('30 + 4'), findsOneWidget);
      expect(find.bySemanticsLabel('30 plus 4 égale 34'), findsOneWidget);
      expect(
        find.textContaining('3 paquets et 4 bâtonnets font 34'),
        findsOneWidget,
      );
    });
    testWidgets('reads the tip of a numbers unit aloud like a table tip', (
      WidgetTester tester,
    ) async {
      // Arrange
      final FakeSpeechService speech = FakeSpeechService();
      await pumpPage(
        tester,
        ReadAloudScope(
          speech: speech,
          child: pages.buildDiscoveryPage(
            unitKey: 'num:tensones',
            onClose: () {},
          ),
        ),
      );
      // Act
      await tester.tap(find.byType(ListenButton));
      await tester.pump();
      // Assert
      expect(speech.spoken, hasLength(1));
      expect(
        speech.spoken.single,
        contains('3 paquets et 4 bâtonnets font 34'),
      );
      expect(speech.languages, <String>['fr']);
    });
    test('plays its stages and its reviews', () {
      // Act
      final QuizSpec? actualStage = pages.specOf(
        const StageSource(
          unitKey: 'num:count20',
          stage: StageKind.writing,
        ).toKey(),
      );
      final QuizSpec? actualReview = pages.specOf(
        'path:review:numbers:2:review',
      );
      final QuizSpec? actualMultiplication = pages.specOf(
        'path:review:2:review',
      );
      // Assert
      expect(actualStage?.domainId, 'numbers');
      expect(
        actualStage?.questionTypeIds,
        contains(QuestionTypeIds.typedAnswer),
      );
      expect(actualReview?.domainId, 'numbers');
      expect(actualReview?.itemKeys, hasLength(60));
      expect(actualMultiplication?.domainId, 'multiplication');
      expect(pages.tableOf('path:num:compare:boss'), 'num:compare');
    });
  });

  group('the Profile cards of a domain', () {
    testWidgets('follow the domain chosen above them', (
      WidgetTester tester,
    ) async {
      // Arrange
      await pumpPage(
        tester,
        Scaffold(
          body: SingleChildScrollView(
            child: pages.buildDomainSection(
              profileId: 'p1',
              builder: (String domainId) => <Widget>[
                pages.buildMonstersCard(profileId: 'p1', domainId: domainId),
              ],
            ),
          ),
        ),
      );
      expect(find.text('0 sur 12'), findsOneWidget);
      // Act
      await tester.tap(find.text('Nombres'));
      await tester.pumpAndSettle();
      // Assert
      expect(find.text('1 sur 7'), findsOneWidget);
      expect(
        find.bySemanticsLabel(
          "Monstre de « Compter jusqu'à 10 », vaincu",
        ),
        findsOneWidget,
      );
      expect(find.text('Voir mes petits monstres'), findsNothing);
      final MonsterPainter actualPainter = tester
          .widgetList<CustomPaint>(find.byType(CustomPaint))
          .map((CustomPaint paint) => paint.painter)
          .whereType<MonsterPainter>()
          .first;
      expect(actualPainter.family, MonsterFamily.antennae);
    });
  });
}
