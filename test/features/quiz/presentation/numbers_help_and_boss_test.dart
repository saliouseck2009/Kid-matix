import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/quiz/answer.dart';
import 'package:kid_matix/core/quiz/item_help.dart';
import 'package:kid_matix/core/quiz/prompt_token.dart';
import 'package:kid_matix/core/quiz/question.dart';
import 'package:kid_matix/core/quiz/question_types/question_type_ids.dart';
import 'package:kid_matix/core/widgets/monster_family.dart';
import 'package:kid_matix/core/widgets/monster_painter.dart';
import 'package:kid_matix/features/division/domain/services/division_domain.dart';
import 'package:kid_matix/features/multiplication/domain/services/multiplication_domain.dart';
import 'package:kid_matix/features/number/domain/services/numbers_domain.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/math_picture_view.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/quiz_help_card.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/quiz_labels.dart';
import 'package:kid_matix/features/reward/presentation/widgets/badge_labels.dart';
import 'package:kid_matix/l10n/app_localizations_fr.dart';

import '../../../helpers/pump_localized.dart';
import '../helpers/quiz_fixtures.dart';

Question _questionOf(String itemKey, String unitKey) {
  return Question(
    itemKey: itemKey,
    unitKey: unitKey,
    questionTypeId: QuestionTypeIds.typedAnswer,
    prompt: const <PromptToken>[BlankToken()],
    expectedAnswer: const NumberAnswer(1),
  );
}

void main() {
  final NumbersDomain domain = NumbersDomain();
  final QuizLabels labels = QuizLabels(
    domains: buildDomainRegistry(),
    l10n: AppLocalizationsFr(),
  );

  testWidgets('captions the dots of a division as a sharing in groups', (
    WidgetTester tester,
  ) async {
    // Arrange
    final DivisionDomain inputDivision = DivisionDomain();
    tester.view.physicalSize = const Size(1170, 2532);
    addTearDown(tester.view.reset);
    // Act
    await pumpLocalized(
      tester,
      Scaffold(
        body: QuizHelpCard(
          help: inputDivision.helpOf(inputDivision.findItem('div:56/7')!),
          unitName: 'Diviser par 7',
        ),
      ),
    );
    await tester.pumpAndSettle();
    // Assert
    expect(
      find.text('56 points partagés en 7 groupes\u00a0: 8 dans chaque groupe'),
      findsOneWidget,
    );
    expect(find.text('56 ÷ 7 = 8'), findsOneWidget);
  });
  testWidgets('keeps the rows caption for the dots of a multiplication', (
    WidgetTester tester,
  ) async {
    // Arrange
    final MultiplicationDomain inputDomain = MultiplicationDomain();
    tester.view.physicalSize = const Size(1170, 2532);
    addTearDown(tester.view.reset);
    // Act
    await pumpLocalized(
      tester,
      Scaffold(
        body: QuizHelpCard(
          help: inputDomain.helpOf(inputDomain.findItem('mul:7x8')!),
          unitName: 'Table de 7',
        ),
      ),
    );
    await tester.pumpAndSettle();
    // Assert
    expect(find.textContaining('rangées'), findsOneWidget);
    expect(find.textContaining('partagés'), findsNothing);
  });
  testWidgets('helps with the whole unit and the drawing of the answer', (
    WidgetTester tester,
  ) async {
    // Arrange
    final ItemHelp inputHelp = domain.helpOf(domain.findItem('num:place:34')!);
    tester.view.physicalSize = const Size(1170, 2532);
    addTearDown(tester.view.reset);
    // Act
    await pumpLocalized(
      tester,
      Scaffold(
        body: QuizHelpCard(
          help: inputHelp,
          unitName: labels.describeUnitOf(
            _questionOf('num:place:34', 'num:tensones'),
            NumbersDomain.domainId,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    // Assert
    expect(find.text("Fiche d'aide · Dizaines et unités"), findsOneWidget);
    expect(find.text('30 + 4 = 34'), findsOneWidget);
    expect(find.byType(MathPictureView), findsOneWidget);
    expect(
      find.bySemanticsLabel('3 paquets de dix et 4 bâtonnets'),
      findsOneWidget,
    );
  });
  test('names the boss of a unit and draws it with antennae', () {
    // Assert
    expect(
      labels.describeBoss(
        _questionOf('num:compare:3:8', 'num:compare'),
        NumbersDomain.domainId,
      ),
      'Boss · Comparer',
    );
    expect(
      labels.describeBoss(_questionOf('mul:5x3', 'mul:5'), 'multiplication'),
      'Boss de la table de 5',
    );
    expect(
      MonsterIllustration.familyOf(NumbersDomain.domainId),
      MonsterFamily.antennae,
    );
    expect(
      MonsterIllustration.familyOf('multiplication'),
      MonsterFamily.horned,
    );
  });
  test('names the tamer badge of a unit of the numbers', () {
    // Arrange
    final BadgeLabels inputLabels = BadgeLabels(
      domains: buildDomainRegistry(),
      l10n: AppLocalizationsFr(),
    );
    // Assert
    expect(
      inputLabels.nameOf('tamer:num:compare'),
      'Dompteur de « Comparer »',
    );
    expect(inputLabels.nameOf('tamer:mul:7'), 'Dompteur de la table de 7');
  });
}
