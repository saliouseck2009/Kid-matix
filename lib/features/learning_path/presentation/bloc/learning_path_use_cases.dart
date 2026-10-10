import 'package:kid_matix/features/learning_path/domain/usecases/get_learning_path_use_case.dart';
import 'package:kid_matix/features/learning_path/domain/usecases/watch_learning_path_changes_use_case.dart';

/// Use cases of the learning path screens, grouped so the Bloc takes one
/// argument.
final class LearningPathUseCases {
  /// Groups the use cases.
  const LearningPathUseCases({
    required this.getLearningPath,
    required this.watchChanges,
  });

  /// Reads the path of a player.
  final GetLearningPathUseCase getLearningPath;

  /// Tells when the path may have changed.
  final WatchLearningPathChangesUseCase watchChanges;
}
