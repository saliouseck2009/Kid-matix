import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/quiz/domain_registry.dart';
import 'package:kid_matix/core/quiz/question_types/question_type_ids.dart';
import 'package:kid_matix/core/quiz/quiz_selection.dart';
import 'package:kid_matix/core/quiz/quiz_spec.dart';
import 'package:kid_matix/features/learning_path/domain/entities/learning_path_entity.dart';
import 'package:kid_matix/features/learning_path/domain/entities/review_key.dart';
import 'package:kid_matix/features/learning_path/domain/entities/stage_kind.dart';
import 'package:kid_matix/features/learning_path/domain/entities/stage_progress_entity.dart';
import 'package:kid_matix/features/learning_path/domain/entities/stage_source.dart';
import 'package:kid_matix/features/learning_path/domain/services/learning_path_builder.dart';
import 'package:kid_matix/features/learning_path/domain/services/stage_quiz_specs.dart';
import 'package:kid_matix/features/learning_path/domain/services/unit_domain_resolver.dart';
import 'package:kid_matix/features/addition/domain/services/addition_domain.dart';
import 'package:kid_matix/features/division/domain/services/division_domain.dart';
import 'package:kid_matix/features/math_word/domain/services/math_word_domain.dart';
import 'package:kid_matix/features/multiplication/domain/services/multiplication_domain.dart';
import 'package:kid_matix/features/number/domain/services/numbers_domain.dart';

import '../../math_word/helpers/math_word_fixtures.dart';

/// The learning path of the math words: one unit per family, in the
/// domain selector after the multiplication and the numbers.
void main() {
  final MathWordDomain words = buildMathWordDomain();
  final DomainRegistry domains = DomainRegistry()
    ..register(MultiplicationDomain())
    ..register(NumbersDomain())
    ..register(AdditionDomain())
    ..register(DivisionDomain())
    ..register(words);
  const StageQuizSpecs specs = StageQuizSpecs();

  test('is offered after the other domains', () {
    // Assert
    expect(
      domains.domains.map((domain) => domain.id).toList(),
      <String>[
        'multiplication',
        'numbers',
        'addition',
        'division',
        'math_words',
      ],
    );
  });

  test('finds the domain of a family and of a review', () {
    // Arrange
    const UnitDomainResolver resolver = UnitDomainResolver();
    // Assert
    expect(
      resolver.domainOf(domains: domains, unitKey: 'word:share')?.id,
      'math_words',
    );
    expect(
      resolver.domainOf(domains: domains, unitKey: 'review:math_words:1')?.id,
      'math_words',
    );
    expect(
      ReviewKey.tryParse('review:math_words:2'),
      const ReviewKey(domainId: 'math_words', number: 2),
    );
  });

  test('has one unit per family and a review after every group of 3', () {
    // Act
    final LearningPathEntity actual = const LearningPathBuilder().build(
      domainId: 'math_words',
      units: words.path,
      progress: <StageProgressEntity>[
        StageProgressEntity(
          profileId: 'p1',
          domainId: 'math_words',
          unitKey: 'word:add',
          stage: StageKind.writing,
          bestStars: 2,
          bestScore: 10,
          completedAt: DateTime(2026, 10, 18),
        ),
      ],
      isEverythingUnlocked: false,
    );
    // Assert
    expect(actual.tables, hasLength(6));
    expect(
      actual.nodes.whereType<ReviewPathNode>().map(
        (ReviewPathNode review) => review.unitKey,
      ),
      <String>['review:math_words:1', 'review:math_words:2'],
    );
    expect(actual.tables[0].status, TableStatus.done);
    expect(actual.tables[1].status, TableStatus.current);
    expect(actual.tables[2].status, TableStatus.locked);
  });

  test('discovers a family with its words in order', () {
    // Act
    final QuizSpec actual = specs.specOf(
      domain: words,
      source: const StageSource(
        unitKey: 'word:remove',
        stage: StageKind.discovery,
      ),
    )!;
    // Assert
    expect(actual.domainId, 'math_words');
    expect(actual.selection, QuizSelection.inOrder);
    expect(actual.itemKeys.first, 'word:enlever');
    expect(actual.itemKeys, hasLength(7));
    expect(
      actual.questionTypeIds,
      containsAll(<String>[
        QuestionTypeIds.touchToUnderstand,
        QuestionTypeIds.listenAndTouch,
      ]),
    );
    expect(actual.sourceKey, 'path:word:remove:discovery');
  });

  test('keeps the sentence to touch for Discovery, never in later stages', () {
    for (final StageSource source in <StageSource>[
      const StageSource(unitKey: 'word:remove', stage: StageKind.training),
      const StageSource(unitKey: 'word:remove', stage: StageKind.writing),
      const StageSource(
        unitKey: 'review:math_words:1',
        stage: StageKind.review,
      ),
    ]) {
      // Act
      final QuizSpec actual = specs.specOf(domain: words, source: source)!;
      // Assert
      expect(
        actual.questionTypeIds,
        isNot(contains(QuestionTypeIds.touchToUnderstand)),
        reason: source.toKey(),
      );
    }
  });

  test('keeps the sentence and the statement out of the timed stages', () {
    for (final StageKind stage in <StageKind>[
      StageKind.speed,
      StageKind.boss,
    ]) {
      // Act
      final QuizSpec actual = specs.specOf(
        domain: words,
        source: StageSource(unitKey: 'word:add', stage: stage),
      )!;
      // Assert
      expect(
        actual.questionTypeIds,
        containsAll(<String>[
          QuestionTypeIds.listenAndTouch,
          QuestionTypeIds.wordAndImage,
        ]),
      );
      expect(
        actual.questionTypeIds,
        isNot(contains(QuestionTypeIds.touchToUnderstand)),
      );
      expect(
        actual.questionTypeIds,
        isNot(contains(QuestionTypeIds.whichOperation)),
      );
    }
  });

  test('asks the operation of the statements while writing', () {
    // Act
    final QuizSpec actual = specs.specOf(
      domain: words,
      source: const StageSource(unitKey: 'word:ask', stage: StageKind.writing),
    )!;
    // Assert
    expect(actual.questionTypeIds, contains(QuestionTypeIds.whichOperation));
  });

  test('reviews the families of its own domain only', () {
    // Act
    final QuizSpec actual = specs.specOf(
      domain: words,
      source: const StageSource(
        unitKey: 'review:math_words:1',
        stage: StageKind.review,
      ),
    )!;
    // Assert
    expect(actual.itemKeys, hasLength(21));
    expect(actual.itemKeys.first, 'word:ajouter');
    expect(actual.itemKeys.last, 'word:egal');
  });

  test('fights a boss per family', () {
    // Act
    final QuizSpec actual = specs.specOf(
      domain: words,
      source: const StageSource(unitKey: 'word:group', stage: StageKind.boss),
    )!;
    // Assert
    expect(actual.isBossFight, isTrue);
    expect(actual.itemKeys, hasLength(6));
  });
}
