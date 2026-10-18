import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kid_matix/core/router/app_router.dart';
import 'package:kid_matix/core/router/app_routes.dart';
import 'package:kid_matix/core/entities/app_color_theme.dart';
import 'package:kid_matix/core/theme/app_theme.dart';
import 'package:kid_matix/features/mascot/presentation/mascot_pages.dart';
import 'package:kid_matix/features/mastery/domain/entities/item_progress_entity.dart';
import 'package:kid_matix/main.dart';

import '../features/profile/helpers/profile_fixtures.dart';
import '../helpers/fake_profile_session_service.dart';
import '../helpers/fake_speech_service.dart';
import '../helpers/test_challenge_pages.dart';
import '../helpers/test_mascot_pages.dart';
import '../helpers/test_mastery_pages.dart';
import '../helpers/test_path_pages.dart';
import '../helpers/test_quiz_pages.dart';
import '../helpers/test_reward_pages.dart';
import '../helpers/test_code_challenge_pages.dart';
import '../helpers/test_duel_pages.dart';
import '../helpers/test_leaderboard_pages.dart';
import '../helpers/test_shop_pages.dart';

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
    AppColorTheme theme = AppColorTheme.lavender,
    Locale locale = const Locale('fr'),
  }) async {
    tester.view
      ..physicalSize = _phone
      ..devicePixelRatio = _pixelRatio;
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    mascotPages = buildTestMascotPages();
    // A voice is installed: every listen button must fit at every size.
    final FakeSpeechService speech = FakeSpeechService();
    router = createAppRouter(
      session: FakeProfileSessionService(activeProfileId: 'p-1'),
      profilePages: buildProfilePages(),
      quizPages: buildTestQuizPages(speech: speech),
      pathPages: buildTestPathPages(),
      rewardPages: buildTestRewardPages(),
      mascotPages: mascotPages,
      challengePages: buildTestChallengePages(),
      duelPages: buildTestDuelPages(),
      codePages: buildTestCodeChallengePages(),
      leaderboardPages: buildTestLeaderboardPages(),
      shopPages: buildTestShopPages(),
      masteryPages: buildTestMasteryPages(
        repository: InMemoryItemProgressRepository(<ItemProgressEntity>[
          for (int multiplier = 1; multiplier <= 10; multiplier++)
            ItemProgressEntity(
              profileId: 'p-1',
              domainId: 'multiplication',
              itemKey: 'mul:12x$multiplier',
              presentationCount: 9,
              correctCount: 6,
              lastAnswerTimes: const <Duration>[Duration(seconds: 4)],
              box: multiplier % 5 + 1,
            ),
        ]),
      ),
    );
    final Widget Function(Widget child) mascotScope = testMascotScope(
      mascotPages,
    );
    await tester.pumpWidget(
      KidMatixApp(
        locale: locale,
        router: router,
        speech: speech,
        scope: (Widget child) =>
            Theme(data: AppTheme.of(theme), child: mascotScope(child)),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> visit(WidgetTester tester, String location) async {
    router.go(location);
    await tester.pumpAndSettle();
  }

  group('Text at 130 % on a small phone', () {
    for (final String language in <String>['fr', 'en', 'es']) {
      for (final (String name, String location) in <(String, String)>[
        ('the learning path', AppRoutes.learningPath),
        ('the training', AppRoutes.training),
        ('the challenges', AppRoutes.challenges),
        ('the profile', AppRoutes.profile),
        ('the settings', AppRoutes.settings),
        ('the mascot', AppRoutes.mascot),
        ('the shop', AppRoutes.shop),
        ('my monsters', AppRoutes.challengeMonsters),
        ('the table detail', AppRoutes.tableDetailOf('mul:1')),
        ('the whole table', AppRoutes.tableViewOf('mul:1')),
        ('a multiple choice quiz', AppRoutes.playOf('path:mul:1:discovery')),
        ('a written quiz', AppRoutes.playOf('path:mul:1:writing')),
        ('a quiz against the clock', AppRoutes.playOf('timeAttack:mul:1')),
        ('a boss fight', AppRoutes.playOf('path:mul:1:boss')),
        ..._numbersScreens,
        ('a numbers boss fight', AppRoutes.playOf('path:num:count10:boss')),
        ..._additionScreens,
        (
          'an addition boss fight',
          AppRoutes.playOf('path:addsub:borrow:boss'),
        ),
        ..._divisionScreens,
        ('a division boss fight', AppRoutes.playOf('path:div:7:boss')),
      ]) {
        testWidgets('cuts no text on $name in $language', (
          WidgetTester tester,
        ) async {
          // Arrange
          await pumpApp(tester, locale: Locale(language));
          // Act
          await visit(tester, location);
          // Assert
          expect(tester.takeException(), isNull);
          expect(find.byType(Scaffold), findsWidgets);
        });
      }
    }
  });

  group('Accessibility guidelines', () {
    for (final (String name, String location) in _guidelineScreens) {
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
      }, timeout: _guidelineTimeout);
    }
  });

  group('Color themes of the shop', () {
    for (final AppColorTheme theme in AppColorTheme.values.skip(1)) {
      for (final (String name, String location) in _guidelineScreens) {
        testWidgets('keeps the text readable on $name in ${theme.name}', (
          WidgetTester tester,
        ) async {
          // Arrange
          final SemanticsHandle handle = tester.ensureSemantics();
          await pumpApp(tester, textScale: 1, theme: theme);
          // Act
          await visit(tester, location);
          // Assert
          expect(
            Theme.of(tester.element(find.byType(Scaffold).last)).colorScheme,
            AppTheme.of(theme).colorScheme,
          );
          await expectLater(tester, meetsGuideline(textContrastGuideline));
          handle.dispose();
        }, timeout: _guidelineTimeout);
      }
    }
  });
}

