import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/services/crown_service.dart';
import 'package:kid_matix/core/services/reward_service.dart';
import 'package:kid_matix/core/usecases/usecase.dart';
import 'package:kid_matix/features/mascot/domain/entities/mascot_accessory.dart';
import 'package:kid_matix/features/mascot/domain/entities/mascot_entity.dart';
import 'package:kid_matix/features/mascot/domain/entities/mascot_record.dart';
import 'package:kid_matix/features/mascot/domain/repositories/mascot_repository.dart';
import 'package:kid_matix/features/mascot/domain/services/mascot_rules.dart';

/// Returns the mascot of a player: its name, its stage, the accessories
/// earned and worn; takes the profile id.
class GetMascotUseCase implements UseCase<DataState<MascotEntity>, String> {
  /// Creates the use case.
  const GetMascotUseCase({
    required this._repository,
    required this._rewards,
    required this._crowns,
    this._rules = const MascotRules(),
  });

  final MascotRepository _repository;
  final RewardService _rewards;
  final CrownService _crowns;
  final MascotRules _rules;

  @override
  Future<DataState<MascotEntity>> call({required String params}) async {
    final DataState<MascotRecord> record = await _repository.getMascot(
      profileId: params,
    );
    final DataState<int> level = await _rewards.readLevel(profileId: params);
    final DataState<Set<String>> badges = await _rewards.readBadgeKeys(
      profileId: params,
    );
    final DataState<int> crowns = await _crowns.readCrownCount(
      profileId: params,
    );
    for (final DataState<Object?> read in <DataState<Object?>>[
      record,
      level,
      badges,
      crowns,
    ]) {
      if (read case DataFailed<Object?>(:final exception)) {
        return DataFailed<MascotEntity>(exception);
      }
    }
    return DataSuccess<MascotEntity>(
      _build(
        (record as DataSuccess<MascotRecord>).data,
        (level as DataSuccess<int>).data,
        (badges as DataSuccess<Set<String>>).data,
        (crowns as DataSuccess<int>).data,
      ),
    );
  }

  MascotEntity _build(
    MascotRecord record,
    int level,
    Set<String> badges,
    int crowns,
  ) {
    final int stage = _rules.stageOf(level);
    final Set<MascotAccessory> unlocked = _rules.unlockedBy(
      crowns: crowns,
      badgeKeys: badges,
    );
    return MascotEntity(
      name: record.name,
      stage: stage,
      nextStageLevel: _rules.nextStageLevel(stage),
      unlocked: unlocked,
      worn: _rules.wornAmong(wearing: record.worn, unlocked: unlocked),
      isNewStage: stage > record.celebratedStage,
    );
  }
}
