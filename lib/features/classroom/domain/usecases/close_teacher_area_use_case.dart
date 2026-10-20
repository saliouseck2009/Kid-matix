import 'package:kid_matix/core/services/teacher_session_service.dart';
import 'package:kid_matix/core/usecases/usecase.dart';

/// Closes the teacher area.
class CloseTeacherAreaUseCase implements NoParamUseCase<void> {
  /// Creates the use case.
  const CloseTeacherAreaUseCase({required this._session});

  final TeacherSessionService _session;

  @override
  Future<void> call() async => _session.lock();
}
