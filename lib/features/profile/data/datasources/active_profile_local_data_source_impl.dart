import 'package:kid_matix/core/storage/local_storage.dart';
import 'package:kid_matix/features/profile/data/datasources/active_profile_local_data_source.dart';

/// [ActiveProfileLocalDataSource] stored in the device preferences.
final class ActiveProfileLocalDataSourceImpl
    implements ActiveProfileLocalDataSource {
  /// Creates the data source over [storage].
  const ActiveProfileLocalDataSourceImpl({required this._storage});

  /// Preference key of the active player's identifier.
  static const String activeProfileIdKey = 'active_profile_id';

  final LocalStorage _storage;

  @override
  Future<String?> readActiveProfileId() {
    return _storage.readString(key: activeProfileIdKey);
  }

  @override
  Future<void> writeActiveProfileId({required String profileId}) {
    return _storage.writeString(key: activeProfileIdKey, value: profileId);
  }

  @override
  Future<void> clearActiveProfileId() {
    return _storage.remove(key: activeProfileIdKey);
  }
}
