import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/services/clock.dart';
import 'package:kid_matix/core/services/teacher_area_lock.dart';
import 'package:kid_matix/core/usecases/usecase.dart';
import 'package:kid_matix/features/classroom/domain/repositories/teacher_code_repository.dart';
import 'package:kid_matix/features/classroom/domain/services/teacher_code_attempts.dart';

/// Opens the teacher area when it gets the right code.
///
/// Fails with a `ValidationException` on a wrong code, with a
/// `LimitReachedException` while the door is closed after
/// [TeacherCodeAttempts.maxWrongCodes] wrong codes (the fifth one
/// included), and with a `NotFoundException` when no code was chosen.
class OpenTeacherAreaUseCase implements UseCase<DataState<void>, String> {
  /// Creates the use case.
  const OpenTeacherAreaUseCase({
    required this._codes,
    required this._lock,
    required this._attempts,
    required this._clock,
  });

  final TeacherCodeRepository _codes;
  final TeacherAreaLock _lock;
  final TeacherCodeAttempts _attempts;
  final Clock _clock;

  @override
  Future<DataState<void>> call({required String params}) async {
    final DateTime now = _clock.now();
    if (_attempts.isLockedAt(now)) return _lockedOut();
    return switch (await _codes.readCode()) {
      DataFailed<String?>(:final exception) => DataFailed<void>(exception),
      DataSuccess<String?>(data: null) => const DataFailed<void>(
        NotFoundException(message: 'No teacher code yet.'),
      ),
      DataSuccess<String?>(:final String data) when data == params => _open(),
      DataSuccess<String?>() =>
        _attempts.recordWrongCode(now)
            ? _lockedOut()
            : const DataFailed<void>(
                ValidationException(message: 'Wrong teacher code.'),
              ),
    };
  }

  DataState<void> _open() {
    _attempts.clear();
    _lock.unlock();
    return const DataSuccess<void>(null);
  }

  static DataState<void> _lockedOut() {
    return const DataFailed<void>(
      LimitReachedException(message: 'Too many wrong teacher codes.'),
    );
  }
}
