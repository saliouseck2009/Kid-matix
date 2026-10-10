import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/services/open_units_service.dart';
import 'package:kid_matix/core/usecases/usecase.dart';
import 'package:kid_matix/features/challenge/domain/entities/challenge_source.dart';

/// The time attack of a player: on every table open on their path
/// (owner's choice), so the record grows with them.
class GetTimeAttackUseCase
    implements UseCase<DataState<TimeAttackSource>, String> {
  /// Creates the use case.
  const GetTimeAttackUseCase({required this._openUnits});

  final OpenUnitsService _openUnits;

  /// Returns the time attack of the player [params].
  @override
  Future<DataState<TimeAttackSource>> call({required String params}) async {
    final DataState<List<String>> open = await _openUnits.readOpenUnitKeys(
      profileId: params,
    );
    return switch (open) {
      DataSuccess<List<String>>(:final data) => DataSuccess<TimeAttackSource>(
        TimeAttackSource(unitKeys: data),
      ),
      DataFailed<List<String>>(:final exception) =>
        DataFailed<TimeAttackSource>(exception),
    };
  }
}
