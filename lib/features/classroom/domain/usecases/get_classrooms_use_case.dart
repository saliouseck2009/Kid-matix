import 'package:kid_matix/core/entities/player_identity.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/services/pupil_roster_service.dart';
import 'package:kid_matix/core/usecases/usecase.dart';
import 'package:kid_matix/features/classroom/domain/entities/classroom_entity.dart';
import 'package:kid_matix/features/classroom/domain/entities/classroom_summary.dart';
import 'package:kid_matix/features/classroom/domain/repositories/classroom_repository.dart';

/// Lists the classes of the device, oldest first, with their number of
/// pupils.
class GetClassroomsUseCase
    implements NoParamUseCase<DataState<List<ClassroomSummary>>> {
  /// Creates the use case.
  const GetClassroomsUseCase({
    required this._repository,
    required this._roster,
  });

  final ClassroomRepository _repository;
  final PupilRosterService _roster;

  @override
  Future<DataState<List<ClassroomSummary>>> call() async {
    final DataState<List<ClassroomEntity>> read = await _repository
        .getClassrooms();
    if (read case DataFailed<List<ClassroomEntity>>(:final exception)) {
      return DataFailed<List<ClassroomSummary>>(exception);
    }
    final List<ClassroomSummary> summaries = <ClassroomSummary>[];
    for (final ClassroomEntity classroom
        in (read as DataSuccess<List<ClassroomEntity>>).data) {
      final DataState<List<PlayerIdentity>> pupils = await _roster.readPupils(
        classroomId: classroom.id,
      );
      switch (pupils) {
        case DataFailed<List<PlayerIdentity>>(:final exception):
          return DataFailed<List<ClassroomSummary>>(exception);
        case DataSuccess<List<PlayerIdentity>>(:final data):
          summaries.add(
            ClassroomSummary(classroom: classroom, pupilCount: data.length),
          );
      }
    }
    return DataSuccess<List<ClassroomSummary>>(summaries);
  }
}
