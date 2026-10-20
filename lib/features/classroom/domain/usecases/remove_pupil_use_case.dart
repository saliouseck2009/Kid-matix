import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/services/pupil_roster_service.dart';
import 'package:kid_matix/core/usecases/usecase.dart';

/// Deletes a pupil and everything they own, their class results
/// included, from the teacher area only.
///
/// Takes the identifier of the pupil.
class RemovePupilUseCase implements UseCase<DataState<void>, String> {
  /// Creates the use case.
  const RemovePupilUseCase({required this._roster});

  final PupilRosterService _roster;

  @override
  Future<DataState<void>> call({required String params}) {
    return _roster.removePupil(profileId: params);
  }
}
