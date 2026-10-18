import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/error/app_error_code.dart';
import 'package:kid_matix/features/challenge/domain/entities/challenge_code.dart';
import 'package:kid_matix/features/challenge/domain/entities/challenge_code_error.dart';
import 'package:kid_matix/features/challenge/domain/entities/challenge_code_mode.dart';
import 'package:kid_matix/features/challenge/domain/entities/challenge_code_reading.dart';
import 'package:kid_matix/features/challenge/domain/entities/challenge_source.dart';
import 'package:kid_matix/features/challenge/domain/services/challenge_code_codec.dart';
import 'package:kid_matix/features/challenge/presentation/bloc/challenge_share_cubit.dart';
import 'package:kid_matix/features/challenge/presentation/bloc/challenge_share_state.dart';
import 'package:kid_matix/features/challenge/presentation/bloc/code_challenge_use_cases.dart';
import 'package:kid_matix/features/challenge/presentation/bloc/code_entry_cubit.dart';
import 'package:kid_matix/features/challenge/presentation/bloc/code_entry_state.dart';
import 'package:kid_matix/features/challenge/presentation/code_challenge_pages.dart';
import 'package:kid_matix/features/challenge/presentation/widgets/challenge_labels.dart';
import 'package:kid_matix/l10n/app_localizations_fr.dart';

import '../../../helpers/pump_localized.dart';
import '../../../helpers/test_code_challenge_pages.dart';

const ChallengeCodeCodec _codec = ChallengeCodeCodec();

ChallengeCode _challenge({
  ChallengeCodeMode mode = ChallengeCodeMode.timeAttack,
  int questionCount = 80,
  int score = 18,
}) {
  return ChallengeCode(
    tables: const <int>[2, 5],
    mode: mode,
    questionCount: questionCount,
    seed: 4242,
    scoreToBeat: score,
    generatorVersion: 1,
  );
}

ChallengeCode _decode(String code) {
  return (_codec.decode(code) as ChallengeCodeAccepted).code;
}

