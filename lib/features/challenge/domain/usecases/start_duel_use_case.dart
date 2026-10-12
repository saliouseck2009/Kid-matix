import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/quiz/domain_registry.dart';
import 'package:kid_matix/core/quiz/learning_domain.dart';
import 'package:kid_matix/core/quiz/learning_unit.dart';
import 'package:kid_matix/core/services/open_units_service.dart';
import 'package:kid_matix/core/services/random_source.dart';
import 'package:kid_matix/core/usecases/usecase.dart';
import 'package:kid_matix/features/challenge/domain/entities/duel_game_entity.dart';
import 'package:kid_matix/features/challenge/domain/entities/duel_lineup.dart';
import 'package:kid_matix/features/challenge/domain/entities/duel_player.dart';
import 'package:kid_matix/features/challenge/domain/services/duel_referee.dart';
import 'package:kid_matix/features/challenge/domain/services/duel_rules.dart';

/// Opens a duel for a lineup: each player of the phone plays the tables
/// open on their path, so a young child can beat an older one; a guest
/// plays the 12 tables (owner's choice).
class StartDuelUseCase
    implements UseCase<DataState<DuelGameEntity>, DuelLineup> {
  /// Creates the use case.
  const StartDuelUseCase({
    required this._openUnits,
    required this._domains,
    required this._random,
  });

  final OpenUnitsService _openUnits;
  final DomainRegistry _domains;
  final RandomSource _random;

  @override
  Future<DataState<DuelGameEntity>> call({required DuelLineup params}) async {
    final LearningDomain? domain = _domains.find(DuelRules.domainId);
    if (domain == null) {
      return const DataFailed<DuelGameEntity>(
        NotFoundException(message: 'No duel domain'),
      );
    }
    final DataState<List<String>> top = await _unitKeysOf(params.top, domain);
    final DataState<List<String>> bottom = await _unitKeysOf(
      params.bottom,
      domain,
    );
    if (top case DataFailed<List<String>>(:final exception)) {
      return DataFailed<DuelGameEntity>(exception);
    }
    if (bottom case DataFailed<List<String>>(:final exception)) {
      return DataFailed<DuelGameEntity>(exception);
    }
    return DataSuccess<DuelGameEntity>(
      DuelReferee(domain: domain, random: _random).start(
        top: params.top,
        bottom: params.bottom,
        topUnitKeys: (top as DataSuccess<List<String>>).data,
        bottomUnitKeys: (bottom as DataSuccess<List<String>>).data,
      ),
    );
  }

  Future<DataState<List<String>>> _unitKeysOf(
    DuelPlayer player,
    LearningDomain domain,
  ) async {
    final List<String> allKeys = domain.units
        .map((LearningUnit unit) => unit.key)
        .toList();
    final String? profileId = player.profileId;
    if (profileId == null) return DataSuccess<List<String>>(allKeys);
    final DataState<List<String>> open = await _openUnits.readOpenUnitKeys(
      profileId: profileId,
    );
    return switch (open) {
      DataSuccess<List<String>>(:final data) when data.isEmpty =>
        DataSuccess<List<String>>(allKeys.take(1).toList()),
      _ => open,
    };
  }
}
