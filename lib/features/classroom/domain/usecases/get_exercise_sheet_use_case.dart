import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/quiz/domain_registry.dart';
import 'package:kid_matix/core/quiz/learning_domain.dart';
import 'package:kid_matix/core/quiz/learning_item.dart';
import 'package:kid_matix/core/quiz/learning_unit.dart';
import 'package:kid_matix/core/quiz/question.dart';
import 'package:kid_matix/core/quiz/question_types/question_type_ids.dart';
import 'package:kid_matix/core/services/random_source.dart';
import 'package:kid_matix/core/usecases/usecase.dart';
import 'package:meta/meta.dart';

/// A printable sheet of exercises of one unit, with its answers.
@immutable
final class ExerciseSheet {
  /// Creates the sheet of [unitKey].
  ExerciseSheet({
    required this.domainId,
    required this.unitKey,
    required List<Question> questions,
  }) : questions = List<Question>.unmodifiable(questions);

  /// Learning domain of the unit.
  final String domainId;

  /// Unit worked on.
  final String unitKey;

  /// The exercises, in the order printed; each has its expected answer.
  final List<Question> questions;
}

/// Draws a printable sheet of exercises of a unit (F31-07): each item of
/// the unit once, in a random order, at most [maxExercises], as the
/// keypad asks them (« 7 × 8 = ____ »); the items drawn with a picture are
/// left out, they cannot be written on paper.
///
/// Fails with a `ValidationException` when the unit has no exercise that
/// can be printed.
class GetExerciseSheetUseCase
    implements
        UseCase<DataState<ExerciseSheet>, ({String domainId, String unitKey})> {
  /// Creates the use case.
  const GetExerciseSheetUseCase({
    required this._domains,
    required this._random,
  });

  /// Most exercises on a sheet: two columns of ten on an A4 page.
  static const int maxExercises = 20;

  final DomainRegistry _domains;
  final RandomSource _random;

  @override
  Future<DataState<ExerciseSheet>> call({
    required ({String domainId, String unitKey}) params,
  }) async {
    final LearningDomain? domain = _domains.find(params.domainId);
    final LearningUnit? unit = domain?.findUnit(params.unitKey);
    final List<Question> questions = domain == null || unit == null
        ? const <Question>[]
        : _questionsOf(domain, unit);
    if (questions.isEmpty) {
      return const DataFailed<ExerciseSheet>(
        ValidationException(message: 'Nothing to print in this unit.'),
      );
    }
    return DataSuccess<ExerciseSheet>(
      ExerciseSheet(
        domainId: params.domainId,
        unitKey: params.unitKey,
        questions: questions,
      ),
    );
  }

  List<Question> _questionsOf(LearningDomain domain, LearningUnit unit) {
    final List<Question> questions = <Question>[];
    for (final LearningItem item in _random.shuffled(unit.items)) {
      if (questions.length == maxExercises) break;
      if (!domain
          .questionTypeIdsOf(item)
          .contains(QuestionTypeIds.typedAnswer)) {
        continue;
      }
      final Question question = domain.buildQuestion(
        item: item,
        questionTypeId: QuestionTypeIds.typedAnswer,
        random: _random,
      );
      if (question.picture == null) questions.add(question);
    }
    return questions;
  }
}
