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
/// included; the end of the lockout survives a restart), and with a
/// `NotFoundException` when no code was chosen.
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
    final DataState<DateTime?> lockedUntil = await _codes.readLockedUntil();
    switch (lockedUntil) {
      case DataFailed<DateTime?>(:final exception):
        return DataFailed<void>(exception);
      case DataSuccess<DateTime?>(:final DateTime data) when now.isBefore(data):
        return _lockedOut();
      case DataSuccess<DateTime?>():
        break;
    }
    return switch (await _codes.readCode()) {
      DataFailed<String?>(:final exception) => DataFailed<void>(exception),
      DataSuccess<String?>(data: null) => const DataFailed<void>(
        NotFoundException(message: 'No teacher code yet.'),
      ),
      DataSuccess<String?>(:final String data) when data == params =>
        await _open(),
      DataSuccess<String?>() => await _refuse(now),
    };
  }

  Future<DataState<void>> _open() async {
    _attempts.clear();
    await _codes.saveLockedUntil(until: null);
    _lock.unlock();
    return const DataSuccess<void>(null);
  }

  Future<DataState<void>> _refuse(DateTime now) async {
    if (!_attempts.recordWrongCode()) {
      return const DataFailed<void>(
        ValidationException(message: 'Wrong teacher code.'),
      );
    }
    await _codes.saveLockedUntil(until: now.add(TeacherCodeAttempts.lockout));
    return _lockedOut();
  }

  static DataState<void> _lockedOut() {
    return const DataFailed<void>(
      LimitReachedException(message: 'Too many wrong teacher codes.'),
    );
  }
}
