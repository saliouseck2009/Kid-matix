import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_settings_entity.dart';
import 'package:kid_matix/features/profile/domain/usecases/get_settings_use_case.dart';
import 'package:kid_matix/features/profile/domain/usecases/watch_profile_changes_use_case.dart';

/// Follows the settings of the active player for the whole app; `null`
/// until they are read.
final class PlayerSettingsCubit extends Cubit<ProfileSettingsEntity?> {
  /// Creates the Cubit of the player [profileId].
  PlayerSettingsCubit({
    required this._profileId,
    required this._getSettings,
    required this._watchChanges,
  }) : super(null);

  final String _profileId;
  final GetSettingsUseCase _getSettings;
  final WatchProfileChangesUseCase _watchChanges;
  StreamSubscription<void>? _changes;

  /// Reads the settings and follows their changes.
  Future<void> load() async {
    _changes ??= _watchChanges().listen((_) => unawaited(_reload()));
    await _reload();
  }

  Future<void> _reload() async {
    final DataState<ProfileSettingsEntity> read = await _getSettings(
      params: _profileId,
    );
    if (isClosed) return;
    if (read case DataSuccess<ProfileSettingsEntity>(:final data)) emit(data);
  }

  @override
  Future<void> close() async {
    await _changes?.cancel();
    return super.close();
  }
}
