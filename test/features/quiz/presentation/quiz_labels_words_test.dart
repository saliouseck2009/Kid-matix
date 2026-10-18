import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/quiz/prompt_token.dart';
import 'package:kid_matix/core/quiz/question.dart';
import 'package:kid_matix/core/quiz/question_types/question_type_ids.dart';
import 'package:kid_matix/core/services/dart_random_source.dart';
import 'package:kid_matix/features/math_word/domain/entities/math_word.dart';
import 'package:kid_matix/features/math_word/domain/services/math_word_domain.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/quiz_labels.dart';
import 'package:kid_matix/l10n/app_localizations_fr.dart';

import '../../math_word/helpers/math_word_fixtures.dart';
import '../helpers/quiz_fixtures.dart';

/// What the screens and the voice say for the four formats of the words.
void main() {
  final QuizLabels labels = QuizLabels(
    domains: buildDomainRegistry(),
    l10n: AppLocalizationsFr(),
  );
  final MathWordDomain domain = buildMathWordDomain();
  final MathWord word = domain.catalog.wordOf('il_reste')!;

  Question build(String typeId) {
    return domain.buildQuestion(
      item: word,
      questionTypeId: typeId,
      random: DartRandomSource(seed: 3),
    );
  }

  test('labels each format by what the child does', () {
    // Assert
    expect(
      labels.describeQuestion(
        build(QuestionTypeIds.listenAndTouch),
        'math_words',
      ),
      'Écoute et touche',
    );
    expect(
      labels.describeQuestion(
        build(QuestionTypeIds.touchToUnderstand),
        'math_words',
      ),
      'Touche pour comprendre',
    );
    expect(
      labels.describeQuestion(
        build(QuestionTypeIds.whichOperation),
        'math_words',
      ),
      'Quelle opération ?',
    );
  });

  test('speaks the word, the sentence, the statement and the board title', () {
    // Act
    final Question statement = build(QuestionTypeIds.whichOperation);
    // Assert
    expect(
      labels.speakQuestion(
        build(QuestionTypeIds.listenAndTouch),
        'math_words',
      ),
      'il reste',
    );
    expect(
      labels.speakQuestion(
        build(QuestionTypeIds.touchToUnderstand),
        'math_words',
      ),
      word.example,
    );
    expect(
      labels.speakQuestion(statement, 'math_words'),
      (statement.prompt.single as TextToken).text,
    );
    expect(
      labels.speakQuestion(
        build(QuestionTypeIds.wordAndImage),
        'math_words',
      ),
      'Relie chaque mot à son dessin',
    );
  });

  test('tells what to touch under the pictures and the operations', () {
    // Assert
    expect(
      labels.describeHint(build(QuestionTypeIds.listenAndTouch)),
      'Touche le bon dessin',
    );
    expect(
      labels.describeHint(build(QuestionTypeIds.whichOperation)),
      "Touche l'opération",
    );
    expect(labels.describeHint(build(QuestionTypeIds.wordAndImage)), isNull);
  });

  test('names the unit of a word question and its word in the results', () {
    // Assert
    expect(
      labels.describeUnitOf(
        build(QuestionTypeIds.listenAndTouch),
        'math_words',
      ),
      'Enlever',
    );
    expect(labels.describeItem(word.key, 'math_words'), 'il reste');
    expect(
      labels.unitNumberOf(build(QuestionTypeIds.listenAndTouch), 'math_words'),
      2,
    );
  });
}
