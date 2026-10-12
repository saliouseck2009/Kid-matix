import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/services/clock.dart';
import 'package:kid_matix/core/services/id_generator.dart';
import 'package:kid_matix/core/usecases/usecase.dart';
import 'package:kid_matix/features/reward/domain/entities/xp_award_entity.dart';
import 'package:kid_matix/features/reward/domain/repositories/reward_repository.dart';
import 'package:kid_matix/features/reward/domain/usecases/award_xp_params.dart';

/// Gives a player XP earned outside a quiz, now; nothing is saved for 0
/// XP or less.
class AwardXpUseCase implements UseCase<DataState<void>, AwardXpParams> {
  /// Creates the use case.
  const AwardXpUseCase({
    required this._repository,
    required this._ids,
    required this._clock,
  });

  final RewardRepository _repository;
  final IdGenerator _ids;
  final Clock _clock;

  @override
  Future<DataState<void>> call({required AwardXpParams params}) async {
    if (params.xp <= 0) return const DataSuccess<void>(null);
    return _repository.saveXpAward(
      award: XpAwardEntity(
        id: _ids.generateId(),
        profileId: params.profileId,
        sourceKey: params.sourceKey,
        xp: params.xp,
        earnedAt: _clock.now(),
      ),
    );
  }
}
