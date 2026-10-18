import 'package:kid_matix/core/storage/local_storage.dart';
import 'package:kid_matix/features/learning_path/data/datasources/path_domain_local_data_source.dart';

/// [PathDomainLocalDataSource] stored in the device preferences, one key
/// per player: a convenience, not progress, so no database row.
final class PathDomainLocalDataSourceImpl implements PathDomainLocalDataSource {
  /// Creates the data source over [storage].
  const PathDomainLocalDataSourceImpl({required this._storage});

  /// Preference key of the domain of a player, followed by the player's
  /// identifier.
  static const String keyPrefix = 'path_domain.';

  final LocalStorage _storage;

  @override
  Future<String?> readDomain({required String profileId}) {
    return _storage.readString(key: '$keyPrefix$profileId');
  }

  @override
  Future<void> writeDomain({
    required String profileId,
    required String domainId,
  }) {
    return _storage.writeString(key: '$keyPrefix$profileId', value: domainId);
  }
}
