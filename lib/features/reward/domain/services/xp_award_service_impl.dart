import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/services/xp_award_service.dart';
import 'package:kid_matix/features/reward/domain/usecases/award_xp_params.dart';
import 'package:kid_matix/features/reward/domain/usecases/award_xp_use_case.dart';

/// [XpAwardService] over the use case of the reward feature.
final class XpAwardServiceImpl implements XpAwardService {
  /// Creates the service.
  const XpAwardServiceImpl({required this._awardXp});

  final AwardXpUseCase _awardXp;

  @override
  Future<DataState<void>> awardXp({
    required String profileId,
    required int xp,
    required String sourceKey,
  }) {
    return _awardXp(
      params: AwardXpParams(
        profileId: profileId,
        xp: xp,
        sourceKey: sourceKey,
      ),
    );
  }
}
