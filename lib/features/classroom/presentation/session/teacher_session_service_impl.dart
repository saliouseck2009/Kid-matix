import 'package:flutter/widgets.dart';
import 'package:kid_matix/core/services/clock.dart';
import 'package:kid_matix/core/services/profile_session_service.dart';
import 'package:kid_matix/core/services/teacher_session_service.dart';

/// [TeacherSessionService] kept in memory: every launch starts closed.
///
/// It closes on its own as soon as a player starts playing, so a pupil
/// who comes back to « Qui joue ? » never finds the area open, and when
/// the app comes back after more than [backgroundLimit] in the
/// background. A shorter pause leaves it open: the system file picker and
/// the share targets pause the app in the middle of a transfer.
final class TeacherSessionServiceImpl extends ChangeNotifier
    implements TeacherSessionService {
  /// Creates the service, which follows the player [session] and, when
  /// [followsAppLifecycle], the background of the app.
  TeacherSessionServiceImpl({
    required this._session,
    required this._clock,
    bool followsAppLifecycle = true,
  }) {
    _session.addListener(_followPlayer);
    if (followsAppLifecycle) {
      _lifecycle = AppLifecycleListener(
        onPause: notePause,
        onResume: noteResume,
      );
    }
  }

  /// Longest stay in the background that keeps the area open.
  static const Duration backgroundLimit = Duration(seconds: 60);

  final ProfileSessionService _session;
  final Clock _clock;
  AppLifecycleListener? _lifecycle;
  DateTime? _pausedAt;
  bool _isUnlocked = false;

  @override
  bool get isUnlocked => _isUnlocked;

  @override
  void unlock() => _setUnlocked(true);

  @override
  void lock() => _setUnlocked(false);

  /// The app went to the background.
  void notePause() => _pausedAt = _clock.now();

  /// The app came back: the area closes when it stayed away too long.
  void noteResume() {
    final DateTime? pausedAt = _pausedAt;
    _pausedAt = null;
    if (pausedAt == null) return;
    if (_clock.now().difference(pausedAt) > backgroundLimit) lock();
  }

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
    _lifecycle?.dispose();
    _session.removeListener(_followPlayer);
    super.dispose();
  }
}
