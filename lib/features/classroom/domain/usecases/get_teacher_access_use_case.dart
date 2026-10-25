import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/services/teacher_area_lock.dart';
import 'package:kid_matix/core/usecases/usecase.dart';
import 'package:kid_matix/features/classroom/domain/entities/teacher_access.dart';
import 'package:kid_matix/features/classroom/domain/repositories/teacher_code_repository.dart';

/// Tells whether the teacher area has a code yet and whether it is open.
class GetTeacherAccessUseCase
    implements NoParamUseCase<DataState<TeacherAccess>> {
  /// Creates the use case.
  const GetTeacherAccessUseCase({
    required this._codes,
    required this._session,
  });

  final TeacherCodeRepository _codes;
  final TeacherAreaLock _session;

  @override
  Future<DataState<TeacherAccess>> call() async {
    if (_session.isUnlocked) {
      return const DataSuccess<TeacherAccess>(TeacherAccess.unlocked);
    }
    return switch (await _codes.readCode()) {
      DataSuccess<String?>(data: null) => const DataSuccess<TeacherAccess>(
        TeacherAccess.noCode,
      ),
      DataSuccess<String?>() => const DataSuccess<TeacherAccess>(
        TeacherAccess.locked,
      ),
      DataFailed<String?>(:final exception) => DataFailed<TeacherAccess>(
        exception,
      ),
    };
  }
}