/// Screens checked against the accessibility guidelines.
final List<(String, String)> _guidelineScreens = <(String, String)>[
  ('the learning path', AppRoutes.learningPath),
  ('the training', AppRoutes.training),
  ('the challenges', AppRoutes.challenges),
  ('the profile', AppRoutes.profile),
  ('the settings', AppRoutes.settings),
  ('the mascot', AppRoutes.mascot),
  ('the shop', AppRoutes.shop),
  ('the leaderboard', AppRoutes.leaderboard),
  ('my monsters', AppRoutes.challengeMonsters),
  ('the table detail', AppRoutes.tableDetailOf('mul:1')),
  ('the whole table', AppRoutes.tableViewOf('mul:1')),
  ('a multiple choice quiz', AppRoutes.playOf('path:mul:1:discovery')),
  ('a written quiz', AppRoutes.playOf('path:mul:1:writing')),
  ..._numbersScreens,
  ..._divisionScreens,
  ..._additionScreens,
];

/// Screens of the additions and subtractions: the unit with the longest
/// name and a quiz asking a subtraction with a borrow.
final List<(String, String)> _additionScreens = <(String, String)>[
  ('a unit of the additions', AppRoutes.tableDetailOf('addsub:sub100')),
  ('an addition quiz', AppRoutes.playOf('path:addsub:borrow:discovery')),
];

/// Screens of the numbers domain: a unit, a drawing to read, the signs of
/// a comparison.
final List<(String, String)> _numbersScreens = <(String, String)>[
  ('a unit of the numbers', AppRoutes.tableDetailOf('num:count10')),
  ('a numbers quiz', AppRoutes.playOf('path:num:tensones:discovery')),
  ('a comparison quiz', AppRoutes.playOf('path:num:compare:writing')),
];

/// Screens of the division domain: a unit and a quiz with its operation.
final List<(String, String)> _divisionScreens = <(String, String)>[
  ('a unit of the division', AppRoutes.tableDetailOf('div:7')),
  ('a division quiz', AppRoutes.playOf('path:div:7:writing')),
];

/// Longest a guideline test may take: the contrast check takes a picture
/// of the screen, which once hung on a loaded machine; failing beats
/// waiting forever.
const Timeout _guidelineTimeout = Timeout(Duration(minutes: 2));
