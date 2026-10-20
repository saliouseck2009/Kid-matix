import 'package:kid_matix/core/usecases/usecase.dart';
import 'package:kid_matix/features/classroom/domain/services/pupil_enrollment.dart';

/// Returns the nicknames of a list that cannot be used, so the form shows
/// them before anything is written.
class FindUnusableNicknamesUseCase
    implements UseCase<List<String>, List<String>> {
  /// Creates the use case.
  const FindUnusableNicknamesUseCase({required this._enrollment});

  final PupilEnrollment _enrollment;

  @override
  Future<List<String>> call({required List<String> params}) async {
    return _enrollment.findUnusableNicknames(params);
  }
}
