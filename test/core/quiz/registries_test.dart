import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/quiz/answer.dart';
import 'package:kid_matix/core/quiz/answer_nature.dart';
import 'package:kid_matix/core/quiz/domain_registry.dart';
import 'package:kid_matix/core/quiz/item_help.dart';
import 'package:kid_matix/core/quiz/learning_domain.dart';
import 'package:kid_matix/core/quiz/learning_item.dart';
import 'package:kid_matix/core/quiz/learning_unit.dart';
import 'package:kid_matix/core/quiz/prompt_token.dart';
import 'package:kid_matix/core/quiz/question.dart';
import 'package:kid_matix/core/quiz/question_type.dart';
import 'package:kid_matix/core/quiz/question_type_registry.dart';
import 'package:kid_matix/core/services/random_source.dart';

final class _FakeDomain implements LearningDomain {
  const _FakeDomain(this.id);

  @override
  final String id;

  @override
  List<LearningUnit> get units => const <LearningUnit>[];

  @override
  List<LearningUnit> get path => const <LearningUnit>[];

  @override
  List<String> get questionTypeIds => const <String>[];

  @override
  LearningItem? findItem(String key) => null;

  @override
  LearningUnit? findUnit(String key) => null;

  @override
  int drawWeightOf(LearningItem item) => 1;

  @override
  LearningItem? mirrorOf(LearningItem item) => null;

  @override
  ItemHelp helpOf(LearningItem item) {
    return ItemHelp(unitFacts: const <List<PromptToken>>[], itemIndex: 0);
  }

  @override
  List<PromptToken> describeItem(LearningItem item) => const <PromptToken>[];

  @override
  Question buildQuestion({
    required LearningItem item,
    required String questionTypeId,
    required RandomSource random,
  }) {
    throw UnimplementedError();
  }
}

final class _FakeQuestionType implements QuestionType {
  const _FakeQuestionType(this.id);

  @override
  final String id;

  @override
  AnswerNature get answerNature => AnswerNature.recognized;

  @override
  bool isCorrect({required Question question, required Answer answer}) {
    return answer == question.expectedAnswer;
  }
}

void main() {
  group('DomainRegistry', () {
    test('finds a registered domain by its identifier', () {
      // Arrange
      final DomainRegistry registry = DomainRegistry();
      const _FakeDomain expectedDomain = _FakeDomain('multiplication');
      // Act
      registry.register(expectedDomain);
      // Assert
      expect(registry.find('multiplication'), expectedDomain);
      expect(registry.find('division'), isNull);
      expect(registry.domains, <LearningDomain>[expectedDomain]);
    });
    test('refuses the same identifier twice', () {
      // Arrange
      final DomainRegistry registry = DomainRegistry()
        ..register(const _FakeDomain('multiplication'));
      // Act
      void actualRegister() =>
          registry.register(const _FakeDomain('multiplication'));
      // Assert
      expect(actualRegister, throwsStateError);
    });
  });

  group('QuestionTypeRegistry', () {
    test('finds a registered type by its identifier', () {
      // Arrange
      final QuestionTypeRegistry registry = QuestionTypeRegistry();
      const _FakeQuestionType expectedType = _FakeQuestionType('typed');
      // Act
      registry.register(expectedType);
      // Assert
      expect(registry.find('typed'), expectedType);
      expect(registry.find('missing'), isNull);
      expect(registry.questionTypes, <QuestionType>[expectedType]);
    });
    test('refuses the same identifier twice', () {
      // Arrange
      final QuestionTypeRegistry registry = QuestionTypeRegistry()
        ..register(const _FakeQuestionType('typed'));
      // Act
      void actualRegister() =>
          registry.register(const _FakeQuestionType('typed'));
      // Assert
      expect(actualRegister, throwsStateError);
    });
  });
}
