import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/quiz/question.dart';
import 'package:kid_matix/core/quiz/question_types/question_type_ids.dart';
import 'package:kid_matix/core/services/dart_random_source.dart';
import 'package:kid_matix/features/problem/domain/services/problem_domain.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/quiz_labels.dart';
import 'package:kid_matix/l10n/app_localizations_en.dart';
import 'package:kid_matix/l10n/app_localizations_fr.dart';

import '../../problem/helpers/problem_fixtures.dart';
import '../helpers/quiz_fixtures.dart';

/// What the screens and the voice say for the formats of the word problems.
void main() {
  final QuizLabels labels = QuizLabels(
    domains: buildDomainRegistry(),
    l10n: AppLocalizationsFr(),
  );
  final ProblemDomain domain = buildProblemDomain();

  Question build(String typeId) {
    return domain.buildQuestion(
      item: domain.findItem('problem:mangues_donnees')!,
      questionTypeId: typeId,
      random: DartRandomSource(seed: 3),
    );
  }

  test('labels each format by what the child does', () {
    // Assert
    expect(
      labels.describeQuestion(build(QuestionTypeIds.solveProblem), 'problems'),
      'Résous le problème',
    );
    expect(
      labels.describeQuestion(build(QuestionTypeIds.barModel), 'problems'),
      'Fais le schéma',
    );
    expect(
      labels.describeQuestion(
        build(QuestionTypeIds.problemOperation),
        'problems',
      ),
      'Quelle opération\u00a0?',
    );
    expect(
      QuizLabels(
        domains: buildDomainRegistry(),
        l10n: AppLocalizationsEn(),
      ).describeQuestion(
        build(QuestionTypeIds.barModel),
        'problems',
      ),
      'Draw the model',
    );
  });

  test('reads the statement aloud, in French whatever the interface', () {
    // Act
    final Question asked = build(QuestionTypeIds.problemOperation);
    // Assert
    expect(
      labels.speakQuestion(asked, 'problems'),
      asked.prompt.single.toString(),
    );
    expect(labels.contentLanguageOf('problems'), 'fr');
  });

  test('names the unit of a problem and its boss', () {
    // Act
    final Question asked = build(QuestionTypeIds.barModel);
    // Assert
    expect(labels.describeUnitOf(asked, 'problems'), 'Enlever · avec images');
    expect(
      labels.describeBoss(asked, 'problems'),
      contains('Enlever · avec images'),
    );
    expect(labels.unitNumberOf(asked, 'problems'), 2);
  });

  test('describes a missed problem by its own calculation', () {
    // Assert
    expect(
      labels.describeItem('problem:mangues_donnees', 'problems'),
      '12 − 5 = 7',
    );
    expect(labels.helpOf('problem:mangues_donnees', 'problems'), isNotNull);
  });
}
