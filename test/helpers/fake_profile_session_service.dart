import 'package:flutter/foundation.dart';
import 'package:kid_matix/core/services/profile_session_service.dart';

/// [ProfileSessionService] whose session the test sets by hand.
final class FakeProfileSessionService extends ChangeNotifier
    implements ProfileSessionService {
  /// Creates a restored session.
  FakeProfileSessionService({this.hasProfiles = true, this.activeProfileId});

  @override
  bool hasProfiles;

  @override
  String? activeProfileId;

  @override
  bool get isRestored => true;

  @override
  Future<void> restore() async {}

  /// Changes the session and notifies the router.
  void update({required bool hasProfiles, String? activeProfileId}) {
    this.hasProfiles = hasProfiles;
    this.activeProfileId = activeProfileId;
    notifyListeners();
  }
}
