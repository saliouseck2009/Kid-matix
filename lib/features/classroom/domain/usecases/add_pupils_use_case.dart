import 'package:kid_matix/core/entities/player_identity.dart';
import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/services/pupil_roster_service.dart';
import 'package:kid_matix/core/usecases/usecase.dart';
import 'package:kid_matix/features/classroom/domain/services/pupil_enrollment.dart';
import 'package:kid_matix/features/classroom/domain/usecases/add_pupils_params.dart';

/// Adds pupils to an existing class; resolves to how many were added.
///
/// Fails with a `ValidationException` when a nickname cannot be used, a
/// `LimitReachedException` when the class would go beyond its maximum,
/// and a `ConflictException` when a nickname is already in the class.
class AddPupilsUseCase implements UseCase<DataState<int>, AddPupilsParams> {
  /// Creates the use case.
  const AddPupilsUseCase({
    required this._roster,
    required this._enrollment,
  });

  final PupilRosterService _roster;
  final PupilEnrollment _enrollment;

  @override
  Future<DataState<int>> call({required AddPupilsParams params}) async {
    final DataState<List<PlayerIdentity>> existing = await _roster.readPupils(
      classroomId: params.classroomId,
    );
    if (existing case DataFailed<List<PlayerIdentity>>(:final exception)) {
      return DataFailed<int>(exception);
    }
    final AppException? problem = _enrollment.findProblem(
      nicknames: params.nicknames,
      existingCount:
          (existing as DataSuccess<List<PlayerIdentity>>).data.length,
    );
    if (problem != null) return DataFailed<int>(problem);
    return _enrollment.enroll(
      classroomId: params.classroomId,
      nicknames: params.nicknames,
    );
  }
}
