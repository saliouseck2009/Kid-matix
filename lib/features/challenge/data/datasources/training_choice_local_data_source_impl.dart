import 'package:kid_matix/core/storage/local_storage.dart';
import 'package:kid_matix/features/challenge/data/datasources/training_choice_local_data_source.dart';

/// [TrainingChoiceLocalDataSource] stored in the device preferences.
final class TrainingChoiceLocalDataSourceImpl
    implements TrainingChoiceLocalDataSource {
  /// Creates the data source over [storage].
  const TrainingChoiceLocalDataSourceImpl({required this._storage});

  /// Preference key of the last training of a player, followed by the
  /// player's identifier.
  static const String keyPrefix = 'training_choice.';

  final LocalStorage _storage;

  @override
  Future<String?> readChoice({required String profileId}) {
    return _storage.readString(key: '$keyPrefix$profileId');
  }

  @override
  Future<void> writeChoice({
    required String profileId,
    required String sourceKey,
  }) {
    return _storage.writeString(key: '$keyPrefix$profileId', value: sourceKey);
  }
}
