import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/quiz/item_help.dart';
import 'package:kid_matix/core/widgets/monster_painter.dart';
import 'package:kid_matix/features/number/domain/services/numbers_domain.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/math_picture_view.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/quiz_help_card.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/quiz_labels.dart';
import 'package:kid_matix/features/reward/presentation/widgets/badge_labels.dart';
import 'package:kid_matix/l10n/app_localizations_fr.dart';

import '../../../helpers/pump_localized.dart';
import '../helpers/quiz_fixtures.dart';

void main() {
  final NumbersDomain domain = NumbersDomain();
  final QuizLabels labels = QuizLabels(
    domains: buildDomainRegistry(),
    l10n: AppLocalizationsFr(),
  );

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
          unitName: labels.describeUnit(
            domain.findUnit('num:tensones')!,
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
    expect(labels.describeBoss(5, NumbersDomain.domainId), 'Boss · Comparer');
    expect(labels.describeBoss(5, 'multiplication'), 'Boss de la table de 5');
    expect(
      labels.monsterFamilyOf(NumbersDomain.domainId),
      MonsterPainter.antennaFamily,
    );
    expect(
      labels.monsterFamilyOf('multiplication'),
      MonsterPainter.hornedFamily,
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
