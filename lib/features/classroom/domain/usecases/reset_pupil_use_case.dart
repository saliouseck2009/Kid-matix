import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/services/pupil_roster_service.dart';
import 'package:kid_matix/core/usecases/usecase.dart';

/// Erases the progress of a pupil, from the teacher area only; the class
/// keeps their results.
///
/// Takes the identifier of the pupil.
class ResetPupilUseCase implements UseCase<DataState<void>, String> {
  /// Creates the use case.
  const ResetPupilUseCase({required this._roster});

  final PupilRosterService _roster;

  @override
  Future<DataState<void>> call({required String params}) {
    return _roster.resetPupil(profileId: params);
  }
}
