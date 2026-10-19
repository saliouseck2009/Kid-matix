import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/quiz/answer_nature.dart';
import 'package:kid_matix/core/quiz/learning_item.dart';
import 'package:kid_matix/core/quiz/question_types/question_type_ids.dart';
import 'package:kid_matix/core/quiz/quiz_item_plan.dart';
import 'package:kid_matix/features/mastery/domain/entities/item_progress_entity.dart';
import 'package:kid_matix/features/mastery/domain/services/question_format_picker.dart';
import 'package:kid_matix/features/multiplication/domain/services/multiplication_domain.dart';

const QuestionFormatPicker _formats = QuestionFormatPicker();
const Map<String, AnswerNature> _allTypes = <String, AnswerNature>{
  QuestionTypeIds.multipleChoice: AnswerNature.recognized,
  QuestionTypeIds.typedAnswer: AnswerNature.produced,
  QuestionTypeIds.missingNumber: AnswerNature.produced,
  QuestionTypeIds.trueFalse: AnswerNature.recognized,
};
const List<String> _picked = <String>[
  QuestionTypeIds.multipleChoice,
  QuestionTypeIds.trueFalse,
];
const List<String> _written = <String>[
  QuestionTypeIds.typedAnswer,
  QuestionTypeIds.missingNumber,
];

/// The multiplication domain does not ask objects to count.
const Map<String, AnswerNature> _withUnfitType = <String, AnswerNature>{
  ..._allTypes,
  QuestionTypeIds.countObjects: AnswerNature.recognized,
};

ItemProgressEntity _progress(String itemKey, int box) {
  return ItemProgressEntity.notSeen(
    profileId: 'p1',
    domainId: 'multiplication',
    itemKey: itemKey,
  ).copyWith(box: box);
}

void main() {
  final MultiplicationDomain domain = MultiplicationDomain();
  final LearningItem item = domain.findUnit('mul:7')!.items.first;

  group('QuestionFormatPicker.questionTypesFor', () {
    test('picks answers up to box 2 and writes them from box 3', () {
      // Act
      final List<List<String>> actualTypes = <int>[0, 1, 2, 3, 5]
          .map(
            (int box) => _formats.questionTypesFor(
              box: box,
              questionTypeNatures: _allTypes,
            ),
          )
          .toList();
      // Assert
      expect(actualTypes, <List<String>>[
        _picked,
        _picked,
        _picked,
        _written,
        _written,
      ]);
    });
    test('falls back to every allowed type when none fits the box', () {
      // Arrange
      const Map<String, AnswerNature> inputTypes = <String, AnswerNature>{
        QuestionTypeIds.multipleChoice: AnswerNature.recognized,
      };
      // Act
      final List<String> actualTypes = _formats.questionTypesFor(
        box: 4,
        questionTypeNatures: inputTypes,
      );
      // Assert
      expect(actualTypes, <String>[QuestionTypeIds.multipleChoice]);
    });
  });

  group('QuestionFormatPicker.fitFor', () {
    test('keeps only the types the domain asks for the item', () {
      // Act
      final Map<String, AnswerNature> actualFit = _formats.fitFor(
        domain,
        item,
        _withUnfitType,
      );
      // Assert
      expect(actualFit, _allTypes);
    });
  });

  group('QuestionFormatPicker.planFor', () {
    test('gives the item the formats of its box that fit it', () {
      // Act
      final QuizItemPlan actualPlan = _formats.planFor(
        domain: domain,
        item: item,
        box: 1,
        questionTypeNatures: _withUnfitType,
      );
      // Assert
      expect(actualPlan.itemKey, item.key);
      expect(actualPlan.questionTypeIds, _picked);
    });
  });

  group('QuestionFormatPicker.planItem', () {
    test('gives the item of the progress the formats of its box', () {
      // Act
      final QuizItemPlan actualPlan = _formats.planItem(
        domain: domain,
        progress: _progress(item.key, 4),
        questionTypeNatures: _withUnfitType,
      );
      // Assert
      expect(actualPlan.itemKey, item.key);
      expect(actualPlan.questionTypeIds, _written);
    });
    test('clamps a box above the last one', () {
      // Act
      final QuizItemPlan actualPlan = _formats.planItem(
        domain: domain,
        progress: _progress(item.key, 99),
        questionTypeNatures: _allTypes,
      );
      // Assert
      expect(actualPlan.questionTypeIds, _written);
    });
    test('keeps every allowed type for an item the domain lacks', () {
      // Act
      final QuizItemPlan actualPlan = _formats.planItem(
        domain: domain,
        progress: _progress('unknown', 0),
        questionTypeNatures: _withUnfitType,
      );
      // Assert
      expect(actualPlan.itemKey, 'unknown');
      expect(actualPlan.questionTypeIds, <String>[
        ..._picked,
        QuestionTypeIds.countObjects,
      ]);
    });
  });
}
