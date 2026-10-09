import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/services/profile_session_service.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_session_entity.dart';
import 'package:kid_matix/features/profile/domain/usecases/get_profile_session_use_case.dart';
import 'package:kid_matix/features/profile/domain/usecases/watch_profile_changes_use_case.dart';

/// [ProfileSessionService] kept up to date with the stored profiles.
///
/// It reloads the session after every profile change and notifies its
/// listeners, the router first, when the active player or the presence of
/// profiles changes.
final class ProfileSessionServiceImpl extends ChangeNotifier
    implements ProfileSessionService {
  /// Creates the service.
  ProfileSessionServiceImpl({
    required this._getSession,
    required this._watchChanges,
  });

  static const String _logName = 'profile';
  static const ProfileSessionEntity _emptySession = ProfileSessionEntity(
    profileCount: 0,
  );

  final GetProfileSessionUseCase _getSession;
  final WatchProfileChangesUseCase _watchChanges;
  StreamSubscription<void>? _changes;
  ProfileSessionEntity? _session;

  @override
  bool get isRestored => _session != null;

  @override
  bool get hasProfiles => (_session?.profileCount ?? 0) > 0;

  @override
  String? get activeProfileId => _session?.activeProfileId;

  @override
  Future<void> restore() async {
    _changes ??= _watchChanges().listen((_) => unawaited(_reload()));
    await _reload();
  }

  @override
  void dispose() {
    unawaited(_changes?.cancel());
    super.dispose();
  }

  Future<void> _reload() async {
    final DataState<ProfileSessionEntity> state = await _getSession();
    final ProfileSessionEntity session = switch (state) {
      DataSuccess<ProfileSessionEntity>(:final data) => data,
      DataFailed<ProfileSessionEntity>(:final exception) => _keepSession(
        exception,
      ),
    };
    if (session == _session) return;
    _session = session;
    notifyListeners();
  }

  ProfileSessionEntity _keepSession(Object exception) {
    log('Session not reloaded', name: _logName, error: exception);
    return _session ?? _emptySession;
  }
}
