import 'package:kid_matix/features/learning_path/domain/usecases/get_placement_history_use_case.dart';
import 'package:kid_matix/features/learning_path/domain/usecases/watch_placement_results_use_case.dart';

/// Use cases of the placement card of the Profile, grouped so the Cubit
/// takes one argument.
final class PlacementHistoryUseCases {
  /// Groups the use cases.
  const PlacementHistoryUseCases({
    required this.getHistory,
    required this.watchResults,
  });

  /// Reads the tests of a player.
  final GetPlacementHistoryUseCase getHistory;

  /// Tells when a test was finished.
  final WatchPlacementResultsUseCase watchResults;
}
