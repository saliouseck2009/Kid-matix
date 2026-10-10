import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/challenge/domain/entities/challenge_source.dart';

/// The last free training each player chose, offered again next time.
abstract interface class TrainingChoiceRepository {
  /// Returns the last choice of [profileId], or `null` when there is none.
  Future<DataState<TrainingSource?>> getChoice({required String profileId});

  /// Keeps [choice] as the last choice of [profileId].
  Future<DataState<void>> saveChoice({
    required String profileId,
    required TrainingSource choice,
  });
}
