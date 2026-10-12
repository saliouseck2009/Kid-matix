import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/quiz/domain_registry.dart';
import 'package:kid_matix/core/quiz/learning_domain.dart';
import 'package:kid_matix/core/quiz/learning_item.dart';
import 'package:kid_matix/core/quiz/learning_unit.dart';
import 'package:kid_matix/core/quiz/question_types/question_type_ids.dart';
import 'package:kid_matix/core/services/random_source.dart';
import 'package:kid_matix/core/usecases/usecase.dart';
import 'package:kid_matix/features/learning_path/domain/entities/placement_test_entity.dart';

/// Builds the placement test of a domain: one question per unit, in the
/// natural order of the units, on a fact drawn in the middle of the unit
/// (7 × 3 to 7 × 8 for the table of 7), answered on the keypad.
///
/// Fails with a `ValidationException` when the domain is unknown or
/// cannot ask typed answers.
class RunPlacementTestUseCase
    implements UseCase<DataState<PlacementTestEntity>, String> {
  /// Creates the use case.
  const RunPlacementTestUseCase({
    required this._domains,
    required this._random,
  });

  /// Items left out at each end of a unit: the facts × 1, × 2, × 9 and
  /// × 10 are too easy to tell whether a table is known.
  static const int skippedEdgeItems = 2;

  final DomainRegistry _domains;
  final RandomSource _random;

  /// Builds the test of the domain [params].
  @override
  Future<DataState<PlacementTestEntity>> call({required String params}) async {
    final LearningDomain? domain = _domains.find(params);
    if (domain == null ||
        !domain.questionTypeIds.contains(QuestionTypeIds.typedAnswer)) {
      return const DataFailed<PlacementTestEntity>(
        ValidationException(message: 'No placement test for this domain.'),
      );
    }
    return DataSuccess<PlacementTestEntity>(
      PlacementTestEntity(
        domainId: domain.id,
        questions: <PlacementQuestionEntity>[
          for (final LearningUnit unit in domain.units)
            PlacementQuestionEntity(
              unitNumber: unit.number,
              question: domain.buildQuestion(
                item: _drawMiddleItem(unit),
                questionTypeId: QuestionTypeIds.typedAnswer,
                random: _random,
              ),
            ),
        ],
      ),
    );
  }

  LearningItem _drawMiddleItem(LearningUnit unit) {
    final List<LearningItem> items = unit.items;
    final List<LearningItem> middle = items.length > 2 * skippedEdgeItems
        ? items.sublist(skippedEdgeItems, items.length - skippedEdgeItems)
        : items;
    return middle[_random.nextInt(middle.length)];
  }
}
