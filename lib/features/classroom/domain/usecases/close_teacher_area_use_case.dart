import 'package:kid_matix/core/services/teacher_area_lock.dart';
import 'package:kid_matix/core/usecases/usecase.dart';

/// Closes the teacher area.
class CloseTeacherAreaUseCase implements NoParamUseCase<void> {
  /// Creates the use case.
  const CloseTeacherAreaUseCase({required this._session});

  final TeacherAreaLock _session;

  @override
  Future<void> call() async => _session.lock();
}
