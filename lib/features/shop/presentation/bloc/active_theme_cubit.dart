import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/entities/app_color_theme.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/shop/domain/usecases/get_active_theme_use_case.dart';
import 'package:kid_matix/features/shop/domain/usecases/watch_theme_changes_use_case.dart';

/// The color theme a player applied, followed as it changes; lavender
/// until it is read, and when it cannot be.
final class ActiveThemeCubit extends Cubit<AppColorTheme> {
  /// Creates the Cubit of the theme of [profileId].
  ActiveThemeCubit({
    required this._profileId,
    required this._getActiveTheme,
    required this._watchChanges,
  }) : super(AppColorTheme.lavender);

  final String _profileId;
  final GetActiveThemeUseCase _getActiveTheme;
  final WatchThemeChangesUseCase _watchChanges;
  StreamSubscription<void>? _changes;

  /// Reads the theme and follows its changes.
  Future<void> load() async {
    _changes ??= _watchChanges().listen((_) => unawaited(_reload()));
    await _reload();
  }

  Future<void> _reload() async {
    final DataState<AppColorTheme> read = await _getActiveTheme(
      params: _profileId,
    );
    if (isClosed) return;
    if (read case DataSuccess<AppColorTheme>(:final data)) emit(data);
  }

  @override
  Future<void> close() async {
    await _changes?.cancel();
    return super.close();
  }
}
