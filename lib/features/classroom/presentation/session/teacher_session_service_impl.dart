import 'package:flutter/foundation.dart';
import 'package:kid_matix/core/services/profile_session_service.dart';
import 'package:kid_matix/core/services/teacher_session_service.dart';

/// [TeacherSessionService] kept in memory: every launch starts closed.
///
/// It closes on its own as soon as a player starts playing, so a pupil
/// who comes back to « Qui joue ? » never finds the area open.
final class TeacherSessionServiceImpl extends ChangeNotifier
    implements TeacherSessionService {
  /// Creates the service, which follows the player [session].
  TeacherSessionServiceImpl({required this._session}) {
    _session.addListener(_followPlayer);
  }

  final ProfileSessionService _session;
  bool _isUnlocked = false;

  @override
  bool get isUnlocked => _isUnlocked;

  @override
  void unlock() => _setUnlocked(true);

  @override
  void lock() => _setUnlocked(false);

  void _followPlayer() {
    if (_session.activeProfileId != null) lock();
  }

  void _setUnlocked(bool isUnlocked) {
    if (_isUnlocked == isUnlocked) return;
    _isUnlocked = isUnlocked;
    notifyListeners();
  }

  @override
  void dispose() {
    _session.removeListener(_followPlayer);
    super.dispose();
  }
}
