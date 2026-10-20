import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/services/clock.dart';
import 'package:kid_matix/core/services/id_generator.dart';
import 'package:kid_matix/core/usecases/usecase.dart';
import 'package:kid_matix/features/classroom/domain/entities/classroom_entity.dart';
import 'package:kid_matix/features/classroom/domain/entities/classroom_rules.dart';
import 'package:kid_matix/features/classroom/domain/repositories/classroom_repository.dart';
import 'package:kid_matix/features/classroom/domain/services/pupil_enrollment.dart';
import 'package:kid_matix/features/classroom/domain/usecases/create_classroom_params.dart';

/// Creates a class and all its pupils in one go.
///
/// Fails with a `ValidationException` when the name is empty or too long
/// or a nickname cannot be used, and with a `LimitReachedException` beyond
/// [ClassroomRules.maxPupils] pupils. Nothing is written then, nor when
/// the pupils cannot be written.
class CreateClassroomUseCase
    implements UseCase<DataState<ClassroomEntity>, CreateClassroomParams> {
  /// Creates the use case.
  const CreateClassroomUseCase({
    required this._repository,
    required this._enrollment,
    required this._ids,
    required this._clock,
  });

  final ClassroomRepository _repository;
  final PupilEnrollment _enrollment;
  final IdGenerator _ids;
  final Clock _clock;

  @override
  Future<DataState<ClassroomEntity>> call({
    required CreateClassroomParams params,
  }) async {
    final String? name = ClassroomRules.cleanName(params.name);
    final AppException? problem = name == null
        ? const ValidationException(message: 'Invalid class name.')
        : _enrollment.findProblem(nicknames: params.nicknames);
    if (problem != null) return DataFailed<ClassroomEntity>(problem);
    final DateTime now = _clock.now();
    final ClassroomEntity classroom = ClassroomEntity(
      id: _ids.generateId(),
      name: name!,
      weeklyGoal: ClassroomRules.defaultWeeklyGoal,
      createdAt: now,
      updatedAt: now,
    );
    final DataState<void> created = await _repository.createClassroom(
      classroom: classroom,
    );
    if (created case DataFailed<void>(:final exception)) {
      return DataFailed<ClassroomEntity>(exception);
    }
    final DataState<int> enrolled = await _enrollment.enroll(
      classroomId: classroom.id,
      nicknames: params.nicknames,
    );
    if (enrolled case DataFailed<int>(:final exception)) {
      // The pupils are written all or nothing: none was, so the class
      // goes too, and the creation leaves nothing behind.
      await _repository.deleteEmptyClassroom(classroomId: classroom.id);
      return DataFailed<ClassroomEntity>(exception);
    }
    return DataSuccess<ClassroomEntity>(classroom);
  }
}
