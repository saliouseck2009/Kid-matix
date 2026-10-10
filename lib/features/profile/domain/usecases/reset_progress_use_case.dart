import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/services/progress_reset_service.dart';
import 'package:kid_matix/core/usecases/usecase.dart';

/// Starts a player over: their progress in every feature is erased, their
/// nickname, avatar, settings and mascot name stay; takes the profile id.
class ResetProgressUseCase implements UseCase<DataState<void>, String> {
  /// Creates the use case.
  const ResetProgressUseCase({required this._resetter});

  final ProgressResetService _resetter;

  @override
  Future<DataState<void>> call({required String params}) {
    return _resetter.resetProgress(profileId: params);
  }
}
