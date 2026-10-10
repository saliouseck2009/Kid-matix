import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_stats_entity.dart';
import 'package:kid_matix/features/profile/domain/usecases/get_profile_stats_use_case.dart';
import 'package:kid_matix/features/profile/domain/usecases/watch_progress_changes_use_case.dart';

/// Reads the progress figures of a player and reloads them after each
/// quiz; `null` while reading, and when they cannot be read.
final class ProgressCubit extends Cubit<ProfileStatsEntity?> {
  /// Creates the Cubit of the player [profileId].
  ProgressCubit({
    required this._profileId,
    required this._getStats,
    required this._watchChanges,
  }) : super(null);

  final String _profileId;
  final GetProfileStatsUseCase _getStats;
  final WatchProgressChangesUseCase _watchChanges;
  StreamSubscription<void>? _changes;

  /// Reads the figures and follows their changes.
  Future<void> load() async {
    _changes ??= _watchChanges().listen((_) => unawaited(_reload()));
    await _reload();
  }

  Future<void> _reload() async {
    final DataState<ProfileStatsEntity> read = await _getStats(
      params: _profileId,
    );
    if (isClosed) return;
    if (read case DataSuccess<ProfileStatsEntity>(:final data)) emit(data);
  }

  @override
  Future<void> close() async {
    await _changes?.cancel();
    return super.close();
  }
}
