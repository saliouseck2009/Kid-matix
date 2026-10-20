import 'package:kid_matix/core/entities/player_identity.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/services/pupil_roster_service.dart';
import 'package:kid_matix/core/usecases/usecase.dart';
import 'package:kid_matix/features/classroom/domain/entities/classroom_entity.dart';
import 'package:kid_matix/features/classroom/domain/entities/classroom_roster.dart';
import 'package:kid_matix/features/classroom/domain/entities/pupil_entity.dart';
import 'package:kid_matix/features/classroom/domain/repositories/classroom_repository.dart';

/// Returns a class with its pupils, in the order of their list.
///
/// Takes the identifier of the class; fails with a `NotFoundException`
/// when there is none.
class GetClassroomRosterUseCase
    implements UseCase<DataState<ClassroomRoster>, String> {
  /// Creates the use case.
  const GetClassroomRosterUseCase({
    required this._repository,
    required this._roster,
  });

  final ClassroomRepository _repository;
  final PupilRosterService _roster;

  @override
  Future<DataState<ClassroomRoster>> call({required String params}) async {
    final DataState<ClassroomEntity> classroom = await _repository.getClassroom(
      classroomId: params,
    );
    if (classroom case DataFailed<ClassroomEntity>(:final exception)) {
      return DataFailed<ClassroomRoster>(exception);
    }
    return switch (await _roster.readPupils(classroomId: params)) {
      DataFailed<List<PlayerIdentity>>(:final exception) =>
        DataFailed<ClassroomRoster>(exception),
      DataSuccess<List<PlayerIdentity>>(:final data) =>
        DataSuccess<ClassroomRoster>(
          ClassroomRoster(
            classroom: (classroom as DataSuccess<ClassroomEntity>).data,
            pupils: <PupilEntity>[
              for (final PlayerIdentity player in data)
                PupilEntity(classroomId: params, player: player),
            ],
          ),
        ),
    };
  }
}
