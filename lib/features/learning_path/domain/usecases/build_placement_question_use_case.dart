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

/// The unit a question of the placement test is drawn from.
@immutable
final class PlacementProbeParams {
  /// Creates the parameters.
  const PlacementProbeParams({required this.domainId, required this.unitKey});

  /// Learning domain that teaches the unit.
  final String domainId;

  /// Key of the unit, such as `addsub:add5`.
  final String unitKey;
}

/// Builds one question of the placement test: a fact drawn in the middle
/// of the unit (7 × 3 to 7 × 8 for the table of 7), answered on the
/// keypad.
///
/// Fails with a `ValidationException` when the domain or the unit is
/// unknown, or the item cannot be answered with typed digits.
class BuildPlacementQuestionUseCase
    implements UseCase<DataState<Question>, PlacementProbeParams> {
  /// Creates the use case.
  const BuildPlacementQuestionUseCase({
    required this._domains,
    required this._random,
  });

  /// Items left out at each end of a unit: the facts × 1, × 2, × 9 and
  /// × 10 are too easy to tell whether a table is known.
  static const int skippedEdgeItems = 2;

  final DomainRegistry _domains;
  final RandomSource _random;

  /// Builds the question of the unit [params].
  @override
  Future<DataState<Question>> call({
    required PlacementProbeParams params,
  }) async {
    final LearningDomain? domain = _domains.find(params.domainId);
    final LearningUnit? unit = domain?.findUnit(params.unitKey);
    if (domain == null || unit == null) {
      return const DataFailed<Question>(
        ValidationException(message: 'No placement question for this unit.'),
      );
    }
    final LearningItem item = _drawMiddleItem(unit);
    if (!domain.questionTypeIdsOf(item).contains(QuestionTypeIds.typedAnswer)) {
      return const DataFailed<Question>(
        ValidationException(message: 'The item cannot be typed.'),
      );
    }
    return DataSuccess<Question>(
      domain.buildQuestion(
        item: item,
        questionTypeId: QuestionTypeIds.typedAnswer,
        random: _random,
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
