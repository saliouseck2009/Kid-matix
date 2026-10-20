import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/usecases/usecase.dart';
import 'package:kid_matix/features/classroom/domain/repositories/teacher_code_repository.dart';

/// Tells when the teacher code was last replaced after « Code oublié ? »,
/// so « Mes classes » can say it; `null` when it never was.
class GetTeacherCodeChangeUseCase
    implements NoParamUseCase<DataState<DateTime?>> {
  /// Creates the use case.
  const GetTeacherCodeChangeUseCase({required this._codes});

  final TeacherCodeRepository _codes;

  @override
  Future<DataState<DateTime?>> call() => _codes.readCodeChangedAt();
}
