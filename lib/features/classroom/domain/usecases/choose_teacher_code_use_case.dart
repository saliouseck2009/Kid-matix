import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/services/teacher_area_lock.dart';
import 'package:kid_matix/core/usecases/usecase.dart';
import 'package:kid_matix/features/classroom/domain/entities/classroom_rules.dart';
import 'package:kid_matix/features/classroom/domain/repositories/teacher_code_repository.dart';

/// Stores the code the teacher chose at the first visit, then opens the
/// area.
///
/// Fails with a `ValidationException` when the code is not 4 digits, and
/// with a `ConflictException` when a code already exists: it is chosen
/// once.
class ChooseTeacherCodeUseCase implements UseCase<DataState<void>, String> {
  /// Creates the use case.
  const ChooseTeacherCodeUseCase({
    required this._codes,
    required this._session,
  });

  final TeacherCodeRepository _codes;
  final TeacherAreaLock _session;

  @override
  Future<DataState<void>> call({required String params}) async {
    if (!ClassroomRules.isTeacherCode(params)) {
      return const DataFailed<void>(
        ValidationException(message: 'A teacher code is 4 digits.'),
      );
    }
    final DataState<String?> existing = await _codes.readCode();
    switch (existing) {
      case DataFailed<String?>(:final exception):
        return DataFailed<void>(exception);
      case DataSuccess<String?>(data: String()):
        return const DataFailed<void>(
          ConflictException(message: 'A teacher code exists.'),
        );
      case DataSuccess<String?>():
        break;
    }
    final DataState<void> saved = await _codes.saveCode(code: params);
    if (saved is DataSuccess<void>) _session.unlock();
    return saved;
  }
}
