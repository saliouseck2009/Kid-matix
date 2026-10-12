import 'package:kid_matix/core/storage/local_storage.dart';
import 'package:kid_matix/features/reward/data/datasources/leaderboard_visibility_local_data_source.dart';

/// [LeaderboardVisibilityLocalDataSource] stored in the device
/// preferences, shared by every player of the phone.
final class LeaderboardVisibilityLocalDataSourceImpl
    implements LeaderboardVisibilityLocalDataSource {
  /// Creates the data source over [storage].
  const LeaderboardVisibilityLocalDataSourceImpl({required this._storage});

  /// Preference key of the setting (`classementActif` in the
  /// specifications).
  static const String leaderboardShownKey = 'leaderboard_shown';

  static const String _shown = 'true';
  static const String _hidden = 'false';

  final LocalStorage _storage;

  @override
  Future<bool?> readShown() async {
    return switch (await _storage.readString(key: leaderboardShownKey)) {
      _shown => true,
      _hidden => false,
      _ => null,
    };
  }

  @override
  Future<void> writeShown({required bool isShown}) {
    return _storage.writeString(
      key: leaderboardShownKey,
      value: isShown ? _shown : _hidden,
    );
  }
}
