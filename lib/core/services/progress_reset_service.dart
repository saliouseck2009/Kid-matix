import 'package:kid_matix/core/error/data_state.dart';

/// Erases the progress of a player in every feature at once.
abstract interface class ProgressResetService {
  /// Erases the progress of [profileId]: mastery, stages, rewards,
  /// records, the accessories worn and the quiz journal. The nickname,
  /// avatar, settings and mascot name stay.
  Future<DataState<void>> resetProgress({required String profileId});
}
