import 'package:kid_matix/core/error/data_state.dart';

/// The learning domain each player last chose, shown again on the map and
/// in the Profile.
abstract interface class PathDomainRepository {
  /// Returns the domain [profileId] last chose, or `null` when none.
  Future<DataState<String?>> getDomain({required String profileId});

  /// Keeps [domainId] as the domain [profileId] chose, and tells the
  /// screens that follow it.
  Future<DataState<void>> saveDomain({
    required String profileId,
    required String domainId,
  });

  /// Emits the player each time their chosen domain changes.
  Stream<String> watchChanges();
}
