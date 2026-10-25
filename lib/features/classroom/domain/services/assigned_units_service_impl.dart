import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/services/assigned_units_service.dart';
import 'package:kid_matix/core/services/pupil_roster_service.dart';
import 'package:kid_matix/features/classroom/domain/entities/assignment_entity.dart';
import 'package:kid_matix/features/classroom/domain/repositories/assignment_repository.dart';

/// [AssignedUnitsService] over the assignments of the classes: every
/// unit ever given to the player's class stays open, past homework
/// included.
final class AssignedUnitsServiceImpl implements AssignedUnitsService {
  /// Creates the service.
  const AssignedUnitsServiceImpl({
    required this._roster,
    required this._assignments,
  });

  final PupilRosterService _roster;
  final AssignmentRepository _assignments;

  @override
  Future<DataState<Set<String>>> readAssignedUnitKeys({
    required String profileId,
  }) async {
    final DataState<String?> classroom = await _roster.readClassroomOf(
      profileId: profileId,
    );
    switch (classroom) {
      case DataFailed<String?>(:final exception):
        return DataFailed<Set<String>>(exception);
      case DataSuccess<String?>(data: null):
        return const DataSuccess<Set<String>>(<String>{});
      case DataSuccess<String?>(:final String data):
        return _unitsOf(data);
    }
  }

  Future<DataState<Set<String>>> _unitsOf(String classroomId) async {
    return switch (await _assignments.getAssignments(
      classroomId: classroomId,
    )) {
      DataFailed<List<AssignmentEntity>>(:final exception) =>
        DataFailed<Set<String>>(exception),
      DataSuccess<List<AssignmentEntity>>(:final data) =>
        DataSuccess<Set<String>>(<String>{
          for (final AssignmentEntity assignment in data) assignment.unitKey,
        }),
    };
  }
}
