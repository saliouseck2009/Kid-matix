import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/services/clock.dart';
import 'package:kid_matix/core/usecases/usecase.dart';
import 'package:kid_matix/features/classroom/domain/entities/classroom_entity.dart';
import 'package:kid_matix/features/classroom/domain/repositories/classroom_repository.dart';

/// Sets the goal of right answers of the class challenge of a class.
///
/// Takes the class and its new goal; fails with a `ValidationException`
/// when the goal is not positive.
class SetWeeklyGoalUseCase
    implements UseCase<DataState<void>, ({String classroomId, int goal})> {
  /// Creates the use case.
  const SetWeeklyGoalUseCase({
    required this._repository,
    required this._clock,
  });

  final ClassroomRepository _repository;
  final Clock _clock;

  @override
  Future<DataState<void>> call({
    required ({String classroomId, int goal}) params,
  }) async {
    if (params.goal <= 0) {
      return const DataFailed<void>(
        ValidationException(message: 'A goal is positive.'),
      );
    }
    final DataState<ClassroomEntity> read = await _repository.getClassroom(
      classroomId: params.classroomId,
    );
    return switch (read) {
      DataFailed<ClassroomEntity>(:final exception) => DataFailed<void>(
        exception,
      ),
      DataSuccess<ClassroomEntity>(:final data) => _repository.updateClassroom(
        classroom: data.copyWith(
          weeklyGoal: params.goal,
          updatedAt: _clock.now(),
        ),
      ),
    };
  }
}
