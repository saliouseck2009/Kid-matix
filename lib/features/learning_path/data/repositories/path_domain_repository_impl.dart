import 'dart:async';
import 'dart:developer';

import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/learning_path/data/datasources/path_domain_local_data_source.dart';
import 'package:kid_matix/features/learning_path/domain/repositories/path_domain_repository.dart';

/// [PathDomainRepository] over the device preferences; it tells the map
/// and the Profile when a player chooses another domain on either.
final class PathDomainRepositoryImpl implements PathDomainRepository {
  /// Creates the repository.
  PathDomainRepositoryImpl({required this._domains});

  static const String _logName = 'learning_path';

  final PathDomainLocalDataSource _domains;
  final StreamController<String> _changes =
      StreamController<String>.broadcast();

  @override
  Future<DataState<String?>> getDomain({required String profileId}) async {
    try {
      return DataSuccess<String?>(
        await _domains.readDomain(profileId: profileId),
      );
    } on Exception catch (error, stackTrace) {
      return _fail('Domain choice not read', error, stackTrace);
    }
  }

  @override
  Future<DataState<void>> saveDomain({
    required String profileId,
    required String domainId,
  }) async {
    try {
      await _domains.writeDomain(profileId: profileId, domainId: domainId);
      _changes.add(profileId);
      return const DataSuccess<void>(null);
    } on Exception catch (error, stackTrace) {
      return _fail('Domain choice not saved', error, stackTrace);
    }
  }

  @override
  Stream<String> watchChanges() => _changes.stream;

  DataFailed<T> _fail<T>(
    String message,
    Exception error,
    StackTrace stackTrace,
  ) {
    log(message, name: _logName, error: error, stackTrace: stackTrace);
    return DataFailed<T>(CacheException(message: error.toString()));
  }
}
