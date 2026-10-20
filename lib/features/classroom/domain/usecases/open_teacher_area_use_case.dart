import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/services/teacher_session_service.dart';
import 'package:kid_matix/core/usecases/usecase.dart';
import 'package:kid_matix/features/classroom/domain/repositories/teacher_code_repository.dart';

/// Opens the teacher area when it gets the right code.
///
/// Fails with a `ValidationException` on a wrong code, and with a
/// `NotFoundException` when no code was chosen yet.
class OpenTeacherAreaUseCase implements UseCase<DataState<void>, String> {
  /// Creates the use case.
  const OpenTeacherAreaUseCase({
    required this._codes,
    required this._session,
  });

  final TeacherCodeRepository _codes;
  final TeacherSessionService _session;

  @override
  Future<DataState<void>> call({required String params}) async {
    return switch (await _codes.readCode()) {
      DataFailed<String?>(:final exception) => DataFailed<void>(exception),
      DataSuccess<String?>(data: null) => const DataFailed<void>(
        NotFoundException(message: 'No teacher code yet.'),
      ),
      DataSuccess<String?>(:final String data) when data == params => _open(),
      DataSuccess<String?>() => const DataFailed<void>(
        ValidationException(message: 'Wrong teacher code.'),
      ),
    };
  }

  DataState<void> _open() {
    _session.unlock();
    return const DataSuccess<void>(null);
  }
}