void main() {
  final CodeChallengePages pages = buildTestCodeChallengePages();
  final String timeAttackCode = _codec.encode(_challenge());

  Future<void> pumpPage(WidgetTester tester, Widget page) async {
    tester.view.physicalSize = const Size(1170, 2532);
    addTearDown(tester.view.reset);
    await pumpLocalized(tester, page);
    await tester.pumpAndSettle();
  }

  group('CodeChallengePages.buildShareButton', () {
    testWidgets('makes a code of a time attack with its score', (
      WidgetTester tester,
    ) async {
      // Arrange
      final List<String> shared = <String>[];
      final Widget? button = pages.buildShareButton(
        sourceKey: TimeAttackSource(
          unitKeys: const <String>['mul:2', 'mul:5'],
        ).toKey(),
        score: 18,
        onShare: shared.add,
      );
      await pumpPage(tester, Scaffold(body: button));
      // Act
      await tester.tap(find.text('Défier un ami'));
      await tester.pumpAndSettle();
      // Assert
      expect(shared, hasLength(1));
      final ChallengeCode actualCode = _decode(shared.single);
      expect(actualCode.tables, <int>[2, 5]);
      expect(actualCode.mode, ChallengeCodeMode.timeAttack);
      expect(actualCode.scoreToBeat, 18);
    });
    test('offers nothing for a game that is not coded', () {
      // Act & Assert
      for (final String? inputKey in <String?>[
        null,
        'path:mul:5:training',
        'survival:mul:1',
        'dailyReview',
        'code:$timeAttackCode',
      ]) {
        expect(
          pages.buildShareButton(
            sourceKey: inputKey,
            score: 3,
            onShare: (_) {},
          ),
          isNull,
          reason: inputKey,
        );
      }
    });
  });

  group('CodeChallengePages.buildCodePage', () {
    testWidgets('shows the code to give and copies it', (
      WidgetTester tester,
    ) async {
      // Arrange
      String? copied;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (MethodCall call) async {
          if (call.method == 'Clipboard.setData') {
            copied =
                (call.arguments as Map<Object?, Object?>)['text'] as String?;
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );
      await pumpPage(
        tester,
        pages.buildCodePage(
          code: timeAttackCode,
          onBack: () {},
          onPlay: (_) {},
        ),
      );
      // Act
      await tester.tap(find.text('Copier le code'));
      await tester.pumpAndSettle();
      // Assert
      expect(find.text('Défier un ami'), findsOneWidget);
      expect(find.text('Contre-la-montre'), findsOneWidget);
      expect(find.text('Tables de 2 et de 5'), findsOneWidget);
      expect(find.text('18'), findsOneWidget);
      expect(
        find.text(ChallengeCodeCodec.format(timeAttackCode)),
        findsOneWidget,
      );
      expect(find.text('Tu as reçu un code ?'), findsOneWidget);
      expect(copied, ChallengeCodeCodec.format(timeAttackCode));
      expect(find.text('Code copié !'), findsOneWidget);
    });
    testWidgets('« J\'ai un code » shows the entry alone and goes back', (
      WidgetTester tester,
    ) async {
      // Arrange
      int backCount = 0;
      await pumpPage(
        tester,
        pages.buildCodePage(
          code: null,
          onBack: () => backCount++,
          onPlay: (_) {},
        ),
      );
      // Act
      await tester.tap(find.byTooltip('Retour'));
      // Assert
      expect(find.text("J'ai un code"), findsOneWidget);
      expect(find.text('Copier le code'), findsNothing);
      expect(backCount, 1);
    });
    testWidgets('plays a valid code typed in lowercase with dashes', (
      WidgetTester tester,
    ) async {
      // Arrange
      final List<String> played = <String>[];
      await pumpPage(
        tester,
        pages.buildCodePage(code: null, onBack: () {}, onPlay: played.add),
      );
      // Act
      await tester.enterText(
        find.byType(TextField),
        ChallengeCodeCodec.format(timeAttackCode).toLowerCase(),
      );
      await tester.pump();
      await tester.tap(find.text('Jouer ce défi'));
      await tester.pumpAndSettle();
      // Assert
      expect(played, <String>['code:$timeAttackCode']);
    });
    testWidgets('says why a code is refused, until it is changed', (
      WidgetTester tester,
    ) async {
      // Arrange
      final String inputAltered =
          '${timeAttackCode.substring(0, 9)}'
          '${timeAttackCode[9] == 'A' ? 'B' : 'A'}';
      await pumpPage(
        tester,
        pages.buildCodePage(code: null, onBack: () {}, onPlay: (_) {}),
      );
      // Act
      await tester.enterText(find.byType(TextField), inputAltered);
      await tester.testTextInput.receiveAction(TextInputAction.go);
      await tester.pumpAndSettle();
      // Assert
      expect(
        find.text(
          'Une lettre ou un chiffre ne va pas. Vérifie le code avec ton ami.',
        ),
        findsOneWidget,
      );
      // Act
      await tester.enterText(find.byType(TextField), 'K7M2');
      await tester.pump();
      // Assert
      expect(find.textContaining('ne va pas'), findsNothing);
    });
    testWidgets('cannot play an empty code', (WidgetTester tester) async {
      // Arrange
      await pumpPage(
        tester,
        pages.buildCodePage(code: null, onBack: () {}, onPlay: (_) {}),
      );
      // Act
      await tester.tap(find.text('Jouer ce défi'));
      await tester.pumpAndSettle();
      // Assert
      expect(find.textContaining("n'existe pas"), findsNothing);
    });
  });

  group('CodeChallengePages.buildOutcome', () {
    Future<List<String>> pumpOutcome(
      WidgetTester tester, {
      required int score,
      VoidCallback? onBack,
    }) async {
      final List<String> shared = <String>[];
      await pumpPage(
        tester,
        Scaffold(
          body: pages.buildOutcome(
            sourceKey: 'code:$timeAttackCode',
            score: score,
            onShare: shared.add,
            onBack: onBack ?? () {},
            xpLabel: const Text('+210 XP'),
          ),
        ),
      );
      return shared;
    }

    testWidgets('a won challenge: both scores, the crown and the XP', (
      WidgetTester tester,
    ) async {
      // Act
      await pumpOutcome(tester, score: 21);
      // Assert
      expect(find.text('Défi gagné !'), findsOneWidget);
      expect(
        find.text('Contre-la-montre · tables de 2 et de 5'),
        findsOneWidget,
      );
      expect(find.text('Score à battre'), findsOneWidget);
      expect(find.text('Ton score'), findsOneWidget);
      expect(find.text('18'), findsOneWidget);
      expect(find.text('21'), findsOneWidget);
      expect(find.text('3 bonnes réponses de plus'), findsOneWidget);
      expect(find.text('+210 XP'), findsOneWidget);
    });
    testWidgets('a lost challenge and a tie', (WidgetTester tester) async {
      // Act
      await pumpOutcome(tester, score: 17);
      // Assert
      expect(find.text('Pas cette fois !'), findsOneWidget);
      expect(find.text('1 bonne réponse de moins'), findsOneWidget);
      // Act
      await pumpOutcome(tester, score: 18);
      // Assert
      expect(find.text('Égalité !'), findsOneWidget);
      expect(find.text('Autant de bonnes réponses'), findsOneWidget);
    });
    testWidgets('sends back the same questions with the new score', (
      WidgetTester tester,
    ) async {
      // Arrange
      int backCount = 0;
      final List<String> shared = await pumpOutcome(
        tester,
        score: 25,
        onBack: () => backCount++,
      );
      // Act
      await tester.tap(find.text('Renvoyer un défi'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Retour aux défis'));
      // Assert
      expect(shared, <String>[
        _codec.encode(_challenge().copyWith(scoreToBeat: 25)),
      ]);
      expect(backCount, 1);
    });
    test('replaces nothing but a game played from a code', () {
      // Act
      final Widget? actualOutcome = pages.buildOutcome(
        sourceKey: 'timeAttack:mul:1',
        score: 3,
        onShare: (_) {},
        onBack: () {},
      );
      // Assert
      expect(actualOutcome, isNull);
    });
  });

  group('ChallengeShareCubit', () {
    final CodeChallengeUseCases useCases = buildTestCodeChallengeUseCases();

    blocTest<ChallengeShareCubit, ChallengeShareState>(
      'fails for a game that cannot be coded',
      build: () => ChallengeShareCubit(encode: useCases.encode),
      act: (ChallengeShareCubit cubit) =>
          cubit.share(sourceKey: 'dailyReview', score: 3),
      expect: () => <Matcher>[
        isA<ChallengeSharing>(),
        isA<ChallengeShareFailed>().having(
          (ChallengeShareFailed state) => state.errorCode,
          'errorCode',
          AppErrorCode.validation,
        ),
      ],
    );
    blocTest<ChallengeShareCubit, ChallengeShareState>(
      'ignores a second tap while the code is made',
      build: () => ChallengeShareCubit(encode: useCases.encode),
      act: (ChallengeShareCubit cubit) {
        cubit
          ..share(sourceKey: 'code:$timeAttackCode', score: 3)
          ..share(sourceKey: 'code:$timeAttackCode', score: 4);
      },
      expect: () => <Matcher>[
        isA<ChallengeSharing>(),
        isA<ChallengeShareReady>(),
      ],
    );
  });

  group('CodeEntryCubit', () {
    final CodeChallengeUseCases useCases = buildTestCodeChallengeUseCases();

    blocTest<CodeEntryCubit, CodeEntryState>(
      'refuses a malformed code, then forgets it once edited',
      build: () =>
          CodeEntryCubit(buildQuizFromCode: useCases.buildQuizFromCode),
      act: (CodeEntryCubit cubit) async {
        await cubit.submit('O0O0');
        cubit
          ..edit()
          ..edit();
      },
      expect: () => <Matcher>[
        isA<CodeEntryChecking>(),
        isA<CodeEntryRejected>().having(
          (CodeEntryRejected state) => state.error,
          'error',
          ChallengeCodeError.malformed,
        ),
        isA<CodeEntryIdle>(),
      ],
    );
  });

  group('ChallengeLabels', () {
    test('names one table, several tables and all of them', () {
      // Arrange
      final AppLocalizationsFr l10n = AppLocalizationsFr();
      String describe(List<int> tables) =>
          ChallengeLabels.describeTables(tables, l10n, tableCount: 12);
      // Assert
      expect(describe(<int>[7]), 'table de 7');
      expect(describe(<int>[2, 5]), 'tables de 2 et de 5');
      expect(describe(<int>[2, 5, 7]), 'tables de 2, de 5 et de 7');
      expect(
        describe(<int>[for (int table = 1; table <= 12; table++) table]),
        'toutes les tables',
      );
      expect(
        ChallengeLabels.describeTables(
          <int>[7],
          l10n,
          tableCount: 12,
          isLineStart: true,
        ),
        'Table de 7',
      );
      expect(
        ChallengeLabels.describeTables(
          <int>[for (int table = 1; table <= 12; table++) table],
          l10n,
          tableCount: 12,
          isLineStart: true,
        ),
        'Toutes les tables',
      );
      expect(
        ChallengeLabels.describeCodeMode(
          _challenge(mode: ChallengeCodeMode.training, questionCount: 10),
          l10n,
        ),
        'Entraînement libre',
      );
      expect(
        ChallengeLabels.describeCodeError(
          ChallengeCodeError.unknownVersion,
          l10n,
        ),
        contains('version plus récente'),
      );
      expect(
        ChallengeLabels.describeSource('code:$timeAttackCode', l10n),
        'Contre-la-montre',
      );
    });
  });
}
