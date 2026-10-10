import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/features/learning_path/domain/entities/stage_kind.dart';
import 'package:kid_matix/features/learning_path/domain/entities/stage_progress_entity.dart';
import 'package:kid_matix/features/reward/domain/entities/badge_unlock_entity.dart';

import '../../../helpers/pump_localized.dart';
import '../../../helpers/test_path_pages.dart';
import '../../../helpers/test_reward_pages.dart';

void main() {
  testWidgets('the badge card shows the badges earned and to earn', (
    WidgetTester tester,
  ) async {
    // Arrange
    final SemanticsHandle handle = tester.ensureSemantics();
    final InMemoryRewardRepository inputRewards = InMemoryRewardRepository(
      badges: <BadgeUnlockEntity>[
        BadgeUnlockEntity(badgeKey: 'firstStep', unlockedAt: DateTime(2026)),
        BadgeUnlockEntity(badgeKey: 'tamer:mul:1', unlockedAt: DateTime(2026)),
      ],
    );
    // Act
    await pumpLocalized(
      tester,
      Scaffold(
        body: buildTestRewardPages(
          repository: inputRewards,
        ).buildBadgesCard(profileId: 'p1'),
      ),
    );
    await tester.pumpAndSettle();
    // Assert
    expect(find.text('Mes badges'), findsOneWidget);
    expect(find.bySemanticsLabel('Premier pas, obtenu'), findsOneWidget);
    expect(
      find.bySemanticsLabel('Dompteur de la table de 1, obtenu'),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel(RegExp(r'^Sprinter, à obtenir')),
      findsOneWidget,
    );
    handle.dispose();
  });

  testWidgets('the monster card colors the monsters defeated', (
    WidgetTester tester,
  ) async {
    // Arrange
    final SemanticsHandle handle = tester.ensureSemantics();
    final InMemoryStageProgressRepository inputProgress =
        InMemoryStageProgressRepository(<StageProgressEntity>[
          StageProgressEntity(
            profileId: 'p1',
            domainId: 'multiplication',
            unitKey: 'mul:1',
            stage: StageKind.boss,
            bestStars: 2,
            bestScore: 12,
            completedAt: DateTime(2026, 10, 10),
          ),
        ]);
    // Act
    await pumpLocalized(
      tester,
      Scaffold(
        body: buildTestPathPages(
          repository: inputProgress,
        ).buildMonstersCard(profileId: 'p1'),
      ),
    );
    await tester.pumpAndSettle();
    // Assert
    expect(find.text('Mes monstres'), findsOneWidget);
    expect(find.text('1 sur 12'), findsOneWidget);
    expect(
      find.bySemanticsLabel('Monstre de la table de 1, vaincu'),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel('Monstre de la table de 7, pas encore vaincu'),
      findsOneWidget,
    );
    handle.dispose();
  });
}
