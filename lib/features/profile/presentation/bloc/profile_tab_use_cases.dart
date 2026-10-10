import 'package:kid_matix/features/profile/domain/usecases/clear_active_profile_use_case.dart';
import 'package:kid_matix/features/profile/domain/usecases/get_profile_stats_use_case.dart';
import 'package:kid_matix/features/profile/domain/usecases/get_profile_use_case.dart';
import 'package:kid_matix/features/profile/domain/usecases/watch_profile_changes_use_case.dart';
import 'package:kid_matix/features/profile/domain/usecases/watch_progress_changes_use_case.dart';

/// Use cases of the Profile tab, grouped so `ProfileTabCubit` takes one
/// argument.
final class ProfileTabUseCases {
  /// Groups the use cases.
  const ProfileTabUseCases({
    required this.getProfile,
    required this.watchChanges,
    required this.clearActiveProfile,
    required this.getStats,
    required this.watchProgress,
  });

  /// Reads the active player.
  final GetProfileUseCase getProfile;

  /// Signals a renamed or changed player.
  final WatchProfileChangesUseCase watchChanges;

  /// Lets another child play.
  final ClearActiveProfileUseCase clearActiveProfile;

  /// Reads the streak, crowns and badges.
  final GetProfileStatsUseCase getStats;

  /// Signals new progress figures.
  final WatchProgressChangesUseCase watchProgress;
}
