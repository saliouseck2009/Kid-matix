import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kid_matix/core/router/app_router.dart';
import 'package:kid_matix/core/router/app_routes.dart';
import 'package:kid_matix/features/mascot/presentation/mascot_pages.dart';
import 'package:kid_matix/main.dart';

import '../features/profile/helpers/profile_fixtures.dart';
import '../helpers/fake_profile_session_service.dart';
import '../helpers/test_challenge_pages.dart';
import '../helpers/test_mascot_pages.dart';
import '../helpers/test_mastery_pages.dart';
import '../helpers/test_path_pages.dart';
import '../helpers/test_quiz_pages.dart';
import '../helpers/test_reward_pages.dart';

/// A small phone: 360 x 740 points.
const Size _phone = Size(1080, 2220);
const double _pixelRatio = 3;

/// Largest system text size the app must support without cut text.
const double _largestTextScale = 1.3;

void main() {
  late GoRouter router;
  late MascotPages mascotPages;

  Future<void> pumpApp(
    WidgetTester tester, {
    double textScale = _largestTextScale,
  }) async {
    tester.view
      ..physicalSize = _phone
      ..devicePixelRatio = _pixelRatio;
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    mascotPages = buildTestMascotPages();
    router = createAppRouter(
      session: FakeProfileSessionService(activeProfileId: 'p-1'),
      profilePages: buildProfilePages(),
      quizPages: buildTestQuizPages(),
      pathPages: buildTestPathPages(),
      rewardPages: buildTestRewardPages(),
      mascotPages: mascotPages,
      challengePages: buildTestChallengePages(),
      masteryPages: buildTestMasteryPages(),
    );
    await tester.pumpWidget(
      KidMatixApp(router: router, scope: testMascotScope(mascotPages)),
    );
    await tester.pumpAndSettle();
  }

  Future<void> visit(WidgetTester tester, String location) async {
    router.go(location);
    await tester.pumpAndSettle();
  }

  group('Text at 130 % on a small phone', () {
    for (final (String name, String location) in <(String, String)>[
      ('the learning path', AppRoutes.learningPath),
      ('the training', AppRoutes.training),
      ('the challenges', AppRoutes.challenges),
      ('the profile', AppRoutes.profile),
      ('the settings', AppRoutes.settings),
      ('the mascot', AppRoutes.mascot),
      ('the table detail', AppRoutes.tableDetailOf('mul:1')),
      ('the whole table', AppRoutes.tableViewOf('mul:1')),
      ('a multiple choice quiz', AppRoutes.playOf('path:mul:1:discovery')),
      ('a written quiz', AppRoutes.playOf('path:mul:1:writing')),
      ('a quiz against the clock', AppRoutes.playOf('timeAttack:mul:1')),
      ('a boss fight', AppRoutes.playOf('path:mul:1:boss')),
    ]) {
      testWidgets('cuts no text on $name', (WidgetTester tester) async {
        // Arrange
        await pumpApp(tester);
        // Act
        await visit(tester, location);
        // Assert
        expect(tester.takeException(), isNull);
        expect(find.byType(Scaffold), findsWidgets);
      });
    }
  });

  group('Accessibility guidelines', () {
    for (final (String name, String location) in <(String, String)>[
      ('the learning path', AppRoutes.learningPath),
      ('the training', AppRoutes.training),
      ('the challenges', AppRoutes.challenges),
      ('the profile', AppRoutes.profile),
      ('the settings', AppRoutes.settings),
      ('the mascot', AppRoutes.mascot),
      ('the table detail', AppRoutes.tableDetailOf('mul:1')),
      ('a multiple choice quiz', AppRoutes.playOf('path:mul:1:discovery')),
      ('a written quiz', AppRoutes.playOf('path:mul:1:writing')),
    ]) {
      testWidgets('meets the tap, label and contrast rules on $name', (
        WidgetTester tester,
      ) async {
        // Arrange
        final SemanticsHandle handle = tester.ensureSemantics();
        await pumpApp(tester, textScale: 1);
        // Act
        await visit(tester, location);
        // Assert
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        await expectLater(tester, meetsGuideline(textContrastGuideline));
        handle.dispose();
      });
    }
  });
}
