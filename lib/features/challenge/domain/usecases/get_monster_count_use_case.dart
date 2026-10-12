import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/quiz/learning_domain_ids.dart';
import 'package:kid_matix/core/services/mastery_service.dart';
import 'package:kid_matix/core/usecases/usecase.dart';

/// How many monsters a player has to tame, for the card of the monster
/// hunt.
class GetMonsterCountUseCase implements UseCase<DataState<int>, String> {
  /// Creates the use case.
  const GetMonsterCountUseCase({required this._mastery});

  /// Domain of the facts hunted.
  static const String domainId = LearningDomainIds.multiplication;

  final MasteryService _mastery;

  /// Returns the monster count of the player [params].
  @override
  Future<DataState<int>> call({required String params}) {
    return _mastery.readMonsterCount(profileId: params, domainId: domainId);
  }
}
