import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/usecases/usecase.dart';
import 'package:kid_matix/features/classroom/domain/repositories/teacher_code_repository.dart';
import 'package:kid_matix/features/classroom/domain/services/teacher_code_attempts.dart';

/// « Code oublié ? »: forgets the code, once an adult answered the gate,
/// so the teacher chooses a new one; classes and results stay.
class ForgetTeacherCodeUseCase implements NoParamUseCase<DataState<void>> {
  /// Creates the use case.
  const ForgetTeacherCodeUseCase({
    required this._codes,
    required this._attempts,
  });

  final TeacherCodeRepository _codes;
  final TeacherCodeAttempts _attempts;

  @override
  Future<DataState<void>> call() async {
    final DataState<void> cleared = await _codes.clearCode();
    if (cleared is DataFailed<void>) return cleared;
    _attempts.clear();
    return _codes.saveLockedUntil(until: null);
  }
}
